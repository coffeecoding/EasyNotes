import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static Iterable<Color> get themeColors => Colors.primaries.map(
        (MaterialColor materialColor) => <int>[300, 400, 500, 600]
            .map((int shade) => materialColor[shade]!)
            .firstWhere(
              (Color color) =>
                  ThemeData.estimateBrightnessForColor(color) ==
                  Brightness.dark,
              orElse: () => materialColor.shade700,
            ),
      );
}
