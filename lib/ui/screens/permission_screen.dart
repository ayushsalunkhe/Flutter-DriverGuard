import 'package:driver_guard/ui/screens/profile_setup_screen.dart';
import 'package:driver_guard/ui/theme.dart';
import 'package:driver_guard/ui/widgets/glow_text.dart';
import 'package:driver_guard/ui/widgets/liquid_button.dart';
import 'package:driver_guard/ui/widgets/modern_glass_card.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _isLoading = false;

  Future<void> _checkPermissions() async {
    setState(() => _isLoading = true);

    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check Service
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable Location Services')));
      }
      setState(() => _isLoading = false);
      return;
    }

    // 2. Check Permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission is denied.')));
        }
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permission is permanently denied. Enable in Settings.')));
      }
      setState(() => _isLoading = false);
      return;
    }

    // Success -> Navigate to Profile Setup
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => const ProfileSetupScreen(isOnboarding: true)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF001524), Color(0xFF050510)],
          ),
        ),
        child: Stack(
          children: [
            // Background decorations
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cyan.withOpacity(0.15),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.cyan.withOpacity(0.2),
                          blurRadius: 100,
                          spreadRadius: 20)
                    ]),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ModernGlassCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 60, color: AppTheme.cyan),
                      const SizedBox(height: 20),
                      const GlowText(
                        "PERMISSION REQUIRED",
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Driver Guard requires precise location access to send emergency alerts with your coordinates.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "We also identify nearby hospitals for quicker response.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: LiquidButton(
                          onPressed: _checkPermissions,
                          label: "GRANT ACCESS",
                          icon: Icons.check_circle_outline,
                          isLoading: _isLoading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
