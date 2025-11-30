import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/data/stores/settings_store.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';
import 'package:mchad/utils/localization_util.dart';
import 'package:mchad/utils/theme_util.dart';
import 'package:mchad/utils/ui_util.dart';
import 'package:system_theme/system_theme.dart';

class SettingsModel {
  SettingsModel({
    required this.colorIndex,
    required this.isDark,
    required this.notifications,
    required this.haptics,
    required this.languageIndex,
    required this.transitionAnimations,
    required this.openLinksInBrowser,
    required this.lowContrastBackground,
  });
  int colorIndex;
  bool isDark;
  bool notifications;
  bool haptics;
  bool transitionAnimations;
  bool openLinksInBrowser;
  bool lowContrastBackground;
  int languageIndex;

  static SettingsModel fromString(String strinfigiedSettings) {
    final props = List<String>.from(jsonDecode(strinfigiedSettings));
    return SettingsModel(
      colorIndex: int.tryParse(props.elementAtOrNull(0) ?? '0') ?? 0,
      isDark: props.elementAtOrNull(1) == 'true',
      notifications: props.elementAtOrNull(2) == 'true',
      haptics: props.elementAtOrNull(3) == 'true',
      languageIndex: int.tryParse(props.elementAtOrNull(4) ?? '0') ?? 0,
      transitionAnimations: props.elementAtOrNull(5) == 'true',
      openLinksInBrowser: props.elementAtOrNull(6) == 'true',
      lowContrastBackground: props.elementAtOrNull(7) == 'true',
    );
  }

  Locale get locale {
    return AppLocalizations.supportedLocales[languageIndex];
  }

  static SettingsModel get defaultSettings {
    return SettingsModel(
      colorIndex: 0,
      isDark: UiUtil.isSystemDarkMode,
      notifications: false,
      haptics: false,
      languageIndex: LocalizationUtil.systemLanguageIndex,
      transitionAnimations: true,
      openLinksInBrowser: false,
      lowContrastBackground: false,
    );
  }

  @override
  String toString() {
    return jsonEncode(<String>[
      colorIndex.toString(),
      isDark.toString(),
      notifications.toString(),
      haptics.toString(),
      languageIndex.toString(),
      transitionAnimations.toString(),
      openLinksInBrowser.toString(),
      lowContrastBackground.toString(),
    ]);
  }

  Future<SettingsModel> save() async {
    final store = await SettingsStore.getInstance();
    store.setSettings(this);
    return apply();
  }

  List<Color> get colors {
    final colors = [...KAppTheme.appColors];
    colors[0] = SystemTheme.accentColor.accent.withAlpha(255);
    return colors;
  }

  ColorScheme get colorScheme {
    if (lowContrastBackground) {
      return ThemeUtil.getLowContrastColorScheme(
        colors.elementAt(colorIndex),
        isDark,
      );
    } else {
      return ThemeUtil.getRegularColorScheme(
        colors.elementAt(colorIndex),
        isDark,
      );
    }
  }

  SettingsModel setDarkMode(bool value) {
    isDark = value;
    return this;
  }

  SettingsModel setColorIndex(int index) {
    colorIndex = index;
    return this;
  }

  SettingsModel setNotifications(bool value) {
    notifications = value;
    return this;
  }

  SettingsModel setLanguage(int languageIndex) {
    this.languageIndex = languageIndex;
    return this;
  }

  SettingsModel setHaptics(bool value) {
    haptics = value;
    return this;
  }

  SettingsModel setTransitionAnimations(bool value) {
    transitionAnimations = value;
    return this;
  }

  SettingsModel setOpenLinksInBrowser(bool value) {
    openLinksInBrowser = value;
    return this;
  }

  SettingsModel setLowContrastBackground(bool value) {
    lowContrastBackground = value;
    return this;
  }

  SettingsModel apply() {
    settingsNotifier.value = this;
    settingsNotifier.notifyListeners();
    return this;
  }
}
