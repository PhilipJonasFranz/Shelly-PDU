import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shelly_pdu/util/navigation.dart';
import 'package:shelly_pdu/util/request.dart';
import 'package:shelly_pdu/widgets/interactive_widget.dart';
import 'package:shelly_pdu/widgets/loading_widget.dart';

class DevicePanel extends StatefulWidget {
  final Map<String, dynamic> device;
  final bool interactive;

  const DevicePanel({Key? key, required this.device, this.interactive = true})
      : super(key: key);

  @override
  State<DevicePanel> createState() => DevicePanelState();
}

class DevicePanelState extends State<DevicePanel> {
  bool isToggledOn = true;
  int displaySwitchAmount = 2;

  @override
  Widget build(BuildContext context) {
    List<dynamic> switches = widget.device["switches"];

    TextStyle faded = Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(100));

    Container content = Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surface),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                height: 30,
                alignment: Alignment.centerLeft,
                child: Text(widget.device["name"],
                    style: Theme.of(context).textTheme.bodyLarge)),
            const SizedBox(height: 10),
            Row(children: [
              for (int i = 0;
                  i < min(displaySwitchAmount, switches.length);
                  i++) ...[
                i < displaySwitchAmount - 1 && i < switches.length - 1
                    ? Text("${switches[i]}, ", style: faded)
                    : Text("${switches[i]}", style: faded),
                if (i == displaySwitchAmount - 1 &&
                    switches.length - displaySwitchAmount > 0)
                  Text(" + ${switches.length - displaySwitchAmount} more",
                      style: faded)
              ]
            ])
          ]),
          DeviceInfoSection(device: widget.device)
        ]));

    if (!widget.interactive) {
      return content;
    }

    return InteractiveWidget(
        onTap: () {
          updatePageNavIndex("device");
          Navigator.pushNamed(context, "/device/${widget.device["id"]}");
        },
        child: content);
  }
}

class DeviceInfoSection extends StatefulWidget {
  final Map<String, dynamic> device;

  const DeviceInfoSection({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceInfoSection> createState() => DeviceInfoSectionState();
}

class DeviceInfoSectionState extends State<DeviceInfoSection> {
  Timer? _timer;

  Map<String, String> switchAddresses = {};

  @override
  void initState() {
    super.initState();
    requestSwitchAddresses().then((value) {
      _timer = Timer.periodic(
          const Duration(seconds: 2), (Timer t) => setState(() {}));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> requestSwitchAddresses() async {
    Map<String, dynamic> hosts = await requestSwitchHosts();

    for (Map<String, dynamic> switch0 in hosts["hosts"]) {
      switchAddresses[switch0["id"]] = switch0["address"];
    }

    setState(() {});
  }

  Future<double> computeDevicePowerConsumption() async {
    double sum = 0;

    for (String switch0 in widget.device["switches"]) {
      String? address = switchAddresses[switch0];
      if (address != null) {
        Map<String, dynamic> switchInformation =
            await requestSwitchStatus(address);

        sum += switchInformation["apower"];
      }
    }

    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
        future: computeDevicePowerConsumption(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const SizedBox(
                height: 50,
                child: Row(children: [
                  Icon(Icons.error_outline_rounded),
                  SizedBox(width: 10),
                  Text("An error has occurred.")
                ]));
          }

          if (snapshot.hasData) {
            double consumption = snapshot.data!;

            return Row(children: [
              Text(consumption.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.headlineMedium),
              Padding(
                  padding: const EdgeInsets.only(top: 8, left: 3),
                  child:
                      Text("W", style: Theme.of(context).textTheme.bodyMedium))
            ]);
          }

          return const Row(children: [LoadingWidget(size: 30, stroke: 3)]);
        });
  }
}
