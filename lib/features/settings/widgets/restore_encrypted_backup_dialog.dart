import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/backup_encryption_service.dart';
import '../../../data/providers/password_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/models/password_model.dart';
import '../../../data/models/category_model.dart';

class RestoreEncryptedBackupDialog extends StatefulWidget {
  const RestoreEncryptedBackupDialog({super.key});

  @override
  State<RestoreEncryptedBackupDialog> createState() =>
      _RestoreEncryptedBackupDialogState();
}

class _RestoreEncryptedBackupDialogState
    extends State<RestoreEncryptedBackupDialog> {
  final _backupKeyController = TextEditingController();
  bool _showKey = false;
  String? _selectedFile;
  String? _error;
  Map<String, dynamic>? _decryptedData;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['enc'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.single.path;
          _decryptedData = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memilih file backup';
      });
    }
  }

  Future<void> _decryptBackup() async {
    if (_selectedFile == null) {
      setState(() {
        _error = 'Pilih file backup terlebih dahulu';
      });
      return;
    }

    if (_backupKeyController.text.isEmpty) {
      setState(() {
        _error = 'Masukkan kunci backup';
      });
      return;
    }

    final data = await BackupEncryptionService.restoreFromEncryptedBackup(
      _selectedFile!,
      _backupKeyController.text,
    );

    if (data != null) {
      setState(() {
        _decryptedData = data;
        _error = null;
      });
    } else {
      setState(() {
        _error =
            'Gagal mendekripsi backup. Pastikan kunci yang dimasukkan benar.';
      });
    }
  }

  Future<void> _restoreBackup() async {
    if (_decryptedData == null) return;

    try {
      final passwords = (_decryptedData!['passwords'] as List)
          .map((p) => Password(
                title: p['title'],
                username: p['username'],
                password: p['password'],
                website: p['website'],
                category: p['category'],
                createdAt: DateTime.parse(p['createdAt']),
                lastModified: p['lastModified'] != null
                    ? DateTime.parse(p['lastModified'])
                    : null,
                tags: List<String>.from(p['tags'] ?? []),
                isFavorite: p['isFavorite'] ?? false,
                expirationDate: p['expirationDate'] != null
                    ? DateTime.parse(p['expirationDate'])
                    : null,
              ))
          .toList();

      final categories = (_decryptedData!['categories'] as List)
          .map((c) => Category(
                name: c['name'],
                icon: c['icon'],
                color: Color(c['color']),
              ))
          .toList();

      await context.read<PasswordProvider>().restorePasswords(passwords);
      await context.read<CategoryProvider>().restoreCategories(categories);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil dipulihkan dari backup'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memulihkan data: Format backup tidak valid';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pulihkan dari Backup Terenkripsi'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.file_upload),
              label: const Text('Pilih File Backup'),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 8),
              Text(
                'File: $_selectedFile',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
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
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            if (_decryptedData != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Preview Data:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Passwords: ${(_decryptedData!['passwords'] as List).length}',
              ),
              Text(
                'Categories: ${(_decryptedData!['categories'] as List).length}',
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        if (_decryptedData == null)
          ElevatedButton(
            onPressed: _decryptBackup,
            child: const Text('Dekripsi'),
          )
        else
          ElevatedButton(
            onPressed: _restoreBackup,
            child: const Text('Pulihkan'),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _backupKeyController.dispose();
    super.dispose();
  }
}
