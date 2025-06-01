import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/views/pages/login_page.dart';
import 'package:mchad/views/tabs/accounts_tab.dart';
import 'package:mchad/views/tabs/chat_tab.dart';
import 'package:mchad/views/tabs/settings_tab.dart';
import 'package:mchad/views/widgets/dark_mode_button_widget.dart';
import 'package:mchad/views/widgets/floating_scroll_button_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const tabs = [ChatTab(), AccountsTab(), SettingsTab()];

class TabsPage extends StatelessWidget {
  const TabsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: settingsNotifier,
      builder:
          (context, settings, child) => ValueListenableBuilder(
            valueListenable: selectedTabNotifier,
            builder:
                (context, selectedTab, child) => Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    title: Hero(
                      tag: 'appBarTitle',
                      child: ValueListenableBuilder(
                        valueListenable: selectedAccountNotifier,
                        builder:
                            (context, selectedAccount, child) => Material(
                              color: Colors.transparent,
                              child: Text(
                                selectedAccount?.forumName ??
                                    AppLocalizations.of(context)!.appName,
                                style: TextStyle(fontSize: 22.0),
                              ),
                            ),
                      ),
                    ),
                    actions: [DarkModeButtonWidget()],
                  ),
                  body: SafeArea(
                    child: AnimatedSwitcher(
                      duration: Duration(
                        milliseconds: settings.transitionAnimations ? 500 : 0,
                      ),
                      child: tabs[selectedTab],
                    ),
                  ),
                  floatingActionButton:
                      selectedTab == 1
                          ? FloatingActionButton.extended(
                            icon: Icon(Icons.login),
                            label: Text(AppLocalizations.of(context)!.loginButtonLabel),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            onPressed: () {
                              HapticsUtil.vibrate();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            },
                          )
                          : selectedTab == 0
                          ? FloatingScrollButtonWidget(settings: settings)
                          : null,
                  bottomNavigationBar: ValueListenableBuilder(
                    valueListenable: selectedAccountNotifier,
                    builder:
                        (context, account, child) => NavigationBar(
                          height: KNavigationBarStyle.navigationBarHeight,
                          selectedIndex: selectedTab,
                          onDestinationSelected: (value) {
                            if (selectedTab == value) return;
                            HapticsUtil.vibrate();
                            selectedTabNotifier.value = value;
                          },
                          destinations: [
                            ValueListenableBuilder(
                              valueListenable: messageMapNotifier,
                              builder: (context, messageMap, child) {
                                var unreadMessages = messageMap[account]!.where(
                                  (m) => !(m.isRead ?? false),
                                );
                                var icon =
                                    selectedTab == 0
                                        ? Icon(Icons.chat)
                                        : Icon(Icons.chat_outlined);
                                if (unreadMessages.isEmpty) {
                                  return NavigationDestination(
                                    icon: icon,
                                    label: AppLocalizations.of(context)!.chatLabelValue,
                                  );
                                }
                                return NavigationDestination(
                                  icon: Badge(
                                    label: Text('${unreadMessages.length}'),
                                    child: icon,
                                  ),
                                  label: AppLocalizations.of(context)!.chatLabelValue,
                                );
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: messageMapNotifier,
                              builder: (context, messageMap, child) {
                                var unreadMessages = <Message>[];
                                messageMap.forEach((key, messages) {
                                  if (key != account) {
                                    unreadMessages.addAll(
                                      messages.where(
                                        (m) => !(m.isRead ?? false),
                                      ),
                                    );
                                  }
                                });
                                var icon =
                                    selectedTab == 1
                                        ? Icon(Icons.people)
                                        : Icon(Icons.people_outline);
                                if (unreadMessages.isEmpty) {
                                  return NavigationDestination(
                                    icon: icon,
                                    label: AppLocalizations.of(context)!.accountsLabelValue,
                                  );
                                }
                                return NavigationDestination(
                                  icon: Badge(
                                    label: Text('${unreadMessages.length}'),
                                    child: icon,
                                  ),
                                  label: AppLocalizations.of(context)!.accountsLabelValue,
                                );
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: updateNotifier,
                              builder: (context, update, child) {
                                var icon =
                                    selectedTab == 2
                                        ? Icon(Icons.settings)
                                        : Icon(Icons.settings_outlined);
                                return NavigationDestination(
                                  icon:
                                      update == UpdateStatus.available
                                          ? Badge(label: Text('!'), child: icon)
                                          : icon,
                                  label: AppLocalizations.of(context)!.settingsLabelValue,
                                );
                              },
                            ),
                          ],
                        ),
                  ),
                ),
          ),
    );
  }
}
