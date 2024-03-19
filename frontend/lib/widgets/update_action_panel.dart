import 'package:flutter/material.dart';
import 'package:shelly_pdu/util/request.dart';
import 'package:shelly_pdu/widgets/interactive_widget.dart';
import 'package:shelly_pdu/widgets/loading_widget.dart';

class UpdateActionPanel extends StatefulWidget {
  const UpdateActionPanel({
    Key? key,
  }) : super(key: key);

  @override
  State<UpdateActionPanel> createState() => UpdateActionPanelState();
}

class UpdateActionPanelState extends State<UpdateActionPanel> {
  final Map<String, dynamic> _updatesAvailable = {};

  @override
  Widget build(BuildContext context) {
    double leftWidth = 150;
    double rightWidth = 150;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(children: [
                const Icon(Icons.upgrade_rounded, size: 25),
                const SizedBox(width: 10),
                Text("Check for Firmware Update",
                    style: Theme.of(context).textTheme.headlineSmall)
              ]),
              InteractiveWidget(
                  onTap: () async {
                    Map<String, dynamic> hosts = await requestSwitchHosts();
                    setState(() {
                      for (Map<String, dynamic> host in hosts["hosts"]) {
                        _updatesAvailable[host["id"]] = null;
                      }
                    });
                  },
                  enableHoverTilt: true,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(40)),
                    child: Icon(Icons.refresh_rounded,
                        size: 30,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ))
            ]),
        if (_updatesAvailable.isNotEmpty) ...[
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: leftWidth,
                  child: Text(
                    "Switch",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const Spacer(),
                Text(
                  "Version",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: rightWidth,
                  child: Text(
                    "Actions",
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          const Divider()
        ],
        for (String sid in _updatesAvailable.keys)
          FutureBuilder<Map<String, dynamic>>(
            future: requestSwitchHostInformation(sid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic> switchInformation = snapshot.data!;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: leftWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              switchInformation["name"],
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              switchInformation["id"],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .color!
                                        .withAlpha(100),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 50),
                          child: FutureBuilder(
                              future: requestSwitchDeviceInformation(
                                  switchInformation["address"]),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  Map<String, dynamic> deviceInformation =
                                      snapshot.data!;

                                  if (deviceInformation.isEmpty) {
                                    return const Icon(Icons.warning_rounded);
                                  }

                                  return Text(deviceInformation["ver"]);
                                }

                                return const LoadingWidget(size: 12, stroke: 2);
                              })),
                      const Spacer(),
                      SizedBox(
                        width: rightWidth,
                        child: FutureBuilder(
                          future: checkForFirmwareUpdate(
                              switchInformation["address"]),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Map<String, dynamic> updateInformation =
                                  snapshot.data!;

                              if (updateInformation.isEmpty) {
                                return const Text("No updates",
                                    textAlign: TextAlign.end);
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (updateInformation["stable"] != null)
                                    ElevatedButton(
                                      onPressed: () {
                                        performFirmwareUpdate(
                                          switchInformation["address"],
                                          "stable",
                                        );
                                      },
                                      child: Text(
                                        "${updateInformation["stable"]["version"]}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                      ),
                                    ),
                                  if (updateInformation["stable"] == null &&
                                      updateInformation["beta"] != null)
                                    ElevatedButton(
                                      onPressed: () {
                                        performFirmwareUpdate(
                                          switchInformation["address"],
                                          "beta",
                                        );
                                      },
                                      child: Text(
                                        "${updateInformation["beta"]["version"]}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                      ),
                                    )
                                ],
                              );
                            }

                            return const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Checking "),
                                SizedBox(width: 5),
                                LoadingWidget(size: 12, stroke: 2),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          )
      ]),
    );
  }
}
