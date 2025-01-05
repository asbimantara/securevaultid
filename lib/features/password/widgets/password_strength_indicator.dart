import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String? password;
  final double? strength;
  final bool showLabel;
  final double size;

  const PasswordStrengthIndicator({
    super.key,
    this.password,
    this.strength,
    this.showLabel = false,
    this.size = 80,
  }) : assert(password != null || strength != null);

  double get _strength {
    if (strength != null) return strength!;
    if (password == null) return 0;

    // Implementasi logika pengecekan kekuatan password
    double score = 0;
    if (password!.length >= 8) score += 0.2;
    if (password!.contains(RegExp(r'[A-Z]'))) score += 0.2;
    if (password!.contains(RegExp(r'[a-z]'))) score += 0.2;
    if (password!.contains(RegExp(r'[0-9]'))) score += 0.2;
    if (password!.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 0.2;
    return score;
  }

  Color get _color {
    if (_strength < 0.3) return Colors.red;
    if (_strength < 0.6) return Colors.orange;
    return Colors.green;
  }

  String get _label {
    if (_strength < 0.3) return 'Lemah';
    if (_strength < 0.6) return 'Sedang';
    return 'Kuat';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: _strength,
            backgroundColor: _color.withOpacity(0.2),
            color: _color,
            strokeWidth: 8,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
