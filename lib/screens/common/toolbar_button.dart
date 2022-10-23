import 'package:flutter/material.dart';

class ToolbarButton extends StatelessWidget {
  const ToolbarButton(
      {super.key,
      this.onPressed,
      required this.iconData,
      required this.title,
      this.enabled = true});

  final Function()? onPressed;
  final bool enabled;
  final IconData iconData;
  final String title;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      child: Row(
        children: [
          Icon(iconData,
              color:
                  enabled ? Colors.white70 : Theme.of(context).disabledColor),
          const SizedBox(width: 4),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: enabled
                      ? Colors.white70
                      : Theme.of(context).disabledColor)),
        ],
      ),
    );
  }
}
