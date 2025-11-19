import 'package:mchad/data/models/account_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountStore {
  AccountStore({required this.prefs}) : key = 'phpbb_accounts';
  final String key;
  SharedPreferences prefs;

  static Future<AccountStore> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return AccountStore(prefs: prefs);
  }

  Future<int> add(Account account) async {
    final existing = prefs.getStringList(key) ?? [];
    final index = existing.length;
    prefs.setStringList(key, [...existing, account.toString()]);
    return index;
  }

  Future<int> update(Account account) async {
    final index = all.indexOf(account);
    if (index == -1) throw 'Account does not exist';
    final existingStr = prefs.getStringList(key) ?? [];
    existingStr[index] = account.toString();
    prefs.setStringList(key, existingStr);
    return index;
  }

  List<Account> get all {
    final values = prefs.getStringList(key) ?? [];
    final allAccounts = <Account>[];
    for (var value in values) {
      final account = Account.fromString(value);
      allAccounts.add(account);
    }
    return allAccounts;
  }

  Account get(int index) {
    final values = prefs.getStringList(key);
    if (values == null) throw 'No data is stored';
    if (values.length <= index) throw 'Index out of range';
    return Account.fromString(values[index]);
  }

  Account? getOrNull(int index) {
    final values = prefs.getStringList(key);
    if (values == null) return null;
    if (values.length <= index) return null;
    return Account.fromString(values[index]);
  }

  int indexOf(Account account) {
    for (var i = 0; i < all.length; i++) {
      if (all.elementAt(i) == account) {
        return i;
      }
    }
    return -1;
  }

  Account? find(bool Function(Account account) predicate) {
    for (var account in all) {
      if (predicate(account)) return account;
    }
    return null;
  }

  int get count {
    final values = prefs.getStringList(key) ?? [];
    return values.length;
  }

  Future<void> remove(int index) async {
    final values = prefs.getStringList(key) ?? [];
    values.removeAt(index);
    await prefs.setStringList(key, values);
  }

  Future<void> removeAll() async {
    await prefs.remove(key);
  }
}
