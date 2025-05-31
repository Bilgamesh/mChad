import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/utils/crypto_util.dart';

class ChatEmoticonWidget extends StatelessWidget {
  const ChatEmoticonWidget({
    Key? key,
    required this.attributes,
    required this.account,
  }) : super(key: key);
  final LinkedHashMap<Object, String> attributes;
  final Account account;

  @override
  Widget build(BuildContext context) {
    var headers = {
      'x-requested-with': 'XMLHttpRequest',
      'cookie': account.cachedCookies ?? '',
      'user-agent': account.userAgent ?? '',
    };
    var cacheKey = CryptoUtil.generateMd5('$headers${attributes['src']}');
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: CachedNetworkImage(
        imageUrl: attributes['src']!,
        httpHeaders: headers,
        cacheKey: cacheKey,
        fit: BoxFit.cover,
        height: double.tryParse(attributes['height'] ?? ''),
        width: double.tryParse(attributes['width'] ?? ''),
        placeholder:
            (context, url) =>
                CircularProgressIndicator(padding: EdgeInsets.all(100)),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }
}
