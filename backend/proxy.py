from flask import Flask, jsonify, request
from flask_cors import CORS
import requests
import re
import copy

import hashlib

import threading
import time

import shelly_util
import scraper
import influxdb

import paramiko
from paramiko.client import SSHClient

from influxdb_client import InfluxDBClient
from influxdb_client.client.write_api import SYNCHRONOUS

app = Flask(__name__)
CORS(app)


def run_task(hostname, username, password, task):
    client = SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        client.connect(hostname, username=username, password=password)

        _, stdout, _ = client.exec_command(task, get_pty=True)

        while not stdout.channel.exit_status_ready():
            time.sleep(0.5)

    finally:
        client.close()


@app.route('/power_stats', methods=['GET'])
def power_stats():
    hids = request.args.get('hids', '')
    numDatapoints = int(request.args.get('numDatapoints'))
    datapointIntervalInSeconds = int(request.args.get('intervalSeconds'))

    client = InfluxDBClient(url=influxdb.influxdb_url, token=influxdb.influxdb_token, org=influxdb.influxdb_org)
    query_api = client.query_api()

    datapoints = {}

    for hid in hids.split(","):
        fluxQuery = f'''
        from(bucket: "{influxdb.influxdb_bucket}")
            |> range(start: -{(numDatapoints + 3) * datapointIntervalInSeconds}s)
            |> filter(fn: (r) => r["mac"] == "{hid}")
            |> filter(fn: (r) => r["_field"] == "value")
            |> filter(fn: (r) => r["_measurement"] == "shelly_switch_power_watts")
            |> aggregateWindow(every: {datapointIntervalInSeconds}s, fn: mean, createEmpty: false)
            |> yield(name: "mean")
        '''

        result = query_api.query(fluxQuery)

        records = []
        for table in result:
            for record in table.records:
                timestamp_unix = record.get_time().timestamp()
                records.append({
                    "time": timestamp_unix,
                    "value": record.get_value()
                })

        datapoints[hid] = records

    return jsonify(datapoints)


@app.route('/temperature_stats', methods=['GET'])
def temperature_stats():
    hids = request.args.get('hids', '')
    numDatapoints = int(request.args.get('numDatapoints'))
    datapointIntervalInSeconds = int(request.args.get('intervalSeconds'))

    client = InfluxDBClient(url=influxdb.influxdb_url, token=influxdb.influxdb_token, org=influxdb.influxdb_org)
    query_api = client.query_api()

    datapoints = {}

    for hid in hids.split(","):
        fluxQuery = f'''
        from(bucket: "{influxdb.influxdb_bucket}")
            |> range(start: -{(numDatapoints + 3) * datapointIntervalInSeconds}s)
            |> filter(fn: (r) => r["mac"] == "{hid}")
            |> filter(fn: (r) => r["_field"] == "value")
            |> filter(fn: (r) => r["_measurement"] == "shelly_temperature_celsius")
            |> aggregateWindow(every: {datapointIntervalInSeconds}s, fn: mean, createEmpty: false)
            |> yield(name: "mean")
        '''

        result = query_api.query(fluxQuery)

        records = []
        for table in result:
            for record in table.records:
                timestamp_unix = record.get_time().timestamp()
                records.append({
                    "time": timestamp_unix,
                    "value": record.get_value()
                })

        datapoints[hid] = records

    return jsonify(datapoints)


@app.route('/average_power', methods=['GET'])
def average_power():
    client = InfluxDBClient(url=influxdb.influxdb_url, token=influxdb.influxdb_token, org=influxdb.influxdb_org)
    query_api = client.query_api()

    fluxQuery = f'''
    from(bucket: "{influxdb.influxdb_bucket}")
    |> range(start: -5m)
    |> filter(fn: (r) => r["_field"] == "value")
    |> filter(fn: (r) => r["_measurement"] == "shelly_switch_power_watts")
    |> timedMovingAverage(every: 10s, period: 5m)
    |> truncateTimeColumn(unit: 10s)
    |> group(columns: ["_time", "_field"])
    |> sum()
    |> range(start: -3m, stop: -30s)
    |> yield(name: "total")'''

    result = query_api.query(fluxQuery)

    sum = 0

    for table in result:
        for record in table.records:
            sum += record.get_value()

    average = sum
    if len(result) > 0:
        average = average / len(result)

    return jsonify({ "average": average})


@app.route('/hosts', methods=['GET'])
def hosts():
    # Create a copy of hosts_data without the password field
    config_data_copy = copy.deepcopy(shelly_util.config_data)
    for host_entry in config_data_copy.get("hosts", []):
        host_entry.pop("password", None)  # Remove the password field if present

    return jsonify({"hosts": config_data_copy["hosts"]}), 200


