import 'package:flutter/material.dart';

class LoadMeter extends StatelessWidget {
  final double score;

  const LoadMeter({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    // Score 0-100
    // Color gradient based on score

    Color color;
    if (score < 40)
      color = const Color(0xFF00E5FF); // Low - Cyan
    else if (score < 70)
      color = const Color(0xFFFFC107); // Med - Amber
    else
      color = const Color(0xFFFF2A68); // High - Red

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.white10,
                color: color,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              children: [
                Text(
                  "${score.toInt()}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  "%",
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "COGNITIVE",
          style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: Colors.white70),
        ),
      ],
    );
  }
}
