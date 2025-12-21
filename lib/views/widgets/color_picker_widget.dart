import 'package:flutter/material.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/state/notifiers.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/views/widgets/gradient_circle_widget.dart';

class ColorPickerWidget extends StatefulWidget {
  const ColorPickerWidget({Key? key, required this.settings}) : super(key: key);
  final SettingsModel settings;

  @override
  _ColorPickerWidgetState createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: settingsNotifier,
      builder:
          (context, settings, child) => Column(
            children: [
              ...List.generate(
                4,
                (wrapIndex) => Wrap(
                  alignment: WrapAlignment.spaceAround,
                  children: [
                    ...List.generate(6, (iconIndex) {
                      int colorIndex = wrapIndex * 6 + iconIndex;
                      bool isSelected = colorIndex == settings.colorIndex;
                      return IconButton(
                        onPressed: () async {
                          HapticsUtil.vibrate();
                          setState(() {
                            settings.colorIndex = colorIndex;
                          });
                          widget.settings.setColorIndex(colorIndex).save();
                        },
                        icon: GradientCircleWidget(
                          enableGradient: colorIndex == 0,
                          icon: switch (isSelected) {
                            true => Icons.circle,
                            false => Icons.circle_outlined,
                          },
                          gradientColors: [Colors.redAccent, Colors.blueAccent],
                          color: settings.colors
                              .elementAt(colorIndex)
                              .withAlpha(255),
                          size: 40.0,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}
