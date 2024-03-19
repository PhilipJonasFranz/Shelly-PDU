import os

influxdb_url = os.getenv('INFLUXDB_URL', 'http://influxdb:8086')
influxdb_token = os.getenv('INFLUXDB_TOKEN', 'CHANGE_ME')
influxdb_org = os.getenv('INFLUXDB_ORG', 'shelly-pdu')
influxdb_bucket = os.getenv('INFLUXDB_BUCKET', 'shelly-pdu')