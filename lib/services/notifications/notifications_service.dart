import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart' as message_model;
import 'package:mchad/utils/logging_util.dart';

final logger = LoggingUtil(module: 'notifications_service');

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
bool notificationsInitialized = false;

class NotificationsService {
  NotificationsService({required this.account});
  final Account account;

  static Future<void> initialize() async {
    if (notificationsInitialized) return;
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(KNotificationsConfig.icon);
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    notificationsInitialized = true;
  }

  static Future<bool> get notificationsEnabled async {
    return await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled() ??
        false;
  }

  static Future<bool> requestPermission() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    return await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;
  }

  Future<void> notify(List<message_model.Message> messages) async {
    if (!notificationsInitialized) throw 'Notifications not initialized';
    if (messages.lastOrNull?.user.id == account.userId) {
      logger.info(
        'Skipping notification from ${account.forumName} as last message came from the user',
      );
      return;
    }
    final lastMessages =
        messages.reversed
            .take(KNotificationsConfig.maxNotificationMessages)
            .toList();
    if (lastMessages.isEmpty) {
      logger.info('Skipping notification due to 0 messages');
      return;
    }
    for (var message in lastMessages) {
      message.notify();
    }

    final accountIndex = await account.getIndex();

    await flutterLocalNotificationsPlugin.show(
      accountIndex,
      null,
      null,
      NotificationDetails(
        android: AndroidNotificationDetails(
          KNotificationsConfig.channelId,
          KNotificationsConfig.channelName,
          groupKey: account.hashCode.toString(),
          styleInformation: MessagingStyleInformation(
            Person(key: account.userId, name: account.userName),
            groupConversation: true,
            conversationTitle: account.forumName,
            messages:
                lastMessages.reversed
                    .map(
                      (message) => Message(
                        message.message.text,
                        DateTime.fromMillisecondsSinceEpoch(
                          int.parse(message.time) * 1000,
                        ),
                        Person(key: message.user.id, name: message.user.name),
                      ),
                    )
                    .toList(),
          ),
        ),
      ),
      payload: accountIndex.toString(),
    );
  }
}
