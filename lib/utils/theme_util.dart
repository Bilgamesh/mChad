import 'package:flutter/material.dart';

class ThemeUtil {
  static ColorScheme getRegularColorScheme(Color seedColor, bool dark) {
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: dark ? Brightness.dark : Brightness.light,
    );
  }

  static ColorScheme getLowContrastColorScheme(Color seedColor, bool dark) {
    final scheme = getRegularColorScheme(seedColor, dark);
    return scheme.copyWith(surface: scheme.surfaceContainerLow);
  }
}
