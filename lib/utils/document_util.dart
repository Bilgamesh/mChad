import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/bbtag_model.dart';
import 'package:mchad/utils/logging_util.dart';

var logger = LoggingUtil(module: 'document_util');

class DocumentUtil {
  static String findInputData(Document doc, String name, String field) {
    if (name.startsWith('#')) {
      final result = doc.querySelectorAll(name).elementAt(0).attributes[field];
      if (result == null) throw 'Field $field of $name missing in the document';
      return result;
    } else {
      final result =
          doc.querySelectorAll('[name="$name"]').elementAt(0).attributes[field];
      if (result == null) throw 'Field $field of $name missing in the document';
      return result;
    }
  }

  static String? extractCookie(Map<String, String> headers) {
    try {
      String result = '';
      List<String> cookies = headers['set-cookie']?.split(',') ?? [];
      List<String> authCookies =
          cookies
              .where(
                (cookie) =>
                    cookie.contains('_u=') ||
                    cookie.contains('_k=') ||
                    cookie.contains('_sid='),
              )
              .toList();

      for (String cookie in authCookies) {
        result += ' ${cookie.split(';')[0]};';
      }
      return result.trim();
    } catch (e) {
      logger.error('Failed to extract cookie due to error: $e');
      return null;
    }
  }

  static bool hasSessionCookie(Map<String, String>? headers) {
    return headers != null &&
        headers['set-cookie'] != null &&
        headers['set-cookie'] != 'null' &&
        !isAnonymousCookieUser(headers['set-cookie']!);
  }

  static bool isAnonymousCookieUser(String cookie) {
    final items = cookie.split(" ");
    for (var item in items) {
      final parts = item.split("=");
      final key = parts.elementAtOrNull(0) ?? "";
      final value = parts.elementAtOrNull(1) ?? "";
      if (key.endsWith("_u") && value == "1;") return true;
      if (key.endsWith("_u") && value != "1;" && value != ";") return false;
    }
    return false;
  }

  static String? extractUserId(String cookie) {
    RegExp regex = RegExp(r'.+_u=\d+', caseSensitive: false);
    return regex.allMatches(cookie).elementAt(0).group(0)?.split('=')[1];
  }

  static String unicodeToString(String text) {
    return text.replaceAllMapped(
      RegExp(r'\\u[\dA-F]{4}', caseSensitive: false),
      (match) {
        return String.fromCharCode(
          int.parse(match.group(0)!.replaceAll('\\u', ''), radix: 16),
        );
      },
    );
  }

  static String? extractLikeMessage(Document doc) {
    try {
      for (var script in doc.getElementsByTagName('script')) {
        if (script.text.contains('\tlikes\t')) {
          final regex = RegExp(r"\tlikes\s+:\s'(.+?)'", caseSensitive: false);
          final match = regex.firstMatch(script.text);
          if (match == null) return null;
          return unicodeToString(match.group(0)!.split('\'')[1]);
        }
      }
      return null;
    } catch (e) {
      logger.error('Failed to extract like message due to error: $e');
      return null;
    }
  }

  static List<BBTag>? extractBBTags(Document doc) {
    try {
      for (var script in doc.getElementsByTagName('script')) {
        if (script.text.contains('bbtags = new Array(')) {
          final bbTagsArr = script.text
              .split('bbtags = new Array(')
              .last
              .split(');')
              .elementAt(0)
              .split(',')
              .map((tag) => tag.replaceAll('\'', '').trim());
          List<BBTag> bbtags = [];
          for (var i = 0; i < bbTagsArr.length; i += 2) {
            bbtags.add(
              BBTag(
                start: bbTagsArr.elementAt(i),
                end: bbTagsArr.elementAt(i + 1),
                name: bbTagsArr
                    .elementAt(i)
                    .substring(1, bbTagsArr.elementAt(i).length - 1),
              ),
            );
          }
          return bbtags;
        }
      }
      return null;
    } catch (e) {
      logger.error('Failed to extract BBtags due to error: $e');
      return null;
    }
  }

  static int extractEditDeleteLimit(Document doc) {
    try {
      for (var script in doc.getElementsByTagName('script')) {
        if (script.text.contains('editDeleteLimit')) {
          final limit =
              script.text
                  .split('editDeleteLimit')
                  .elementAt(1)
                  .split(',')
                  .elementAt(0)
                  .replaceFirst(':', '')
                  .trim();
          return int.tryParse(limit) ?? 0;
        }
      }
      return 0;
    } catch (e) {
      logger.error('Failed to extract editDeleteLimit due to error: $e');
      return 0;
    }
  }

