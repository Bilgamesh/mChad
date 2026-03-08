import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/emoticons_response_model.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/utils/json_util.dart';
import 'package:mchad/utils/haptics_util.dart';

final emptyImage = Image.asset(
  'assets/images/no_avatar.gif',
  fit: BoxFit.cover,
);

class EmoticonTileWidget extends StatelessWidget {
  const EmoticonTileWidget({
    Key? key,
    required this.account,
    required this.settings,
    required this.emoticon,
    required this.chatboxFocusNode,
    required this.textController,
    required this.lastTextSelection,
  }) : super(key: key);
  final Account account;
  final SettingsModel settings;
  final Emoticon emoticon;
  final FocusNode chatboxFocusNode;
  final TextEditingController textController;
  final TextSelection? lastTextSelection;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    final cacheKey =
        '${JsonUtil.serializeHeaders(account.getHeaders())}|${emoticon.pictureUrl}';

    return ClipRRect(
      borderRadius: borderRadius,
      child: Material(
        color: settings.colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
        child: Tooltip(
          message: emoticon.title,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: () => onEmoticonTap(context, emoticon),
            child: CachedNetworkImage(
              height: 65,
              width: 65,
              scale: 0.1,
              fit: BoxFit.contain,
              fadeInDuration: Duration.zero,
              placeholderFadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              imageUrl: emoticon.pictureUrl,
              httpHeaders: account.getHeaders(src: emoticon.pictureUrl),
              errorWidget:
                  (context, url, error) =>
                      url.isEmpty ? emptyImage : SizedBox.shrink(),
              placeholder:
                  (context, url) =>
                      url.isEmpty ? emptyImage : SizedBox.shrink(),
              cacheKey: cacheKey,
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
