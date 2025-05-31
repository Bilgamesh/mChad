import 'dart:async';

import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/bbtag_model.dart';
import 'package:mchad/data/models/emoticons_response_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/models/online_users_response_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/services/mchat/mchat_chat_service.dart';
import 'package:mchad/services/mchat/mchat_emoticons_service.dart';
import 'package:mchad/services/mchat/mchat_users_service.dart';
import 'package:mchad/utils/logging_util.dart';
import 'package:mchad/data/globals.dart' as globals;
import 'package:mchad/utils/modal_util.dart';

class MchatSync {
  MchatSync({required this.account})
    : logger = LoggingUtil(module: '${account.forumName}_single_sync'),
      stopped = false,
      index = 0;
  final Account account;
  final LoggingUtil logger;
  Timer? timer;
  bool stopped;
  int index;
  bool loadingArchive = false;

  Future<void> onTick() async {
    try {
      logger.info('Start tick');

      refreshStatusNotifier.value[account] = VerificationStatus.loading;
      refreshStatusNotifier.notifyListeners();

      var existingMessages = messageMapNotifier.value[account] ?? [];

      /* When the application has just been opened
        (hence there are no remembered messages) 
        fetch the main page to get initial messages,
        formToken and creationTime */
      if (existingMessages.isEmpty) {
        var chatService = MchatChatService(account: account);
        var mainPage = await chatService.fetchMainPage();
        account.formToken = mainPage.formToken;
        account.creationTime = mainPage.creationTime;
        if (mainPage.messages != null) saveLikeMessage(mainPage.messages!);
        for (var message in mainPage.messages ?? <Message>[]) {
          message.read();
        }
        if (mainPage.bbtags != null) onBBTags(mainPage.bbtags!);
        if (mainPage.editDeleteLimit != null) {
          onEditDeleteLimit(mainPage.editDeleteLimit!);
        }
        if (mainPage.messageLimit != null) {
          onMessageLimit(mainPage.messageLimit!);
        }
        if (mainPage.messages != null) onAdd(mainPage.messages!);
      }

      /* Check for new messages every tick
        after the initial messages have been fetched*/
      if (existingMessages.isNotEmpty) {
        var chatService = MchatChatService(account: account);
        var latestMessage = messageMapNotifier.value[account]!.first;
        var chatData = await chatService.refresh(
          latestMessage.id,
          globals.logIdMap[account]!,
        );
        if (chatData.add != null) onAdd(chatData.add!);
        if (chatData.edit != null) onEdit(chatData.edit!);
        if (chatData.del != null) onDel(chatData.del!);
        if (chatData.log != null) updateLogId(chatData.log!);
      }

      /* When running application is resumed from background
        (hence sync was restarted so index is 0, but there are already
        remembered messagges from previous syncs)
        fetch the main page to refresh the formToken and creationTime
        needed for posting messages. Also do it if the appplication
        has been in the foreground for a long time (every 100th request) */
      if ((index == 0 && existingMessages.isNotEmpty) ||
          (index % 100 == 0 && index != 0)) {
        var chatService = MchatChatService(account: account);
        var mainPage = await chatService.fetchMainPage();
        account.formToken = mainPage.formToken;
        account.creationTime = mainPage.creationTime;
        if (mainPage.messages != null) saveLikeMessage(mainPage.messages!);
        if (mainPage.bbtags != null) onBBTags(mainPage.bbtags!);
        if (mainPage.editDeleteLimit != null) {
          onEditDeleteLimit(mainPage.editDeleteLimit!);
        }
        if (mainPage.messageLimit != null) {
          onMessageLimit(mainPage.messageLimit!);
        }
      }

      /* Periodically fetch user profile
        in case any user information has changed */
      if (index % 10 == 0) {
        var profileService = MchatUsersService(account: account);
        var profile = await profileService.fetchUserProfile();
        await onUserProfile(profile);
      }

      /* Periodically check who is online */
      if (index % 10 == 0) {
        var profileService = MchatUsersService(account: account);
        var onlineUsersData = await profileService.fetchOnlineUsers();
        onOnlineUsersUpdate(onlineUsersData);
      }

      /* Periodically fetch emoticons
        in case forum admin has changed them */
      if (index % 15 == 0) {
        var emoticonsService = MchatEmoticonsService(account: account);
        bool next;
        var start = 0;
        List<Emoticon> emoticons = [];
        do {
          var emoticonsData = await emoticonsService.fetchEmoticons(start);
          emoticons.addAll(emoticonsData.emoticons);
          next = emoticonsData.hasNextPage;
          start = emoticonsData.count;
        } while (next);
        onEmoticons(emoticons);
      }

      refreshTimeMapNotifer.value[account] = DateTime.now();
      refreshTimeMapNotifer.notifyListeners();
      refreshStatusNotifier.value[account] = VerificationStatus.success;
      refreshStatusNotifier.notifyListeners();
      index++;
    } catch (e) {
      logger.error('Tick failed due to error: $e');
      refreshTimeMapNotifer.value[account] = DateTime.now();
      refreshTimeMapNotifer.notifyListeners();
      refreshStatusNotifier.value[account] = VerificationStatus.error;
      refreshStatusNotifier.notifyListeners();
      ModalUtil.showError(e);
    } finally {
      if (!stopped) {
        timer = Timer(
          const Duration(seconds: KTimerConfig.timerIntervalSeconds),
          onTick,
        );
      }
    }
  }

