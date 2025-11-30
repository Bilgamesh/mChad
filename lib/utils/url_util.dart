import 'package:mchad/data/notifiers.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlUtil {
  static List<String> getAllUrlPermutations(String userProvidedUrl) {
    userProvidedUrl = userProvidedUrl.toLowerCase().replaceFirst(
      'index.php',
      '',
    );
    while (userProvidedUrl.endsWith('/')) {
      userProvidedUrl = userProvidedUrl.substring(userProvidedUrl.length - 1);
    }
    var core = userProvidedUrl
        .replaceFirst('https://', '')
        .replaceFirst('http://', '');
    if (core.startsWith('www.')) core = core.replaceFirst('www.', '');
    final permutations = [
      'https://$core',
      'https://www.$core',
      'http://$core',
      'http://www.$core',
    ];
    if (userProvidedUrl.startsWith('https://')) {
      permutations.insert(0, userProvidedUrl);
    }
    return permutations.toSet().toList();
  }

  static String mapToUrlEncoded(Map<String, String> data) {
    return data.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}',
        )
        .join('&');
  }

  static String convertUrlToName(String baseUrl) {
    var name = baseUrl
        .toLowerCase()
        .replaceFirst('https://www.', '')
        .replaceFirst('https://', '')
        .split('/')
        .elementAt(0);
    if (name.startsWith('www.')) name = name.replaceFirst('www.', '');
    return name[0].toUpperCase() + name.substring(1);
  }

  static Future<void> openUrl(String url) async {
    final LaunchMode mode =
        settingsNotifier.value.openLinksInBrowser
            ? LaunchMode.externalApplication
            : LaunchMode.inAppBrowserView;
    if (!await launchUrl(Uri.parse(url), mode: mode)) {
      throw Exception('Could not launch $url');
    }
  }
}
