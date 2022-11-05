import 'package:flutter/material.dart';

class SettingsDialog extends Dialog {
  const SettingsDialog({super.key, required Widget child})
      : super(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
            child: child);
}
