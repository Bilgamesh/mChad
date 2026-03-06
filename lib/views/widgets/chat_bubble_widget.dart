import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/models/settings_model.dart';
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
  final SettingsModel settings;

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
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final constraint = min(
      MediaQuery.sizeOf(context).width / 1.5,
      MediaQuery.sizeOf(context).height / 1.5,
    );

    final borderRadius = getBubbleBorderRadius();

    return Padding(
      padding: EdgeInsets.only(
        top: isFollowUp ? 0.0 : 10.0,
        bottom: hasFollowUp ? 3.0 : 10.0,
      ),
      child: Align(
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
            borderRadius: borderRadius,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            child: InkWell(
              onLongPress: () => onLongPress(context, account),
              borderRadius: borderRadius,
              child: Container(
                padding: const EdgeInsets.all(10),
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

  BorderRadius getBubbleBorderRadius() {
    final bottomLeft = isSentByMe ? 15.0 : (hasFollowUp ? 15.0 : 3.0);
    final bottomRight = isSentByMe ? (hasFollowUp ? 15.0 : 3.0) : 15.0;

    return BorderRadius.only(
      topLeft: const Radius.circular(15),
      topRight: const Radius.circular(15),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
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
