import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:mchad/data/globals.dart' as globals;
import 'package:mchad/data/notifiers.dart';

var modalShown = false;

class ModalUtil {
  static void showError(Object? error) {
    if (globals.navigatorKey.currentContext == null || modalShown) return;
    modalShown = true;
    Flushbar(
      message: error.toString(),
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      icon: Icon(Icons.error),
      duration: Duration(seconds: 5),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: settingsNotifier.value.colorScheme.errorContainer,
      messageColor: settingsNotifier.value.colorScheme.error,
      titleColor: settingsNotifier.value.colorScheme.error,
    ).show(globals.navigatorKey.currentContext!);
    Timer(Duration(seconds: 5), () {
      modalShown = false;
    });
  }

  static void showMessage(String message) {
    if (globals.navigatorKey.currentContext == null || modalShown) return;
    modalShown = true;
    Flushbar(
      message: message,
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      icon: Icon(Icons.info),
      duration: Duration(seconds: 5),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: settingsNotifier.value.colorScheme.surfaceContainer,
      messageColor: settingsNotifier.value.colorScheme.inverseSurface,
      titleColor: settingsNotifier.value.colorScheme.inverseSurface,
    ).show(globals.navigatorKey.currentContext!);
    Timer(Duration(seconds: 5), () {
      modalShown = false;
    });
  }
}
