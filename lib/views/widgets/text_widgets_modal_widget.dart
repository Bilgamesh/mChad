import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/views/widgets/bbcodes_list_widget.dart';
import 'package:mchad/views/widgets/emoticon_list_widget.dart';

enum Tabs { emoticons, bbcodes }

class TextWidgetsModalWidget extends StatefulWidget {
  const TextWidgetsModalWidget({
    Key? key,
    required this.account,
    required this.tab,
    required this.textController,
    required this.lastTextSelection,
    required this.chatboxFocusNode,
    required this.scrollController,
  }) : super(key: key);
  final Account account;
  final Tabs tab;
  final TextEditingController textController;
  final TextSelection? lastTextSelection;
  final FocusNode chatboxFocusNode;
  final ScrollController scrollController;

  @override
  State<TextWidgetsModalWidget> createState() => _TextWidgetsModalWidgetState();
}

class _TextWidgetsModalWidgetState extends State<TextWidgetsModalWidget> {
  Set<Tabs>? tab;

  @override
  Widget build(BuildContext context) {
    tab ??= {widget.tab};
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: languageNotifier,
            builder:
                (context, language, child) => SegmentedButton(
                  segments: [
                    ButtonSegment(
                      value: Tabs.bbcodes,
                      label: Text(language.bbcodes),
                      icon: Icon(Icons.code),
                    ),
                    ButtonSegment(
                      value: Tabs.emoticons,
                      label: Text(language.emoticons),
                      icon: Icon(Icons.emoji_emotions_outlined),
                    ),
                  ],
                  selected: tab!,
                  onSelectionChanged: (selection) {
                    HapticsUtil.vibrate();
                    setState(() {
                      tab = selection;
                    });
                  },
                ),
          ),
          tab?.first == Tabs.bbcodes
              ? BbcodesListWidget(
                account: widget.account,
                textController: widget.textController,
                lastTextSelection: widget.lastTextSelection,
                chatboxFocusNode: widget.chatboxFocusNode,
                scrollController: widget.scrollController,
              )
              : EmoticonListWidget(
                account: widget.account,
                textController: widget.textController,
                lastTextSelection: widget.lastTextSelection,
                chatboxFocusNode: widget.chatboxFocusNode,
                scrollController: widget.scrollController,
              ),
        ],
      ),
    );
  }
}
