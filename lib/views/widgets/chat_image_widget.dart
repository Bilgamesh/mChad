import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/utils/crypto_util.dart';
import 'package:mchad/views/pages/image_page.dart';

class ChatImageWidget extends StatelessWidget {
  const ChatImageWidget({Key? key, required this.src, required this.account})
    : super(key: key);
  final String src;
  final Account account;

  @override
  Widget build(BuildContext context) {
    final constraint = min(
      MediaQuery.sizeOf(context).width / 1.5,
      MediaQuery.sizeOf(context).height / 1.5,
    );
    final cacheKey = CryptoUtil.generateMd5('${account.getHeaders()}$src');
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: GestureDetector(
        onTap: () => open(context, account.getHeaders(), cacheKey),
        child: CachedNetworkImage(
          fadeInDuration: Duration.zero,
          placeholderFadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          imageUrl: src,
          httpHeaders: account.getHeaders(src: src),
          cacheKey: cacheKey,
          height: constraint,
          width: constraint,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => FittedBox(
                child: CircularProgressIndicator(padding: EdgeInsets.all(50)),
              ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }

  void open(
    BuildContext context,
    Map<String, String> headers,
    String cacheKey,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ImagePage(
              src: src,
              cacheKey: cacheKey,
              headers: account.getHeaders(src: src),
            ),
      ),
    );
  }
}
