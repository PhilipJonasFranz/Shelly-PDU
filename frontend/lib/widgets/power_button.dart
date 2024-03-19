import 'package:flutter/material.dart';
import 'package:shelly_pdu/util/helpers.dart';
import 'package:shelly_pdu/util/request.dart';

class PowerButton extends StatefulWidget {
  final Map<String, dynamic> host;

  const PowerButton({Key? key, required this.host}) : super(key: key);

  @override
  PowerButtonState createState() => PowerButtonState();
}

class PowerButtonState extends State<PowerButton> {
  bool isHovering = false;

  bool isToggledOn = false;
  bool isLoading = true;

  requestPowerStatus() async {
    Map<String, dynamic> status =
        await requestSwitchStatus(widget.host["address"]);
    setState(() {
      isToggledOn = status["output"];
      isLoading = false;
    });
  }

  Color getSwitchColor(BuildContext context) {
    return isSwitchCritical(widget.host)
        ? Colors.red
        : isSwitchImportant(widget.host)
            ? Colors.orange
            : Theme.of(context).colorScheme.primary;
  }

  @override
  void initState() {
    requestPowerStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: InkWell(
        onTap: isSwitchCritical(widget.host) || isSwitchImportant(widget.host)
            ? null
            : () => setState(() {
                  isToggledOn = !isToggledOn;
                  setSwitchPower(widget.host["address"], isToggledOn);
                }),
        onLongPress: isSwitchImportant(widget.host)
            ? () => setState(() {
                  isToggledOn = !isToggledOn;
                  setSwitchPower(widget.host["address"], isToggledOn);
                })
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(45),
            color: Colors.white,
            boxShadow: [
              if (isToggledOn) ...[
                BoxShadow(
                  color: getSwitchColor(context)
                      .withOpacity(isHovering ? 0.8 : 0.7),
                  spreadRadius: isHovering ? 3 : 2,
                  blurRadius: isHovering ? 10 : 8,
                  offset: const Offset(0, 0),
                ),
                BoxShadow(
                  color: getSwitchColor(context)
                      .withOpacity(isHovering ? 0.6 : 0.5),
                  spreadRadius: isHovering ? 10 : 8,
                  blurRadius: isHovering ? 20 : 15,
                  offset: const Offset(0, 0),
                ),
              ] else ...[
                BoxShadow(
                  color: Colors.grey.withOpacity(0.7),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 0),
                ),
              ],
            ],
          ),
          child: Icon(
            isSwitchCritical(widget.host)
                ? Icons.emergency_outlined
                : isSwitchImportant(widget.host)
                    ? Icons.warning_amber_rounded
                    : Icons.power_settings_new_rounded,
            color: getSwitchColor(context),
          ),
        ),
      ),
    );
  }
}
