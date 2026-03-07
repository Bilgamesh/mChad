import 'package:flutter/material.dart';
import 'package:mchad/data/state/notifiers.dart';
import 'package:mchad/data/state/globals.dart' as globals;
import 'package:background_fetch/background_fetch.dart';
import 'package:mchad/data/persistent-stores/account_store.dart';
import 'package:mchad/data/persistent-stores/settings_store.dart';
import 'package:mchad/jobs/mchat/mchat_background_sync.dart';
import 'package:mchad/services/lifecycle/lifecycle_service.dart';
import 'package:mchad/services/notifications/notifications_service.dart';
import 'package:mchad/utils/logging_util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:system_theme/system_theme.dart';

final logger = LoggingUtil(module: 'app_initialization');

class AppInitializationData {
  AppInitializationData({required this.isLoggedIn});
  final bool isLoggedIn;
}

Future<AppInitializationData> initApp() async {
  initializeDateFormatting();
  await initSettings();
  await initPackageInfo();

  final prefs = await SharedPreferences.getInstance();
  await waitForUnblock(prefs);
  final accountStore = AccountStore(prefs: prefs);
  final accounts = accountStore.all;

  for (var account in accounts) {
    account.updateNotifiers();
    if (account.wasPreviouslySelected == true) account.select();
  }

  await initBackgroundFetch();
  NotificationsService.initialize();

  globals.syncManager.startAll();
  globals.updateCheck.startCheck();

  LifecycleService().addListener((AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        globals.syncManager.stopAll();
        globals.updateCheck.stopCheck();
        globals.background = true;
        break;
      default:
        globals.syncManager.startAll();
        globals.updateCheck.startCheck();
        globals.background = false;
    }
  }).startListening();

  selectedTabNotifier.addListener(() {
    chatScrollOffsetNotifier.value = 0;
  });

  return AppInitializationData(isLoggedIn: accounts.isNotEmpty);
}

Future<void> waitForUnblock(SharedPreferences prefs) async {
  var count = 0;
  while (count++ < 5 && (prefs.getBool('block_app') ?? false)) {
    await Future.delayed(Duration(seconds: 1));
  }
  prefs.setBool('block_app', false);
}

Future<void> initSettings() async {
  final settingsStore = await SettingsStore.getInstance();
  final settings = await settingsStore.getSettings();
  SystemTheme.fallbackColor = settings.colors[0];
  await SystemTheme.accentColor.load();
  settings.apply();
}

Future<void> initPackageInfo() async {
  final packageInfo = await PackageInfo.fromPlatform();
  packageInfoNotifier.value = packageInfo;
}

Future<void> initBackgroundFetch() async {
  int status = await BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 15,
      stopOnTerminate: false,
      enableHeadless: true,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresStorageNotLow: false,
      requiresDeviceIdle: false,
      requiredNetworkType: NetworkType.ANY,
    ),
    BackgroundSync.backgroundFetchTask,
    BackgroundSync.backgroundFetchTimeout,
  );
  BackgroundFetch.registerHeadlessTask(
    BackgroundSync.backgroundFetchHeadlessTask,
  );
  logger.info('[BackgroundFetch] configure success: $status');
}
