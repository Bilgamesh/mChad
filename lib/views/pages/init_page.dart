import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:mchad/data/stores/account_store.dart';
import 'package:mchad/data/stores/settings_store.dart';
import 'package:mchad/jobs/mchat/mchat_background_sync.dart';
import 'package:mchad/services/lifecycle/lifecycle_service.dart';
import 'package:mchad/services/notifications/notifications_service.dart';
import 'package:mchad/utils/logging_util.dart';
import 'package:mchad/views/pages/login_page.dart';
import 'package:mchad/views/pages/tabs_page.dart';
import 'package:mchad/views/widgets/loading_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mchad/data/globals.dart' as globals;

final logger = LoggingUtil(module: 'init_page');

class InitPage extends StatelessWidget {
  const InitPage({Key? key}) : super(key: key);

  Future<void> initApp(BuildContext context) async {
    initializeDateFormatting();
    initSettings();

    var prefs = await SharedPreferences.getInstance();
    var accountStore = AccountStore(prefs: prefs);
    var accounts = accountStore.getAll();

    for (var account in accounts) {
      account.updateNotifiers();
      if (account.wasPreviouslySelected == true) account.select();
    }

    await initBackgroundFetch();
    NotificationsService.initialize();

    globals.syncManager.startAll();
    globals.updateCheck.startCheck();

    LifecycleService().addListener(() {
      final state = WidgetsBinding.instance.lifecycleState;
      if (state == AppLifecycleState.paused) {
        globals.syncManager.stopAll();
        globals.updateCheck.stopCheck();
        globals.background = true;
      } else if (state == AppLifecycleState.resumed) {
        globals.syncManager.startAll();
        globals.updateCheck.startCheck();
        globals.background = false;
      }
    }).startListening();

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => accounts.isNotEmpty ? TabsPage() : LoginPage(),
      ),
    );
  }

  Future<void> initSettings() async {
    var settingsStore = await SettingsStore.getInstance();
    var settings = await settingsStore.getSettings();
    settings.apply();
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

  @override
  Widget build(BuildContext context) {
    if (!globals.appInitialized) {
      initApp(context);
      globals.appInitialized = true;
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: LoadingWidget(),
      ),
    );
  }
}
