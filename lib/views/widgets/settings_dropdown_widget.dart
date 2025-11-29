import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/utils/haptics_util.dart';

class SettingsDropdownWidget<T> extends StatelessWidget {
  const SettingsDropdownWidget({
    Key? key,
    required this.label,
    required this.value,
    required this.menuItems,
    required this.onChanged,
  }) : super(key: key);
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> menuItems;
  final void Function(T? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: KTextStyle.settingsLabelText),
      minVerticalPadding: 25,
      trailing: DropdownButton<T>(
        value: value,
        items: menuItems,
        onTap: () => HapticsUtil.vibrate(),
        onChanged: (value) {
          HapticsUtil.vibrate();
          onChanged(value);
        },
      ),
    );
  }
}
