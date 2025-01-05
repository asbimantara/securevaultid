import 'package:flutter/material.dart';
import '../../../core/services/backup_service.dart';

class CreateBackupDialog extends StatefulWidget {
  const CreateBackupDialog({super.key});

  @override
  State<CreateBackupDialog> createState() => _CreateBackupDialogState();
}

class _CreateBackupDialogState extends State<CreateBackupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isEncrypted = true;
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buat Backup'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Backup',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama backup tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enkripsi Backup'),
              subtitle: const Text(
                'Backup akan dienkripsi dengan password master',
              ),
              value: _isEncrypted,
              onChanged: (value) => setState(() => _isEncrypted = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _handleCreate,
          child: _isCreating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Buat'),
        ),
      ],
    );
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);
    try {
      await BackupService.createBackup(
        name: _nameController.text,
        encrypted: _isEncrypted,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat backup: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
