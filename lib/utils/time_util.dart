import 'package:flutter/widgets.dart';
import 'package:mchad/utils/localization_util.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';

class TimeUtil {
  static Future<String> convertToAgo(DateTime input) async {
    Duration diff = DateTime.now().difference(input);
    final l10n = await LocalizationUtil.currentLocalization;

    if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} ${diff.inSeconds == 1
          ? l10n.secondAgo
          : diff.inSeconds >= 2 && diff.inSeconds <= 4
          ? l10n.secondsAgo
          : l10n.secondsAgo2}';
    } else {
      return l10n.justNow;
    }
  }

  static String convertToAgoSync(DateTime input, BuildContext context) {
    Duration diff = DateTime.now().difference(input);
    final l10n = AppLocalizations.of(context);

    if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} ${diff.inSeconds == 1
          ? l10n.secondAgo
          : diff.inSeconds >= 2 && diff.inSeconds <= 4
          ? l10n.secondsAgo
          : l10n.secondsAgo2}';
    } else {
      return l10n.justNow;
    }
  }

  static bool isTimeLimitExceeded({required int timeMs, required int limitMs}) {
    return (DateTime.now().millisecondsSinceEpoch - timeMs) >= limitMs;
  }
}
