import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/views/widgets/chat_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatPlaceholderWidget extends StatefulWidget {
  const ChatPlaceholderWidget({Key? key}) : super(key: key);

  @override
  State<ChatPlaceholderWidget> createState() => _ChatPlaceholderWidgetState();
}

class _ChatPlaceholderWidgetState extends State<ChatPlaceholderWidget> {
  final rnd = Random();

  final dummyUsers = [
    User(id: 'u1', name: 'User 1'),
    User(id: 'u2', name: 'User 2 ....'),
    User(id: 'u3', name: 'Long User 3 ........'),
    User(id: 'u4', name: 'Long User 4 .............'),
  ];

  final dummyTexts = [
    'Aaa aaa aa a',
    'Aaa aaa aa a aaa aa a aaa aa a aaa aa aaaaaaaa',
    'Aaa aaa aa aaaa aaa aa aa',
    'Aaa aaa aa a aaa aa a aaa aa a aaa aa a\nAaa aaa aa a aaa aa a aaa aa a aaa aa a\nAaa aaa aa a aaa aa a aaa aa a aaa aa aaaaa',
  ];

  List<Message> messages = [];

  Message generateRandomMessage(int id) {
    final user = dummyUsers[rnd.nextInt(dummyUsers.length)];
    final text = dummyTexts[rnd.nextInt(dummyTexts.length)];

    return Message(
      id: id,
      time: DateTime.now().millisecondsSinceEpoch.toString(),
      user: user,
      message: InnerMessage(text: text, html: '<p>$text</p>', baseUrl: ''),
      avatar: Avatar(src: '', width: 64),
      likeMessage: rnd.nextBool() ? 'Like!' : null,
      logId: 'log_$id',
    );
  }

  List<Message> generateRandomMessages(int count) {
    return List.generate(count, (i) => generateRandomMessage(i + 1));
  }

  @override
  void initState() {
    messages = generateRandomMessages(10);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final account = Account(
      userName: 'TestUser',
      userId: '12345',
      forumName: 'TestForum',
      forumUrl: 'https://przegrywy.net',
      avatarUrl: 'https://example.com',
      userAgent: 'Dart/Flutter Dummy UA',
      wasPreviouslySelected: false,
    );

    return Skeletonizer(
      enabled: true,
      child: ChatWidget(
        account: account,
        messages: messages,
        textController: TextEditingController(),
        chatboxFocusNode: FocusNode(),
        transitionAnimations: false,
      ),
    );
  }
}
