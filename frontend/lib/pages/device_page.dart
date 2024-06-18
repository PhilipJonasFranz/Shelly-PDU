import 'dart:math';

import 'package:shelly_pdu/util/navigation.dart';
import 'package:flutter/material.dart';
import 'package:shelly_pdu/util/request.dart';
import 'package:shelly_pdu/widgets/action_panel.dart';
import 'package:shelly_pdu/widgets/graph_stat_chart.dart';
import 'package:shelly_pdu/widgets/interactive_widget.dart';
import 'package:shelly_pdu/widgets/loading_widget.dart';
import 'package:shelly_pdu/widgets/locate_switch_panel.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'package:shelly_pdu/widgets/switch_panel.dart';

class DevicePage extends StatefulWidget {
  final String did;

  const DevicePage({super.key, required this.did});

  @override
  DevicePageState createState() => DevicePageState();
}

class DevicePageState extends State<DevicePage> {
  Map<String, dynamic> _deviceInformation = {};
  Map<String, dynamic> _actionInformation = {};

  List<Widget> timeSelection = <Widget>[
    const Text('10m'),
    const Text('1h'),
    const Text('10h'),
    const Text('1d'),
    const Text('10d')
  ];

  final List<bool> _selectedTime = <bool>[true, false, false, false, false];

  List<ActionPanel> panels = [];

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

  fetchDeviceInformation() async {
    requestDeviceInformation(widget.did).then((value) async {
      _deviceInformation = value;

      requestDeviceAllowedActions(widget.did).then((value) async {
        _actionInformation = value;

        for (Map<String, dynamic> action in _actionInformation["actions"]) {
          panels.add(ActionPanel(
              did: widget.did,
              label: action["label"],
              action: action["name"],
              icon: action["icon"]));
        }

        setState(() {});
      });
    });
  }

  @override
  void initState() {
    fetchDeviceInformation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_deviceInformation.isEmpty) {
      return const Column(children: [
        Expanded(
            child: LoadingWidget(
          size: 40,
          stroke: 4,
        ))
      ]);
    }

    Widget? titleWrap = _deviceInformation.isNotEmpty
        ? Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text(_deviceInformation["name"],
                style: Theme.of(context).textTheme.headlineMedium),
            if (_deviceInformation["management"] != null) ...[
              const SizedBox(width: 10),
              InteractiveWidget(
                  enableHoverTilt: true,
                  onTap: () {
                    js.context.callMethod(
                        'open', ["${_deviceInformation["management"]}"]);
                  },
                  child: const Icon(Icons.settings_rounded))
            ]
          ])
        : null;

    List<String> switches = [];
    for (String switch0 in _deviceInformation["switches"]) {
      switches.add(switch0);
    }

    double gridSpacing = 20;
    double screenWidth = min(MediaQuery.of(context).size.width, 1000);
    double panelWidth = 100.0;

    // Calculate the number of panels that can fit in a row
    int crossAxisCount = (screenWidth / (panelWidth + gridSpacing * 2)).floor();

    return PageFrame(
        body: SelectionArea(
            child: Container(
      padding: const EdgeInsets.all(20),
      height: double.infinity,
      child: _deviceInformation.isEmpty
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
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [titleWrap!]))),
              const SizedBox(height: 10),
              Expanded(
                  child: ListView(children: [
                if (panels.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.play_circle_rounded),
                      const SizedBox(width: 10),
                      Text(
                        "Actions",
                        style: Theme.of(context).textTheme.headlineSmall,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: gridSpacing,
                      crossAxisSpacing: gridSpacing,
                    ),
                    children: panels,
                  ),
                  const SizedBox(height: 20),
                ],
                Row(
                  children: [
                    const Icon(Icons.power_rounded),
                    const SizedBox(width: 10),
                    Text(
                      "Switches",
                      style: Theme.of(context).textTheme.headlineSmall,
                    )
                  ],
                ),
                const SizedBox(height: 10),
                for (String switch0 in switches) ...[
                  SwitchPanel(sid: switch0),
                  const SizedBox(height: 10)
                ],
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
                            "Power Draw",
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
                        callback: powerUsageStats,
                        numDatapoints: getNumDatapoints(),
                        datapointIntervalInSeconds:
                            getSampleIntervalInSeconds(),
                        hids: switches)),
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
                    child: LocateSwitchPanel(sids: switches))
              ]))
            ]),
    )));
  }
}
