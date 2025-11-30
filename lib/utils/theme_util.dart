import 'package:flutter/material.dart';

class ThemeUtil {
  static ThemeData createTheme({
    required ColorScheme colorScheme,
    TextTheme Function([TextTheme? textTheme])? textThemeBuilder,
  }) {
    final baseThemeData = ThemeData(colorScheme: colorScheme);
    if (textThemeBuilder == null) return baseThemeData;
    return baseThemeData.copyWith(
      textTheme: textThemeBuilder(baseThemeData.textTheme),
    );
  }

  static ColorScheme getRegularColorScheme(Color seedColor, bool dark) {
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: dark ? Brightness.dark : Brightness.light,
    );
  }

  static ColorScheme getLowContrastColorScheme(Color seedColor, bool dark) {
    final scheme = getRegularColorScheme(seedColor, dark);
    return scheme.copyWith(
      surface: scheme.surfaceContainer,
      surfaceContainer: scheme.surfaceContainerHigh,
    );
  }
}
