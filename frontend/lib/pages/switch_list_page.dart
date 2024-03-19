import 'package:shelly_pdu/util/navigation.dart';
import 'package:flutter/material.dart';
import 'package:shelly_pdu/widgets/switch_panel.dart';
import 'package:shelly_pdu/util/request.dart';
import 'package:shelly_pdu/widgets/loading_widget.dart';

class SwitchListPage extends StatefulWidget {
  const SwitchListPage({super.key});

  @override
  SwitchListPageState createState() => SwitchListPageState();
}

class SwitchListPageState extends State<SwitchListPage> {
  List<Map<String, dynamic>>? switches;

  @override
  void initState() {
    requestSwitchHosts().then((data) {
      setState(() {
        switches = [];
        List<dynamic> hosts = data["hosts"];
        for (Map<String, dynamic> host in hosts) {
          switches!.add(host);
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.power_settings_new_rounded, size: 35),
                      const SizedBox(width: 10),
                      Text("Switches",
                          style: Theme.of(context).textTheme.headlineMedium)
                    ]))),
        Expanded(
            child: switches != null
                ? ListView(children: [
                    for (Map<String, dynamic> host in switches!) ...[
                      Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SwitchPanel(sid: host["id"])),
                    ]
                  ])
                : const LoadingWidget(size: 30, stroke: 3))
      ]),
    )));
  }
}
