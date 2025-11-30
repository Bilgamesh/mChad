import 'package:flutter/material.dart';

class LifecycleService with WidgetsBindingObserver {
  static final LifecycleService _instance = LifecycleService._internal();
  factory LifecycleService() => _instance;

  LifecycleService._internal();

  final List<void Function(AppLifecycleState state)> _listeners = [];

  LifecycleService addListener(
    void Function(AppLifecycleState state) listener,
  ) {
    _listeners.add(listener);
    return this;
  }

  LifecycleService removeListener(
    void Function(AppLifecycleState state) listener,
  ) {
    _listeners.remove(listener);
    return this;
  }

  void notifyListeners(AppLifecycleState state) {
    for (var listener in _listeners) {
      listener(state);
    }
  }

  LifecycleService startListening() {
    WidgetsBinding.instance.addObserver(this);
    return this;
  }

  LifecycleService stopListening() {
    WidgetsBinding.instance.removeObserver(this);
    return this;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    notifyListeners(state);
  }
}
