import 'package:flutter/material.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/ui_util.dart';

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
    var space = orientation == Orientation.portrait ? 70 : 35;
    return ValueListenableBuilder(
      valueListenable: chatScrollNotifier,
      builder: (context, scrollController, child) {
        if ((scrollController?.offset ?? 0) < 2000) {
          return SizedBox.shrink();
        }
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
              scrollController?.animateTo(
                scrollController.position.minScrollExtent,
                duration: const Duration(seconds: 1),
                curve: Curves.easeOut,
              );
            },
          ),
        );
      },
    );
  }
}
