import 'package:shelly_pdu/util/navigation.dart';
import 'package:flutter/material.dart';
import 'package:shelly_pdu/util/request.dart';
import 'package:shelly_pdu/widgets/loading_widget.dart';
import 'package:shelly_pdu/widgets/update_action_panel.dart';

class ActionsPage extends StatefulWidget {
  const ActionsPage({super.key});

  @override
  ActionsPageState createState() => ActionsPageState();
}

class ActionsPageState extends State<ActionsPage> {
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
    List<Widget> panels = [const UpdateActionPanel()];

    return PageFrame(
        body: SelectionArea(
            child: Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Column(children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_rounded, size: 35),
                      const SizedBox(width: 10),
                      Text("Actions",
                          style: Theme.of(context).textTheme.headlineMedium)
                    ]))),
        Expanded(
            child: switches != null
                ? ListView(children: panels)
                : const LoadingWidget(size: 30, stroke: 3))
      ]),
    )));
  }
}
