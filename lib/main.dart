import 'package:driver_guard/database/database_helper.dart'; // Added
import 'package:driver_guard/ui/screens/main_scaffold.dart';
import 'package:driver_guard/ui/screens/permission_screen.dart'; // Added
import 'package:driver_guard/ui/screens/profile_setup_screen.dart'; // Added
import 'package:driver_guard/ui/theme.dart';
import 'package:driver_guard/providers/driver_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize minimal services here if needed (e.g. Database)

  runApp(const DriverGuardApp());
}

class DriverGuardApp extends StatelessWidget {
  const DriverGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DriverStateProvider()),
      ],
      child: MaterialApp(
        title: 'Driver Guard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        // Define routes so we can navigate by name
        routes: {
          '/home': (context) => const MainScaffold(),
          '/permission': (context) => const PermissionScreen(),
          '/profile_setup': (context) =>
              const ProfileSetupScreen(isOnboarding: true),
        },
        // Use a wrapper to decide where to go first
        home: const OnboardingWrapper(),
      ),
    );
  }
}

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    // 1. Check Location Permission

    await Future.delayed(Duration.zero); // Process next frame

    // Ensure we are mounted
    if (!mounted) return;

    final db = DatabaseHelper();
    final profile = await db.getProfile();

    if (mounted) {
      if (profile == null) {
        Navigator.of(context).pushReplacementNamed('/permission');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))),
    );
  }
}
