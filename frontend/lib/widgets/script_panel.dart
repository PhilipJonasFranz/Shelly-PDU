import 'package:flutter/material.dart';
import 'package:shelly_pdu/util/request.dart';
import 'package:shelly_pdu/widgets/interactive_widget.dart';

class ScriptPanel extends StatefulWidget {
  final Map<String, dynamic> host;
  final Map<String, dynamic> script;

  const ScriptPanel({Key? key, required this.host, required this.script})
      : super(key: key);

  @override
  State<ScriptPanel> createState() => ScriptPanelState();
}

class ScriptPanelState extends State<ScriptPanel> {
  bool scriptIsEnabled = false;
  bool scriptIsRunning = false;

  @override
  void initState() {
    scriptIsEnabled = widget.script["enable"];
    scriptIsRunning = widget.script["running"];

    super.initState();
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
                InteractiveWidget(
                    child: Icon(
                        scriptIsRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 30),
                    onTap: () {
                      setState(() {
                        scriptIsRunning = !scriptIsRunning;
                      });
                      setScriptExecutionStatus(widget.host["address"],
                          widget.script["id"], scriptIsRunning);
                    }),
                const SizedBox(width: 10),
                Text(widget.script["name"],
                    style: Theme.of(context).textTheme.bodyLarge)
              ]),
              Switch(
                value: scriptIsEnabled,
                overlayColor: overlayColor,
                trackColor: trackColor,
                thumbColor: const MaterialStatePropertyAll<Color>(Colors.white),
                onChanged: (bool value) {
                  setState(() {
                    scriptIsEnabled = value;
                    setScriptEnabled(widget.host["address"],
                        widget.script["id"], scriptIsEnabled);
                  });
                },
              )
            ]));
  }
}
