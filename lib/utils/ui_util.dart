import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mchad/data/constants.dart';

class UiUtil {
  static double getBottomSafeAreaHeight(BuildContext context, bool withNavbar) {
    var inset = MediaQuery.of(context).viewInsets.bottom;
    var padding = withNavbar ? MediaQuery.of(context).viewPadding.bottom : 0;
    var height =
        inset -
        padding -
        (withNavbar ? KNavigationBarStyle.navigationBarHeight : 0);
    return height > 0 ? height : 0;
  }

  static bool get isSystemDarkMode {
    return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }
}
