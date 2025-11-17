import 'package:flutter/material.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/haptics_util.dart';

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
                      return IconButton(
                        onPressed: () async {
                          HapticsUtil.vibrate();
                          setState(() {
                            settings.colorIndex = colorIndex;
                          });
                          widget.settings.setColorIndex(colorIndex).save();
                        },
                        icon:
                            colorIndex == 0
                                ? GradientIcon(
                                  icon:
                                      (colorIndex) == settings.colorIndex
                                          ? Icons.circle
                                          : Icons.circle_outlined,
                                  size: 40.0,
                                  offset: Offset(0, 0),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.redAccent,
                                      Colors.blueAccent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                )
                                : Icon(
                                  (colorIndex) == settings.colorIndex
                                      ? Icons.circle
                                      : Icons.circle_outlined,
                                  size: 40.0,
                                  color: settings.colors
                                      .elementAt(colorIndex)
                                      .withAlpha(255),
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
