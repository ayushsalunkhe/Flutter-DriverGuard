import 'package:driver_guard/providers/driver_state_provider.dart';
import 'package:driver_guard/ui/theme.dart';
import 'package:flutter/material.dart';

class VignetteOverlay extends StatelessWidget {
  final DriverState state;

  const VignetteOverlay({super.key, required this.state});

  Color _getGlowColor() {
    switch (state) {
      case DriverState.AWAKE:
        return AppTheme.cyan; // Cool Blue/Cyan
      case DriverState.HIGH_LOAD:
        return AppTheme.warningAmber; // Amber
      case DriverState.DROWSY:
      case DriverState.NO_FACE:
        return AppTheme.severeRed; // Danger Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getGlowColor();

    // For Drowsy/NoFace, we want a stronger, possibly pulsing effect.
    // For Awake, a subtle "Safe" glow.

    bool isDanger = state == DriverState.DROWSY || state == DriverState.NO_FACE;

    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0, // Extending to edges
            colors: [
              Colors.transparent,
              Colors.transparent,
              color.withOpacity(
                  isDanger ? 0.4 : 0.1), // Stronger opacity if danger
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
      ),
    );
  }
}
