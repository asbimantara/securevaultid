import 'package:flutter/material.dart';
import '../../../core/services/emergency_access_service.dart';
import '../../../core/utils/validation_utils.dart';

class EmergencyAccessDialog extends StatefulWidget {
  final bool isSetup;

  const EmergencyAccessDialog({
    super.key,
    this.isSetup = false,
  });

  @override
  State<EmergencyAccessDialog> createState() => _EmergencyAccessDialogState();
}

class _EmergencyAccessDialogState extends State<EmergencyAccessDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.isSetup) {
        if (_codeController.text != _confirmController.text) {
          setState(() {
            _error = 'Kode tidak cocok';
            _isLoading = false;
          });
          return;
        }
        await EmergencyAccessService.setupEmergencyAccess(_codeController.text);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final isValid = await EmergencyAccessService.verifyEmergencyAccess(
            _codeController.text);
        if (mounted) {
          Navigator.pop(context, isValid);
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isSetup ? 'Setup Kode Darurat' : 'Akses Darurat'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Kode Darurat',
                border: OutlineInputBorder(),
              ),
              validator: ValidationUtils.validatePassword,
              obscureText: true,
            ),
            if (widget.isSetup) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Kode',
                  border: OutlineInputBorder(),
                ),
                validator: ValidationUtils.validatePassword,
                obscureText: true,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.isSetup ? 'Simpan' : 'Verifikasi'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}
