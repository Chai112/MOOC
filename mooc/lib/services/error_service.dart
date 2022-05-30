import 'package:flutter/material.dart';
import 'package:mooc/services/networking_service.dart' as networking_service;

void reportError(
    networking_service.NetworkingException error, BuildContext context) {
  if (!error.expandError) return;
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(error.message),
      content: SizedBox(
          height: 250,
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
