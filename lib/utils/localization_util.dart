import 'package:mchad/data/notifiers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocalizationUtil {
  static Future<AppLocalizations> get currentLocalization async {
    return await AppLocalizations.delegate.load(settingsNotifier.value.locale);
  }
}
