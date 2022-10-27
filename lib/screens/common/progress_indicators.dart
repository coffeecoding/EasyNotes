import 'package:flutter/material.dart';

class InlineCircularProgressIndicator extends StatelessWidget {
  const InlineCircularProgressIndicator({
    super.key,
    this.color,
  });

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 20,
        width: 36,
        child: CircularProgressIndicator(
          strokeWidth: 1,
          color: color,
        ));
  }
}
