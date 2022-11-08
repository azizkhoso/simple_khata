import 'package:flutter/material.dart';

void addToast(
    {required BuildContext context, required String message, String? type}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 5),
    backgroundColor: type == 'error' ? Colors.red[800] : Colors.green[800],
  ));
}
