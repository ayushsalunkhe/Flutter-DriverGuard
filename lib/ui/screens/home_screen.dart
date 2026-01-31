import 'package:camera/camera.dart';
import 'package:driver_guard/providers/driver_state_provider.dart';
import 'package:driver_guard/ui/hud/live_waveform.dart';
import 'package:driver_guard/ui/hud/tech_load_meter.dart';
import 'package:driver_guard/ui/hud/vignette_overlay.dart';
import 'package:driver_guard/ui/simulation/emergency_overlay.dart';
import 'package:driver_guard/ui/theme.dart';
import 'package:driver_guard/ui/widgets/alert_flasher.dart';
import 'package:driver_guard/ui/widgets/contrast_gradient_overlay.dart';
import 'package:driver_guard/ui/widgets/glow_text.dart';
import 'package:driver_guard/ui/widgets/modern_glass_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showEmergency = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<DriverStateProvider>(context, listen: false).initialize());
  }

  Widget build(BuildContext context) {
    final driverState = Provider.of<DriverStateProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Feed
          if (driverState.isCameraInitialized)
            CameraPreview(driverState.cameraController!)
          else
            const Center(
                child: CircularProgressIndicator(color: AppTheme.cyan)),

          // 3. Dynamic Vignette (Edge Glow)
          VignetteOverlay(state: driverState.currentState),

          // 4. Contrast Gradient (Bottom Shadow for readability)
          const ContrastGradientOverlay(),

          // 5. Alert Flasher
          AlertFlasher(state: driverState.currentState),

          // 6. MAIN HUD UI
          SafeArea(
            child: Column(
              children: [
                // --- TOP HUD: Dynamic Island (Moved to MainScaffold) ---
                const SizedBox(height: 60), // Space for floating island

                const Spacer(),

                // --- CENTER: Emergency Messages ---
                if (driverState.isEmergencyTriggered)
                  _buildEmergencyMessage(
                      "EMERGENCY ALERT SENT", Colors.redAccent)
                else if (driverState.dangerDuration > 0)
                  _buildEmergencyMessage(
                      "EMERGENCY PROTOCOL T-${10 - driverState.dangerDuration}",
                      AppTheme.severeRed),

                // --- BOTTOM HUD: Dashboard ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  child: ModernGlassCard(
                    blur: 10,
                    opacity: 0.05, // Almost transparent
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Tech Load Meter
                        TechLoadMeter(score: driverState.cognitiveScore),

                        // Center: Divider
                        Container(width: 1, height: 60, color: Colors.white12),

                        // Right: Data Visualization
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Label
                              const Text("ATTENTION METRICS",
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 10,
                                      letterSpacing: 2)),
                              const SizedBox(height: 10),

                              // Live Waveform (EAR)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text("EAR",
                                      style: TextStyle(
                                          color: AppTheme.cyan,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 10),
                                  LiveWaveform(
                                      value: driverState.ear,
                                      color: AppTheme.cyan),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Blink Rate
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("BLINK ${driverState.cognitiveLabel}",
                                      style: const TextStyle(
                                          color: AppTheme.warningAmber,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 7. Simulation Overlay
          if (_showEmergency)
            EmergencyOverlay(
                onDismiss: () => setState(() => _showEmergency = false)),
        ],
      ),
    );
  }

  Widget _buildEmergencyMessage(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.6), blurRadius: 40, spreadRadius: 5)
          ]),
      child: GlowText(text, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
