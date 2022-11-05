import 'package:easynotes/screens/common/responsive.dart';
import 'package:flutter/material.dart';

class ToolbarButton extends StatelessWidget {
  ToolbarButton(
      {super.key,
      this.onPressed,
      required this.iconData,
      this.title,
      this.enabled = true,
      this.small = false,
      Color? enabledColor})
      : enabledColor = enabledColor ?? Colors.white.withOpacity(1);

  final Function()? onPressed;
  final bool enabled;
  final Color? enabledColor;
  final IconData iconData;
  final String? title;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      child: Row(
        children: [
          Icon(iconData,
              size: small ? 16 : 20,
              color: enabled ? enabledColor : Theme.of(context).disabledColor),
          const SizedBox(width: 4),
          if (!Responsive.isMobile(context) && title != null)
            Text(title!,
                style: TextStyle(
                    fontSize: small ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: enabled
                        ? enabledColor
                        : Theme.of(context).disabledColor)),
        ],
      ),
    );
  }
}
