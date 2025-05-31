import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';

class VerificationIconWidget extends StatelessWidget {
  const VerificationIconWidget({Key? key, required this.status})
    : super(key: key);
  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    return status == VerificationStatus.loading
        ? UnconstrainedBox(
          child: SizedBox(
            height: 30.0,
            width: 30.0,
            child: CircularProgressIndicator(),
          ),
        )
        : (status == VerificationStatus.error
            ? UnconstrainedBox(
              child: SizedBox(
                height: 30.0,
                width: 30.0,
                child: Icon(Icons.error, color: Colors.red),
              ),
            )
            : (status == VerificationStatus.success
                ? UnconstrainedBox(
                  child: SizedBox(
                    height: 30.0,
                    width: 30.0,
                    child: Icon(Icons.check, color: Colors.green),
                  ),
                )
                : SizedBox.shrink()));
  }
}
