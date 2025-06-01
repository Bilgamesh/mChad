import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({Key? key}) : super(key: key);

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  final browser = InAppBrowser();
  final settings = InAppBrowserClassSettings(
    browserSettings: InAppBrowserSettings(hideUrlBar: false),
    webViewSettings: InAppWebViewSettings(
      javaScriptEnabled: true,
      isInspectable: true,
    ),
  );

  CookieManager cookieManager = CookieManager.instance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.appName)),
      body: Center(
        child: Column(
          children: [
            OutlinedButton(
              onPressed: () async {
                // var request = URLRequest(
                //   url: WebUri('https://introwertyzm.pl'),
                // );

                // await browser.openUrlRequest(
                //   urlRequest: request,
                //   settings: settings,
                // );

                // print('DONE!!!!!');

                // var html = await browser.platform.webViewController?.getHtml();
                // print('HTML:');
                // print(html);

                var headlessWebView = HeadlessInAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri('https://introwertyzm.pl/ucp.php?mode=login'),
                  ),
                  initialSettings: InAppWebViewSettings(
                    isInspectable: true,
                    incognito: true,
                  ),
                  onWebViewCreated: (controller) async {
                    var html = await controller.getHtml();
                    print('HTML!!!! - onWebViewCreated');
                    print(html);
                  },
                  onLoadStart: (controller, url) async {
                    var html = await controller.getHtml();
                    print('HTML!!!! - onLoadStart');
                    print(html);
                  },
                  onLoadStop: (controller, url) async {
                    var results = await controller.callAsyncJavaScript(
                      functionBody: 'return navigator.userAgent;',
                    );
                    print('JS RESULTS!!!!!!!!!!!!');
                    print(results);

                    var cookie = await CookieManager.instance().getCookie(
                      url: WebUri('https://introwertyzm.pl'),
                      name: 'cf_clearance',
                    );
                    print('COOKIE!!!!!');
                    print(cookie);

                    // działa, mam cookie oraz user agenta
                  },
                );

                await headlessWebView.run();
              },
              child: Text('Open browser'),
            ),
          ],
        ),
      ),
    );
  }
}
