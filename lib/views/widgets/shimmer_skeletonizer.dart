import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ShimmerSkeletonizer extends StatelessWidget {
  const ShimmerSkeletonizer({
    Key? key,
    required this.colorScheme,
    required this.child,
  }) : super(key: key);
  final ColorScheme colorScheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: colorScheme.tertiaryContainer,
        highlightColor: Color.alphaBlend(
          Colors.white70,
          colorScheme.tertiaryContainer,
        ),
        duration: const Duration(seconds: 1),
      ),
      child: child,
    );
  }
}
