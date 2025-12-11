import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../widgets/pin_input.dart';
import '../../../core/widgets/loading_indicator.dart';
import 'dart:async';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  bool _showPin = false;
  Timer? _lockTimer;
  String? _lockTimeDisplay;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkUser() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.loadUser();

    if (!authProvider.hasUser && mounted) {
      Navigator.pushReplacementNamed(context, '/pin-setup');
    }
  }

  void _startLockTimer(Duration duration) {
    var secondsRemaining = duration.inSeconds;

    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsRemaining <= 0) {
          _lockTimeDisplay = null;
          timer.cancel();
        } else {
          final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
          final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');
          _lockTimeDisplay = '$minutes:$seconds';
        }
        secondsRemaining--;
      });
    });
  }

  Future<void> _handlePinSubmit(String pin) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.verifyPin(pin);

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (authProvider.shouldResetData) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Terlalu banyak percobaan gagal. Semua data akan dihapus.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushReplacementNamed(context, '/pin-setup');
        } else if (authProvider.isLocked) {
          _startLockTimer(authProvider.remainingLockTime);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Akun terkunci. Silakan tunggu ${_lockTimeDisplay ?? "1 menit"}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'PIN salah. Sisa percobaan: ${authProvider.remainingAttempts}. '
                'Setelah ${AuthProvider.maxAttempts} kali gagal, akun akan terkunci.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLocked = authProvider.isLocked;

    if (isLocked && _lockTimeDisplay == null) {
      _startLockTimer(authProvider.remainingLockTime);
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.lock, size: 64),
              const SizedBox(height: 32),
              Text(
                'SecureVault ID',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Masukkan PIN untuk melanjutkan',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              if (isLocked) ...[
                const Icon(
                  Icons.lock_clock,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Akun terkunci',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan tunggu $_lockTimeDisplay',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ] else
                PinInput(
                  onCompleted: _handlePinSubmit,
                  enabled: !_isLoading && !isLocked,
                ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
