import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/emoticons_response_model.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/state/notifiers.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/notifier_util.dart';
import 'package:mchad/views/widgets/emoticon_wrap_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EmoticonListWidget extends StatelessWidget {
  const EmoticonListWidget({
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
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: SingleChildScrollView(
        controller: scrollController,
        child: ValueListenablesBuilder(
          listenables: [emoticonMapNotifer, settingsNotifier],
          builder: (context, values, child) {
            final emoticonMap = values[0] as Map<Account, List<Emoticon>>;
            final emoticons = emoticonMap[account] ?? [];
            final settings = values[1] as SettingsModel;
            return SafeArea(
              child: switch (emoticons.length) {
                0 => Skeletonizer(
                  enabled: true,
                  child: EmoticonWrapWidget(
                    account: account,
                    settings: settings,
                    emoticons: List<Emoticon>.generate(
                      10,
                      (index) => Emoticon(
                        pictureUrl: '',
                        width: 1,
                        height: 1,
                        code: '',
                        title: '',
                      ),
                    ),
                    chatboxFocusNode: chatboxFocusNode,
                    textController: textController,
                    lastTextSelection: lastTextSelection,
                  ),
                ),
                _ => EmoticonWrapWidget(
                  account: account,
                  settings: settings,
                  emoticons: emoticons,
                  chatboxFocusNode: chatboxFocusNode,
                  textController: textController,
                  lastTextSelection: lastTextSelection,
                ),
              },
            );
          },
        ),
      ),
    ),
  );

  void onEmoticonTap(BuildContext context, Emoticon emoticon) {
    HapticsUtil.vibrate();
    Navigator.pop(context);
    chatboxFocusNode.requestFocus();
    if (lastTextSelection == null) {
      textController.text += ' ${emoticon.code} ';
      return;
    }
    final left = textController.text.substring(0, lastTextSelection!.start);
    final right = textController.text.substring(lastTextSelection!.start);
    textController.value = TextEditingValue(
      text: '$left ${emoticon.code} $right',
      selection: TextSelection.fromPosition(
        TextPosition(offset: '$left ${emoticon.code} '.length),
      ),
    );
  }
}
