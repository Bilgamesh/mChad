import 'package:flutter/material.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/haptics_util.dart';

class DarkModeButtonWidget extends StatelessWidget {
  const DarkModeButtonWidget({Key? key, this.hero}) : super(key: key);
  final bool? hero;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: settingsNotifier,
      builder:
          (context, settings, child) => Hero(
            tag: hero == false ? '' : DarkModeButtonWidget,
            child: IconButton(
              onPressed: () async {
                HapticsUtil.vibrate();
                await settings.setDarkMode(!settings.isDark).save();
              },
              icon: switch (settings.isDark) {
                true => Icon(Icons.light_mode),
                false => Icon(Icons.dark_mode),
              },
            ),
          ),
    );
  }
}
