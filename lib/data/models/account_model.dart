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
    var index = accountsNotifier.value.indexOf(this);
    if (index == -1) {
      accountsNotifier.value.add(this);
    } else {
      accountsNotifier.value[index] = this;
    }
    accountsNotifier.notifyListeners();
    return this;
  }

  static Account fromString(String stringifiedAccount) {
    var decodedList = List<String>.from(jsonDecode(stringifiedAccount));
    var account = Account(
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
    var store = await AccountStore.getInstance();
    return store.get(index);
  }

  static Future<List<Account>> getAll() async {
    var store = await AccountStore.getInstance();
    return store.getAll();
  }

  static Future<void> saveAll() async {
    var accounts = await getAll();
    for (var account in accounts) {
      await account.save();
    }
  }

  Future<int> save() async {
    var store = await AccountStore.getInstance();
    var index = store.indexOf(this);
    if (index != -1) {
      return await store.update(this);
    } else {
      return await store.add(this);
    }
  }

  Future<int> getIndex() async {
    var store = await AccountStore.getInstance();
    return store.indexOf(this);
  }

  Future<void> delete() async {
    var store = await AccountStore.getInstance();
    var index = store.indexOf(this);
    if (index == -1) throw 'Account is not saved. Failed to delete.';
    accountsNotifier.value.removeAt(index);
    accountsNotifier.notifyListeners();
    store.remove(index);
  }

  Future<void> setCookies(String cookie) async {
    return await cookieStore.set(cookie);
  }

  Future<void> updateCookies(String cookies) async {
    var split = cookies.split(' ');
    for (var cookie in split) {
      await updateCookie(cookie);
    }
  }

  Future<void> addCookie(String cookie) async {
    if (!cookie.endsWith(';')) cookie += ';';
    var existing = await getCookies();
    var all = existing.split(' ');
    all.add(cookie);
    await setCookies(all.join(' '));
  }

  Future<String> getCookies() async {
    cachedCookies = await cookieStore.get();
    return cachedCookies!;
  }

  Future<void> removeCookie(String cookie) async {
    var name = cookie.split('=').first;
    var existing = await getCookies();
    var all = existing.split(' ');
    for (var cookie in [...all]) {
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
}
