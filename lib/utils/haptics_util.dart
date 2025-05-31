import 'package:flutter/services.dart';
import 'package:mchad/data/notifiers.dart';

class HapticsUtil {
  static Future<void> vibrate() async {
    if (settingsNotifier.value.haptics) {
      await HapticFeedback.heavyImpact();
    }
  }

}
