import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24),
      child: Text(text,
          textAlign: TextAlign.left,
          style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.white70)),
    );
  }
}
