import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/utils/document_util.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/modal_util.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({
    Key? key,
    required this.src,
    required this.headers,
    required this.cacheKey,
  }) : super(key: key);
  final String src;
  final Map<String, String> headers;
  final String cacheKey;

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  var uiVisible = true;

  @override
  void dispose() {
    if (!uiVisible) {
      showUi();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var fileName = urlToName(widget.src);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: uiVisible,
        title: FittedBox(
          child: switch (uiVisible) {
            true => Text(fileName, style: TextStyle(color: Colors.white)),
            false => null,
          },
        ),
        backgroundColor: uiVisible ? Colors.black54 : Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (uiVisible)
            IconButton(
              onPressed: () => download(widget.src, fileName, context),
              icon: Icon(Icons.download),
            ),
          if (uiVisible)
            IconButton(
              onPressed: () => share(widget.src),
              icon: Icon(Icons.share),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            uiVisible = !uiVisible;
            if (!uiVisible) {
              hideUi();
            } else {
              showUi();
            }
          });
        },
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(
            widget.src,
            headers: widget.headers,
            cacheKey: widget.cacheKey,
          ),
          gaplessPlayback: true,
        ),
      ),
    );
  }

  void hideUi() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  void showUi() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    ); // to re-show bars
  }

  String urlToName(String url) {
    var fileName = url.split('/').last;
    if (!fileName.contains('/') &&
        KImageConfig.imageExtensions.contains(
          '.${fileName.split('.').last.toLowerCase()}',
        )) {
      return fileName.toLowerCase();
    }
    return 'image-${DateTime.now().millisecondsSinceEpoch}';
  }

  void share(String url) {
    HapticsUtil.vibrate();
    SharePlus.instance.share(ShareParams(text: url));
  }

  bool hasExtension(String fileName) {
    for (var extension in KImageConfig.imageExtensions) {
      if (fileName.toLowerCase().endsWith(extension)) return true;
    }
    return false;
  }

  Future<void> download(
    String url,
    String fileName,
    BuildContext context,
  ) async {
    HapticsUtil.vibrate();
    try {
      if (!hasExtension(fileName)) {
        fileName += '.png';
      }
      var path = '/storage/emulated/0/Download/$fileName';
      var file = File(path);
      var index = 0;
      while (await file.exists()) {
        for (var extension in KImageConfig.imageExtensions) {
          if (fileName.toLowerCase().endsWith(extension)) {
            path =
                '/storage/emulated/0/Download/${DocumentUtil.replaceLastOccurrence(fileName, extension, ' (${++index})$extension')}';
            break;
          }
        }
        file = File(path);
      }
      if (index > 0) {
        fileName = path.replaceFirst('/storage/emulated/0/Download/', '');
      }
      var res = await get(Uri.parse(url));
      await file.writeAsBytes(res.bodyBytes);
      if (!context.mounted) return;
      ModalUtil.showMessage(
        '${AppLocalizations.of(context).imageSaved} $fileName',
      );
    } catch (e) {
      ModalUtil.showError(e);
    }
  }
}
