import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/secure_sharing_service.dart';
import '../../../data/providers/password_provider.dart';
import '../../../data/models/password_model.dart';

class ImportSharedPasswordDialog extends StatefulWidget {
  const ImportSharedPasswordDialog({super.key});

  @override
  State<ImportSharedPasswordDialog> createState() =>
      _ImportSharedPasswordDialogState();
}

class _ImportSharedPasswordDialogState
    extends State<ImportSharedPasswordDialog> {
  final _encryptedTextController = TextEditingController();
  final _shareKeyController = TextEditingController();
  bool _showShareKey = false;
  Password? _decryptedPassword;

  void _decryptPassword() {
    final password = SecureSharingService.decryptSharedPassword(
      _encryptedTextController.text,
      _shareKeyController.text,
    );

    setState(() {
      _decryptedPassword = password;
    });

    if (password == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mendekripsi password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Password yang Dibagikan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _encryptedTextController,
              decoration: InputDecoration(
                labelText: 'Teks Terenkripsi',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data?.text != null) {
                      _encryptedTextController.text = data!.text!;
                    }
                  },
                ),
              ),
              maxLines: 3,
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _decryptPassword,
              icon: const Icon(Icons.lock_open),
              label: const Text('Dekripsi'),
            ),
            if (_decryptedPassword != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Password Terdekripsi:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildPasswordPreview(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        if (_decryptedPassword != null)
          ElevatedButton(
            onPressed: () {
              context.read<PasswordProvider>().addPassword(_decryptedPassword!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password berhasil diimpor'),
                ),
              );
            },
            child: const Text('Import'),
          ),
      ],
    );
  }

  Widget _buildPasswordPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreviewRow('Judul', _decryptedPassword!.title),
            const SizedBox(height: 8),
            _buildPreviewRow('Username', _decryptedPassword!.username),
            const SizedBox(height: 8),
            _buildPreviewRow('Password', _decryptedPassword!.password),
            if (_decryptedPassword!.website != null) ...[
              const SizedBox(height: 8),
              _buildPreviewRow('Website', _decryptedPassword!.website!),
            ],
            const SizedBox(height: 8),
            _buildPreviewRow('Kategori', _decryptedPassword!.category),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _encryptedTextController.dispose();
    _shareKeyController.dispose();
    super.dispose();
  }
}
