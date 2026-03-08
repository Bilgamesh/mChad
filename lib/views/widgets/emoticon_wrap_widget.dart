import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/emoticons_response_model.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/views/widgets/emoticon_tile_widget.dart';

class EmoticonWrapWidget extends StatelessWidget {
  const EmoticonWrapWidget({
    Key? key,
    required this.account,
    required this.settings,
    required this.emoticons,
    required this.chatboxFocusNode,
    required this.textController,
    required this.lastTextSelection,
  }) : super(key: key);
  final Account account;
  final SettingsModel settings;
  final List<Emoticon> emoticons;
  final FocusNode chatboxFocusNode;
  final TextEditingController textController;
  final TextSelection? lastTextSelection;

  @override
  Widget build(BuildContext context) => Wrap(
    children: List.generate(emoticons.length, (index) {
      final emoticon = emoticons[index];
      return Padding(
        padding: const EdgeInsets.all(6.0),
        child: EmoticonTileWidget(
          account: account,
          settings: settings,
          emoticon: emoticon,
          chatboxFocusNode: chatboxFocusNode,
          textController: textController,
          lastTextSelection: lastTextSelection,
        ),
      );
    }),
  );
}
