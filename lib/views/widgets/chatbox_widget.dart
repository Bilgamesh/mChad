import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/data/globals.dart' as globals;
import 'package:mchad/utils/modal_util.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';

final offset1 = Tween(begin: const Offset(0, 1), end: const Offset(0, 0));
final offset2 = Tween(begin: const Offset(0, 1), end: const Offset(0, 0));

class ChatboxWidget extends StatefulWidget {
  const ChatboxWidget({
    Key? key,
    required this.chatboxFocusNode,
    required this.textController,
    required this.onCodePressed,
    required this.onEmojiPressed,
    required this.account,
    required this.messageLimit,
  }) : super(key: key);
  final FocusNode chatboxFocusNode;
  final TextEditingController textController;
  final void Function(TextSelection? lastTextSelection) onCodePressed;
  final void Function(TextSelection? lastTextSelection) onEmojiPressed;
  final Account account;
  final int messageLimit;

  @override
  _ChatboxWidgetState createState() => _ChatboxWidgetState();
}

class _ChatboxWidgetState extends State<ChatboxWidget> {
  bool loaded = false;
  String labelText = '';

  @override
  void initState() {
    widget.textController.addListener(updateCachedInputText);
    widget.textController.addListener(updateMessageLengthLimitLabel);
    Timer(const Duration(milliseconds: 0), () {
      setState(() {
        loaded = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.textController.removeListener(updateCachedInputText);
    widget.textController.removeListener(updateMessageLengthLimitLabel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: settingsNotifier,
      builder:
          (context, settings, child) => AnimatedSwitcher(
            duration: Duration(
              milliseconds: settings.transitionAnimations ? 150 : 0,
            ),
            transitionBuilder:
                (child, animation) => SlideTransition(
                  position: (animation.value == 1 ? offset2 : offset1).animate(
                    animation,
                  ),
                  child: child,
                ),
            child:
                !loaded
                    ? SizedBox(height: 61.0)
                    : Container(
                      color: settings.colorScheme.surfaceContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 45.0,
                          width: double.infinity,
                          child: TextField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(
                                widget.messageLimit > 0
                                    ? widget.messageLimit
                                    : -1,
                              ),
                            ],
                            onTapOutside:
                                (event) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
                            controller: widget.textController,
                            focusNode: widget.chatboxFocusNode,
                            style: TextStyle(fontSize: 16.0),
                            onSubmitted: onSubmitted,
                            decoration: InputDecoration(
                              filled: true,
                              suffixIcon: SizedBox(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed:
                                          () => widget.onCodePressed(
                                            globals.textSelectionMap[widget
                                                .account],
                                          ),
                                      icon: Icon(Icons.code_outlined),
                                    ),
                                    IconButton(
                                      onPressed:
                                          () => widget.onEmojiPressed(
                                            globals.textSelectionMap[widget
                                                .account],
                                          ),
                                      icon: Icon(Icons.emoji_emotions_outlined),
                                    ),
                                  ],
                                ),
                              ),
                              hintText:
                                  AppLocalizations.of(context)!.chatboxHint,
                              labelText:
                                  labelText.isNotEmpty ? labelText : null,
                              labelStyle: TextStyle(
                                color: settings.colorScheme.error,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
          ),
    );
  }

  void updateCachedInputText() {
    globals.textSelectionMap[widget.account] = widget.textController.selection;
    var value = widget.textController.text;
    if (selectedAccountNotifier.value != null) {
      globals.chatBoxValueMap[selectedAccountNotifier.value!] = value;
    }
  }

  void updateMessageLengthLimitLabel() {
    var messageLength = widget.textController.text.length;
    var ratio = messageLength / widget.messageLimit;
    if (widget.messageLimit == 0 || messageLength == 0 || ratio < 0.9) {
      setState(() {
        labelText = '';
      });
      return;
    }
    if (ratio >= 0.9) {
      setState(() {
        labelText = '$messageLength/${widget.messageLimit}';
      });
    }
  }

  void onSubmitted(String value) {
    if (value.isEmpty) return;
    if (widget.messageLimit > 0 && value.length > widget.messageLimit) {
      widget.textController.text = widget.textController.text.substring(
        0,
        widget.messageLimit,
      );
      return;
    }
    widget.textController.clear();
    globals.syncManager.sync.then(
      (sync) => sync
          .sendToServer(value)
          .onError((error, trace) => ModalUtil.showError(error)),
    );
  }
}
