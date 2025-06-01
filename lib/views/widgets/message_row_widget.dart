import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/crypto_util.dart';
import 'package:mchad/views/widgets/chat_bubble_widget.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessageRowWidget extends StatefulWidget {
  MessageRowWidget({
    Key? key,
    required this.index,
    required this.account,
    required this.messageMap,
    required this.chatboxFocusNode,
    required this.textController,
    required this.isOnline,
    required this.hasFollowUp,
    required this.isFollowUp,
    required this.settings,
  }) : messages = messageMap[account]!,
       message = messageMap[account]![index],
       isSender = messageMap[account]![index].user.id == account.userId,
       avatarSrc = messageMap[account]![index].avatar.src,
       super(key: key);
  final int index;
  final Account account;
  final Map<Account, List<Message>> messageMap;
  final List<Message> messages;
  final Message message;
  final String avatarSrc;
  final bool isSender;
  final FocusNode chatboxFocusNode;
  final TextEditingController textController;
  final bool isOnline;
  final bool hasFollowUp;
  final bool isFollowUp;
  final SettingsModel settings;

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
      settingsNotifier.value.locale.countryCode,
    );
    var dateTime =
        '${formatter.format(DateTime.fromMillisecondsSinceEpoch(int.parse(widget.message.time) * 1000))} '
            .replaceAll(RegExp(r':\d{2} '), ' ')
            .trim();

    var headers = {
      'x-requested-with': 'XMLHttpRequest',
      'cookie': widget.account.cachedCookies ?? '',
      'user-agent': widget.account.userAgent ?? '',
    };

    return AnimatedOpacity(
      opacity: (loaded! && !widget.message.isDeleting) ? 1.0 : 0.0,
      duration: Duration(
        milliseconds: widget.settings.transitionAnimations ? 500 : 0,
      ),
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
                mainAxisAlignment:
                    widget.isSender
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  widget.isSender
                      ? SizedBox.shrink()
                      : Stack(
                        children: [
                          widget.hasFollowUp
                              ? SizedBox(width: 50.0)
                              : CircleAvatar(
                                radius: 25.0,
                                foregroundImage: CachedNetworkImageProvider(
                                  widget.avatarSrc,
                                  headers:
                                      widget.avatarSrc.startsWith(
                                            widget.account.forumUrl,
                                          )
                                          ? headers
                                          : {},
                                  cacheKey: CryptoUtil.generateMd5(
                                    '$headers${widget.avatarSrc}',
                                  ),
                                ),
                                backgroundImage: AssetImage(
                                  'assets/images/no_avatar.gif',
                                ),
                              ),
                          widget.isOnline && !widget.hasFollowUp
                              ? Padding(
                                padding: const EdgeInsets.only(
                                  left: 35.0,
                                  top: 35.0,
                                ),
                                child: Icon(
                                  Icons.circle,
                                  color: Colors.green,
                                  size: 15,
                                ),
                              )
                              : SizedBox.shrink(),
                        ],
                      ),
                  Column(
                    children: [
                      ChatBubble(
                        isSentByMe: widget.isSender,
                        message: widget.message,
                        index: widget.index,
                        account: widget.account,
                        messageMap: widget.messageMap,
                        chatboxFocusNode: widget.chatboxFocusNode,
                        textController: widget.textController,
                        hasFollowUp: widget.hasFollowUp,
                        isFollowUp: widget.isFollowUp,
                      ),
                      // SizedBox(height: 20,);
                    ],
                  ),
                  widget.hasFollowUp
                      ? SizedBox(width: 50.0)
                      : widget.isSender
                      ? CircleAvatar(
                        radius: 25.0,
                        // backgroundImage: NetworkImage(widget.avatarSrc),
                        backgroundImage: AssetImage(
                          'assets/images/no_avatar.gif',
                        ),
                        foregroundImage: CachedNetworkImageProvider(
                          widget.avatarSrc,
                          headers:
                              widget.avatarSrc.startsWith(
                                    widget.account.forumUrl,
                                  )
                                  ? headers
                                  : {},
                          cacheKey: CryptoUtil.generateMd5(
                            '$headers${widget.avatarSrc}',
                          ),
                        ),
                      )
                      : SizedBox.shrink(),
                ],
              ),
              widget.hasFollowUp
                  ? SizedBox.shrink()
                  : Material(
                    child: Row(
                      mainAxisAlignment:
                          widget.isSender
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                      children: [
                        widget.isSender
                            ? Text(
                              '$dateTime • ${widget.message.user.name}',
                              style: TextStyle(fontSize: 10.0),
                            )
                            : Text(
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
