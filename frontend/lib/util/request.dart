import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> requestSwitchHosts() async {
  http.Response response = await http.get(Uri.parse('/api/hosts'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> powerUsageStats(
    List<String> hids, int numDatapoints, int intervalSeconds) async {
  http.Response response = await http.get(Uri.parse(
      '/api/power_stats?hids=${hids.join(",")}&numDatapoints=$numDatapoints&intervalSeconds=$intervalSeconds'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> temperatureStats(
    List<String> hids, int numDatapoints, int intervalSeconds) async {
  http.Response response = await http.get(Uri.parse(
      '/api/temperature_stats?hids=${hids.join(",")}&numDatapoints=$numDatapoints&intervalSeconds=$intervalSeconds'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> averagePowerConsumption() async {
  http.Response response = await http.get(Uri.parse('/api/average_power'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> getSettings() async {
  http.Response response = await http.get(Uri.parse('/api/settings'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> requestDevices() async {
  http.Response response = await http.get(Uri.parse('/api/devices'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> requestSwitchHostInformation(String hid) async {
  http.Response response = await http.get(Uri.parse('/api/host?hid=$hid'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> requestSwitchDeviceInformation(
    String address) async {
  http.Response response = await http.get(
      Uri.parse('/api/proxy?url=http://$address/rpc/Shelly.GetDeviceInfo'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> requestDeviceAllowedActions(String did) async {
  http.Response response = await http.get(Uri.parse('/api/actions?did=$did'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> requestDeviceInformation(String did) async {
  http.Response response = await http.get(Uri.parse('/api/device?hid=$did'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> requestSwitchStatus(String address) async {
  http.Response response = await http.get(
      Uri.parse('/api/proxy?url=http://$address/rpc/Switch.GetStatus?id=0'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> requestDeviceSystemConfiguration(
    String address) async {
  http.Response response = await http
      .get(Uri.parse('/api/proxy?url=http://$address/rpc/Sys.GetConfig'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> requestDeviceWiFiConfiguration(
    String address) async {
  http.Response response = await http
      .get(Uri.parse('/api/proxy?url=http://$address/rpc/WiFi.GetConfig'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> requestDeviceBLEConfiguration(
    String address) async {
  http.Response response = await http
      .get(Uri.parse('/api/proxy?url=http://$address/rpc/BLE.GetConfig'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> requestDeviceCloudConfiguration(
    String address) async {
  http.Response response = await http
      .get(Uri.parse('/api/proxy?url=http://$address/rpc/Cloud.GetConfig'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> requestDeviceScriptList(String address) async {
  http.Response response = await http
      .get(Uri.parse('/api/proxy?url=http://$address/rpc/Script.List'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> setScriptExecutionStatus(
    String address, int scriptId, bool scriptRunning) async {
  http.Response response = scriptRunning
      ? await http.get(Uri.parse(
          '/api/proxy?url=http://$address/rpc/Script.Start?id=$scriptId'))
      : await http.get(Uri.parse(
          '/api/proxy?url=http://$address/rpc/Script.Stop?id=$scriptId'));
  return jsonDecode(response.body);
}

setScriptEnabled(String address, int scriptId, bool scriptEnabled) async {
  String jsonPart = Uri.encodeComponent('{"enable": $scriptEnabled}');
  await http.get(Uri.parse(
      '/api/proxy?url=http://$address/rpc/Script.SetConfig?id=$scriptId%26config=$jsonPart'));
}

Future<Map<String, dynamic>> setSwitchPower(
    String address, bool powerOn) async {
  http.Response response = await http.get(Uri.parse(
      '/api/proxy?url=http://$address/rpc/Switch.Set?id=0%26on=$powerOn'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> getLEDConfiguration(String address) async {
  http.Response response = await http
      .get(Uri.parse('/api/proxy?url=http://$address/rpc/PLUGS_UI.GetConfig'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> checkForFirmwareUpdate(String address) async {
  http.Response response = await http.get(
      Uri.parse('/api/proxy?url=http://$address/rpc/Shelly.CheckForUpdate'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> performFirmwareUpdate(
    String address, String stage) async {
  http.Response response = await http.get(Uri.parse(
      '/api/proxy?url=http://$address/rpc/Shelly.Update?stage=$stage'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> setLEDBrightness(
    String address, int brightness) async {
  if (brightness >= 0 && brightness <= 100) {
    http.Response response = await http.get(Uri.parse(
        '/api/proxy?url=http://$address/rpc/PLUGS_UI.SetConfig?config={"leds":{"colors":{"switch:0":{"on":{"brightness":$brightness},"off":{"brightness":$brightness}},"power":{"brightness":$brightness}}}}'));
    return jsonDecode(response.body);
  }

  return Future.value({});
}

Future<Map<String, dynamic>> runActionOnDevice(
    String did, String action, String auth) async {
  http.Response response = await http
      .post(Uri.parse('/api/action?did=$did&action=$action&auth=$auth'));
  return jsonDecode(response.body);
}
