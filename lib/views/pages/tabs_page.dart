import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/value_listenables_builder.dart';
import 'package:mchad/views/tabs/accounts_tab.dart';
import 'package:mchad/views/tabs/chat_tab.dart';
import 'package:mchad/views/tabs/settings_tab.dart';
import 'package:mchad/views/widgets/dark_mode_button_widget.dart';
import 'package:mchad/views/widgets/floating_scroll_button_widget.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';
import 'package:mchad/views/widgets/login_button_widget.dart';
import 'package:mchad/views/widgets/navigation_bar_widget.dart';
import 'package:mchad/views/widgets/navigation_rail_widget.dart';

final tabs = [
  (Orientation orientation) => ChatTab(orientation: orientation),
  (Orientation orientation) => AccountsTab(),
  (Orientation orientation) => SettingsTab(),
];

class TabsPage extends StatelessWidget {
  const TabsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenablesBuilder(
      listenables: [
        settingsNotifier,
        selectedTabNotifier,
        selectedAccountNotifier,
      ],
      builder: (context, values, child) {
        final settings = values[0] as SettingsModel;
        final selectedTab = values[1] as int;
        final selectedAccount = values[2] as Account?;
        return OrientationBuilder(
          builder:
              (context, orientation) => Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: switch (orientation) {
                  Orientation.portrait => AppBar(
                    title: Hero(
                      tag: 'appBarTitle',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          selectedAccount?.forumName ??
                              AppLocalizations.of(context).appName,
                          style: TextStyle(fontSize: 22.0),
                        ),
                      ),
                    ),
                    actions: [DarkModeButtonWidget()],
                  ),
                  _ => null,
                },
                body: SafeArea(
                  child: Row(
                    children: [
                      if (orientation == Orientation.landscape)
                        NavigationRailWidget(),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: Duration(
                            milliseconds:
                                settings.transitionAnimations ? 250 : 0,
                          ),
                          child: tabs[selectedTab](orientation),
                        ),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: switch (selectedTab) {
                  0 => FloatingScrollButtonWidget(
                    settings: settings,
                    orientation: orientation,
                  ),
                  1 => LoginButtonWidget(),
                  _ => null,
                },
                bottomNavigationBar: switch (orientation) {
                  Orientation.portrait => NavigationBarWidget(),
                  _ => SizedBox.shrink(),
                },
              ),
        );
      },
    );
  }
}
