import 'package:easynotes/screens/common/responsive.dart';
import 'package:flutter/material.dart';

class ToolbarButton extends StatelessWidget {
  const ToolbarButton(
      {super.key,
      this.onPressed,
      required this.iconData,
      required this.title,
      this.enabled = true,
      this.enabledColor = Colors.lightBlue});

  final Function()? onPressed;
  final bool enabled;
  final Color enabledColor;
  final IconData iconData;
  final String title;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      child: Row(
        children: [
          Icon(iconData,
              color: enabled ? enabledColor : Theme.of(context).disabledColor),
          const SizedBox(width: 4),
          if (!Responsive.isMobile(context))
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? enabledColor
                        : Theme.of(context).disabledColor)),
        ],
      ),
    );
  }
}
