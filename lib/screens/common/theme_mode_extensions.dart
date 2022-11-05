import 'package:easynotes/app_theme.dart';
import 'package:easynotes/screens/common/color_extension.dart';
import 'package:flutter/material.dart';

// courtesy Glider for Hackernews https://github.com/Mosc/Glider/tree/master/lib/utils
extension ThemeModeExtension on ThemeMode {
  String title(BuildContext context) {
    switch (this) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  Color color(BuildContext context) {
    switch (this) {
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness.isDark
            ? Colors.black
            : AppTheme.lightBackgroundColor;
      case ThemeMode.light:
        return AppTheme.lightBackgroundColor;
      case ThemeMode.dark:
        return Colors.black;
    }
  }
}