  startAll() async {
    if (index != 0) throw 'Can\'t start sync which has already started';
    logger.info('Starting sync');
    if (index == 0) await onTick();
  }

  void stop() {
    logger.info('Stopping sync');
    if (timer == null) throw 'Can\'t stop sync that has not started';
    timer!.cancel();
    index = 0;
    stopped = true;
  }

  void onAddOld(List<Message> messages) {
    if (stopped) return;
    var existingMessages = messageMapNotifier.value[account] ?? <Message>[];
    for (var message in messages.reversed) {
      if (!existingMessages.contains(message)) {
        messageMapNotifier.value[account]?.add(message);
      }
    }
    messageMapNotifier.notifyListeners();
  }

  void onAdd(List<Message> messages) {
    if (stopped) return;
    if (messages.isNotEmpty && messages[0].logId != null) {
      updateLogId(messages[0].logId!);
    }
    var existingMessages = messageMapNotifier.value[account] ?? <Message>[];
    for (var message in messages) {
      if (!existingMessages.contains(message)) {
        messageMapNotifier.value[account]?.insert(0, message);
      }
    }
    messageMapNotifier.notifyListeners();
    messageMapNotifier.value[account]?.firstOrNull?.saveAsLatest(account);
  }

  void onDel(List<int> ids) {
    if (stopped) return;
    messageMapNotifier.value[account]?.forEach((m) {
      if (ids.contains(m.id)) {
        m.delete();
      }
    });
    messageMapNotifier.notifyListeners();
    Timer(const Duration(milliseconds: 500), () {
      messageMapNotifier.value[account]?.removeWhere(
        (message) => ids.contains(message.id),
      );
      messageMapNotifier.notifyListeners();
    });
  }

  void onEdit(List<Message> messages) {
    if (stopped) return;
    for (var message in messages) {
      message.read();
      var index = messageMapNotifier.value[account]?.indexOf(message);
      if (index != -1 && index != null) {
        messageMapNotifier.value[account]?[index] = message;
      }
    }
    messageMapNotifier.notifyListeners();
  }

  void onEmoticons(List<Emoticon> emoticons) {
    if (stopped) return;
    emoticonMapNotifer.value[account] = emoticons;
  }

  void onBBTags(List<BBTag> bbtags) {
    if (stopped) return;
    bbtagMapNotifier.value[account] = bbtags;
  }

  void onEditDeleteLimit(int limit) {
    if (stopped) return;
    editDeleteLimitMapNotifier.value[account] = limit;
  }

  void onMessageLimit(int limit) {
    if (stopped) return;
    messageLimitMapNotifier.value[account] = limit;
  }

  void updateLogId(String log) {
    var oldLog = int.tryParse(globals.logIdMap[account] ?? '0') ?? 0;
    var newLog = int.tryParse(log) ?? 0;
    globals.logIdMap[account] =
        (newLog > oldLog) ? log : globals.logIdMap[account] ?? '0';
  }

