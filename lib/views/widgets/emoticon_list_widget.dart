import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/emoticons_response_model.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/crypto_util.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/value_listenables_builder.dart';

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

  Map<String, String> getHeaders({required bool condition}) {
    if (!condition) return {};
    return {
      'x-requested-with': 'XMLHttpRequest',
      'cookie': account.cachedCookies ?? '',
      'user-agent': account.userAgent ?? '',
    };
  }

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
            final settings = values[1] as SettingsModel;
            return SafeArea(
              child: Wrap(
                children: List.generate(
                  emoticonMap[account]?.length ?? 0,
                  (index) => Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: settings.colorScheme.surfaceContainerHighest,
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
                                      emoticonMap[account]![index].pictureUrl,
                                  httpHeaders: getHeaders(
                                    condition: emoticonMap[account]![index]
                                        .pictureUrl
                                        .startsWith(account.forumUrl),
                                  ),
                                  cacheKey: CryptoUtil.generateMd5(
                                    '${getHeaders(condition: true)}${emoticonMap[account]![index].pictureUrl}',
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
