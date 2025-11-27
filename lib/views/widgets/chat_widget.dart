import 'package:flutter/material.dart';
import 'package:mchad/data/globals.dart' as globals;
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/models/online_users_response_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/views/widgets/message_row_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    Key? key,
    required this.account,
    required this.messages,
    required this.textController,
    required this.chatboxFocusNode,
    required this.transitionAnimations,
    this.infiniteScrollEnabled,
    this.onlineUsers,
  }) : super(key: key);
  final Account account;
  final List<Message> messages;
  final TextEditingController textController;
  final FocusNode chatboxFocusNode;
  final OnlineUsersResponse? onlineUsers;
  final bool transitionAnimations;
  final bool? infiniteScrollEnabled;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      chatScrollOffsetNotifier.value = 0;
      globals.chatScrollController = scrollController;

      scrollController.addListener(() {
        chatScrollOffsetNotifier.value = scrollController.offset;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    chatScrollOffsetNotifier.value = 0;
    globals.chatScrollController = null;
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: (widget.messages.length + 2),
      reverse: true,
      controller: scrollController,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == 0) {
          return SizedBox(height: 100.0);
        }
        if (index - 1 < widget.messages.length) {
          return MessageRowWidget(
            key: Key('${widget.messages[index - 1].id}'),
            index: index - 1,
            account: widget.account,
            chatboxFocusNode: widget.chatboxFocusNode,
            textController: widget.textController,
            hasFollowUp: hasFollowUpMessage(index - 1, widget.messages),
            isFollowUp: hasFollowUpMessage(index, widget.messages),
            isOnline: isOnline(
              widget.onlineUsers,
              widget.messages[index - 1].user.id,
            ),
            message: widget.messages[index - 1],
            messages: widget.messages,
            transitionAnimations: widget.transitionAnimations,
          );
        }
        if (widget.infiniteScrollEnabled == true) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: VisibilityDetector(
                key: Key('archive-fetch-indicator'),
                onVisibilityChanged: onArchiveFetch,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return SizedBox.shrink();
      },
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
