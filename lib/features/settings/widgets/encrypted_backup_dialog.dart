import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/backup_encryption_service.dart';
import '../../../data/providers/password_provider.dart';
import '../../../data/providers/category_provider.dart';

class EncryptedBackupDialog extends StatefulWidget {
  const EncryptedBackupDialog({super.key});

  @override
  State<EncryptedBackupDialog> createState() => _EncryptedBackupDialogState();
}

class _EncryptedBackupDialogState extends State<EncryptedBackupDialog> {
  final _backupKeyController = TextEditingController();
  final _confirmKeyController = TextEditingController();
  bool _showKey = false;
  String? _error;

  Future<void> _createBackup() async {
    if (_backupKeyController.text.length < 8) {
      setState(() {
        _error = 'Kunci backup minimal 8 karakter';
      });
      return;
    }

    if (_backupKeyController.text != _confirmKeyController.text) {
      setState(() {
        _error = 'Konfirmasi kunci tidak cocok';
      });
      return;
    }

    final passwords = context.read<PasswordProvider>().passwords;
    final categories = context.read<CategoryProvider>().categories;

    final backupPath = await BackupEncryptionService.createEncryptedBackup(
      passwords: passwords,
      categories: categories,
      backupKey: _backupKeyController.text,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            backupPath != null
                ? 'Backup terenkripsi berhasil disimpan di: $backupPath'
                : 'Gagal membuat backup terenkripsi',
          ),
          backgroundColor: backupPath != null ? null : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Backup Terenkripsi'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Masukkan kunci untuk mengenkripsi backup Anda. '
            'Simpan kunci ini dengan aman, Anda akan memerlukannya untuk memulihkan data.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _backupKeyController,
            decoration: InputDecoration(
              labelText: 'Kunci Backup',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _showKey ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _showKey = !_showKey;
                  });
                },
              ),
            ),
            obscureText: !_showKey,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmKeyController,
            decoration: const InputDecoration(
              labelText: 'Konfirmasi Kunci',
              border: OutlineInputBorder(),
            ),
            obscureText: !_showKey,
          ),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _createBackup,
          child: const Text('Backup'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _backupKeyController.dispose();
    _confirmKeyController.dispose();
    super.dispose();
  }
}
