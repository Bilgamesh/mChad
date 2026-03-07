import 'package:flutter/material.dart';
import 'package:mchad/config/constants.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/models/online_users_response_model.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/state/notifiers.dart';
import 'package:mchad/data/persistent-stores/account_store.dart';
import 'package:mchad/services/mchat/mchat_login_service.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/logging_util.dart';
import 'package:mchad/utils/notifier_util.dart';
import 'package:mchad/views/pages/login_page.dart';
import 'package:mchad/views/widgets/account_card_widget.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';
import 'package:mchad/data/state/globals.dart' as globals;

final logger = LoggingUtil(module: 'accounts_tab');

class AccountsTab extends StatelessWidget {
  const AccountsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: ValueListenablesBuilder(
        listenables: [
          accountsNotifier,
          selectedAccountNotifier,
          settingsNotifier,
          onlineUsersMapNotifer,
          refreshStatusNotifier,
          messageMapNotifier,
        ],
        builder: (context, values, child) {
          final accounts = values[0] as List<Account>;
          final selectedAccount = values[1] as Account?;
          final settings = values[2] as SettingsModel;
          final onlineUsersMap = values[3] as Map<Account, OnlineUsersResponse>;
          final refreshStatusMap =
              values[4] as Map<Account, VerificationStatus>;
          final messageMap = values[5] as Map<Account, List<Message>>;

          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: ListView(
              children: [
                ...List.generate(
                  accounts.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: AccountCardWidget(
                      account: accounts.elementAt(index),
                      messageMap: messageMap,
                      onlineUsersMap: onlineUsersMap,
                      refreshStatusMap: refreshStatusMap,
                      settings: settings,
                      isSelected: accounts[index] == selectedAccount,
                      onOpen: () => open(accounts[index]),
                      onSelect: switch (accounts[index] == selectedAccount) {
                        true => null,
                        false => () {
                          return select(accounts[index]);
                        },
                      },
                      onLogout: () {
                        HapticsUtil.vibrate();
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text(
                                  AppLocalizations.of(context).logout,
                                ),
                                content: Text(
                                  '${AppLocalizations.of(context).logoutConfirmation} ${accounts.elementAt(index).userName}@${accounts.elementAt(index).forumName} ${AppLocalizations.of(context).account}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      HapticsUtil.vibrate();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      AppLocalizations.of(context).cancel,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => logout(
                                          context,
                                          accounts.elementAt(index),
                                        ),
                                    child: Text(
                                      AppLocalizations.of(context).confirm,
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 200.0),
              ],
            ),
          );
        },
      ),
    );
  }

  void open(Account account) {
    select(account);
    selectedTabNotifier.value = 0;
  }

  void select(Account account) {
    HapticsUtil.vibrate();
    account.select();
    Account.saveAll();
  }

  void logout(BuildContext context, Account account) async {
    if (context.mounted) Navigator.of(context).pop();
    HapticsUtil.vibrate();
    final accountStore = await AccountStore.getInstance();
    final wasSelected = account.isSelected();

    globals.syncManager.tryStopAll();

    try {
      final loginService = MchatLoginService(baseUrl: account.forumUrl);
      await loginService.logout(account);
    } catch (e) {
      logger.error(e.toString());
    }
    try {
      await account.delete();
    } catch (e) {
      logger.error(e.toString());
    }

    if (wasSelected) {
      accountStore.getOrNull(0)?.select();
      Account.saveAll();
    }

    if (accountStore.count > 0) globals.syncManager.tryStartAll();

    if (accountStore.count == 0) {
      globals.syncManager.tryStopAll();
      Navigator.pushAndRemoveUntil(
        context.mounted ? context : globals.navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }
}
