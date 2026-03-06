import 'package:flutter/material.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/state/notifiers.dart';
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
    const space = 70;
    final bottomSafeArea = UiUtil.getBottomSafeAreaHeight(
      context,
      orientation == Orientation.portrait,
    );

    return ValueListenableBuilder(
      valueListenable: chatScrollOffsetNotifier,
      builder:
          (context, value, child) =>
              value < 2000
                  ? SizedBox.shrink()
                  : Padding(
                    padding: EdgeInsets.only(bottom: space + bottomSafeArea),
                    child: FloatingActionButton.small(
                      shape: CircleBorder(),
                      child: Icon(Icons.arrow_downward),
                      onPressed: () {
                        HapticsUtil.vibrate();
                        PrimaryScrollController.maybeOf(context)?.animateTo(
                          PrimaryScrollController.maybeOf(
                            context,
                          )!.position.minScrollExtent,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
                  ),
    );
  }
}
