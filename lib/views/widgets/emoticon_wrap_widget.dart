import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/emoticons_response_model.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/utils/crypto_util.dart';
import 'package:mchad/utils/haptics_util.dart';

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
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(
        emoticons.length,
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
                  message: emoticons[index].title,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.0),
                    onTap: () => onEmoticonTap(context, emoticons[index]),
                    child: FittedBox(
                      child: CachedNetworkImage(
                        fadeInDuration: Duration.zero,
                        placeholderFadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        imageUrl: emoticons[index].pictureUrl,
                        httpHeaders: account.getHeaders(
                          src: emoticons[index].pictureUrl,
                        ),
                        errorWidget:
                            (context, url, error) =>
                                url.isEmpty
                                    ? Image.asset(
                                      'assets/images/no_avatar.gif',
                                      fit: BoxFit.cover,
                                    )
                                    : SizedBox.shrink(),
                        placeholder:
                            (context, url) =>
                                url.isEmpty
                                    ? Image.asset(
                                      'assets/images/no_avatar.gif',
                                      fit: BoxFit.cover,
                                    )
                                    : SizedBox.shrink(),
                        cacheKey: CryptoUtil.generateMd5(
                          '${account.getHeaders()}${emoticons[index].pictureUrl}',
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
