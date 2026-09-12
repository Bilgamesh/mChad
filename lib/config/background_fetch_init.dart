import 'package:background_fetch/background_fetch.dart';
import 'package:mchad/jobs/mchat/mchat_background_sync.dart';

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
