import 'package:flutter/material.dart';
import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/style/widgets/scholarly_text_field.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void reportError(
    networking_service.NetworkingException error, BuildContext context) {
  if (!error.expandError) return;
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(error.message),
      content: SizedBox(
          width: 250,
          child: Text(error.description ?? "No description given.")),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Dismiss'),
        ),
      ],
    ),
  );
}

class Alert {
  String title, description, buttonName, prefillInputText;
  bool acceptInput;
  Function(String input) callback;
  Alert(
      {required this.title,
      required this.description,
      required this.buttonName,
      required this.callback,
      this.prefillInputText = "",
      this.acceptInput = false}) {
    _alertInputController.text = prefillInputText;
  }
}

Alert? alertQueued;
bool isRunningAlert = false;
void alert(Alert alertMessage) {
  alertQueued = alertMessage;
}

final _alertInputController = ScholarlyTextFieldController();

// stupid code
// delete later maybe
void checkAlerts(BuildContext bc) async {
  if (alertQueued != null && !isRunningAlert) {
    isRunningAlert = true;
    await Future.delayed(Duration(milliseconds: 100), () {});
    showDialog<String>(
      context: bc,
      builder: (BuildContext context) => AlertDialog(
        title: Text(alertQueued!.title),
        content: SizedBox(
            width: 250,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alertQueued!.description),
                SizedBox(height: 20),
                alertQueued!.acceptInput
                    ? ScholarlyTextField(
                        label: "", controller: _alertInputController)
                    : Container(),
              ],
            )),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              alertQueued!.callback(_alertInputController.text);
              isRunningAlert = false;
              alertQueued = null;
              Navigator.pop(context);
            },
            child: Text(alertQueued!.buttonName),
          ),
          TextButton(
            onPressed: () {
              isRunningAlert = false;
              alertQueued = null;
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
