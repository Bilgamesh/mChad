import 'package:flutter/material.dart';
import 'package:mchad/config/constants.dart';

class SettingsSliderWidget extends StatelessWidget {
  const SettingsSliderWidget({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);
  final String label;
  final double value;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: KTextStyle.settingsLabelText),
      minVerticalPadding: 25,
      trailing: SizedBox(
        width: 180,
        child: Slider(
          showValueIndicator: ShowValueIndicator.onDrag,
          value: value,
          label: value.toString(),
          min: 4,
          max: 22,
          onChanged: (value) => onChanged(value),
        ),
      ),
    );
  }
}
