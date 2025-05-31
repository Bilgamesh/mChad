import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        height: 100.0,
        width: 100.0,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
