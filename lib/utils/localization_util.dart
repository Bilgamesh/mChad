import 'dart:io';

import 'package:mchad/data/notifiers.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';
import 'package:mchad/utils/logging_util.dart';

final logger = LoggingUtil(module: 'localization_util');

class LocalizationUtil {
  static Future<AppLocalizations> get currentLocalization async {
    return await AppLocalizations.delegate.load(settingsNotifier.value.locale);
  }

  static int get systemLanguageIndex {
    final index = AppLocalizations.supportedLocales.indexWhere(
      (locale) => locale.languageCode == Platform.localeName.split('_').first,
    );
    if (index != -1) return index;
    logger.error('Could not detect system language');
    return 0;
  }
}
