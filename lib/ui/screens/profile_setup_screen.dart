import 'package:driver_guard/database/database_helper.dart';
import 'package:driver_guard/ui/theme.dart';
import 'package:driver_guard/ui/widgets/glow_text.dart';
import 'package:driver_guard/ui/widgets/glow_text_field.dart';
import 'package:driver_guard/ui/widgets/liquid_button.dart';
import 'package:driver_guard/ui/widgets/modern_glass_card.dart';
import 'package:flutter/material.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isOnboarding;
  const ProfileSetupScreen({super.key, this.isOnboarding = false});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _bloodController = TextEditingController();
  final _contactController = TextEditingController();
  final _medicalController = TextEditingController();
  final _telegramController = TextEditingController();

  final _db = DatabaseHelper();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _db.getProfile();
    if (profile != null) {
      setState(() {
        _nameController.text = profile['name'] ?? '';
        _bloodController.text = profile['blood_group'] ?? '';
        _contactController.text = profile['emergency_contact'] ?? '';
        _medicalController.text = profile['medical_notes'] ?? '';
        _telegramController.text = profile['telegram_chat_id'] ?? '';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await _db.saveProfile({
        'name': _nameController.text,
        'blood_group': _bloodController.text,
        'emergency_contact': _contactController.text,
        'medical_notes': _medicalController.text,
        'telegram_chat_id': _telegramController.text,
      });

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Saved Securely")),
      );

      if (widget.isOnboarding) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        Navigator.pop(context);
      }
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
            // Decorative Glow
            Positioned(
              bottom: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.severeRed.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.severeRed.withOpacity(0.15),
                          blurRadius: 100,
                          spreadRadius: 20)
                    ]),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 140, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Manual Header
                    if (!widget.isOnboarding)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: GlowText("PROFILE SETUP",
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.cyan),
                        ),
                      ),

                    ModernGlassCard(
                      child: Column(
                        children: [
                          const Text(
                            "Emergency Profile",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "This data is stored locally and only used during emergency escalation.",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          GlowTextField(
                              label: "Full Name",
                              controller: _nameController,
                              icon: Icons.person_outline),
                          GlowTextField(
                              label: "Blood Group",
                              controller: _bloodController,
                              icon: Icons.water_drop_outlined),
                          GlowTextField(
                              label: "Emergency Email",
                              controller: _contactController,
                              isEmail: true,
                              icon: Icons.email_outlined),
                          GlowTextField(
                              label: "Medical Notes (Opt)",
                              controller: _medicalController,
                              icon: Icons.medical_services_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ModernGlassCard(
                      child: Column(
                        children: [
                          const GlowText("Telegram Alert",
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.glassWhite),
                          const SizedBox(height: 10),
                          const Text(
                            "1. Start @DriverGuardBot on Telegram\n2. Get Chat ID from @userinfobot",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          const SizedBox(height: 15),
                          GlowTextField(
                              label: "Telegram Chat ID",
                              controller: _telegramController,
                              icon: Icons.send_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    LiquidButton(
                      onPressed: _saveProfile,
                      label: "SAVE & CONTINUE",
                      icon: Icons.shield_outlined,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 40),
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
