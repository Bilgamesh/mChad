import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/bbtag_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/haptics_util.dart';

class BbcodesListWidget extends StatefulWidget {
  const BbcodesListWidget({
    Key? key,
    required this.account,
    required this.textController,
    required this.lastTextSelection,
    required this.chatboxFocusNode,
    required this.scrollController,
  }) : super(key: key);
  final Account account;
  final TextEditingController textController;
  final TextSelection? lastTextSelection;
  final FocusNode chatboxFocusNode;
  final ScrollController scrollController;

  @override
  State<BbcodesListWidget> createState() => _BbcodesListWidgetState();
}

class _BbcodesListWidgetState extends State<BbcodesListWidget> {
  ClipboardData? clipboardData;
  Timer? clipBoardSyncTimer;

  @override
  void initState() {
    updateClipboardData();
    clipBoardSyncTimer = Timer.periodic(
      Duration(seconds: 1),
      (timer) => updateClipboardData(),
    );
    super.initState();
  }

  @override
  void dispose() {
    clipBoardSyncTimer?.cancel();
    super.dispose();
  }

  Future<void> updateClipboardData() async {
    final hasData = await Clipboard.hasStrings();
    if (!hasData) return;
    final data = await Clipboard.getData('text/plain');
    setState(() {
      clipboardData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: SingleChildScrollView(
          controller: widget.scrollController,
          child: ValueListenableBuilder(
            valueListenable: bbtagMapNotifier,
            builder: (context, bbtagMap, child) {
              final bbtags = bbtagMap[widget.account] ?? [];
              return SafeArea(
                child: Wrap(
                  children: List.generate(
                    bbtags.length,
                    (index) => switch (shouldBeAvailable(
                      bbtags[index],
                      bbtags,
                    )) {
                      true => Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: IconButton.filled(
                            isSelected: bbtags[index].supportsContent(
                              clipboardData?.text,
                            ),
                            onPressed:
                                () => onBbCodeTap(context, bbtags[index]),
                            onLongPress:
                                () => onBbCodeTap(context, bbtags[index]),
                            icon: Icon(bbtags[index].icon),
                          ),
                        ),
                      ),
                      false => SizedBox.shrink(),
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool shouldBeAvailable(BBTag bbtag, List<BBTag> allBbtags) {
    return bbtag.isSupported && !bbtag.hasBetterAlternative(allBbtags);
  }

  void onBbCodeTap(BuildContext context, BBTag bbcode) {
    HapticsUtil.vibrate();
    Navigator.pop(context);
    widget.chatboxFocusNode.requestFocus();
    if (widget.lastTextSelection == null) {
      return addBbCodeToEmptyTextField(bbcode);
    }
    if (widget.lastTextSelection!.start == widget.lastTextSelection!.end) {
      return addBbCodeAtCursorPosition(bbcode);
    }
    return wrapSelectedTextWithBbCode(bbcode);
  }

  void addBbCodeToEmptyTextField(BBTag bbcode) {
    final fullBbCodeValue = switch (bbcode.supportsContent(clipboardData?.text)) {
      true => '${bbcode.start}${clipboardData?.text}${bbcode.end} ',
      false => '${bbcode.start}${bbcode.end}',
    };
    final cursorPosition = switch (bbcode.supportsContent(clipboardData?.text)) {
      true => '${bbcode.start}${clipboardData?.text}${bbcode.end} '.length,
      false => bbcode.start.length,
    };
    widget.textController.value = TextEditingValue(
      text: fullBbCodeValue,
      selection: TextSelection.fromPosition(
        TextPosition(offset: cursorPosition),
      ),
    );
  }

  void addBbCodeAtCursorPosition(BBTag bbcode) {
    final left = widget.textController.text.substring(
      0,
      widget.lastTextSelection!.start,
    );
    final right = widget.textController.text.substring(
      widget.lastTextSelection!.start,
    );
    final fullBbCodeValue = switch (bbcode.supportsContent(clipboardData?.text)) {
      true => '${bbcode.start}${clipboardData?.text}${bbcode.end} ',
      false => '${bbcode.start}${bbcode.end}',
    };
    final cursorPosition = switch (bbcode.supportsContent(clipboardData?.text)) {
      true => '$left${bbcode.start}${clipboardData?.text}${bbcode.end} '.length,
      false => '$left${bbcode.start}'.length,
    };
    widget.textController.value = TextEditingValue(
      text: '$left$fullBbCodeValue$right',
      selection: TextSelection.fromPosition(
        TextPosition(offset: cursorPosition),
      ),
    );
  }

  void wrapSelectedTextWithBbCode(BBTag bbcode) {
    final left = widget.textController.text.substring(
      0,
      widget.lastTextSelection!.start,
    );
    final inside = widget.textController.text.substring(
      widget.lastTextSelection!.start,
      widget.lastTextSelection!.end,
    );
    final right = widget.textController.text.substring(
      widget.lastTextSelection!.end,
    );
    final fullBbCodeValue = '${bbcode.start}$inside${bbcode.end}';
    widget.textController.value = TextEditingValue(
      text: '$left$fullBbCodeValue$right',
      selection: TextSelection(
        baseOffset: '$left${bbcode.start}'.length,
        extentOffset: '$left${bbcode.start}$inside'.length,
      ),
    );
  }
}
