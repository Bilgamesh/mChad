import 'package:flutter/widgets.dart';
import 'package:mchad/utils/localization_util.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';

class TimeUtil {
  static Future<String> convertToAgo(DateTime input) async {
    Duration diff = DateTime.now().difference(input);
    var localization = await LocalizationUtil.currentLocalization;

    if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} ${diff.inSeconds == 1
          ? localization.secondAgo
          : diff.inSeconds >= 2 && diff.inSeconds <= 4
          ? localization.secondsAgo
          : localization.secondsAgo2}';
    } else {
      return localization.justNow;
    }
  }

  static String convertToAgoSync(DateTime input, BuildContext context) {
    Duration diff = DateTime.now().difference(input);
    var localization = AppLocalizations.of(context);

    if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} ${diff.inSeconds == 1
          ? localization.secondAgo
          : diff.inSeconds >= 2 && diff.inSeconds <= 4
          ? localization.secondsAgo
          : localization.secondsAgo2}';
    } else {
      return localization.justNow;
    }
  }
}
