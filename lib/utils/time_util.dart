import 'package:mchad/data/notifiers.dart';

class TimeUtil {
  static String convertToAgo(DateTime input) {
    Duration diff = DateTime.now().difference(input);

    if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} ${diff.inSeconds == 1 ? languageNotifier.value.secondAgo : languageNotifier.value.secondsAgo}';
    } else {
      return languageNotifier.value.justNow;
    }
  }
}
