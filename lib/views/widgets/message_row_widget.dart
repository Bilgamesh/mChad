import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/state/notifiers.dart';
import 'package:mchad/utils/ui_util.dart';
import 'package:mchad/views/widgets/avatar_widget.dart';
import 'package:mchad/views/widgets/chat_bubble_widget.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';

class MessageRowWidget extends StatefulWidget {
  MessageRowWidget({
    Key? key,
    required this.index,
    required this.account,
    required this.message,
    required this.messages,
    required this.chatboxFocusNode,
    required this.textController,
    required this.isOnline,
    required this.hasFollowUp,
    required this.isFollowUp,
    required this.transitionAnimations,
    required this.settings,
  }) : isSender = message.user.id == account.userId,
       avatarSrc = message.avatar.src,
       super(key: key);
  final int index;
  final Account account;
  final List<Message> messages;
  final Message message;
  final String avatarSrc;
  final bool isSender;
  final FocusNode chatboxFocusNode;
  final TextEditingController textController;
  final bool isOnline;
  final bool hasFollowUp;
  final bool isFollowUp;
  final bool transitionAnimations;
  final SettingsModel settings;

  @override
  State<MessageRowWidget> createState() => _MessageRowWidgetState();
}

const onlineDot = Padding(
  padding: EdgeInsets.only(left: 35.0, top: 35.0),
  child: Icon(Icons.circle, color: Colors.green, size: 15),
);

class _MessageRowWidgetState extends State<MessageRowWidget> {
  bool loaded = false;

  @override
  void initState() {
    loaded = !widget.message.isNew;
    if (!loaded) {
      Future.microtask(() {
        if (!mounted) return;
        setState(() {
          loaded = true;
          widget.message.isNew = false;
        });
      });
    }
    super.initState();
  }

  List<Widget> buildLeftAvatar() {
    return [
      if (widget.hasFollowUp)
        const SizedBox(width: 50.0)
      else
        AvatarWidget(avatarSrc: widget.avatarSrc, account: widget.account),
      if (widget.isOnline && !widget.hasFollowUp) onlineDot,
    ];
  }

  List<Widget> buildRightAvatar() {
    return [
      if (widget.hasFollowUp) const SizedBox(width: 50.0),
      if (!widget.hasFollowUp && widget.isSender)
        AvatarWidget(avatarSrc: widget.avatarSrc, account: widget.account),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final DateFormat formatter = DateFormat(null, l10n.localeName);
    final dateTime =
        '${formatter.format(DateTime.fromMillisecondsSinceEpoch(int.parse(widget.message.time) * 1000))} '
            .replaceAll(RegExp(r':\d{2} '), ' ')
            .trim();
    final mainAxisAlignment =
        widget.isSender ? MainAxisAlignment.end : MainAxisAlignment.start;
    final label =
        widget.isSender
            ? '$dateTime • ${widget.message.user.name}'
            : '${widget.message.user.name} • $dateTime';

    final labelWidget = Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [Text(label, style: const TextStyle(fontSize: 10.0))],
    );

    return UiUtil.wrapConditionally(
      condition: widget.transitionAnimations,
      wrapper:
          (child) => AnimatedOpacity(
            opacity: (loaded && !widget.message.isDeleting) ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: child,
          ),
      child: VisibilityDetector(
        key: Key('${widget.message.id}-padding'),
        onVisibilityChanged: (info) {
          bool statusChanged = false;
          widget.messages
              .where((m) => m.id <= widget.message.id && m.isRead != true)
              .forEach((m) {
                m.read();
                statusChanged = true;
              });
          if (statusChanged) messageMapNotifier.notifyListeners();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: mainAxisAlignment,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!widget.isSender) Stack(children: [...buildLeftAvatar()]),
                  Column(
                    children: [
                      ChatBubble(
                        isSentByMe: widget.isSender,
                        message: widget.message,
                        index: widget.index,
                        account: widget.account,
                        chatboxFocusNode: widget.chatboxFocusNode,
                        textController: widget.textController,
                        hasFollowUp: widget.hasFollowUp,
                        isFollowUp: widget.isFollowUp,
                        settings: widget.settings,
                      ),
                    ],
                  ),
                  ...buildRightAvatar(),
                ],
              ),
              if (!widget.hasFollowUp) labelWidget,
            ],
          ),
        ),
      ),
    );
  }
}