  static int extractMessageLimit(Document doc) {
    try {
      for (var script in doc.getElementsByTagName('script')) {
        if (script.text.contains('editDeleteLimit')) {
          final limit =
              script.text
                  .split('mssgLngth')
                  .elementAt(1)
                  .split(',')
                  .elementAt(0)
                  .replaceFirst(':', '')
                  .trim();
          return int.tryParse(limit) ?? 0;
        }
      }
      return 0;
    } catch (e) {
      logger.error('Failed to extract message limit due to error: $e');
      return 0;
    }
  }

  static String? extractLogId(Document doc) {
    try {
      for (var script in doc.getElementsByTagName('script')) {
        if (script.text.contains('\tlikes\t')) {
          final regex = RegExp(r'logId\s+:\s(\d+),');
          final match = regex.firstMatch(script.text);
          if (match != null) {
            return match.group(1);
          }
        }
      }
      return null;
    } catch (e) {
      logger.error('Failed to extract log ID due to error: $e');
      return null;
    }
  }

  static String removeInnerBlockquotes(String htmlString) {
    try {
      final document = parse(htmlString);
      final topLevelBlockquotes = document.querySelectorAll('blockquote');
      for (var blockquote in topLevelBlockquotes) {
        final innerBlockquotes = blockquote.querySelectorAll('blockquote');
        for (var inner in innerBlockquotes) {
          inner.remove();
        }
      }
      return document.body?.innerHtml ?? '';
    } catch (e) {
      logger.error('Failed to remove inner blockquotes due to error: $e');
      return htmlString;
    }
  }

  static bool isImageUrl(String text) {
    final RegExp imageUrlPattern = RegExp(
      r'^(https?:\/\/.*\.(?:png|jpg|jpeg|gif|bmp|webp|svg))$',
      caseSensitive: false,
    );
    return imageUrlPattern.hasMatch(text);
  }

  static bool isValidUrl(String url) {
    final RegExp urlPattern = RegExp(
      r'^(https?:\/\/)?([a-z0-9\-]+\.)+[a-z]{2,6}(\/[^\s]*)?$',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(url);
  }

  static bool isImage(Element element) {
    return (element.toString().contains('img'));
  }

  static bool isSmilie(Element element) {
    return isImage(element) &&
        (element.attributes['class']?.contains('smilies') ?? false);
  }

  static bool isSystemSmilie(Element element) {
    return element.className == 'emoji smilies' &&
        (element.attributes['alt'] != null ||
            element.attributes['src'] != null);
  }

  static bool isImageLink(Element element) {
    final isLink = element.attributes['class']?.contains('postlink') ?? false;
    if (!isLink) return false;
    final url = element.attributes['href']?.toString() ?? '';
    final extension = '.${url.split('.').lastOrNull ?? ''}';
    return KImageConfig.imageExtensions.contains(extension);
  }

  static bool isCloudflare(String body, String baseUrl) {
    if (!baseUrl.startsWith('https')) return false;
    return body.contains('>cloudflare<') ||
        body.contains('<title>Just a moment...</title>');
  }

  static String fixMessageLinks(String baseUrl, String message) {
    message = message
        .replaceAll('src="./', 'src="$baseUrl/')
        .replaceAll('href="./', 'href="$baseUrl/');
    message = fixEmbeddedYoutube(message);
    return message;
  }

  static String replaceLastOccurrence(
    String original,
    String toReplace,
    String replacement,
  ) {
    int lastIndex = original.lastIndexOf(toReplace);
    if (lastIndex != -1) {
      return original.replaceRange(
        lastIndex,
        lastIndex + toReplace.length,
        replacement,
      );
    }
    return original;
  }

  static String fixEmbeddedYoutube(String message) {
    while (message.contains('<iframe')) {
      final url = message
          .split('src="')[1]
          .split('"')[0]
          .replaceAll('embed/', 'watch?v=');
      message = message
          .replaceFirst(
            RegExp(r'<iframe ', caseSensitive: false),
            '<a href="$url" ',
          )
          .replaceFirst(
            RegExp(r'><\/iframe>', caseSensitive: false),
            '>$url</a>',
          );
    }
    return message;
  }

  static bool isJson(String text) {
    try {
      jsonDecode(text) as Map<String, dynamic>;
      return true;
    } catch (e) {
      return false;
    }
  }
}
