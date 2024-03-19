import 'dart:math';

import 'package:shelly_pdu/util/navigation.dart';
import 'package:flutter/material.dart';
import 'package:shelly_pdu/widgets/statistic_panel.dart';
import 'package:shelly_pdu/util/request.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> switches = [];

  @override
  void initState() {
    requestSwitchHosts().then((data) {
      setState(() {
        List<dynamic> hosts = data["hosts"];
        for (Map<String, dynamic> host in hosts) {
          switches.add(host);
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double gridSpacing = 20;
    double screenWidth = min(MediaQuery.of(context).size.width, 1000);
    double panelWidth = 150.0;

    // Calculate the number of panels that can fit in a row
    int crossAxisCount = (screenWidth / (panelWidth + gridSpacing * 2)).floor();

    List<StatisticPanel> panels = [
      StatisticPanel(
          computeValue: () async {
            return requestSwitchHosts().then((data) async {
              double total = 0;

              List<dynamic> hosts = data["hosts"];

              await Future.forEach(hosts, (host) async {
                Map<String, dynamic> hostStatus =
                    await requestSwitchStatus(host["address"]);
                total += hostStatus["apower"];
              });

              if (total >= 10) {
                return "${total.toInt()} W";
              }

              return "${total.toStringAsFixed(2)} W";
            });
          },
          label: "Total Power",
          route: "/statistics",
          duration: const Duration(seconds: 2)),
      StatisticPanel(
          computeValue: () async {
            Map<String, dynamic> averageConsumption =
                await averagePowerConsumption();

            Map<String, dynamic> settings = await getSettings();

            double sum = averageConsumption["average"] * 2;

            // Convert to kwh for a month
            sum *= (30 * 24) / 1000;

            // Convert to € by multiplying with kwh price
            sum *= settings["kwh_price"] ?? 0.25;

            if (sum >= 10) {
              return "${sum.toInt()} €";
            }

            return "${sum.toStringAsFixed(2)} €";
          },
          label: "Cost per Month",
          route: "/statistics",
          duration: const Duration(seconds: 5)),
      StatisticPanel(
          computeValue: () async {
            return requestSwitchHosts().then((data) {
              List<dynamic> hosts = data["hosts"];
              return hosts.length;
            });
          },
          label: "Switches",
          route: "/switches"),
      StatisticPanel(
          computeValue: () async {
            return requestDevices().then((data) {
              List<dynamic> devices = data["devices"];
              return devices.length;
            });
          },
          label: "Devices",
          route: "/devices"),
    ];

    return PageFrame(
        body: SelectionArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        height: double.infinity,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.dashboard_rounded, size: 35),
                    const SizedBox(width: 10),
                    Text("Dashboard",
                        style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: gridSpacing,
                  crossAxisSpacing: gridSpacing,
                ),
                children: panels,
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
