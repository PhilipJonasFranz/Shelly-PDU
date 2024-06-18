import 'package:shelly_pdu/widgets/script_panel.dart';
import 'package:shelly_pdu/util/navigation.dart';
import 'package:flutter/material.dart';
import 'package:shelly_pdu/util/request.dart';
import 'package:shelly_pdu/widgets/graph_stat_chart.dart';
import 'package:shelly_pdu/widgets/hover_icon.dart';
import 'package:shelly_pdu/widgets/interactive_widget.dart';
import 'package:shelly_pdu/widgets/loading_widget.dart';
import 'package:shelly_pdu/widgets/locate_switch_panel.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'package:shelly_pdu/widgets/switch_panel.dart';

class SwitchPage extends StatefulWidget {
  final String sid;

  const SwitchPage({super.key, required this.sid});

  @override
  SwitchPageState createState() => SwitchPageState();
}

class SwitchPageState extends State<SwitchPage> {
  Map<String, dynamic> _hostInformation = {};
  Map<String, dynamic> _systemConfig = {};
  Map<String, dynamic> _wifiConfig = {};
  Map<String, dynamic> _bleConfig = {};
  Map<String, dynamic> _cloudConfig = {};
  Map<String, dynamic> _scriptList = {};

  List<Widget> timeSelection = <Widget>[
    const Text('10m'),
    const Text('1h'),
    const Text('10h'),
    const Text('1d'),
    const Text('10d'),
  ];

  final List<bool> _selectedTime = <bool>[true, false, false, false, false];

  int getNumDatapoints() {
    return 61;
  }

  int getSampleIntervalInSeconds() {
    if (_selectedTime[0]) {
      return 10;
    } else if (_selectedTime[1]) {
      return 60;
    } else if (_selectedTime[2]) {
      return 600;
    } else if (_selectedTime[3]) {
      return 1440;
    } else {
      return 1440 * 10;
    }
  }

  fetchHostInformation() async {
    requestSwitchHostInformation(widget.sid).then((value) async {
      _hostInformation = value;
      await requestDeviceSystemConfiguration(_hostInformation["address"])
          .then((value) {
        _systemConfig = value;
      });

      await requestDeviceWiFiConfiguration(_hostInformation["address"])
          .then((value) {
        _wifiConfig = value;
      });

      await requestDeviceBLEConfiguration(_hostInformation["address"])
          .then((value) {
        _bleConfig = value;
      });

      await requestDeviceCloudConfiguration(_hostInformation["address"])
          .then((value) {
        _cloudConfig = value;
      });

      await requestDeviceScriptList(_hostInformation["address"]).then((value) {
        _scriptList = value;
      });

      setState(() {});
    });
  }

  @override
  void initState() {
    fetchHostInformation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool mqttEnabled = _systemConfig.isNotEmpty &&
        _systemConfig["debug"]["mqtt"]["enable"] == true;
    bool cloudEnabled =
        _cloudConfig.isNotEmpty && _cloudConfig["enable"] == true;
    bool bleEnabled = _bleConfig.isNotEmpty && _bleConfig["enable"] == true;
    bool wifiEnabled =
        _wifiConfig.isNotEmpty && _wifiConfig["sta"]["enable"] == true;
    bool apEnabled =
        _wifiConfig.isNotEmpty && _wifiConfig["ap"]["enable"] == true;

    double screenWidth = MediaQuery.of(context).size.width;
    bool isOnMobile = screenWidth < 500;
    double iconSize = isOnMobile ? 40 : 30;
    double spaceBetweenIcons = isOnMobile ? 20 : 10;

    Wrap? titleWrap = _hostInformation.isNotEmpty
        ? Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text(_hostInformation["name"],
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(width: 10),
            InteractiveWidget(
                enableHoverTilt: true,
                onTap: () {
                  js.context.callMethod(
                      'open', ["http://${_hostInformation["address"]}"]);
                },
                child: const Icon(Icons.settings_rounded))
          ])
        : null;

