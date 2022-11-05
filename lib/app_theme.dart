import 'package:easynotes/screens/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  static final Color defaultColor = themeColors.first;
  static final Color surfaceColor = Colors.grey.withOpacity(0.15);
  static final Color errorColor = Colors.red.shade400;
  static const Color onErrorColor = Colors.white;
  static final Color lightBackgroundColor = Colors.grey.shade50;
  static final Color darkBackgroundColor = Colors.grey.shade900;
  static const Color blackBackgroundColor = Colors.black;
  static const Color spaceBackgroundColor = Color(0xff242933);
  static const TextStyle tallTextStyle = TextStyle(height: 1.25);

  static ThemeData lightTheme(Color color) =>
      _buildTheme(color, backgroundColor: lightBackgroundColor);

  static ThemeData darkTheme(Color color) =>
      _buildTheme(color, backgroundColor: darkBackgroundColor);

  static ThemeData blackTheme(Color color) =>
      _buildTheme(color, backgroundColor: blackBackgroundColor);

  static ThemeData spaceTheme(Color color) =>
      _buildTheme(color, backgroundColor: spaceBackgroundColor);

  static ThemeData _buildTheme(Color color, {required Color backgroundColor}) {
    final Brightness brightness =
        ThemeData.estimateBrightnessForColor(backgroundColor);
    final Brightness colorBrightness =
        ThemeData.estimateBrightnessForColor(color);
    final Color onColor = colorBrightness.isDark ? Colors.white : Colors.black;
    final Color canvasColor = backgroundColor.lighten(0.05);
    final Color appBarBackgroundColor =
        brightness.isDark ? backgroundColor : color;
    final bool appBarIsDark = brightness.isDark || colorBrightness.isDark;
    const bool useGestures = true;

    return ThemeData(
      brightness: brightness,
      visualDensity: VisualDensity.standard,
      colorScheme: brightness.isDark
          ? ColorScheme.dark(
              primary: color,
              secondary: color,
              surface: surfaceColor,
              error: errorColor,
              onPrimary: onColor,
              onSecondary: onColor,
              onError: onErrorColor,
            )
          : ColorScheme.light(
              primary: color,
              secondary: color,
              surface: surfaceColor,
              error: errorColor,
              onPrimary: onColor,
              onSecondary: onColor,
              // ignore: avoid_redundant_argument_values
              onError: onErrorColor,
            ),
      canvasColor: canvasColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: canvasColor,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: const TextTheme(
        displayLarge: tallTextStyle,
        displayMedium: tallTextStyle,
        displaySmall: tallTextStyle,
        headlineLarge: tallTextStyle,
        headlineMedium: tallTextStyle,
        headlineSmall: tallTextStyle,
        titleLarge: tallTextStyle,
        titleMedium: tallTextStyle,
        titleSmall: tallTextStyle,
        bodyLarge: tallTextStyle,
        bodyMedium: tallTextStyle,
        bodySmall: tallTextStyle,
      ),
      pageTransitionsTheme: useGestures ? null : null,
      dialogBackgroundColor: canvasColor,
      toggleableActiveColor: color,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackgroundColor,
        iconTheme: IconThemeData(
          color: brightness.isDark ? Colors.white : onColor,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: appBarBackgroundColor,
          statusBarBrightness:
              appBarIsDark ? Brightness.dark : Brightness.light,
          statusBarIconBrightness:
              appBarIsDark ? Brightness.light : Brightness.dark,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        textTheme: ButtonTextTheme.primary,
      ),
      chipTheme: ChipThemeData.fromDefaults(
        brightness: brightness,
        secondaryColor: color,
        labelStyle: const TextStyle(),
      ).copyWith(
        backgroundColor: backgroundColor,
        selectedColor: surfaceColor,
        side: MaterialStateBorderSide.resolveWith(
          (Set<MaterialState> states) => BorderSide(
            color:
                states.contains(MaterialState.selected) ? color : surfaceColor,
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        valueIndicatorTextStyle: TextStyle(
          color: brightness.isDark ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
