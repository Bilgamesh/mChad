import 'package:flutter/material.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/state/globals.dart' as globals;
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/models/online_users_response_model.dart';
import 'package:mchad/data/state/notifiers.dart';
import 'package:mchad/views/widgets/message_row_widget.dart';
import 'package:mchad/views/widgets/placeholder_message_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    Key? key,
    required this.account,
    required this.messages,
    required this.textController,
    required this.chatboxFocusNode,
    required this.transitionAnimations,
    required this.settings,
    this.infiniteScrollEnabled,
    this.onlineUsers,
  }) : super(key: key);
  final Account account;
  final List<Message> messages;
  final TextEditingController textController;
  final FocusNode chatboxFocusNode;
  final OnlineUsersResponse? onlineUsers;
  final SettingsModel settings;
  final bool transitionAnimations;
  final bool? infiniteScrollEnabled;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        final diff =
            chatScrollOffsetNotifier.value - scrollNotification.metrics.pixels;
        if (diff.abs() > 300)
          chatScrollOffsetNotifier.value = scrollNotification.metrics.pixels;
        return false;
      },
      child: ListView.builder(
        itemCount: (messages.length + 2),
        reverse: true,
        shrinkWrap: true,
        primary: true,
        itemBuilder: (context, index) {
          if (index == 0) {
            return SizedBox(height: 100.0);
          }
          if (index - 1 < messages.length) {
            return MessageRowWidget(
              key: Key('${messages[index - 1].id}'),
              index: index - 1,
              account: account,
              chatboxFocusNode: chatboxFocusNode,
              textController: textController,
              hasFollowUp: hasFollowUpMessage(index - 1, messages),
              isFollowUp: hasFollowUpMessage(index, messages),
              isOnline: isOnline(onlineUsers, messages[index - 1].user.id),
              message: messages[index - 1],
              messages: messages,
              transitionAnimations: transitionAnimations,
              settings: settings,
            );
          }

          if (infiniteScrollEnabled == true) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: VisibilityDetector(
                key: Key('archive-fetch-indicator'),
                onVisibilityChanged: onArchiveFetch,
                child: Column(
                  children: [
                    PlaceholderMessageWidget(
                      index: index,
                      textController: textController,
                      chatboxFocusNode: chatboxFocusNode,
                      settings: settings,
                    ),
                    PlaceholderMessageWidget(
                      index: index,
                      textController: textController,
                      chatboxFocusNode: chatboxFocusNode,
                      settings: settings,
                    ),
                    PlaceholderMessageWidget(
                      index: index,
                      textController: textController,
                      chatboxFocusNode: chatboxFocusNode,
                      settings: settings,
                    ),
                  ],
                ),
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  bool hasFollowUpMessage(int index, List<Message> messages) {
    if (index == 0) return false;
    final currentMessage = messages.elementAtOrNull(index);
    final nextMessage = messages.elementAtOrNull(index - 1);
    if (currentMessage == null || nextMessage == null) return false;
    if (currentMessage.user.id != nextMessage.user.id) return false;
    final currentMessageTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(currentMessage.time) * 1000,
    );
    final nextMessageTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(nextMessage.time) * 1000,
    );
    final diff = nextMessageTime.difference(currentMessageTime);
    return diff.inMinutes < 1;
  }

  bool isOnline(OnlineUsersResponse? onlineUsersData, String userId) {
    if (onlineUsersData == null) return false;
    return onlineUsersData.userIds.contains(userId);
  }

  void onArchiveFetch(VisibilityInfo indicatorVisibility) {
    if (indicatorVisibility.visibleFraction > 0) {
      globals.syncManager.sync.then((sync) => sync.fetchArchiveMessages());
    }
  }
}
