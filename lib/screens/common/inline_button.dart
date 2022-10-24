import 'package:flutter/material.dart';

class InlineButton extends StatelessWidget {
  InlineButton(
      {super.key,
      this.onPressed,
      required this.iconData,
      this.enabled = true,
      this.small = false,
      Color? enabledColor})
      : enabledColor = enabledColor ?? Colors.white;

  final Function()? onPressed;
  final bool enabled;
  final Color? enabledColor;
  final IconData iconData;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: small ? 24 : 32,
      child: IconButton(
        iconSize: small ? 12 : 20,
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
