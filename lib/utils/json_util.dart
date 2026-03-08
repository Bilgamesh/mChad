class JsonUtil {
  static String serializeHeaders(Map<String, String> headers) {
    final entries =
        headers.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => '${e.key}:${e.value}').join('|');
  }
}
