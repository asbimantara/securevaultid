import 'package:flutter/material.dart';
import '../../../core/services/secure_sharing_service.dart';
import '../../../data/models/password_model.dart';

class SecureShareDialog extends StatefulWidget {
  final Password password;

  const SecureShareDialog({
    super.key,
    required this.password,
  });

  @override
  State<SecureShareDialog> createState() => _SecureShareDialogState();
}

class _SecureShareDialogState extends State<SecureShareDialog> {
  final _shareKeyController = TextEditingController();
  bool _showShareKey = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bagikan Password Secara Aman'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Masukkan kunci berbagi untuk mengenkripsi password sebelum dibagikan.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _shareKeyController,
            decoration: InputDecoration(
              labelText: 'Kunci Berbagi',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _showShareKey ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _showShareKey = !_showShareKey;
                  });
                },
              ),
            ),
            obscureText: !_showShareKey,
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan untuk membagikan kunci ini melalui saluran yang berbeda dengan password yang dibagikan.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_shareKeyController.text.length < 8) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kunci berbagi minimal 8 karakter'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            SecureSharingService.shareSecurely(
              context,
              widget.password,
              _shareKeyController.text,
            );
            Navigator.pop(context);
          },
          child: const Text('Bagikan'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _shareKeyController.dispose();
    super.dispose();
  }
}
