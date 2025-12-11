import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PinInput extends StatelessWidget {
  final Function(String) onCompleted;
  final bool enabled;
  final bool obscureText;
  final TextEditingController? controller;

  const PinInput({
    super.key,
    required this.onCompleted,
    this.enabled = true,
    this.obscureText = true,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: 6,
      enabled: enabled,
      obscureText: obscureText,
      onCompleted: onCompleted,
      controller: controller,
      defaultPinTheme: PinTheme(
        width: 56,
        height: 56,
        textStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
