import 'package:flutter/material.dart';
import 'package:mchad/data/globals.dart' as globals;
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/models/online_users_response_model.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/value_listenables_builder.dart';
import 'package:mchad/views/widgets/chat_placeholder_widget.dart';
import 'package:mchad/views/widgets/chat_widget.dart';
import 'package:mchad/views/widgets/chatbox_widget.dart';
import 'package:mchad/views/widgets/keyboard_space_widget.dart';
import 'package:mchad/views/widgets/text_widgets_modal_widget.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({Key? key, required this.orientation}) : super(key: key);
  final Orientation orientation;

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final chatboxFocusNode = FocusNode();
  final textController = TextEditingController(
    text: switch (selectedAccountNotifier.value) {
      null => '',
      _ => globals.chatBoxValueMap[selectedAccountNotifier.value],
    },
  );

  @override
  void dispose() {
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
        final messages = messageMap[account!] ?? [];
        final settings = values[2] as SettingsModel;
        final onlineUsersMap = values[3] as Map<Account, OnlineUsersResponse>;
        final onlineUsers = onlineUsersMap[account];
        final messageLimitMap = values[4] as Map<Account, int>;
        final messageLimit = messageLimitMap[account] ?? 0;
        return Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: switch (messages.length) {
                  0 => ChatPlaceholderWidget(),
                  _ => ChatWidget(
                    account: account,
                    chatboxFocusNode: chatboxFocusNode,
                    messages: messages,
                    textController: textController,
                    onlineUsers: onlineUsers,
                    transitionAnimations: settings.transitionAnimations,
                    infiniteScrollEnabled: account.infiniteScroll,
                  ),
                },
              ),
            ),
            ChatboxWidget(
              chatboxFocusNode: chatboxFocusNode,
              textController: textController,
              account: account,
              messageLimit: messageLimit,
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
}
