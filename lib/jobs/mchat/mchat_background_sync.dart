import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as flutter_local_notifications;
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/data/stores/account_store.dart';
import 'package:mchad/data/stores/settings_store.dart';
import 'package:mchad/services/mchat/mchat_chat_service.dart';
import 'package:mchad/services/notifications/notifications_service.dart';
import 'package:mchad/utils/logging_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mchad/data/globals.dart' as globals;

final logger = LoggingUtil(module: 'background_sync');

@pragma('vm:entry-point')
class BackgroundSync {
  @pragma('vm:entry-point')
  static Future<void> backgroundFetchHeadlessTask(HeadlessTask task) async {
    String taskId = task.taskId;
    bool isTimeout = task.timeout;
    if (isTimeout) {
      logger.info('[BackgroundFetch] Headless task timed-out: $taskId');
      BackgroundFetch.finish(taskId);
      return;
    }
    logger.info('[BackgroundFetch] Headless event received.');
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('block_app', true);
    try {
      final accountStore = AccountStore(prefs: prefs);
      final accounts = accountStore.all;
      final settings = await SettingsStore(prefs: prefs).getSettings();
      for (var account in accounts) {
        try {
          final chatService = MchatChatService(account: account);
          final mainPage = await chatService.fetchMainPage();
          final latestSavedMessageId = await Message.getLatestId(account);
          final newMessages =
              mainPage.messages
                  ?.where((message) => message.id > latestSavedMessageId)
                  .toList();
          if (newMessages != null) {
            if (settings.notifications) {
              await NotificationsService.initialize();
              await NotificationsService(account: account).notify(newMessages);
            }
            await newMessages.lastOrNull?.saveAsLatest(account);
          }
        } catch (e) {
          logger.error(e.toString());
        }
      }
    } catch (e) {
      logger.error(e.toString());
    } finally {
      prefs.setBool('block_app', false);
      BackgroundFetch.finish(taskId);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> notificationTapBackground(
    flutter_local_notifications.NotificationResponse notificationResponse,
  ) async {
    final accountIndex = int.parse(notificationResponse.payload ?? '0');
    final accountStore = await AccountStore.getInstance();
    final account = accountStore.get(accountIndex);
    account.select();
    await account.save();
  }

  static Future<void> backgroundFetchTask(String taskId) async {
    try {
      logger.info('[BackgroundFetch] Event received $taskId');

      if (globals.background) {
        globals.blocked = true;
        final prefs = await SharedPreferences.getInstance();
        final accountStore = AccountStore(prefs: prefs);
        final accounts = accountStore.all;
        final settings = await SettingsStore(prefs: prefs).getSettings();

        for (var account in accounts) {
          try {
            final chatService = MchatChatService(account: account);
            final mainPage = await chatService.fetchMainPage();
            final existingMessages =
                messageMapNotifier.value[account] ?? <Message>[];
            final newMessages =
                mainPage.messages
                    ?.where((message) => !existingMessages.contains(message))
                    .toList();
            if (newMessages != null && settings.notifications) {
              await NotificationsService(account: account).notify(newMessages);
            }
          } catch (e) {
            logger.error(e.toString());
          }
        }
      }
    } catch (e) {
      logger.error(e.toString());
    } finally {
      globals.blocked = false;
      BackgroundFetch.finish(taskId);
    }
  }

  static Future<void> backgroundFetchTimeout(String taskId) async {
    logger.info('[BackgroundFetch] TASK TIMEOUT taskId: $taskId');
    BackgroundFetch.finish(taskId);
  }
}
