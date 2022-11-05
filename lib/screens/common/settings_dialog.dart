import 'package:flutter/material.dart';

class SettingsDialog extends Dialog {
  SettingsDialog({super.key, required Widget child})
      : super(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
            child: SizedBox(width: 400, height: 500, child: child));
}