    Wrap? configWrap = _hostInformation.isNotEmpty
        ? Wrap(
            children: [
              SizedBox(
                  height: iconSize,
                  width: iconSize,
                  child: HoverIconWidget(
                      icon: Icons.router_rounded,
                      size: iconSize,
                      color: apEnabled
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      tooltip: apEnabled ? "AP enabled" : "AP disabled")),
              SizedBox(width: spaceBetweenIcons),
              SizedBox(
                  height: iconSize,
                  width: iconSize,
                  child: HoverIconWidget(
                      icon: Icons.wifi_rounded,
                      size: iconSize,
                      color: wifiEnabled
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      tooltip: wifiEnabled ? "WiFi enabled" : "WiFi disabled")),
              SizedBox(width: spaceBetweenIcons),
              SizedBox(
                  height: iconSize,
                  width: iconSize,
                  child: HoverIconWidget(
                      icon: Icons.bluetooth_rounded,
                      size: iconSize,
                      color: bleEnabled
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      tooltip: bleEnabled
                          ? "Bluetooth enabled"
                          : "Bluetooth disabled")),
              SizedBox(width: spaceBetweenIcons),
              SizedBox(
                  height: iconSize,
                  width: iconSize,
                  child: HoverIconWidget(
                      icon: Icons.cloud_rounded,
                      size: iconSize,
                      color: cloudEnabled
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      tooltip:
                          cloudEnabled ? "Cloud enabled" : "Cloud disabled")),
              SizedBox(width: spaceBetweenIcons),
              SizedBox(
                  height: iconSize,
                  width: iconSize,
                  child: Container(
                      padding: const EdgeInsets.all(5),
                      child: HoverWidget(
                          icon: Center(
                              child: mqttEnabled
                                  ? Image.asset(
                                      'assets/images/mqtt_enabled.png',
                                      isAntiAlias: true,
                                      filterQuality: FilterQuality.high)
                                  : Theme.of(context).colorScheme.brightness ==
                                          Brightness.dark
                                      ? Image.asset(
                                          'assets/images/mqtt_disabled_light.png',
                                          isAntiAlias: true,
                                          filterQuality: FilterQuality.high)
                                      : Image.asset(
                                          'assets/images/mqtt_disabled_dark.png',
                                          isAntiAlias: true,
                                          filterQuality: FilterQuality.high)),
                          color: mqttEnabled
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                          tooltip:
                              mqttEnabled ? "MQTT enabled" : "MQTT disabled")))
            ],
          )
        : null;

    return PageFrame(
        body: SelectionArea(
            child: Container(
      padding: const EdgeInsets.all(20),
      height: double.infinity,
      child: _hostInformation.isEmpty
          ? const Column(children: [
              Expanded(
                  child: LoadingWidget(
                size: 40,
                stroke: 4,
              ))
            ])
          : Column(children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: !isOnMobile
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [titleWrap!, configWrap!]))
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: titleWrap)
                              ]))),
              const SizedBox(height: 10),
              Expanded(
                  child: ListView(children: [
                if (isOnMobile)
                  Container(
                      padding: const EdgeInsets.only(bottom: 20),
                      alignment: Alignment.center,
                      child: configWrap),
                Row(
                  children: [
                    const Icon(Icons.monitor_rounded),
                    const SizedBox(width: 10),
                    Text(
                      "Overview",
                      style: Theme.of(context).textTheme.headlineSmall,
                    )
                  ],
                ),
                const SizedBox(height: 10),
                SwitchPanel(sid: _hostInformation["id"], interactive: false),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Icon(Icons.bar_chart_rounded),
                          const SizedBox(width: 10),
                          Text(
                            "Usage",
                            style: Theme.of(context).textTheme.headlineSmall,
                          )
                        ]),
                    ToggleButtons(
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < _selectedTime.length; i++) {
                            _selectedTime[i] = i == index;
                          }
                        });
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      selectedColor: Colors.white,
                      fillColor: Theme.of(context).colorScheme.primary,
                      color: Theme.of(context).colorScheme.primary,
                      constraints: const BoxConstraints(
                        minHeight: 30.0,
                        minWidth: 50.0,
                      ),
                      isSelected: _selectedTime,
                      children: timeSelection,
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                    height: 300,
                    padding: const EdgeInsets.all(10),
                    child: GraphStatChart(
                        key: UniqueKey(),
                        numDatapoints: getNumDatapoints(),
                        datapointIntervalInSeconds:
                            getSampleIntervalInSeconds(),
                        callback: powerUsageStats,
                        hids: [_hostInformation["id"]])),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.code_rounded),
                    const SizedBox(width: 10),
                    Text(
                      "Scripts",
                      style: Theme.of(context).textTheme.headlineSmall,
                    )
                  ],
                ),
                const SizedBox(height: 10),
                for (Map<String, dynamic> script in _scriptList["scripts"])
                  Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child:
                          ScriptPanel(host: _hostInformation, script: script)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.build_rounded),
                    const SizedBox(width: 10),
                    Text(
                      "Tools",
                      style: Theme.of(context).textTheme.headlineSmall,
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LocateSwitchPanel(sids: [_hostInformation["id"]]))
              ]))
            ]),
    )));
  }
}
