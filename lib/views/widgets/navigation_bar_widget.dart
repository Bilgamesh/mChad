import 'package:flutter/material.dart';
import 'package:mchad/config/constants.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/state/notifiers.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/notifier_util.dart';

class NavigationBarWidget extends StatelessWidget {
  const NavigationBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenablesBuilder(
      listenables: [
        selectedAccountNotifier,
        selectedTabNotifier,
        messageMapNotifier,
        updateNotifier,
      ],
      builder: (context, values, child) {
        final account = values[0] as Account?;
        final selectedTab = values[1] as int;
        final messageMap = values[2] as Map<Account, List<Message>>;
        final messages = messageMap[account] ?? [];
        final update = values[3] as UpdateStatus;
        final l10n = AppLocalizations.of(context);
        final unreadMessagesCurrent = messages.where(
          (m) => !(m.isRead ?? false),
        );
        final unreadMessagesRemaining = <Message>[];
        messageMap.forEach((key, messages) {
          if (key != account) {
            unreadMessagesRemaining.addAll(
              messages.where((m) => !(m.isRead ?? false)),
            );
          }
        });

        return NavigationBar(
          height: KNavigationBarStyle.navigationBarHeight,
          selectedIndex: selectedTab,
          onDestinationSelected: (value) {
            if (selectedTab == value) return;
            HapticsUtil.vibrate();
            selectedTabNotifier.value = value;
          },

          destinations: [
            NavigationDestination(
              icon: Badge(
                label: Text('${unreadMessagesCurrent.length}'),
                isLabelVisible: unreadMessagesCurrent.isNotEmpty,
                child: switch (selectedTab) {
                  0 => Icon(Icons.chat),
                  _ => Icon(Icons.chat_outlined),
                },
              ),
              label: l10n.chatLabelValue,
            ),

            NavigationDestination(
              icon: Badge(
                label: Text('${unreadMessagesRemaining.length}'),
                isLabelVisible: unreadMessagesRemaining.isNotEmpty,
                child: switch (selectedTab) {
                  1 => Icon(Icons.people),
                  _ => Icon(Icons.people_outline),
                },
              ),
              label: l10n.accountsLabelValue,
            ),

            NavigationDestination(
              icon: Badge(
                label: Text('!'),
                isLabelVisible: update == UpdateStatus.available,
                child: switch (selectedTab) {
                  2 => Icon(Icons.settings),
                  _ => Icon(Icons.settings_outlined),
                },
              ),
              label: l10n.settingsLabelValue,
            ),
          ],
        );
      },
    );
  }
}
