import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/ui_util.dart';
import 'package:mchad/utils/value_listenables_builder.dart';

class NavigationRailWidget extends StatelessWidget {
  const NavigationRailWidget({Key? key}) : super(key: key);

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
        final update = values[3] as UpdateStatus;
        var unreadMessagesCurrent = messageMap[account]!.where(
          (m) => !(m.isRead ?? false),
        );
        var unreadMessagesRemaining = <Message>[];
        messageMap.forEach((key, messages) {
          if (key != account) {
            unreadMessagesRemaining.addAll(
              messages.where((m) => !(m.isRead ?? false)),
            );
          }
        });

        return NavigationRail(
          selectedIndex: selectedTab,
          labelType: NavigationRailLabelType.all,
          groupAlignment: 0,
          onDestinationSelected: (value) {
            if (selectedTab == value) return;
            HapticsUtil.vibrate();
            selectedTabNotifier.value = value;
          },
          leading: Row(
            children: [
              Hero(
                tag: 'appBarTitle',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    account?.forumName ?? AppLocalizations.of(context).appName,
                    style: TextStyle(fontSize: 22.0),
                  ),
                ),
              ),
            ],
          ),
          destinations: [
            NavigationRailDestination(
              icon: UiUtil.wrapWithBadge(
                icon:
                    selectedTab == 0
                        ? Icon(Icons.chat)
                        : Icon(Icons.chat_outlined),
                condition: unreadMessagesCurrent.isNotEmpty,
                label: unreadMessagesCurrent.length.toString(),
              ),
              label: Text(AppLocalizations.of(context).chatLabelValue),
            ),
            NavigationRailDestination(
              icon: UiUtil.wrapWithBadge(
                icon:
                    selectedTab == 1
                        ? Icon(Icons.people)
                        : Icon(Icons.people_outline),
                condition: unreadMessagesRemaining.isNotEmpty,
                label: unreadMessagesRemaining.length.toString(),
              ),
              label: Text(AppLocalizations.of(context).accountsLabelValue),
            ),
            NavigationRailDestination(
              icon: UiUtil.wrapWithBadge(
                icon:
                    selectedTab == 2
                        ? Icon(Icons.settings)
                        : Icon(Icons.settings_outlined),
                condition: update == UpdateStatus.available,
                label: '!',
              ),
              label: Text(AppLocalizations.of(context).settingsLabelValue),
            ),
          ],
        );
      },
    );
  }
}
