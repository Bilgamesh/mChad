import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/ui_util.dart';
import 'package:mchad/utils/value_listenables_builder.dart';
import 'package:mchad/views/widgets/dark_mode_button_widget.dart';

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
        final messages = messageMap[account] ?? [];
        final update = values[3] as UpdateStatus;
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
              Padding(
                padding: const EdgeInsets.all(20),
                child: Hero(
                  tag: 'appBarTitle',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      account?.forumName ??
                          AppLocalizations.of(context).appName,
                      style: TextStyle(fontSize: 22.0),
                    ),
                  ),
                ),
              ),
            ],
          ),

          destinations: [
            NavigationRailDestination(
              icon: UiUtil.wrapWithBadge(
                icon: switch (selectedTab) {
                  0 => Icon(Icons.chat),
                  _ => Icon(Icons.chat_outlined),
                },
                condition: unreadMessagesCurrent.isNotEmpty,
                label: unreadMessagesCurrent.length.toString(),
              ),
              label: Text(AppLocalizations.of(context).chatLabelValue),
            ),

            NavigationRailDestination(
              icon: UiUtil.wrapWithBadge(
                icon: switch (selectedTab) {
                  1 => Icon(Icons.people),
                  _ => Icon(Icons.people_outline),
                },
                condition: unreadMessagesRemaining.isNotEmpty,
                label: unreadMessagesRemaining.length.toString(),
              ),
              label: Text(AppLocalizations.of(context).accountsLabelValue),
            ),

            NavigationRailDestination(
              icon: UiUtil.wrapWithBadge(
                icon: switch (selectedTab) {
                  2 => Icon(Icons.settings),
                  _ => Icon(Icons.settings_outlined),
                },
                condition: update == UpdateStatus.available,
                label: '!',
              ),
              label: Text(AppLocalizations.of(context).settingsLabelValue),
            ),
          ],

          trailing: Padding(
            padding: const EdgeInsets.all(20),
            child: DarkModeButtonWidget(hero: false),
          ),
          trailingAtBottom: true,
        );
      },
    );
  }
}
