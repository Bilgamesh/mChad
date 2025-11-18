import 'package:flutter/material.dart';
import 'package:mchad/data/globals.dart' as globals;
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/models/online_users_response_model.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/value_listenables_builder.dart';
import 'package:mchad/views/widgets/chatbox_widget.dart';
import 'package:mchad/views/widgets/keyboard_space_widget.dart';
import 'package:mchad/views/widgets/message_row_widget.dart';
import 'package:mchad/views/widgets/text_widgets_modal_widget.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({Key? key, required this.orientation}) : super(key: key);
  final Orientation orientation;

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final scrollController = ScrollController();
  final chatboxFocusNode = FocusNode();
  final textController = TextEditingController(
    text:
        selectedAccountNotifier.value != null
            ? globals.chatBoxValueMap[selectedAccountNotifier.value]
            : '',
  );

  @override
  void initState() {
    chatScrollNotifier.value = scrollController;
    chatScrollNotifier.notifyListeners();

    scrollController.addListener(() {
      chatScrollNotifier.value = scrollController;
      chatScrollNotifier.notifyListeners();
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        globals.syncManager.sync.then((sync) => sync.fetchArchiveMessages());
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    chatScrollNotifier.value = null;
    chatScrollNotifier.notifyListeners();
    scrollController.dispose();
    chatboxFocusNode.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenablesBuilder(
      listenables: [
        selectedAccountNotifier,
        messageMapNotifier,
        settingsNotifier,
        onlineUsersMapNotifer,
        messageLimitMapNotifier,
      ],
      builder: (context, values, child) {
        final account = values[0] as Account?;
        final messageMap = values[1] as Map<Account, List<Message>>;
        final settings = values[2] as SettingsModel;
        final onlineUsersMap = values[3] as Map<Account, OnlineUsersResponse>;
        final messageLimitMap = values[4] as Map<Account, int>;
        return Column(
          children: [
            Expanded(
              child: Align(
                alignment:
                    (messageMap[account!]?.length ?? 0) > 0
                        ? Alignment.topCenter
                        : Alignment.center,
                child: ListView.builder(
                  itemCount: ((messageMap[account]?.length ?? 0) + 2),
                  reverse: true,
                  controller: scrollController,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return SizedBox(height: 100.0);
                    }
                    if (index - 1 < (messageMap[account]?.length ?? 0)) {
                      return MessageRowWidget(
                        key: Key('${messageMap[account]![index - 1].id}'),
                        index: index - 1,
                        account: account,
                        messageMap: messageMap,
                        chatboxFocusNode: chatboxFocusNode,
                        textController: textController,
                        hasFollowUp: hasFollowUpMessage(
                          index - 1,
                          messageMap[account]!,
                        ),
                        isFollowUp: hasFollowUpMessage(
                          index,
                          messageMap[account]!,
                        ),
                        isOnline: isOnline(
                          onlineUsersMap[account],
                          messageMap[account]![index - 1].user.id,
                        ),
                        settings: settings,
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ),
            ChatboxWidget(
              chatboxFocusNode: chatboxFocusNode,
              textController: textController,
              account: account,
              messageLimit: messageLimitMap[account] ?? 0,
              onCodePressed: (TextSelection? lastTextSelection) {
                HapticsUtil.vibrate();
                openTextWidgetsModal(
                  context,
                  account,
                  Tabs.bbcodes,
                  lastTextSelection,
                );
              },
              onEmojiPressed: (TextSelection? lastTextSelection) {
                HapticsUtil.vibrate();
                openTextWidgetsModal(
                  context,
                  account,
                  Tabs.emoticons,
                  lastTextSelection,
                );
              },
            ),
            KeyboardSpaceWidget(
              withNavbar: widget.orientation == Orientation.portrait,
            ),
          ],
        );
      },
    );
  }

  void openTextWidgetsModal(
    BuildContext context,
    Account account,
    Tabs tab,
    TextSelection? lastTextSelection,
  ) {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      useSafeArea: true,
      builder:
          (context) => DraggableScrollableSheet(
            snap: true,
            initialChildSize: 0.5,
            minChildSize: 0.5,
            maxChildSize: 1.0,
            snapSizes: [0.5, 1.0],
            expand: false,
            builder:
                (context, scrollController) => TextWidgetsModalWidget(
                  account: account,
                  tab: tab,
                  textController: textController,
                  lastTextSelection: lastTextSelection,
                  chatboxFocusNode: chatboxFocusNode,
                  scrollController: scrollController,
                ),
          ),
    );
  }

  bool hasFollowUpMessage(int index, List<Message> messages) {
    if (index == 0) return false;
    var currentMessage = messages.elementAtOrNull(index);
    var nextMessage = messages.elementAtOrNull(index - 1);
    if (currentMessage == null || nextMessage == null) return false;
    if (currentMessage.user.id != nextMessage.user.id) return false;
    var currentMessageTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(currentMessage.time) * 1000,
    );
    var nextMessageTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(nextMessage.time) * 1000,
    );
    var diff = nextMessageTime.difference(currentMessageTime);
    return diff.inMinutes < 1;
  }

  bool isOnline(OnlineUsersResponse? onlineUsersData, String userId) {
    if (onlineUsersData == null) return false;
    return onlineUsersData.userIds.contains(userId);
  }
}
