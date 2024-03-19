import yaml
import random
import hashlib
from urllib.parse import urlparse, parse_qs
import json


def load_config_from_file(file_path):
    with open(file_path, 'r') as file:
        return yaml.safe_load(file)


file_path = 'config.yml'
config_data = load_config_from_file(file_path)


def get_host_password(mac):
    for host in config_data["hosts"]:
        if host["id"].lower() == mac.lower():
            return host.get("password", None)

    return None


def get_device(did):
    for device in config_data["devices"]:
        if device["id"].lower() == did:
            return device

    return None


def get_action(action_name):
    for action in config_data["actions"]:
        if action["name"].lower() == action_name:
            return action
        
    return None


def parse_url_and_params(url):
    parsed_url = urlparse(url)
    base_url = f"{parsed_url.scheme}://{parsed_url.netloc}{parsed_url.path}"
    params = parse_qs(parsed_url.query)

    # Convert parameters to the appropriate format
    updated_params = {}
    for k, v in params.items():
        value = v[0]
        try:
            # Try to parse the value as JSON
            json_value = json.loads(value)

            # Check if the parsed value is a dict, bool, int, or float
            if isinstance(json_value, (dict, bool, int, float)):
                updated_params[k] = json_value
            else:
                updated_params[k] = value
        except json.JSONDecodeError:
            # If parsing fails, use the original value
            updated_params[k] = value

    return base_url, updated_params


def compute_auth_token(realm, nonce):
    mac = realm.split("-")[1]

    username = 'admin'
    password = get_host_password(mac)

    cnonce = str(random.randint(1000000000, 9999999999))

    ha1 = hashlib.sha256(':'.join([username, realm, password]).encode()).hexdigest()
    ha2 = hashlib.sha256(':'.join(["dummy_method", "dummy_uri"]).encode()).hexdigest()
    response = hashlib.sha256(':'.join([ha1, nonce, "1", cnonce, "auth", ha2]).encode()).hexdigest()

    return {
        "realm": realm, 
        "username": username, 
        "nonce": nonce, 
        "cnonce": cnonce, 
        "response": response, 
        "algorithm": "SHA-256"
    }