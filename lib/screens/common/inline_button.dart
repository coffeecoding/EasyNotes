import 'package:flutter/material.dart';

class InlineButton extends StatelessWidget {
  InlineButton(
      {super.key,
      this.onPressed,
      required this.iconData,
      this.enabled = true,
      Color? enabledColor})
      : enabledColor = enabledColor ?? Colors.lightBlue.shade300;

  final Function()? onPressed;
  final bool enabled;
  final Color? enabledColor;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 1,
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
      onPressed: enabled ? onPressed : null,
      icon: Icon(iconData,
          color: enabled ? enabledColor : Theme.of(context).disabledColor),
    );
  }
}
