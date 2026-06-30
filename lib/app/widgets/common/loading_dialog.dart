import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String message;
  static bool _isShowing = false;

  const LoadingDialog({super.key, this.message = 'Please wait...'});

  static void show(BuildContext context, {String message = 'Please wait...'}) {
    if (_isShowing) return;
    _isShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => LoadingDialog(message: message),
    ).then((_) => _isShowing = false);
  }

  static void hide(BuildContext context) {
    if (_isShowing) {
      Navigator.of(context, rootNavigator: true).pop();
      _isShowing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 24),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
