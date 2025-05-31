import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/languages/dictionaries.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/services/github/github_update_service.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/views/widgets/color_picker_widget.dart';
import 'package:mchad/views/widgets/loading_widget.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: settingsNotifier,
      builder:
          (context, settings, child) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView(
              padding: EdgeInsets.all(10.0),
              children: [
                SizedBox(height: 20.0),
                ValueListenableBuilder(
                  valueListenable: updateNotifier,
                  builder:
                      (context, update, child) =>
                          update == UpdateStatus.none
                              ? SizedBox.shrink()
                              : Column(
                                children: [
                                  Stack(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              settings
                                                  .colorScheme
                                                  .errorContainer,
                                        ),
                                        onPressed:
                                            update == UpdateStatus.inProgress
                                                ? null
                                                : () async {
                                                  await GithubUpdateService(
                                                    endpoint:
                                                        KUpdateConfig.endpoint,
                                                  ).downloadLatest();
                                                },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            update == UpdateStatus.inProgress
                                                ? SizedBox(
                                                  height: 20.0,
                                                  child: LoadingWidget(),
                                                )
                                                : Icon(Icons.update),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                              ),
                                              child: Text(
                                                settings
                                                    .language
                                                    .updateAvailable,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.0),
                                ],
                              ),
                ),
                Row(
                  children: [
                    Text(
                      settings.language.colorStyle,
                      style: KTextStyle.settingsLabelText,
                    ),
                  ],
                ),
                ColorPickerWidget(settings: settings),
                SizedBox(height: 40.0),
                Row(
                  children: [
                    Text(
                      settings.language.notifications,
                      style: KTextStyle.settingsLabelText,
                    ),
                    Expanded(child: SizedBox.shrink()),
                    Switch(
                      value: settings.notifications,
                      onChanged: (value) async {
                        HapticsUtil.vibrate();
                        if (value == false) {
                          settings.setNotifications(value).save();
                          return;
                        }
                        var flutterLocalNotificationsPlugin =
                            FlutterLocalNotificationsPlugin();
                        var hasPermission =
                            await flutterLocalNotificationsPlugin
                                .resolvePlatformSpecificImplementation<
                                  AndroidFlutterLocalNotificationsPlugin
                                >()
                                ?.requestNotificationsPermission();
                        if (hasPermission == true) {
                          settings.setNotifications(value).save();
                        } else {
                          settings.setNotifications(!value).save();
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 40.0),
                Row(
                  children: [
                    Text(
                      settings.language.haptics,
                      style: KTextStyle.settingsLabelText,
                    ),
                    Expanded(child: SizedBox.shrink()),
                    Switch(
                      value: settings.haptics,
                      onChanged: (value) {
                        settings.setHaptics(value).save();
                        HapticsUtil.vibrate();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 40.0),
                Row(
                  children: [
                    Text(
                      settings.language.transitionAnimations,
                      style: KTextStyle.settingsLabelText,
                    ),
                    Expanded(child: SizedBox.shrink()),
                    Switch(
                      value: settings.transitionAnimations,
                      onChanged: (value) {
                        HapticsUtil.vibrate();
                        settings.setTransitionAnimations(value).save();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 40.0),
                Row(
                  children: [
                    Text(
                      settings.language.language,
                      style: KTextStyle.settingsLabelText,
                    ),
                    Expanded(child: SizedBox.shrink()),
                    DropdownButton(
                      value: settings.languageIndex,
                      items: List.generate(
                        Dictionaries.all.length,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Text(Dictionaries.languageNames[index]),
                        ),
                      ),
                      onTap: () {
                        HapticsUtil.vibrate();
                      },
                      onChanged: (value) async {
                        HapticsUtil.vibrate();
                        settings.setLanguage(value ?? 0).save();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
