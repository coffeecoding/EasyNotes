import 'package:flutter/material.dart';

class InlineCircularProgressIndicator extends StatelessWidget {
  const InlineCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 1,
        ));
  }
}
