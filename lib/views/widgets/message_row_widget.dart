import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/notifiers.dart';
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

  @override
  State<MessageRowWidget> createState() => _MessageRowWidgetState();
}

class _MessageRowWidgetState extends State<MessageRowWidget> {
  bool? loaded;

  @override
  void initState() {
    loaded = !widget.message.isNew;
    if (!loaded!) {
      Timer(const Duration(milliseconds: 0), () {
        setState(() {
          loaded = true;
          widget.message.isNew = false;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat(
      null,
      AppLocalizations.of(context).localeName,
    );
    final dateTime =
        '${formatter.format(DateTime.fromMillisecondsSinceEpoch(int.parse(widget.message.time) * 1000))} '
            .replaceAll(RegExp(r':\d{2} '), ' ')
            .trim();

    return AnimatedOpacity(
      opacity: (loaded! && !widget.message.isDeleting) ? 1.0 : 0.0,
      duration: Duration(milliseconds: widget.transitionAnimations ? 500 : 0),
      child: VisibilityDetector(
        key: Key('${widget.message.id}-padding'),
        onVisibilityChanged: (info) {
          widget.message.read();
          for (var message in widget.messages.where(
            (message) => message.id < widget.message.id,
          )) {
            message.read();
          }
          messageMapNotifier.notifyListeners();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: switch (widget.isSender) {
                  true => MainAxisAlignment.end,
                  false => MainAxisAlignment.start,
                },
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!widget.isSender)
                    Stack(
                      children: [
                        if (widget.hasFollowUp)
                          SizedBox(width: 50.0)
                        else
                          AvatarWidget(
                            avatarSrc: widget.avatarSrc,
                            account: widget.account,
                          ),
                        if (widget.isOnline && !widget.hasFollowUp)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 35.0,
                              top: 35.0,
                            ),
                            child: Icon(
                              Icons.circle,
                              color: Colors.green,
                              size: 15,
                            ),
                          ),
                      ],
                    ),
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
                      ),
                    ],
                  ),
                  if (widget.hasFollowUp) SizedBox(width: 50.0),
                  if (!widget.hasFollowUp && widget.isSender)
                    AvatarWidget(
                      avatarSrc: widget.avatarSrc,
                      account: widget.account,
                    ),
                ],
              ),
              if (!widget.hasFollowUp)
                Material(
                  child: Row(
                    mainAxisAlignment: switch (widget.isSender) {
                      true => MainAxisAlignment.end,
                      false => MainAxisAlignment.start,
                    },
                    children: [
                      if (widget.isSender)
                        Text(
                          '$dateTime • ${widget.message.user.name}',
                          style: TextStyle(fontSize: 10.0),
                        )
                      else
                        Text(
                          '${widget.message.user.name} • $dateTime',
                          style: TextStyle(fontSize: 10.0),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
