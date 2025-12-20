import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/settings_model.dart';

class UiUtil {
  static double getBottomSafeAreaHeight(BuildContext context, bool withNavbar) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final padding = withNavbar ? MediaQuery.of(context).viewPadding.bottom : 0;
    final height =
        inset -
        padding -
        (withNavbar ? KNavigationBarStyle.navigationBarHeight : 0);
    return height > 0 ? height : 0;
  }

  static bool get isSystemDarkMode {
    return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  static void refreshStatusBarTheme(SettingsModel settings) {
    final oppositeBrightness =
        settings.isDark ? Brightness.light : Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemStatusBarContrastEnforced: false,
        statusBarIconBrightness: oppositeBrightness,
        systemNavigationBarIconBrightness: oppositeBrightness,
        statusBarBrightness: oppositeBrightness,
      ),
    );
  }
}
