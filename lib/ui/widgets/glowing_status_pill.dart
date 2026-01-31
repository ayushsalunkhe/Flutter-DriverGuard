import 'package:driver_guard/providers/driver_state_provider.dart';
import 'package:driver_guard/ui/theme.dart';
import 'package:driver_guard/ui/widgets/glow_text.dart';
import 'package:driver_guard/ui/widgets/modern_glass_card.dart';
import 'package:flutter/material.dart';

class GlowingStatusPill extends StatelessWidget {
  final DriverState state;

  const GlowingStatusPill({super.key, required this.state});

  Color _getStateColor() {
    switch (state) {
      case DriverState.AWAKE:
        return AppTheme.cyan;
      case DriverState.DROWSY:
        return AppTheme.severeRed;
      case DriverState.HIGH_LOAD:
        return AppTheme.warningAmber;
      case DriverState.NO_FACE:
        return Colors.grey;
    }
  }

  String _getStateText() {
    return state.toString().split('.').last.replaceAll("_", " ");
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStateColor();

    return ModernGlassCard(
      borderRadius: BorderRadius.circular(50),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      border: false,
      opacity: 0.15,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: color.withOpacity(0.8),
                      blurRadius: 10,
                      spreadRadius: 2)
                ]),
          ),
          const SizedBox(width: 12),
          GlowText(
            _getStateText(),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            glowRadius: 5,
          ),
        ],
      ),
    );
  }
}
