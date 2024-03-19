import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shelly_pdu/util/navigation.dart';
import 'package:shelly_pdu/widgets/interactive_widget.dart';
import 'package:shelly_pdu/widgets/loading_widget.dart';

class StatisticPanel extends StatefulWidget {
  final Future<dynamic> Function() computeValue;
  final String label;
  final String? route;
  final Duration? duration;

  const StatisticPanel({
    Key? key,
    required this.computeValue,
    required this.label,
    this.route,
    this.duration,
  }) : super(key: key);

  @override
  State<StatisticPanel> createState() => StatisticPanelState();
}

class StatisticPanelState extends State<StatisticPanel> {
  dynamic currentValue;
  bool hasValueBeenComputed = false;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    refreshComputedValue();

    if (widget.duration != null) {
      refreshTimer = Timer.periodic(widget.duration!, (timer) {
        refreshComputedValue();
      });
    }
  }

  void refreshComputedValue() async {
    try {
      var newValue = await widget.computeValue();
      if (mounted) {
        setState(() {
          currentValue = newValue;
          hasValueBeenComputed = true;
        });
      }
    } catch (error) {
      // Handle error if necessary
    }
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveWidget(
      onTap: () {
        if (widget.route != null) {
          updatePageNavIndex(widget.route!);
          Navigator.pushNamed(context, widget.route!);
        }
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: hasValueBeenComputed
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentValue.toString(),
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : const LoadingWidget(size: 30, stroke: 3),
      ),
    );
  }
}
