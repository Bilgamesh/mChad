import 'package:flutter/material.dart';
import 'package:mchad/config/constants.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/state/notifiers.dart';
import 'package:mchad/services/notifications/notifications_service.dart';
import 'package:mchad/utils/url_util.dart';
import 'package:mchad/utils/notifier_util.dart';
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
    final l10n = AppLocalizations.of(context);

    return ValueListenablesBuilder(
      listenables: [settingsNotifier, updateNotifier, packageInfoNotifier],
      builder: (context, values, child) {
        final settings = values[0] as SettingsModel;
        final update = values[1] as UpdateStatus;
        final packageInfo = values[2] as PackageInfo?;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SafeArea(
            child: Column(
              children: [
                if (update != UpdateStatus.none)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: UpdateButtonWidget(
                      settings: settings,
                      update: update,
                    ),
                  ),
                if (update != UpdateStatus.none) SizedBox(height: 20.0),
                ListTile(
                  title: Text(
                    l10n.colorStyle,
                    style: KTextStyle.settingsLabelText,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ColorPickerWidget(settings: settings),
                ),
                SizedBox(height: 20.0),
                SettingsToggleRowWidget(
                  label: l10n.lowConstrast,
                  subtitle: l10n.lowersBackgroundColorContrast,
                  value: settings.lowContrastBackground,
                  onValueChanged:
                      (value) =>
                          settings.setLowContrastBackground(value).save(),
                ),
                SettingsToggleRowWidget(
                  label: l10n.notifications,
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
                  label: l10n.haptics,
                  value: settings.haptics,
                  onValueChanged: (value) => settings.setHaptics(value).save(),
                ),
                SettingsToggleRowWidget(
                  label: l10n.transitionAnimations,
                  value: settings.transitionAnimations,
                  onValueChanged:
                      (value) => settings.setTransitionAnimations(value).save(),
                ),
                SettingsToggleRowWidget(
                  label: l10n.externalBrowser,
                  subtitle: l10n.openLinksInBrowser,
                  value: settings.openLinksInBrowser,
                  onValueChanged:
                      (value) => settings.setOpenLinksInBrowser(value).save(),
                ),
                SettingsDropdownWidget(
                  label: l10n.font,
                  value: settings.fontIndex,
                  menuItems: List.generate(
                    KAppTheme.fontNames.length + 1,
                    (index) => DropdownMenuItem(
                      value: index,
                      child: switch (index) {
                        0 => Text(l10n.defaultFont),
                        _ => Text(
                          KAppTheme.fontNames[index - 1],
                          style: KAppTheme.textStyles[index - 1],
                        ),
                      },
                    ),
                  ),
                  onChanged:
                      (value) => settings.setFontIndex(value ?? 3).save(),
                ),
                SettingsDropdownWidget(
                  label: l10n.languageLabel,
                  value: settings.languageIndex,
                  menuItems: [
                    DropdownMenuItem(value: 0, child: Text(l10n.english)),
                    DropdownMenuItem(value: 1, child: Text(l10n.polish)),
                  ],
                  onChanged: (value) => settings.setLanguage(value ?? 0).save(),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    l10n.version,
                    style: KTextStyle.settingsLabelText,
                  ),
                  subtitle: Text(packageInfo?.version ?? ""),
                  minVerticalPadding: 20,
                  enabled: false,
                ),
                ListTile(
                  title: Text(
                    l10n.license,
                    style: KTextStyle.settingsLabelText,
                  ),
                  subtitle: Text('GPL-3.0'),
                  minVerticalPadding: 20,
                  trailing: Icon(Icons.open_in_new),
                  onTap: () => UrlUtil.openUrl(KRepositoryInfo.licenseUrl),
                ),
                ListTile(
                  title: Text(
                    l10n.sourceCode,
                    style: KTextStyle.settingsLabelText,
                  ),
                  subtitle: Text(KRepositoryInfo.repoUrl),
                  minVerticalPadding: 20,
                  trailing: Icon(Icons.open_in_new),
                  onTap: () => UrlUtil.openUrl(KRepositoryInfo.repoUrl),
                ),
                ListTile(
                  title: Text(
                    l10n.issueTracker,
                    style: KTextStyle.settingsLabelText,
                  ),
                  subtitle: Text(KRepositoryInfo.issueTrackerUrl),
                  minVerticalPadding: 20,
                  trailing: Icon(Icons.open_in_new),
                  onTap: () => UrlUtil.openUrl(KRepositoryInfo.issueTrackerUrl),
                ),
                ListTile(
                  title: Text(
                    l10n.licenses,
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
          ),
        );
      },
    );
  }
}