@app.route('/settings', methods=['GET'])
def settings():
    config_data = copy.deepcopy(shelly_util.config_data)
    return jsonify(config_data.get("settings", {})), 200



@app.route('/host', methods=['GET'])
def host():
    host_id = request.args.get('hid')
    if not host_id:
        return jsonify({'error': 'Host ID not provided'}), 400

    config_data_copy = copy.deepcopy(shelly_util.config_data)
    for host_entry in config_data_copy.get("hosts", []):
        host_entry.pop("password", None)  # Remove the password field if present

    # Search for the host with the matching ID
    for host_entry in config_data_copy["hosts"]:
        if host_entry.get('id') == host_id:
            return jsonify(host_entry), 200

    return jsonify({'error': 'Host not found'}), 404


@app.route('/actions', methods=['GET'])
def actions():
    device_id = request.args.get('did')
    
    device = shelly_util.get_device(device_id)
     
    allowed_actions = device.get("actions", [])

    action_infos = []

    for action in allowed_actions:
        action_infos.append(shelly_util.get_action(action))

    return jsonify({'actions': action_infos}), 200

@app.route('/action', methods=['POST'])
def action():
    device_id = request.args.get('did')
    action = request.args.get('action')
    authentication = request.args.get('auth')
    
    device = shelly_util.get_device(device_id)
        
    to_hash = device_id + "-" + action + "-" + device["ssh_pass"]
    result = hashlib.md5(to_hash.encode())

    if result.hexdigest() == authentication:
        # Lookup device information
        allowed_actions = device.get("actions", [])

        for a_action in allowed_actions:
            if a_action == action:
                action_info = shelly_util.get_action(action)

                # Perform action
                if action_info["type"] == "ssh":
                    run_task(device["ssh_host"], device["ssh_user"], device["ssh_pass"], action_info["command"])
                else:
                    print("Unknown action type")
                    return jsonify({'error': 'Unknown action type'}), 400

                return jsonify({'status': 'ok'}), 200
            
        return jsonify({'error': 'Action not allowed'}), 401
    else:
        return jsonify({'error': 'Invalid password'}), 401


@app.route('/devices', methods=['GET'])
def devices():
    # Create a copy of hosts_data without the password field
    config_data_copy = copy.deepcopy(shelly_util.config_data)
    for host_entry in config_data_copy.get("devices", []):
        host_entry.pop("password", None)  # Remove the password field if present

    return jsonify({"devices": config_data_copy["devices"]}), 200


@app.route('/device', methods=['GET'])
def device():
    host_id = request.args.get('hid')
    if not host_id:
        return jsonify({'error': 'Device ID not provided'}), 400

    config_data_copy = copy.deepcopy(shelly_util.config_data)
    for host_entry in config_data_copy.get("devices", []):
        host_entry.pop("password", None)  # Remove the password field if present

    # Search for the host with the matching ID
    for host_entry in config_data_copy["devices"]:
        if host_entry.get('id') == host_id:
            return jsonify(host_entry), 200

    return jsonify({'error': 'Device not found'}), 404


@app.route('/proxy', methods=['GET'])
def proxy():
    # URL of the target server
    target_url = request.args.get('url')

    try:
        response = requests.get(target_url)

        if response.status_code == 401:        
            # Endpoint requires authentication
        
            # Extract realm and nonce from the 'WWW-Authenticate' header
            auth_header = response.headers.get('WWW-Authenticate')
            realm = re.search('realm="([^"]+)"', auth_header).group(1)
            nonce = re.search('nonce="([^"]+)"', auth_header).group(1)

            # Compute the auth token
            auth_token = shelly_util.compute_auth_token(realm, nonce)

            base_url, params = shelly_util.parse_url_and_params(target_url)

            request_data = {
                "id": 1,
                "method": base_url.split('/')[-1],
                "auth": auth_token
            }

            # Attach parameters if there were any present in the request url
            if params: request_data["params"] = params

            # Make the authenticated request
            authenticated_response = requests.post(target_url.split('/rpc/', 1)[0] + "/rpc", json=request_data)

            if "result" in authenticated_response.json():
                return jsonify(authenticated_response.json()["result"])
            else:
                return jsonify(authenticated_response.json())
            
        return jsonify(response.json())
    except requests.RequestException as e:
        # Handle any errors that occur during the request
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    thread = threading.Thread(target=scraper.scrape_and_write)
    thread.start()

    app.run(debug=True, host="0.0.0.0", port=5000)