import 'package:flutter/material.dart';

class EmergencyOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const EmergencyOverlay({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emergency, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "CRITICAL EVENT DETECTED",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Simulated emergency contact protocol initiated...",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("I'M OKAY", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
