import 'package:flutter/material.dart';
import 'package:gradient_icon/gradient_icon.dart';

class GradientCircleWidget extends StatelessWidget {
  const GradientCircleWidget({
    Key? key,
    required this.enableGradient,
    required this.icon,
    required this.gradientColors,
    required this.color,
    required this.size,
  }) : super(key: key);
  final IconData icon;
  final bool enableGradient;
  final List<Color> gradientColors;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (!enableGradient) return Icon(icon, size: size, color: color);
    return GradientIcon(
      icon: icon,
      size: size,
      offset: Offset(0, 0),
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
