import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shelly_pdu/util/request.dart';
import 'package:shelly_pdu/widgets/interactive_widget.dart';

import 'package:crypto/crypto.dart';
import 'package:shelly_pdu/widgets/loading_widget.dart';

class ActionPanel extends StatefulWidget {
  final String did;
  final String label;
  final String action;
  final int icon;

  const ActionPanel({
    Key? key,
    required this.did,
    required this.label,
    required this.action,
    required this.icon,
  }) : super(key: key);

  @override
  State<ActionPanel> createState() => ActionPanelState();
}

class ActionPanelState extends State<ActionPanel> {
  @override
  Widget build(BuildContext context) {
    return InteractiveWidget(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => ActionPanelConfirmationDialog(
              did: widget.did, action: widget.action),
        );
      },
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100, maxHeight: 100),
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(IconData(widget.icon, fontFamily: "MaterialIcons"),
                      size: 30),
                  const SizedBox(height: 8),
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ))),
    );
  }
}

class ActionPanelConfirmationDialog extends StatefulWidget {
  final String did;
  final String action;

  const ActionPanelConfirmationDialog({
    Key? key,
    required this.did,
    required this.action,
  }) : super(key: key);

  @override
  State<ActionPanelConfirmationDialog> createState() =>
      ActionPanelConfirmationDialogState();
}

class ActionPanelConfirmationDialogState
    extends State<ActionPanelConfirmationDialog> {
  bool passwordVisible = false;

  bool isLoading = false;

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
            width: 400,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.lock_rounded, size: 35),
                      const SizedBox(width: 8),
                      Text(
                        "Authentication",
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      )
                    ]),
                    const SizedBox(height: 20),
                    Text(
                      "Enter the device password to continue:",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (value) {
                        setState(() {});
                      },
                      controller: controller,
                      autofocus: true,
                      obscureText: !passwordVisible,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        labelText: "Password",
                        labelStyle: Theme.of(context).textTheme.bodyMedium,
                        suffixIcon: IconButton(
                          icon: Icon(passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(
                              () {
                                passwordVisible = !passwordVisible;
                              },
                            );
                          },
                        ),
                        alignLabelWithHint: false,
                        filled: true,
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: controller.text.isNotEmpty && !isLoading
                            ? () {
                                setState(() {
                                  isLoading = true;
                                });

                                // Build salted SHA-512 hash
                                Digest hash = md5.convert(utf8.encode(
                                    "${widget.did}-${widget.action}-${controller.text}"));
                                runActionOnDevice(widget.did, widget.action,
                                        hash.toString())
                                    .then((value) {
                                  setState(() {
                                    isLoading = false;
                                    Navigator.of(context).pop();
                                  });
                                });
                              }
                            : null,
                        child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: 50,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: isLoading
                                ? const LoadingWidget(size: 20, stroke: 2)
                                : const Text("Submit")))
                  ],
                ))));
  }
}
