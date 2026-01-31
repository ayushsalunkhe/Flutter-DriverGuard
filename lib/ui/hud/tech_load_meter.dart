import 'package:driver_guard/ui/theme.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class TechLoadMeter extends StatelessWidget {
  final double score; // 0-100

  const TechLoadMeter({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    // Determine Color
    Color color = AppTheme.cyan;
    if (score > 50) color = AppTheme.warningAmber;
    if (score > 80) color = AppTheme.severeRed;

    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Ring
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              color: Colors.white.withOpacity(0.1),
            ),
          ),

          // Foreground Ring (Gradient simulated via Color or ShaderMask)
          SizedBox(
            width: 100,
            height: 100,
            child: ShaderMask(
              shaderCallback: (rect) {
                return SweepGradient(
                  startAngle: 0.0,
                  endAngle: math.pi * 2,
                  colors: [
                    AppTheme.cyan.withOpacity(0.5),
                    color,
                  ],
                  transform: const GradientRotation(-math.pi / 2),
                ).createShader(rect);
              },
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 8,
                backgroundColor: Colors.transparent,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white), // Masked
                strokeCap: StrokeCap.round,
              ),
            ),
          ),

          // Inner Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${score.toInt()}",
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                "LOAD",
                style: TextStyle(
                    fontSize: 10, color: Colors.white54, letterSpacing: 1.5),
              ),
            ],
          )
        ],
      ),
    );
  }
}
