import 'package:flutter/material.dart';

class InlineCircularProgressIndicator extends StatelessWidget {
  const InlineCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 20,
        width: 36,
        child: const CircularProgressIndicator(
          strokeWidth: 1,
        ));
  }
}
