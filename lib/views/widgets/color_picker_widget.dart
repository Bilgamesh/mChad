import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';
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
  int selectedColorIndex = settingsNotifier.value.colorIndex;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(
          4,
          (wrapIndex) => Wrap(
            alignment: WrapAlignment.spaceAround,
            children: [
              ...List.generate(
                6,
                (iconIndex) => IconButton(
                  onPressed: () async {
                    HapticsUtil.vibrate();
                    setState(() {
                      selectedColorIndex = wrapIndex * 6 + iconIndex;
                    });
                    widget.settings.setColorIndex(selectedColorIndex).save();
                  },
                  icon: Icon(
                    (wrapIndex * 6 + iconIndex) == selectedColorIndex
                        ? Icons.circle
                        : Icons.circle_outlined,
                    size: 40.0,
                    color: KAppTheme.appColors.elementAt(
                      wrapIndex * 6 + iconIndex,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
