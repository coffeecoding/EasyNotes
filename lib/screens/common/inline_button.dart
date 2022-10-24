import 'package:flutter/material.dart';

class InlineButton extends StatelessWidget {
  InlineButton(
      {super.key,
      this.onPressed,
      required this.iconData,
      this.enabled = true,
      Color? enabledColor})
      : enabledColor = enabledColor ?? Colors.white;

  final Function()? onPressed;
  final bool enabled;
  final Color? enabledColor;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: IconButton(
        iconSize: 20,
        padding: EdgeInsets.zero,
        splashRadius: 1,
        style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
        onPressed: enabled ? onPressed : null,
        icon: Icon(iconData,
            color: enabled ? enabledColor : Theme.of(context).disabledColor),
      ),
    );
  }
}
