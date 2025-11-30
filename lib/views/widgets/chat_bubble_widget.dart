import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/document_util.dart';
import 'package:mchad/utils/url_util.dart';
import 'package:mchad/views/widgets/chat_emoticon_widget.dart';
import 'package:mchad/views/widgets/chat_image_widget.dart';
import 'package:mchad/views/widgets/message_options_modal.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:html/dom.dart' as dom;

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isSentByMe;
  final int index;
  final Account account;
  final FocusNode chatboxFocusNode;
  final TextEditingController textController;
  final bool hasFollowUp;
  final bool isFollowUp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    required this.index,
    required this.account,
    required this.chatboxFocusNode,
    required this.textController,
    required this.hasFollowUp,
    required this.isFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    final constraint = min(
      MediaQuery.sizeOf(context).width / 1.5,
      MediaQuery.sizeOf(context).height / 1.5,
    );
    return Padding(
      padding: EdgeInsets.only(
        top: isFollowUp ? 0.0 : 10.0,
        bottom: hasFollowUp ? 3.0 : 10.0,
      ),
      child: ValueListenableBuilder(
        valueListenable: settingsNotifier,
        builder:
            (context, settings, child) => Align(
              alignment: switch (isSentByMe) {
                true => Alignment.centerRight,
                false => Alignment.centerLeft,
              },
              child: Container(
                margin: EdgeInsets.only(
                  top: isFollowUp ? 0 : 4,
                  bottom: hasFollowUp ? 0 : 4,
                  left: 10,
                  right: 10,
                ),
                constraints: BoxConstraints(maxWidth: constraint),
                decoration: BoxDecoration(
                  color: switch (isSentByMe) {
                    true => settings.colorScheme.primaryContainer,
                    false => settings.colorScheme.surfaceContainerHighest,
                  },
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: switch (isSentByMe) {
                      true => Radius.circular(15),
                      false => Radius.circular(hasFollowUp ? 15 : 3),
                    },
                    bottomRight: switch (isSentByMe) {
                      true => Radius.circular(hasFollowUp ? 15 : 3),
                      false => Radius.circular(15),
                    },
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: switch (isSentByMe) {
                      true => Radius.circular(15),
                      false => Radius.circular(hasFollowUp ? 15 : 3),
                    },
                    bottomRight: switch (isSentByMe) {
                      true => Radius.circular(hasFollowUp ? 15 : 3),
                      false => Radius.circular(15),
                    },
                  ),
                  child: InkWell(
                    onLongPress: () => onLongPress(context, account),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: switch (isSentByMe) {
                        true => Radius.circular(15),
                        false => Radius.circular(hasFollowUp ? 15 : 3),
                      },
                      bottomRight: switch (isSentByMe) {
                        true => Radius.circular(hasFollowUp ? 15 : 3),
                        false => Radius.circular(15),
                      },
                    ),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: HtmlWidget(
                        message.message.shortHtml,
                        renderMode: RenderMode.column,
                        customStylesBuilder: buildStyles,
                        customWidgetBuilder:
                            (element) => buildHtmlWidget(element, settings),
                        onTapUrl: (url) {
                          UrlUtil.openUrl(url);
                          return true;
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Map<String, String> buildStyles(dom.Element element) {
    if (element.innerHtml.contains('cite') ||
        (element.attributes['href']?.contains('memberlist.php') ?? false)) {
      return {};
    }
    return {'border-radius': '10px'};
  }

  Widget? buildHtmlWidget(dom.Element element, SettingsModel settings) {
    if (element.outerHtml == '<br>') {
      return SizedBox.shrink();
    }
    if (DocumentUtil.isSystemSmilie(element)) {
      return InlineCustomWidget(
        child: switch (element.attributes['alt']?.isNotEmpty) {
          true => Text(element.attributes['alt']!),
          _ => SvgPicture.network('https:${element.attributes['src']}'),
        },
      );
    }
    if (DocumentUtil.isSmilie(element)) {
      return InlineCustomWidget(
        child: ChatEmoticonWidget(
          attributes: element.attributes,
          account: account,
        ),
      );
    }
    if (DocumentUtil.isImage(element)) {
      return FittedBox(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 300),
          child: ChatImageWidget(
            src: element.attributes['src']!,
            account: account,
            settings: settings,
          ),
        ),
      );
    }
    if (DocumentUtil.isImageLink(element)) {
      return ChatImageWidget(
        src: element.attributes['href']!,
        account: account,
        settings: settings,
      );
    }
    return null;
  }

  void onLongPress(BuildContext context, Account account) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder:
          (context) => GestureDetector(
            child: MessageOptionsModal(
              isSelf: isSentByMe,
              account: account,
              message: message,
              chatboxFocusNode: chatboxFocusNode,
              textController: textController,
            ),
          ),
    );
    FocusScope.of(context).unfocus();
  }
}
