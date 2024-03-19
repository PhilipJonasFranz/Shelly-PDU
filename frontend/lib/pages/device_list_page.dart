import 'package:shelly_pdu/util/navigation.dart';
import 'package:flutter/material.dart';
import 'package:shelly_pdu/widgets/device_panel.dart';
import 'package:shelly_pdu/util/request.dart';
import 'package:shelly_pdu/widgets/loading_widget.dart';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});

  @override
  DeviceListPageState createState() => DeviceListPageState();
}

class DeviceListPageState extends State<DeviceListPage> {
  List<Map<String, dynamic>>? devices;

  @override
  void initState() {
    requestDevices().then((data) {
      setState(() {
        devices = [];
        List<dynamic> devs = data["devices"];
        for (Map<String, dynamic> device in devs) {
          devices!.add(device);
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
                      const Icon(Icons.computer_rounded, size: 35),
                      const SizedBox(width: 10),
                      Text("Devices",
                          style: Theme.of(context).textTheme.headlineMedium)
                    ]))),
        Expanded(
            child: devices != null
                ? ListView(children: [
                    for (Map<String, dynamic> device in devices!) ...[
                      Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DevicePanel(device: device)),
                    ]
                  ])
                : const LoadingWidget(size: 30, stroke: 3))
      ]),
    )));
  }
}
