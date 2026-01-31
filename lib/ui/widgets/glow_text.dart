import 'package:flutter/material.dart';

class GlowText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final double glowRadius;

  const GlowText(
    this.text, {
    super.key,
    this.fontSize = 16,
    this.color = Colors.white,
    this.fontWeight = FontWeight.normal,
    this.glowRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        shadows: [
          Shadow(
            color: color.withOpacity(0.6),
            blurRadius: glowRadius,
          ),
        ],
      ),
    );
  }
}
