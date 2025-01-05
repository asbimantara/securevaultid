import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/password_rotation_service.dart';
import '../../../data/providers/password_provider.dart';
import '../../../data/models/password_model.dart';

class PasswordRotationDialog extends StatefulWidget {
  final Password password;

  const PasswordRotationDialog({
    super.key,
    required this.password,
  });

  @override
  State<PasswordRotationDialog> createState() => _PasswordRotationDialogState();
}

class _PasswordRotationDialogState extends State<PasswordRotationDialog> {
  bool _showPreview = false;
  String? _previewPassword;

  void _generatePreview() {
    setState(() {
      _previewPassword = PasswordRotationService.generateStrongPassword();
      _showPreview = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rotasi Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password saat ini:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(widget.password.password),
          const SizedBox(height: 16),
          if (_showPreview) ...[
            Text(
              'Password baru:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(_previewPassword!),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(
            onPressed: _generatePreview,
            icon: const Icon(Icons.refresh),
            label: const Text('Generate Password Baru'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        if (_showPreview)
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<PasswordProvider>();
              await PasswordRotationService.rotatePassword(
                context,
                widget.password,
                provider,
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Terapkan'),
          ),
      ],
    );
  }
}
