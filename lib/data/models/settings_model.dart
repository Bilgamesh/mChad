import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/data/stores/settings_store.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsModel {
  SettingsModel({
    required this.colorIndex,
    required this.isDark,
    required this.notifications,
    required this.haptics,
    required this.languageIndex,
    required this.transitionAnimations,
  }) : colorScheme = ColorScheme.fromSeed(
         seedColor: KAppTheme.appColors.elementAt(colorIndex),
         brightness: isDark ? Brightness.dark : Brightness.light,
       );
  int colorIndex;
  bool isDark;
  bool notifications;
  bool haptics;
  bool transitionAnimations;
  int languageIndex;
  ColorScheme colorScheme;

  static SettingsModel fromString(String strinfigiedTheme) {
    var props = List<String>.from(jsonDecode(strinfigiedTheme));
    return SettingsModel(
      colorIndex: int.tryParse(props.elementAtOrNull(0) ?? '0') ?? 0,
      isDark: props.elementAtOrNull(1) == 'true',
      notifications: props.elementAtOrNull(2) == 'true',
      haptics: props.elementAtOrNull(3) == 'true',
      languageIndex: int.tryParse(props.elementAtOrNull(4) ?? '0') ?? 0,
      transitionAnimations: props.elementAtOrNull(5) == 'true',
    );
  }

  Locale get locale {
    return AppLocalizations.supportedLocales[languageIndex];
  }

  static SettingsModel getDefault() {
    return SettingsModel(
      colorIndex: 0,
      isDark:
          SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark,
      notifications: false,
      haptics: false,
      languageIndex: AppLocalizations.supportedLocales.indexWhere(
        (locale) => locale.languageCode == Platform.localeName.split('_').first,
      ),
      transitionAnimations: true,
    );
  }

  @override
  String toString() {
    return jsonEncode(<String>[
      colorIndex.toString(),
      isDark ? 'true' : 'false',
      notifications ? 'true' : 'false',
      haptics ? 'true' : 'false',
      languageIndex.toString(),
      transitionAnimations ? 'true' : 'false',
    ]);
  }

  Future<SettingsModel> save() async {
    var store = await SettingsStore.getInstance();
    store.setSettings(this);
    return apply();
  }

  SettingsModel updateColorScheme() {
    colorScheme = ColorScheme.fromSeed(
      seedColor: KAppTheme.appColors.elementAt(colorIndex),
      brightness: isDark ? Brightness.dark : Brightness.light,
    );
    return this;
  }

  SettingsModel setDarkMode(bool value) {
    isDark = value;
    updateColorScheme();
    return this;
  }

  SettingsModel setColorIndex(int index) {
    colorIndex = index;
    updateColorScheme();
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

  SettingsModel apply() {
    settingsNotifier.value = this;
    settingsNotifier.notifyListeners();
    return this;
  }
}
