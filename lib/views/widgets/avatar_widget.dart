import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/utils/crypto_util.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({Key? key, required this.avatarSrc, required this.account})
    : super(key: key);
  final String? avatarSrc;
  final Account account;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 25.0,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarSrc ?? '',
          httpHeaders: account.getHeaders(src: avatarSrc),
          cacheKey: CryptoUtil.generateMd5('${account.getHeaders()}$avatarSrc'),
          placeholder:
              (context, url) =>
                  Image.asset('assets/images/no_avatar.gif', fit: BoxFit.cover),
          errorWidget:
              (context, url, error) =>
                  Image.asset('assets/images/no_avatar.gif', fit: BoxFit.cover),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
