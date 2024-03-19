import requests
import re

import time
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS

import shelly_util
import influxdb


# Initialize InfluxDB Client
client = InfluxDBClient(url=influxdb.influxdb_url, token=influxdb.influxdb_token, org=influxdb.influxdb_org)
write_api = client.write_api(write_options=SYNCHRONOUS)


def parse_prometheus_text(text):
    """
    Parse Prometheus text format to extract metric information.
    """
    metrics = []
    for line in text.splitlines():
        if line.strip():
            metric_name, value = line.split(' ')[0], line.split(' ')[1]
            labels = metric_name[metric_name.find("{")+1:metric_name.find("}")]
            labels_dict = {kv.split("=")[0]: kv.split("=")[1].strip('"') for kv in labels.split(",")}
            metric_name = metric_name.split("{")[0]
            metrics.append((metric_name, float(value), labels_dict))
    return metrics


def process_json_response(data):
    prometheus_metrics = data['result']  # Extract Prometheus metrics string
    metrics = parse_prometheus_text(prometheus_metrics)  # Parse Prometheus metrics

    for metric_name, value, labels in metrics:
        point = (
            Point(metric_name)
            .tag("id", labels.get('id', ''))
            .tag("mac", labels.get('mac', ''))
            .field("value", value)
        )
        write_api.write(bucket=influxdb.influxdb_bucket, org=influxdb.influxdb_org, record=point)


def scrape_and_write():
    while True:
        for host in shelly_util.config_data["hosts"]:
            try:
                target_url = f"http://{host['address']}/rpc/Script.Eval?id={host['script_index']}&code=getData()"

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
                        process_json_response(authenticated_response.json()["result"])
                else:
                    if "result" in authenticated_response.json():
                        process_json_response(response.json())
            except Exception as e:
                print(str(e))

        time.sleep(10)
