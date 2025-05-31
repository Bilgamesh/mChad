import 'package:mchad/data/notifiers.dart';
import 'package:mchad/jobs/mchat/mchat_sync.dart';
import 'package:mchad/utils/logging_util.dart';
import 'package:mchad/data/globals.dart' as globals;

var logger = LoggingUtil(module: 'mchat_global_sync');

class MchatSyncManager {
  bool loadingArchive = false;
  bool isRunning = false;

  void startAll() {
    if (isRunning) throw 'All syncs are already running';
    logger.info('Startinc all syncs');
    for (var account in accountsNotifier.value) {
      var sync = MchatSync(account: account);
      globals.syncs.add(sync);
      sync.startAll();
    }
    isRunning = true;
  }

  void stopAll() {
    if (!isRunning) throw 'No sync is currently running';
    logger.info('Stopping all syncs');
    for (var sync in globals.syncs) {
      sync.stop();
    }
    globals.syncs.clear();
    isRunning = false;
  }

  void restartAll() {
    logger.info('Initiating restart of all syncs');
    try {
      stopAll();
    } catch (e) {
      logger.error(e.toString());
    }
    try {
      startAll();
    } catch (e) {
      logger.error(e.toString());
    }
  }

  Future<MchatSync> get sync async {
    var accountIndex = await selectedAccountNotifier.value?.getIndex();
    if (accountIndex == null) {
      throw 'Failed to get synchronizer due to missing account';
    }
    var sync = globals.syncs.elementAtOrNull(accountIndex);
    if (sync == null) {
      throw 'No synchronizers found';
    }
    return sync;
  }
}
