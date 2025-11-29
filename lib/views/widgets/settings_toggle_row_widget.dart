import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/utils/haptics_util.dart';

class SettingsToggleRowWidget extends StatelessWidget {
  const SettingsToggleRowWidget({
    Key? key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onValueChanged,
  }) : super(key: key);
  final String label;
  final String? subtitle;
  final bool value;
  final void Function(bool value) onValueChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: KTextStyle.settingsLabelText),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      minVerticalPadding: 25,
      trailing: Switch(
        value: value,
        onChanged: (value) {
          HapticsUtil.vibrate();
          onValueChanged(value);
        },
      ),
    );
  }
}
