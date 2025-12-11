import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/providers/auth_provider.dart';

class AutoLogoutService {
  static const int _inactivityDuration = 300; // 5 minutes
  static Timer? _timer;

  static void startTimer(BuildContext context) {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: _inactivityDuration), () {
      context.read<AuthProvider>().logout();
      Navigator.of(context).pushReplacementNamed('/auth');
    });
  }

  static void resetTimer(BuildContext context) {
    startTimer(context);
  }

  static void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
