import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ValueListenablesBuilder extends StatelessWidget {
  const ValueListenablesBuilder({
    Key? key,
    required this.listenables,
    required this.builder,
    this.child,
  }) : super(key: key);

  final List<ValueListenable> listenables;
  final Widget? child;

  final Widget Function(
    BuildContext context,
    List<dynamic> values,
    Widget? child,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    return _buildRecursive(context, 0, []);
  }

  Widget _buildRecursive(
    BuildContext context,
    int index,
    List<dynamic> currentValues,
  ) {
    if (index == listenables.length) {
      return builder(context, currentValues, child);
    }

    return ValueListenableBuilder(
      valueListenable: listenables[index],
      builder: (context, value, _) {
        final updated = [...currentValues, value];
        return _buildRecursive(context, index + 1, updated);
      },
    );
  }
}
