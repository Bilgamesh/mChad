import 'package:flutter/material.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/ui_util.dart';

class FloatingScrollButtonWidget extends StatelessWidget {
  const FloatingScrollButtonWidget({Key? key, required this.settings})
    : super(key: key);
  final SettingsModel settings;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: chatScrollNotifier,
      builder:
          (context, scrollController, child) =>
              (scrollController?.offset ?? 0) >= 2000
                  ? AnimatedPadding(
                    duration: Duration(
                      milliseconds: settings.transitionAnimations ? 70 : 0,
                    ),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.only(
                      bottom:
                          (70.0 +
                              UiUtil.getBottomSafeAreaHeight(context, true)),
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
                  )
                  : SizedBox.shrink(),
    );
  }
}
