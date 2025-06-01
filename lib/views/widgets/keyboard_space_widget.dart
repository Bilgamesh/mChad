import 'package:flutter/material.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/ui_util.dart';

class KeyboardSpaceWidget extends StatelessWidget {
  const KeyboardSpaceWidget({Key? key, required this.withNavbar})
    : super(key: key);
  final bool withNavbar;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: settingsNotifier,
      builder:
          (context, settings, child) => AnimatedPadding(
            duration: Duration(
              milliseconds: settings.transitionAnimations ? 70 : 0,
            ),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: UiUtil.getBottomSafeAreaHeight(context, withNavbar),
            ),
            child: SizedBox.shrink(),
          ),
    );
  }
}
