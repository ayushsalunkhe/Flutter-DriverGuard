import 'package:camera/camera.dart';
import 'package:driver_guard/providers/driver_state_provider.dart';
import 'package:driver_guard/ui/simulation/emergency_overlay.dart';
import 'package:driver_guard/ui/widgets/alert_flasher.dart';
import 'package:driver_guard/ui/widgets/glass_container.dart';
import 'package:driver_guard/ui/widgets/load_meter.dart';
import 'package:driver_guard/ui/widgets/status_indicator.dart';
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

  @override
  Widget build(BuildContext context) {
    final driverState = Provider.of<DriverStateProvider>(context);

    // Simulation Trigger
    if (driverState.currentState == DriverState.DROWSY &&
        driverState.cognitiveScore > 90) {
      // Logic handled in provider/alert flasher mostly
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Layer
          if (driverState.isCameraInitialized)
            CameraPreview(driverState.cameraController!)
          else
            const Center(
                child: CircularProgressIndicator(color: Color(0xFF00E5FF))),

          // 2. Alert Flasher Layer
          AlertFlasher(state: driverState.currentState),

          // 3. Main HUD Overlay
          SafeArea(
            child: Column(
              children: [
                // TOP BAR: Status
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: StatusIndicator(state: driverState.currentState),
                ),

                const Spacer(),

                // BOTTOM DASHBOARD
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GlassContainer(
                    blur: 15,
                    opacity: 0.2,
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Load Meter
                        LoadMeter(score: driverState.cognitiveScore),

                        // Center Divider
                        Container(width: 1, height: 60, color: Colors.white24),

                        // Right: Stats
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatRow(
                                "EAR",
                                driverState.ear.toStringAsFixed(2),
                                const Color(0xFF00E5FF)),
                            const SizedBox(height: 10),
                            _buildStatRow("BLINK", driverState.cognitiveLabel,
                                const Color(0xFFFFC107)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Simulated Emergency Overlay
          if (_showEmergency)
            EmergencyOverlay(
                onDismiss: () => setState(() => _showEmergency = false)),

          // 5. Controls (Simulation)
          Positioned(
            right: 20,
            bottom: 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Audio Test
                _buildControlButton(
                    icon: Icons.volume_up,
                    color: Colors.teal,
                    onTap: () async {
                      final audio = Provider.of<DriverStateProvider>(context,
                              listen: false)
                          .audioService;
                      await audio.playAlert();
                      Future.delayed(
                          const Duration(seconds: 2), () => audio.stopAlert());
                    }),
                const SizedBox(height: 15),
                // Emergency Sim
                _buildControlButton(
                    icon: Icons.emergency,
                    color: Colors.red,
                    onTap: () => setState(() => _showEmergency = true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(label,
              style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
        Text(value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontFamily: "monospace",
                fontSize: 16)),
      ],
    );
  }

  Widget _buildControlButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)
            ]),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
