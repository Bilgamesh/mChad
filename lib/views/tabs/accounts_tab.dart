import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/data/stores/account_store.dart';
import 'package:mchad/services/mchat/mchat_login_service.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/logging_util.dart';
import 'package:mchad/views/pages/login_page.dart';
import 'package:mchad/views/widgets/account_card_widget.dart';
import 'package:mchad/data/globals.dart' as globals;

final logger = LoggingUtil(module: 'accounts_tab');

class AccountsTab extends StatelessWidget {
  const AccountsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: languageNotifier,
      builder:
          (context, language, child) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: ValueListenableBuilder(
              valueListenable: accountsNotifier,
              builder:
                  (context, accounts, child) => ListView(
                    // physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      ...List.generate(
                        accounts.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: ValueListenableBuilder(
                            valueListenable: selectedAccountNotifier,
                            builder:
                                (
                                  context,
                                  selectedAccount,
                                  child,
                                ) => AccountCardWidget(
                                  account: accounts.elementAt(index),
                                  isSelected:
                                      accounts[index] == selectedAccount,
                                  onOpen: () => open(accounts[index]),
                                  onSelect:
                                      accounts[index] == selectedAccount
                                          ? null
                                          : () => select(accounts[index]),
                                  onLogout: () {
                                    HapticsUtil.vibrate();
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: Text(language.logout),
                                            content: Text(
                                              '${language.logoutConfirmation} ${accounts.elementAt(index).userName}@${accounts.elementAt(index).forumName} ${language.account}?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  HapticsUtil.vibrate();
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(language.cancel),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => logout(
                                                      context,
                                                      accounts.elementAt(index),
                                                    ),
                                                child: Text(language.confirm),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                ),
                          ),
                        ),
                      ),
                      SizedBox(height: 200.0),
                    ],
                  ),
            ),
          ),
    );
  }

  open(Account account) {
    select(account);
    selectedTabNotifier.value = 0;
  }

  select(Account account) {
    HapticsUtil.vibrate();
    account.select();
    Account.saveAll();
  }

  logout(BuildContext context, Account account) async {
    HapticsUtil.vibrate();
    var accountStore = await AccountStore.getInstance();
    var wasSelected = account.isSelected();
    globals.syncManager.stopAll();
    try {
      var loginService = MchatLoginService(baseUrl: account.forumUrl);
      await loginService.logout(account);
      await account.delete();
    } catch (e) {
      logger.error(e.toString());
    } finally {
      if (wasSelected) {
        accountStore.getOrNull(0)?.select();
        Account.saveAll();
      }
      globals.syncManager.startAll();
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted && accountStore.getCount() == 0) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      }
    }
  }
}
