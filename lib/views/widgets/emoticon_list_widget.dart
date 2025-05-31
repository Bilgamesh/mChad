import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/emoticons_response_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/crypto_util.dart';
import 'package:mchad/utils/haptics_util.dart';

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
  Widget build(BuildContext context) {
    var headers = {
      'x-requested-with': 'XMLHttpRequest',
      'cookie': account.cachedCookies ?? '',
      'user-agent': account.userAgent ?? '',
    };

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: SingleChildScrollView(
          controller: scrollController,
          child: ValueListenableBuilder(
            valueListenable: emoticonMapNotifer,
            builder:
                (context, emoticonMap, child) => Wrap(
                  children: List.generate(
                    emoticonMap[account]?.length ?? 0,
                    (index) => Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: ValueListenableBuilder(
                          valueListenable: settingsNotifier,
                          builder:
                              (context, settings, child) => Container(
                                decoration: BoxDecoration(
                                  color:
                                      settings
                                          .colorScheme
                                          .surfaceContainerHighest,
                                ),
                                height: 65,
                                width: 65,
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Tooltip(
                                    message: emoticonMap[account]![index].title,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12.0),
                                      onTap:
                                          () => onEmoticonTap(
                                            context,
                                            emoticonMap[account]![index],
                                          ),
                                      child: FittedBox(
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              emoticonMap[account]![index]
                                                  .pictureUrl,
                                          httpHeaders:
                                              emoticonMap[account]![index]
                                                      .pictureUrl
                                                      .startsWith(
                                                        account.forumUrl,
                                                      )
                                                  ? headers
                                                  : {},
                                          cacheKey: CryptoUtil.generateMd5(
                                            '$headers${emoticonMap[account]![index].pictureUrl}',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  void onEmoticonTap(BuildContext context, Emoticon emoticon) {
    HapticsUtil.vibrate();
    Navigator.pop(context);
    chatboxFocusNode.requestFocus();
    if (lastTextSelection == null) {
      textController.text += ' ${emoticon.code} ';
      return;
    }
    var left = textController.text.substring(0, lastTextSelection!.start);
    var right = textController.text.substring(lastTextSelection!.start);
    textController.value = TextEditingValue(
      text: '$left ${emoticon.code} $right',
      selection: TextSelection.fromPosition(
        TextPosition(offset: '$left ${emoticon.code} '.length),
      ),
    );
  }
}
