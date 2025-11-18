import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/ui_util.dart';
import 'package:mchad/utils/value_listenables_builder.dart';

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
        final unreadMessagesCurrent = messages.where((m) => !(m.isRead ?? false));
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
              icon: UiUtil.wrapWithBadge(
                icon: switch (selectedTab) {
                  0 => Icon(Icons.chat),
                  _ => Icon(Icons.chat_outlined),
                },
                condition: unreadMessagesCurrent.isNotEmpty,
                label: unreadMessagesCurrent.length.toString(),
              ),
              label: AppLocalizations.of(context).chatLabelValue,
            ),
            NavigationDestination(
              icon: UiUtil.wrapWithBadge(
                icon: switch (selectedTab) {
                  1 => Icon(Icons.people),
                  _ => Icon(Icons.people_outline),
                },
                condition: unreadMessagesRemaining.isNotEmpty,
                label: unreadMessagesRemaining.length.toString(),
              ),
              label: AppLocalizations.of(context).accountsLabelValue,
            ),
            NavigationDestination(
              icon: UiUtil.wrapWithBadge(
                icon: switch (selectedTab) {
                  2 => Icon(Icons.settings),
                  _ => Icon(Icons.settings_outlined),
                },
                condition: update == UpdateStatus.available,
                label: '!',
              ),
              label: AppLocalizations.of(context).settingsLabelValue,
            ),
          ],
        );
      },
    );
  }
}
