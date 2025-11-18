import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gradient_icon/gradient_icon.dart';
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

  static Widget wrapWithBadge({
    required Widget icon,
    required bool condition,
    required String label,
  }) {
    if (!condition) return icon;
    return Badge(label: Text(label), child: icon);
  }

  static Widget wrapWithGradient({
    required IconData icon,
    required bool condition,
    required List<Color> gradientColors,
    required Color color,
    required double size,
  }) {
    if (!condition) return Icon(icon, size: size, color: color);
    return GradientIcon(
      icon: icon,
      size: size,
      offset: Offset(0, 0),
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
