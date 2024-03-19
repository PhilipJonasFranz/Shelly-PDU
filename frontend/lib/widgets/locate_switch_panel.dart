import 'package:flutter/material.dart';

import 'dart:async';

import 'package:shelly_pdu/util/request.dart';

class LocateSwitchPanel extends StatefulWidget {
  final List<String> sids;

  const LocateSwitchPanel({Key? key, required this.sids}) : super(key: key);

  @override
  State<LocateSwitchPanel> createState() => LocateSwitchPanelState();
}

class LocateSwitchPanelState extends State<LocateSwitchPanel> {
  bool locateModeIsOn = false;
  bool ledToggle = true;

  final Map<String, Map<String, dynamic>> _switchesInformation = {};

  Timer? timer;

  fetchSwitchesInformation() async {
    for (String switch0 in widget.sids) {
      requestSwitchHostInformation(switch0).then((value) {
        _switchesInformation[switch0] = value;
      });
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    fetchSwitchesInformation();

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_switchesInformation.isNotEmpty) {
        ledToggle = !ledToggle;
        if (locateModeIsOn) {
          for (String switch0 in widget.sids) {
            setLEDBrightness(
                _switchesInformation[switch0]!["address"], ledToggle ? 100 : 0);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();

    for (String switch0 in widget.sids) {
      setLEDBrightness(_switchesInformation[switch0]!["address"], 100);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MaterialStateProperty<Color?> trackColor =
        MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return Theme.of(context).colorScheme.primary;
        }

        return null;
      },
    );
    final MaterialStateProperty<Color?> overlayColor =
        MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return Theme.of(context).colorScheme.primary.withOpacity(0.54);
        }

        if (states.contains(MaterialState.disabled)) {
          return Colors.grey.shade400;
        }

        return null;
      },
    );

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surface),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                Icon(
                    locateModeIsOn
                        ? Icons.lightbulb_rounded
                        : Icons.lightbulb_rounded,
                    size: 30),
                const SizedBox(width: 10),
                Text("Locate Mode",
                    style: Theme.of(context).textTheme.bodyLarge)
              ]),
              Switch(
                value: locateModeIsOn,
                overlayColor: overlayColor,
                trackColor: trackColor,
                thumbColor: const MaterialStatePropertyAll<Color>(Colors.white),
                onChanged: (bool value) {
                  setState(() {
                    locateModeIsOn = value;

                    if (!value) {
                      for (String switch0 in widget.sids) {
                        setLEDBrightness(
                            _switchesInformation[switch0]!["address"], 100);
                      }
                    }
                  });
                },
              )
            ]));
  }
}
