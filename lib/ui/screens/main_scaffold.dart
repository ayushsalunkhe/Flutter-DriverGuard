import 'package:driver_guard/providers/driver_state_provider.dart';
import 'package:driver_guard/ui/hud/dynamic_island_status.dart';
import 'package:driver_guard/ui/screens/home_screen.dart';
import 'package:driver_guard/ui/screens/profile_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProfileSetupScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final driverState = Provider.of<DriverStateProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black, // Match theme
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Content Body
          // Using IndexedStack to preserve state of HomeScreen (Camera)
          // However, for ProfileScreen we might want to rebuild or not.
          // HomeScreen has camera, so it MUST stay alive.
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // 2. Persistent Dynamic Island
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: DynamicIslandStatus(
                state: driverState.currentState,
                currentIndex: _currentIndex,
                onTabChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
