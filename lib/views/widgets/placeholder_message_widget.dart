import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/views/widgets/message_row_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PlaceholderMessageWidget extends StatefulWidget {
  const PlaceholderMessageWidget({
    Key? key,
    required this.index,
    required this.textController,
    required this.chatboxFocusNode,
  }) : super(key: key);
  final int index;
  final TextEditingController textController;
  final FocusNode chatboxFocusNode;

  @override
  State<PlaceholderMessageWidget> createState() =>
      _PlaceholderMessageWidgetState();
}

class _PlaceholderMessageWidgetState extends State<PlaceholderMessageWidget> {
  late User user;
  late String text;

  final dummyUsers = [
    User(id: 'u1', name: 'User 1'),
    User(id: 'u2', name: 'User 2 ....'),
    User(id: 'u3', name: 'Long User ........'),
  ];

  final dummyTexts = [
    'Aaa aaa aa a',
    'Aaa aaa aa a aaa aa a aaa aa a aaa aa aaaaaaaa',
    'Aaa aaa aa aaaa aaa aa aa',
    'Aaa aaa aa a aaa aa a aaa aa a aaa aa a\nAaa aaa aa a aaa aa a aaa aa a aaa aa a\nAaa aaa aa a aaa aa a aaa aa a aaa aa aaaaa',
  ];

  @override
  void initState() {
    final rnd = Random();
    user = dummyUsers[rnd.nextInt(dummyUsers.length)];
    text = dummyTexts[rnd.nextInt(dummyTexts.length)];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: MessageRowWidget(
        index: widget.index - 1,
        account: Account(
          userName: 'TestUser',
          userId: '12345',
          forumName: 'TestForum',
          forumUrl: 'https://przegrywy.net',
          avatarUrl: 'https://example.com',
          userAgent: 'Dart/Flutter Dummy UA',
          wasPreviouslySelected: false,
        ),
        message: Message(
          id: 0,
          time: DateTime.now().millisecondsSinceEpoch.toString(),
          user: user,
          message: InnerMessage(text: '', html: '<p>$text</p>', baseUrl: ''),
          avatar: Avatar(src: '', width: 64),
          likeMessage: 'Like!',
          logId: 'log_0',
        ),
        messages: [],
        chatboxFocusNode: widget.chatboxFocusNode,
        textController: widget.textController,
        isOnline: false,
        hasFollowUp: false,
        isFollowUp: false,
        transitionAnimations: false,
      ),
    );
  }
}
