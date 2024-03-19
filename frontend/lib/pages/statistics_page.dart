import 'package:flutter/cupertino.dart';
import 'package:shelly_pdu/util/navigation.dart';
import 'package:flutter/material.dart';
import 'package:shelly_pdu/util/request.dart';
import 'package:shelly_pdu/widgets/dropdown_menu.dart';
import 'package:shelly_pdu/widgets/graph_stat_chart.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  StatisticsPageState createState() => StatisticsPageState();
}

class StatisticsPageState extends State<StatisticsPage> {
  final List<dynamic> _hosts = [];

  final List<String> selectedIDs = [];

  String statistic = "power";
  bool aggregate = true;

  List<Widget> timeSelection = <Widget>[
    const Text('10m'),
    const Text('1h'),
    const Text('10h'),
    const Text('1d')
  ];

  final List<bool> _selectedTime = <bool>[true, false, false, false];

  List<String> getHostIDs() {
    List<String> hids = [];

    for (Map<String, dynamic> host in _hosts) {
      hids.add(host["id"]);
    }

    return hids;
  }

  List<String> buildSelectedIDList() {
    List<String> hids = getHostIDs();

    hids.removeWhere((element) => !selectedIDs.contains(element));

    return hids;
  }

  String getHostName(String hid) {
    for (Map<String, dynamic> host in _hosts) {
      if (host["id"] == hid) {
        return host["name"];
      }
    }

    return "?";
  }

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
    } else {
      return 1440;
    }
  }

  @override
  void initState() {
    requestSwitchHosts().then((value) {
      setState(() {
        for (Map<String, dynamic> host in value["hosts"]) {
          _hosts.add(host);
          selectedIDs.add(host["id"]);
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageFrame(
        body: SelectionArea(
            child: Container(
      padding: const EdgeInsets.all(20),
      height: double.infinity,
      child: Column(children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(Icons.bar_chart_rounded, size: 35),
                            const SizedBox(width: 10),
                            Text("Statistics",
                                style:
                                    Theme.of(context).textTheme.headlineMedium)
                          ]),
                      Wrap(children: [
                        ToggleButtons(
                          onPressed: (int index) {
                            setState(() {
                              for (int i = 0; i < _selectedTime.length; i++) {
                                _selectedTime[i] = i == index;
                              }
                            });
                          },
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
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
                      ])
                    ]))),
        const SizedBox(height: 10),
        Expanded(
            child: ListView(children: [
          SizedBox(
              height: 40,
              child: Row(
                  mainAxisAlignment: isDesktop(context)
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 160,
                        height: 32,
                        child: DropdownBox(
                            callback: (value) {
                              setState(() {
                                if (value == "Power") {
                                  statistic = "power";
                                } else if (value == "Temperature") {
                                  statistic = "temp";
                                }
                              });
                            },
                            elements: const ["Power", "Temperature"])),
                    if (statistic != "temp") ...[
                      const SizedBox(width: 10),
                      Text("Aggregate: ",
                          style: Theme.of(context).textTheme.bodyLarge),
                      Transform.scale(
                          scale: 0.75,
                          child: CupertinoSwitch(
                              value: aggregate,
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                              onChanged: (value) {
                                setState(() {
                                  aggregate = value;
                                });
                              })),
                    ]
                  ])),
          const SizedBox(height: 10),
          if (statistic == "power")
            Container(
                height: 400,
                padding: const EdgeInsets.all(10),
                child: GraphStatChart(
                  numDatapoints: getNumDatapoints(),
                  datapointIntervalInSeconds: getSampleIntervalInSeconds(),
                  callback: powerUsageStats,
                  key: UniqueKey(),
                  aggregate: aggregate,
                  hids: buildSelectedIDList().reversed.toList(),
                )),
          if (statistic == "temp")
            Container(
                height: 400,
                padding: const EdgeInsets.all(10),
                child: GraphStatChart(
                  numDatapoints: getNumDatapoints(),
                  datapointIntervalInSeconds: getSampleIntervalInSeconds(),
                  callback: temperatureStats,
                  aggregate: false,
                  unit: "C°",
                  key: UniqueKey(),
                  hids: buildSelectedIDList().reversed.toList(),
                )),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Checkbox(
              side: MaterialStateBorderSide.resolveWith(
                (states) {
                  Color borderColor;
                  if (states.contains(MaterialState.selected)) {
                    borderColor = Theme.of(context).colorScheme.primary;
                  } else {
                    borderColor = Theme.of(context).colorScheme.onSurface;
                  }

                  return BorderSide(width: 1, color: borderColor);
                },
              ),
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(2)),
              value: selectedIDs.length == _hosts.length,
              onChanged: (bool? value) {
                setState(() {
                  if (selectedIDs.length == _hosts.length) {
                    selectedIDs.clear();
                  } else {
                    selectedIDs.clear();
                    selectedIDs.addAll(getHostIDs());
                  }
                });
              },
            ),
            const SizedBox(width: 10),
            Text(
              "Switches",
              style: Theme.of(context).textTheme.headlineMedium,
            )
          ]),
          const Divider(),
          for (String hid in getHostIDs())
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Checkbox(
                side: MaterialStateBorderSide.resolveWith(
                  (states) {
                    Color borderColor;
                    if (states.contains(MaterialState.selected)) {
                      borderColor = Theme.of(context).colorScheme.primary;
                    } else {
                      borderColor = Theme.of(context).colorScheme.onSurface;
                    }

                    return BorderSide(width: 1, color: borderColor);
                  },
                ),
                shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(2)),
                value: selectedIDs.contains(hid),
                onChanged: (bool? value) {
                  setState(() {
                    if (selectedIDs.contains(hid)) {
                      selectedIDs.remove(hid);
                    } else {
                      selectedIDs.add(hid);
                    }
                  });
                },
              ),
              const SizedBox(width: 10),
              Row(children: [
                Text(getHostName(hid)),
                Text(
                  "  -  $hid",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5)),
                )
              ])
            ])
        ]))
      ]),
    )));
  }
}
