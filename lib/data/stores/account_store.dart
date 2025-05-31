import 'package:mchad/data/models/account_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountStore {
  AccountStore({required this.prefs}) : key = 'phpbb_accounts';
  final String key;
  SharedPreferences prefs;

  static Future<AccountStore> getInstance() async {
    var prefs = await SharedPreferences.getInstance();
    return AccountStore(prefs: prefs);
  }

  Future<int> add(Account account) async {
    var existing = prefs.getStringList(key) ?? [];
    var index = existing.length;
    prefs.setStringList(key, [...existing, account.toString()]);
    return index;
  }

  Future<int> update(Account account) async {
    var existing = getAll();
    var index = existing.indexOf(account);
    if (index == -1) throw 'Account does not exist';
    var existingStr = prefs.getStringList(key) ?? [];
    existingStr[index] = account.toString();
    prefs.setStringList(key, existingStr);
    return index;
  }

  List<Account> getAll() {
    var values = prefs.getStringList(key) ?? [];
    var allAccounts = <Account>[];
    for (var value in values) {
      var account = Account.fromString(value);
      allAccounts.add(account);
    }
    return allAccounts;
  }

  Account get(int index) {
    var values = prefs.getStringList(key);
    if (values == null) throw 'No data is stored';
    if (values.length <= index) throw 'Index out of range';
    return Account.fromString(values[index]);
  }

  Account? getOrNull(int index) {
    var values = prefs.getStringList(key);
    if (values == null) return null;
    if (values.length <= index) return null;
    return Account.fromString(values[index]);
  }

  int indexOf(Account account) {
    var accounts = getAll();
    for (var i = 0; i < accounts.length; i++) {
      if (accounts.elementAt(i) == account) {
        return i;
      }
    }
    return -1;
  }

  Account? find(bool Function(Account account) predicate) {
    var accounts = getAll();
    for (var account in accounts) {
      if (predicate(account)) return account;
    }
    return null;
  }

  int getCount() {
    var values = prefs.getStringList(key) ?? [];
    return values.length;
  }

  Future<void> remove(int index) async {
    var values = prefs.getStringList(key) ?? [];
    values.removeAt(index);
    await prefs.setStringList(key, values);
  }

  Future<void> removeAll() async {
    await prefs.remove(key);
  }
}
