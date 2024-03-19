import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shelly_pdu/util/navigation.dart';
import 'package:shelly_pdu/util/request.dart';
import 'package:shelly_pdu/widgets/hover_icon.dart';
import 'package:shelly_pdu/widgets/interactive_widget.dart';
import 'package:shelly_pdu/widgets/loading_widget.dart';
import 'package:shelly_pdu/widgets/power_button.dart';

class SwitchPanel extends StatefulWidget {
  final String sid;
  final bool interactive;

  const SwitchPanel({Key? key, required this.sid, this.interactive = true})
      : super(key: key);

  @override
  State<SwitchPanel> createState() => SwitchPanelState();
}

class SwitchPanelState extends State<SwitchPanel> {
  bool isToggledOn = true;

  Map<String, dynamic> _switchInformation = {};
  Map<String, dynamic> _deviceConfig = {};
  Map<String, dynamic> _switchStatus = {};

  @override
  void initState() {
    requestSwitchHostInformation(widget.sid).then((value) async {
      _switchInformation = value;

      await requestSwitchDeviceInformation(_switchInformation["address"])
          .then((value) {
        _deviceConfig = value;
      });

      await requestSwitchStatus(_switchInformation["address"]).then((value) {
        _switchStatus = value;
      });

      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_switchInformation.isEmpty) {
      return const Column(
          children: [Center(child: LoadingWidget(size: 30, stroke: 3))]);
    }

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
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(_switchInformation["name"],
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(width: 8),
                      const Icon(Icons.device_thermostat_rounded, size: 15),
                      Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Text(
                              "${_switchStatus["temperature"]["tC"]} C°",
                              style: Theme.of(context).textTheme.bodyMedium!)),
                      if (_deviceConfig["auth_en"] == true) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                            child: HoverIconWidget(
                                icon: Icons.lock_rounded,
                                size: 15,
                                color: Theme.of(context).colorScheme.onSurface,
                                tooltip: "Authentication enabled")),
                        if (isDesktop(context)) const SizedBox(width: 5),
                      ],
                      if (isDesktop(context))
                        Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(_switchInformation["id"],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .color!
                                            .withAlpha(100)))),
                    ])),
            const SizedBox(height: 10),
            SwitchInfoSection(host: _switchInformation)
          ]),
          PowerButton(host: _switchInformation)
        ]));

    if (!widget.interactive) {
      return content;
    }

    return InteractiveWidget(
        onTap: () {
          updatePageNavIndex("switch");
          Navigator.pushNamed(context, "/switch/${widget.sid}");
        },
        child: content);
  }
}

class SwitchInfoSection extends StatefulWidget {
  final Map<String, dynamic> host;

  const SwitchInfoSection({Key? key, required this.host}) : super(key: key);

  @override
  State<SwitchInfoSection> createState() => SwitchInfoSectionState();
}

class SwitchInfoSectionState extends State<SwitchInfoSection> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
        const Duration(seconds: 2), (Timer t) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: requestSwitchStatus(widget.host["address"]),
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
            Map<String, dynamic> data = snapshot.data!;

            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 1),
                      borderRadius: BorderRadius.circular(45)),
                  child: Text("${data["voltage"].toString()} V"),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 1),
                      borderRadius: BorderRadius.circular(45)),
                  child: Text("${data["apower"].toString()} W"),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 1),
                      borderRadius: BorderRadius.circular(45)),
                  child: Text("${data["current"].toString()} A"),
                )
              ],
            );
          }

          return const Row(children: [
            LoadingWidget(size: 10, stroke: 2),
            SizedBox(width: 10),
            Text("Fetching status")
          ]);
        });
  }
}
