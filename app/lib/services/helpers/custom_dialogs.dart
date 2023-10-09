import 'package:flutter/material.dart';
import 'package:melotune/utils/strings.dart';

class CustomDialogs {
  static Future showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required Function() onConfirm,
    required Color buttonColor,
  }) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child:  Text(KStrings.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
            child:  Text(
              KStrings.confirm,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}