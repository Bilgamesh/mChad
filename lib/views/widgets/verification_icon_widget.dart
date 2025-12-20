import 'package:flutter/material.dart';
import 'package:mchad/config/constants.dart';

class VerificationIconWidget extends StatelessWidget {
  const VerificationIconWidget({Key? key, required this.status})
    : super(key: key);
  final VerificationStatus status;

  @override
  Widget build(BuildContext context) => switch (status) {
    VerificationStatus.loading => UnconstrainedBox(
      child: SizedBox(
        height: 30.0,
        width: 30.0,
        child: CircularProgressIndicator(
          color: Colors.green,
          strokeCap: StrokeCap.round,
          padding: EdgeInsets.all(5),
        ),
      ),
    ),
    VerificationStatus.error => UnconstrainedBox(
      child: SizedBox(
        height: 30.0,
        width: 30.0,
        child: Icon(Icons.error, color: Colors.red),
      ),
    ),
    VerificationStatus.success => UnconstrainedBox(
      child: SizedBox(
        height: 30.0,
        width: 30.0,
        child: Icon(Icons.check, color: Colors.green),
      ),
    ),
    _ => SizedBox.shrink(),
  };
}
