import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/services/notifications/notifications_service.dart';
import 'package:mchad/utils/url_util.dart';
import 'package:mchad/utils/value_listenables_builder.dart';
import 'package:mchad/views/widgets/color_picker_widget.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';
import 'package:mchad/views/widgets/settings_dropdown_widget.dart';
import 'package:mchad/views/widgets/settings_toggle_row_widget.dart';
import 'package:mchad/views/widgets/update_button_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenablesBuilder(
      listenables: [settingsNotifier, updateNotifier, packageInfoNotifier],
      builder: (context, values, child) {
        final settings = values[0] as SettingsModel;
        final update = values[1] as UpdateStatus;
        final packageInfo = values[2] as PackageInfo?;
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          children: [
            Column(
              children: [
                if (update != UpdateStatus.none)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: UpdateButtonWidget(
                          settings: settings,
                          update: update,
                        ),
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context).colorStyle,
                    style: KTextStyle.settingsLabelText,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ColorPickerWidget(settings: settings),
                ),
                SizedBox(height: 20.0),
                SettingsToggleRowWidget(
                  label: AppLocalizations.of(context).notifications,
                  value: settings.notifications,
                  onValueChanged: (value) async {
                    if (value == false) {
                      settings.setNotifications(value).save();
                      return;
                    }
                    NotificationsService.requestPermission().then(
                      (value) => settings.setNotifications(value).save(),
                    );
                  },
                ),
                SettingsToggleRowWidget(
                  label: AppLocalizations.of(context).haptics,
                  value: settings.haptics,
                  onValueChanged: (value) => settings.setHaptics(value).save(),
                ),
                SettingsToggleRowWidget(
                  label: AppLocalizations.of(context).transitionAnimations,
                  value: settings.transitionAnimations,
                  onValueChanged:
                      (value) => settings.setTransitionAnimations(value).save(),
                ),
                SettingsToggleRowWidget(
                  label: AppLocalizations.of(context).externalBrowser,
                  subtitle: AppLocalizations.of(context).openLinksInBrowser,
                  value: settings.openLinksInBrowser,
                  onValueChanged:
                      (value) => settings.setOpenLinksInBrowser(value).save(),
                ),
                SettingsDropdownWidget(
                  label: AppLocalizations.of(context).languageLabel,
                  value: settings.languageIndex,
                  menuItems: [
                    DropdownMenuItem(
                      value: 0,
                      child: Text(AppLocalizations.of(context).english),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text(AppLocalizations.of(context).polish),
                    ),
                  ],
                  onChanged: (value) => settings.setLanguage(value ?? 0).save(),
                ),
              ],
            ),
            Divider(),
            Column(
              children: [
                ListTile(
                  title: Text(
                    AppLocalizations.of(context).version,
                    style: KTextStyle.settingsLabelText,
                  ),
                  subtitle: Text(packageInfo?.version ?? ""),
                  minVerticalPadding: 20,
                  enabled: false,
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context).license,
                    style: KTextStyle.settingsLabelText,
                  ),
                  subtitle: Text('GPL-3.0'),
                  minVerticalPadding: 20,
                  trailing: Icon(Icons.open_in_new),
                  onTap: () => UrlUtil.openUrl(KRepositoryInfo.licenseUrl),
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context).sourceCode,
                    style: KTextStyle.settingsLabelText,
                  ),
                  subtitle: Text(KRepositoryInfo.repoUrl),
                  minVerticalPadding: 20,
                  trailing: Icon(Icons.open_in_new),
                  onTap: () => UrlUtil.openUrl(KRepositoryInfo.repoUrl),
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context).issueTracker,
                    style: KTextStyle.settingsLabelText,
                  ),
                  subtitle: Text(KRepositoryInfo.issueTrackerUrl),
                  minVerticalPadding: 20,
                  trailing: Icon(Icons.open_in_new),
                  onTap: () => UrlUtil.openUrl(KRepositoryInfo.issueTrackerUrl),
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context).licenses,
                    style: KTextStyle.settingsLabelText,
                  ),
                  minVerticalPadding: 20,
                  onTap: () {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LicensePage()),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
