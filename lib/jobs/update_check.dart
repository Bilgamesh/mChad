import 'dart:async';

import 'package:mchad/data/constants.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/services/github/github_update_service.dart';
import 'package:mchad/utils/logging_util.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateCheck {
  UpdateCheck({required this.endpoint})
    : logger = LoggingUtil(module: 'update_job'),
      stopped = false,
      index = 0;

  final String endpoint;
  final LoggingUtil logger;
  Timer? timer;
  int index;
  bool stopped;

  Future<void> onTick() async {
    try {
      logger.info('Start tick');

      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final updateAvailable = await GithubUpdateService(
        endpoint: endpoint,
      ).isNewVersionAvailable(packageInfo.version);

      if (updateAvailable) {
        updateNotifier.value = UpdateStatus.available;
      } else {
        updateNotifier.value = UpdateStatus.none;
      }

      index++;
    } catch (e) {
      logger.error('Tick failed due to error: $e');
    } finally {
      if (!stopped) {
        timer = Timer(
          const Duration(seconds: KTimerConfig.updateCheckIntervalSeconds),
          onTick,
        );
      }
    }
  }

  Future<void> startCheck() async {
    if (index != 0) throw 'Can\'t start check which has already started';
    logger.info('Starting check');
    if (index == 0) await onTick();
  }

  void stopCheck() {
    logger.info('Stopping check');
    if (timer == null) throw 'Can\'t stop check that has not started';
    timer!.cancel();
    index = 0;
    stopped = true;
  }
}
