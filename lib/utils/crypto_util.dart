import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoUtil {
  static String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  static String serializeHeaders(Map<String, String> headers) {
    final entries =
        headers.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => '${e.key}:${e.value}').join('|');
  }
}
