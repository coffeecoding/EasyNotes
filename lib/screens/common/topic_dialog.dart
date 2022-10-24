import 'package:flutter/material.dart';

class TopicDialog extends Dialog {
  const TopicDialog({super.key, required Widget child})
      : super(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
            child: child);
}
