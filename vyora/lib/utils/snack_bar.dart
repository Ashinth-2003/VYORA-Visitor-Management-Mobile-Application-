import 'package:flutter/material.dart';

void showMessage(BuildContext context, String text, {bool isError = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
            color: isError ? Theme.of(context).colorScheme.error : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    ),
  );
}
