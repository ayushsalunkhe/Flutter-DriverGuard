import 'package:flutter/material.dart';

class GlowTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEmail;
  final IconData? icon;

  const GlowTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isEmail = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TextFormField(
          controller: controller,
          keyboardType:
              isEmail ? TextInputType.emailAddress : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          validator: (value) {
            if (!label.contains("Opt") && (value == null || value.isEmpty)) {
              return "required";
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            prefixIcon: icon != null
                ? Icon(icon, color: Colors.white.withOpacity(0.6))
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }
}
