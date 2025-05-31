import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/cloudflare_authorization_model.dart';

class CloudflareService {
  CloudflareService({required this.baseUrl});
  final String baseUrl;

  Future<CloudflareAuthorization> authorizeHeadless() async {
    Completer<CloudflareAuthorization> completer =
        Completer<CloudflareAuthorization>();
    String? cookie;
    String? userAgent;
    var headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri('$baseUrl/ucp.php?mode=login')),
      initialSettings: InAppWebViewSettings(
        isInspectable: true,
        incognito: true,
      ),
      onLoadStop: (controller, url) async {
        var jsResponse = await controller.callAsyncJavaScript(
          functionBody: 'return navigator.userAgent;',
        );
        userAgent = jsResponse?.value.toString();
        var cookieResponse = await CookieManager.instance().getCookie(
          url: WebUri(baseUrl),
          name: 'cf_clearance',
        );
        if (cookieResponse != null) {
          cookie = '${cookieResponse.name}=${cookieResponse.value};';
        }
      },
    );
    await headlessWebView.run();
    var count = 0;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      count++;
      if (cookie != null && userAgent != null) {
        timer.cancel();
        headlessWebView.dispose();
        completer.complete(
          CloudflareAuthorization(cookie: cookie!, userAgent: userAgent!),
        );
      } else if (count > KCloudflareConfig.cloudflareTimeoutSeconds) {
        timer.cancel();
        headlessWebView.dispose();
        completer.completeError('Cloudflare timeout');
      }
    });

    return completer.future;
  }
}
