import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../widgets/pin_input.dart';
import 'dart:async';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String? _firstPin;
  bool _isConfirming = false;
  bool _showPin = false;
  bool _isLoading = false;
  int _confirmAttempts = 0;
  DateTime? _lockedUntil;
  final _pinController = TextEditingController();
  static const int maxConfirmAttempts = 3;
  static const Duration lockDuration = Duration(seconds: 10);

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  bool get isLocked =>
      _lockedUntil != null && DateTime.now().isBefore(_lockedUntil!);
  Duration get remainingLockTime => _lockedUntil != null
      ? _lockedUntil!.difference(DateTime.now())
      : Duration.zero;

  void _handlePinSubmitted(String pin) async {
    if (isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Tunggu ${remainingLockTime.inSeconds} detik sebelum mencoba lagi'),
        ),
      );
      return;
    }

    if (!_isConfirming) {
      setState(() {
        _firstPin = pin;
        _isConfirming = true;
        _showPin = false;
        _confirmAttempts = 0;
      });
      // Reset pin input
      _pinController.clear();
      return;
    }

    if (_firstPin != pin) {
      _confirmAttempts++;
      if (_confirmAttempts >= maxConfirmAttempts) {
        setState(() {
          _isConfirming = false;
          _firstPin = null;
          _confirmAttempts = 0;
          _lockedUntil = DateTime.now().add(lockDuration);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Terlalu banyak percobaan. Tunggu 10 detik sebelum mencoba lagi'),
          ),
        );

        // Start timer untuk update UI
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          setState(() {});
          if (!isLocked) {
            timer.cancel();
          }
        });

        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'PIN tidak cocok. ${maxConfirmAttempts - _confirmAttempts} kesempatan tersisa'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await context.read<AuthProvider>().setupPin(pin);
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        throw Exception('Gagal menyimpan PIN');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _isConfirming
                    ? 'Masukkan PIN sekali lagi untuk konfirmasi'
                    : 'Buat PIN untuk mengamankan aplikasi',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    PinInput(
                      onCompleted: _handlePinSubmitted,
                      obscureText: !_showPin,
                      controller: _pinController,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _showPin = !_showPin);
                      },
                      icon: Icon(
                        _showPin ? Icons.visibility_off : Icons.visibility,
                      ),
                      label:
                          Text(_showPin ? 'Sembunyikan PIN' : 'Tampilkan PIN'),
                    ),
                  ],
                ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
