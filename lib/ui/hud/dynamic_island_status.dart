import 'package:driver_guard/providers/driver_state_provider.dart';
import 'package:driver_guard/ui/theme.dart';
import 'package:driver_guard/ui/widgets/glow_text.dart';
import 'package:driver_guard/ui/widgets/modern_glass_card.dart';
import 'package:flutter/material.dart';

class DynamicIslandStatus extends StatelessWidget {
  final DriverState state;
  final int currentIndex;
  final Function(int) onTabChanged;

  const DynamicIslandStatus({
    super.key,
    required this.state,
    required this.currentIndex,
    required this.onTabChanged,
  });

  Color _getStateColor() {
    switch (state) {
      case DriverState.AWAKE:
        return AppTheme.cyan;
      case DriverState.DROWSY:
      case DriverState.NO_FACE:
        return AppTheme.severeRed;
      case DriverState.HIGH_LOAD:
        return AppTheme.warningAmber;
    }
  }

  IconData _getStateIcon() {
    switch (state) {
      case DriverState.AWAKE:
        return Icons.check_circle_outline;
      case DriverState.DROWSY:
        return Icons.warning_amber_rounded;
      case DriverState.NO_FACE:
        return Icons.videocam_off_outlined;
      case DriverState.HIGH_LOAD:
        return Icons.psychology_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStateColor();
    final bool isHome = currentIndex == 0;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ModernGlassCard(
        borderRadius: BorderRadius.circular(50),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        blur: 15,
        opacity: 0.15,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HOME TAB (Driver Status) ---
            GestureDetector(
              onTap: () => onTabChanged(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isHome ? color.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(isHome ? _getStateIcon() : Icons.home_outlined,
                        color: isHome ? color : Colors.white54, size: 20),
                    if (isHome) ...[
                      const SizedBox(width: 8),
                      GlowText(
                        state.toString().split('.').last.replaceAll('_', ' '),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        glowRadius: 5,
                      ),
                    ]
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),
            Container(width: 1, height: 20, color: Colors.white12),
            const SizedBox(width: 8),

            // --- PROFILE TAB ---
            GestureDetector(
              onTap: () => onTabChanged(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: !isHome
                      ? AppTheme.cyan.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        color: !isHome ? AppTheme.cyan : Colors.white54,
                        size: 20),
                    if (!isHome) ...[
                      const SizedBox(width: 8),
                      const GlowText(
                        "PROFILE",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        glowRadius: 5,
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
