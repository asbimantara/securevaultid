import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../auth/widgets/pin_input.dart';

class ChangePinDialog extends StatefulWidget {
  const ChangePinDialog({super.key});

  @override
  State<ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<ChangePinDialog> {
  String? _currentPin;
  String? _newPin;
  String? _confirmPin;
  String? _error;
  bool _isLoading = false;
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _verifyCurrentPin(String pin) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final isValid = await context.read<AuthProvider>().verifyPin(pin);
      if (isValid) {
        setState(() {
          _currentPin = pin;
        });
      } else {
        setState(() {
          _error = 'PIN saat ini tidak sesuai';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changePin() async {
    if (_newPin != _confirmPin) {
      setState(() {
        _error = 'PIN baru tidak cocok';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await context.read<AuthProvider>().changePin(_newPin!);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN berhasil diubah')),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentPin == null) ...[
            const Text('Masukkan PIN saat ini'),
            const SizedBox(height: 16),
            PinInput(
              controller: _currentPinController,
              onCompleted: (pin) {
                _verifyCurrentPin(pin);
                _currentPinController.clear();
              },
              enabled: !_isLoading,
            ),
          ] else if (_newPin == null) ...[
            const Text('Masukkan PIN baru'),
            const SizedBox(height: 16),
            PinInput(
              controller: _newPinController,
              onCompleted: (pin) {
                setState(() => _newPin = pin);
                _newPinController.clear();
              },
              enabled: !_isLoading,
            ),
          ] else ...[
            const Text('Konfirmasi PIN baru'),
            const SizedBox(height: 16),
            PinInput(
              controller: _confirmPinController,
              onCompleted: (pin) {
                setState(() => _confirmPin = pin);
                _confirmPinController.clear();
                _changePin();
              },
              enabled: !_isLoading,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
      ],
    );
  }
}
