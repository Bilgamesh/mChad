import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    return child!;
  }
}

class ThemeUtil {
  static ThemeData createTheme({
    required ColorScheme colorScheme,
    required bool animations,
    TextTheme Function([TextTheme? textTheme])? textThemeBuilder,
  }) {
    final oppositeBrightness =
        colorScheme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark;
    final sameBrightness =
        colorScheme.brightness == Brightness.dark
            ? Brightness.dark
            : Brightness.light;
    var baseThemeData = ThemeData(
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
          systemStatusBarContrastEnforced: false,
          statusBarIconBrightness: Platform.isAndroid ? oppositeBrightness : sameBrightness,
          systemNavigationBarIconBrightness: Platform.isAndroid ? oppositeBrightness : sameBrightness,
        ),
      ),
    );
    if (!animations) {
      baseThemeData = baseThemeData.copyWith(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {TargetPlatform.android: _NoTransitionsBuilder()},
        ),
      );
    }
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
