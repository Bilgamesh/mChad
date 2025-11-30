import 'package:flutter/material.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/ui_util.dart';
import 'package:mchad/data/globals.dart' as globals;

class FloatingScrollButtonWidget extends StatelessWidget {
  const FloatingScrollButtonWidget({
    Key? key,
    required this.settings,
    required this.orientation,
  }) : super(key: key);
  final SettingsModel settings;
  final Orientation orientation;

  @override
  Widget build(BuildContext context) {
    final space = switch (orientation) {
      Orientation.portrait => 70,
      _ => 35,
    };
    return AnimatedPadding(
      duration: Duration(
        milliseconds: settings.transitionAnimations ? space : 0,
      ),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom:
            (space +
                UiUtil.getBottomSafeAreaHeight(
                  context,
                  orientation == Orientation.portrait,
                )),
      ),
      child: FloatingActionButton.small(
        shape: CircleBorder(),

        child: Icon(Icons.arrow_downward),
        onPressed: () {
          HapticsUtil.vibrate();
          globals.chatScrollController?.animateTo(
            globals.chatScrollController!.position.minScrollExtent,
            duration: const Duration(seconds: 1),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }
}
