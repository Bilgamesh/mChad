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
    var baseThemeData = ThemeData(
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
          systemStatusBarContrastEnforced: false
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
