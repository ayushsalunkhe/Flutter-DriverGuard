import 'package:driver_guard/ui/screens/home_screen.dart';
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
        home: const HomeScreen(),
      ),
    );
  }
}
