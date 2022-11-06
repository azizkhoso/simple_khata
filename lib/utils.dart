import 'package:flutter/material.dart';

int counter = 0;

void addToast(
    {required BuildContext context, required String message, String? type}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 5),
    backgroundColor: type == 'error' ? Colors.red[800] : Colors.green[800],
  ));
  debugPrint({"couter": counter++}.toString());
}
