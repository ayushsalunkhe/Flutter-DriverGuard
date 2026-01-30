import 'package:driver_guard/providers/driver_state_provider.dart';
import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final DriverState state;

  const StatusIndicator({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;
    Color glowColor;

    switch (state) {
      case DriverState.AWAKE:
        color = const Color(0xFF00E5FF); // Cyan
        text = "ACTIVE";
        icon = Icons.safety_check;
        glowColor = const Color(0xFF00E5FF).withOpacity(0.5);
        break;
      case DriverState.DROWSY:
        color = const Color(0xFFFF2A68); // Neon Red
        text = "DROWSY";
        icon = Icons.warning_amber_rounded;
        glowColor = const Color(0xFFFF2A68).withOpacity(0.8);
        break;
      case DriverState.HIGH_LOAD:
        color = const Color(0xFFFFC107); // Amber
        text = "HIGH LOAD";
        icon = Icons.psychology;
        glowColor = const Color(0xFFFFC107).withOpacity(0.6);
        break;
      case DriverState.NO_FACE:
        color = const Color(0xFFFF9100); // Orange
        text = "DISTRACTION";
        icon = Icons.visibility_off;
        glowColor = const Color(0xFFFF9100).withOpacity(0.6);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              shadows: [
                Shadow(color: color, blurRadius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
