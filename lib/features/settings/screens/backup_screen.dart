import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/backup_service.dart';
import '../../../data/providers/password_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../widgets/backup_list_item.dart';
import '../widgets/create_backup_dialog.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  List<BackupInfo> _backups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);
    try {
      final backups = await BackupService.listBackups();
      setState(() => _backups = backups);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showBackupSettings(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBackups,
              child: _backups.isEmpty ? _buildEmptyState() : _buildBackupList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createBackup(context),
        child: const Icon(Icons.backup),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.backup,
            size: 64,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          const Text('Belum ada backup tersimpan'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _createBackup(context),
            child: const Text('Buat Backup Sekarang'),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _backups.length,
      itemBuilder: (context, index) {
        final backup = _backups[index];
        return BackupListItem(
          backup: backup,
          onRestore: () => _restoreBackup(context, backup),
          onDelete: () => _deleteBackup(context, backup),
        );
      },
    );
  }

  Future<void> _createBackup(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateBackupDialog(),
    );

    if (result == true) {
      await _loadBackups();
    }
  }

  Future<void> _restoreBackup(BuildContext context, BackupInfo backup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pulihkan Backup'),
        content: const Text(
          'Data saat ini akan diganti dengan data dari backup. '
          'Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Pulihkan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await BackupService.restoreFromBackup(backup.path);
        // Reload data
        await context.read<PasswordProvider>().loadPasswords();
        await context.read<CategoryProvider>().loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil dipulihkan')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memulihkan data: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteBackup(BuildContext context, BackupInfo backup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Backup'),
        content: const Text('Backup ini akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await BackupService.deleteBackup(backup.path);
        await _loadBackups();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus backup: $e')),
          );
        }
      }
    }
  }

  void _showBackupSettings(BuildContext context) {
    // TODO: Implement backup settings
  }
}
