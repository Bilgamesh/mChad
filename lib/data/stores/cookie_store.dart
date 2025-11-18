import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CookieStore {
  CookieStore({required this.forumName, required this.userId})
    : secureStorage = FlutterSecureStorage(),
      key = '${forumName.replaceAll('.', '_')}_$userId';
  final String forumName;
  final String userId;
  final FlutterSecureStorage secureStorage;
  final String key;

  Future<String> get() async {
    final cookie = await secureStorage.read(key: key);
    if (cookie == null) throw 'Cookie does not exist';
    return cookie;
  }

  Future<void> set(String cookie) async {
    await secureStorage.write(key: key, value: cookie);
  }

  Future<void> del() async {
    await secureStorage.delete(key: key);
  }
}
