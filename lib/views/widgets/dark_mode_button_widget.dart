import 'package:flutter/material.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/haptics_util.dart';

class DarkModeButtonWidget extends StatelessWidget {
  const DarkModeButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: settingsNotifier,
      builder:
          (context, settings, child) => Hero(
            tag: DarkModeButtonWidget,
            child: IconButton(
              onPressed: () async {
                HapticsUtil.vibrate();
                await settings.setDarkMode(!settings.isDark).save();
              },
              icon:
                  settings.isDark
                      ? Icon(Icons.light_mode)
                      : Icon(Icons.dark_mode),
            ),
          ),
    );
  }
}
