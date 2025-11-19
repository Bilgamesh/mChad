import 'dart:convert';

import 'package:mchad/data/notifiers.dart';
import 'package:mchad/data/stores/account_store.dart';
import 'package:mchad/data/stores/cookie_store.dart';

class Account {
  Account({
    required this.userName,
    required this.userId,
    required this.forumName,
    required this.forumUrl,
    this.avatarUrl,
    this.userAgent,
    this.wasPreviouslySelected,
  }) : cookieStore = CookieStore(forumName: forumName, userId: userId);

  String? avatarUrl;
  String userName;
  final String userId, forumName, forumUrl;
  final CookieStore cookieStore;
  String? formToken, creationTime;
  String? userAgent;
  String? cachedCookies;
  bool? wasPreviouslySelected;

  @override
  bool operator ==(Object other) => hashCode == other.hashCode;

  @override
  int get hashCode => 'AccountModel_${userId}_$forumName'.hashCode;

  @override
  String toString() => jsonEncode(<String>[
    userName,
    userId,
    forumName,
    forumUrl,
    userAgent ?? '',
    isSelected().toString(),
  ]);

  Account updateNotifiers() {
    messageMapNotifier.value[this] = messageMapNotifier.value[this] ?? [];
    bbtagMapNotifier.value[this] = bbtagMapNotifier.value[this] ?? [];
    emoticonMapNotifer.value[this] = emoticonMapNotifer.value[this] ?? [];
    editDeleteLimitMapNotifier.value[this] =
        editDeleteLimitMapNotifier.value[this] ?? 0;
    final index = accountsNotifier.value.indexOf(this);
    if (index == -1) {
      accountsNotifier.value.add(this);
    } else {
      accountsNotifier.value[index] = this;
    }
    accountsNotifier.notifyListeners();
    return this;
  }

  static Account fromString(String stringifiedAccount) {
    final decodedList = List<String>.from(jsonDecode(stringifiedAccount));
    final account = Account(
      userName: decodedList.elementAt(0),
      userId: decodedList.elementAt(1),
      forumName: decodedList.elementAt(2),
      forumUrl: decodedList.elementAt(3),
      userAgent: decodedList.elementAtOrNull(4),
      wasPreviouslySelected: decodedList.elementAtOrNull(5) == 'true',
    );
    return account;
  }

  static Future<Account> fromStore(int index) async {
    final store = await AccountStore.getInstance();
    return store.get(index);
  }

  static Future<List<Account>> getAll() async {
    final store = await AccountStore.getInstance();
    return store.all;
  }

  static Future<void> saveAll() async {
    final accounts = await getAll();
    for (final account in accounts) {
      await account.save();
    }
  }

  Future<int> save() async {
    final store = await AccountStore.getInstance();
    final index = store.indexOf(this);
    if (index != -1) {
      return await store.update(this);
    } else {
      return await store.add(this);
    }
  }

  Future<int> getIndex() async {
    final store = await AccountStore.getInstance();
    return store.indexOf(this);
  }

  Future<void> delete() async {
    final store = await AccountStore.getInstance();
    final index = store.indexOf(this);
    if (index == -1) throw 'Account is not saved. Failed to delete.';
    accountsNotifier.value.removeAt(index);
    accountsNotifier.notifyListeners();
    store.remove(index);
  }

  Future<void> setCookies(String cookie) async {
    return await cookieStore.set(cookie);
  }

  Future<void> updateCookies(String cookies) async {
    final split = cookies.split(' ');
    for (final cookie in split) {
      await updateCookie(cookie);
    }
  }

  Future<void> addCookie(String cookie) async {
    if (!cookie.endsWith(';')) cookie += ';';
    final existing = await getCookies();
    final all = existing.split(' ');
    all.add(cookie);
    await setCookies(all.join(' '));
  }

  Future<String> getCookies() async {
    cachedCookies = await cookieStore.get();
    return cachedCookies!;
  }

  Future<void> removeCookie(String cookie) async {
    final name = cookie.split('=').first;
    final existing = await getCookies();
    final all = existing.split(' ');
    for (final cookie in [...all]) {
      if (cookie.split('=').first == name) {
        all.remove(cookie);
      }
    }
    await setCookies(all.join(' '));
  }

  Future<void> updateCookie(String cookie) async {
    await removeCookie(cookie);
    await addCookie(cookie);
  }

  Future<void> removeCookies() async {
    return await cookieStore.del();
  }

  bool isSelected() {
    return selectedAccountNotifier.value == this;
  }

  void select() {
    selectedAccountNotifier.value = this;
  }

  Map<String, String> getHeaders({String? src}) {
    if (src == null || src.startsWith(forumUrl)) {
      return {
        'x-requested-with': 'XMLHttpRequest',
        'cookie': cachedCookies ?? '',
        'user-agent': userAgent ?? '',
      };
    }
    return {};
  }
}