  Future<void> onUserProfile(Account profile) async {
    account.avatarUrl = profile.avatarUrl;
    account.userName = profile.userName;
    await account.save();
  }

  void onOnlineUsersUpdate(OnlineUsersResponse onlineUsersData) {
    if (stopped) return;
    onlineUsersMapNotifer.value[account] = onlineUsersData;
  }

  Future<void> sendToServer(String text) async {
    try {
      refreshStatusNotifier.value[account] = VerificationStatus.loading;
      refreshStatusNotifier.notifyListeners();

      var lastMessage = messageMapNotifier.value[account]!.elementAtOrNull(0);
      var response = await MchatChatService(account: account).add(
        last: '${lastMessage?.id ?? 0}',
        text: text,
        formToken: account.formToken!,
        creationTime: account.creationTime!,
      );

      if (response.add != null) onAdd(response.add!);
      if (response.del != null) onDel(response.del!);
      if (response.edit != null) onEdit(response.edit!);

      refreshStatusNotifier.value[account] = VerificationStatus.success;
      refreshStatusNotifier.notifyListeners();
    } catch (e) {
      refreshStatusNotifier.value[account] = VerificationStatus.error;
      refreshStatusNotifier.notifyListeners();
      logger.error('Failed to send message to server due to error: $e');
      rethrow;
    } finally {
      refreshTimeMapNotifer.value[account] = DateTime.now();
      refreshTimeMapNotifer.notifyListeners();
    }
  }

  Future<void> deleteFromServer(int id) async {
    try {
      refreshStatusNotifier.value[account] = VerificationStatus.loading;
      refreshStatusNotifier.notifyListeners();

      var response = await MchatChatService(account: account).del(
        id: id,
        formToken: account.formToken!,
        creationTime: account.creationTime!,
      );

      if (response.add != null) onAdd(response.add!);
      if (response.del != null) onDel(response.del!);
      if (response.edit != null) onEdit(response.edit!);

      refreshStatusNotifier.value[account] = VerificationStatus.success;
      refreshStatusNotifier.notifyListeners();
    } catch (e) {
      refreshStatusNotifier.value[account] = VerificationStatus.error;
      refreshStatusNotifier.notifyListeners();
      logger.error('Failed to delete message from server due to error: $e');
      rethrow;
    } finally {
      refreshTimeMapNotifer.value[account] = DateTime.now();
      refreshTimeMapNotifer.notifyListeners();
    }
  }

  Future<void> editOnServer(int id, String text) async {
    try {
      refreshStatusNotifier.value[account] = VerificationStatus.loading;
      refreshStatusNotifier.notifyListeners();

      var response = await MchatChatService(account: account).edit(
        id: id,
        message: text,
        formToken: account.formToken!,
        creationTime: account.creationTime!,
      );

      if (response.add != null) onAdd(response.add!);
      if (response.del != null) onDel(response.del!);
      if (response.edit != null) onEdit(response.edit!);

      refreshStatusNotifier.value[account] = VerificationStatus.success;
      refreshStatusNotifier.notifyListeners();
    } catch (e) {
      refreshStatusNotifier.value[account] = VerificationStatus.error;
      refreshStatusNotifier.notifyListeners();
      logger.error('Failed to edit message on server due to error: $e');
      rethrow;
    } finally {
      refreshTimeMapNotifer.value[account] = DateTime.now();
      refreshTimeMapNotifer.notifyListeners();
    }
  }

  Future<void> fetchArchiveMessages() async {
    if (loadingArchive) return;
    loadingArchive = true;
    try {
      var startIndex = messageMapNotifier.value[account]?.length;
      if (startIndex == null) return;
      var response = await MchatChatService(
        account: account,
      ).fetchArchive(startIndex);
      if (response.messages != null) onAddOld(response.messages!);
      loadingArchive = false;
    } catch (e) {
      loadingArchive = false;
      logger.error('Failed to fetch archive due to error: $e');
      rethrow;
    }
  }

  void saveLikeMessage(List<Message> messages) {
    if (messages.isNotEmpty && messages[0].likeMessage != null) {
      globals.likeMessageMap[account] = messages[0].likeMessage!;
    }
  }
}
