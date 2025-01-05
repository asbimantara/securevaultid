import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/theme_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/services/backup_service.dart';
import '../../data/providers/password_provider.dart';
import '../../data/providers/category_provider.dart';
import '../../features/settings/widgets/export_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/settings/widgets/encrypted_backup_dialog.dart';
import '../../features/settings/widgets/restore_encrypted_backup_dialog.dart';
import '../../features/settings/widgets/activity_log_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _backupData(BuildContext context) async {
    try {
      final passwords = context.read<PasswordProvider>().passwords;
      final categories = context.read<CategoryProvider>().categories;

      final backupPath =
          await BackupService.createBackup(passwords, categories);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup berhasil disimpan di: $backupPath'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuat backup'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _restoreData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final path = result.files.single.path!;
        final data = await BackupService.restoreFromFile(path);

        await context
            .read<PasswordProvider>()
            .restorePasswords(data['passwords']);
        await context
            .read<CategoryProvider>()
            .restoreCategories(data['categories']);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil dipulihkan'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memulihkan data'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Mode Gelap'),
            trailing: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Ubah PIN'),
            onTap: () {
              // Implementasi ubah PIN
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            onTap: () => _backupData(context),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Data'),
            onTap: () => _restoreData(context),
          ),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Export Data'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ExportDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Import Password'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ImportDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.enhanced_encryption),
            title: const Text('Backup Terenkripsi'),
            subtitle: const Text('Backup data dengan enkripsi tambahan'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const EncryptedBackupDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore_page),
            title: const Text('Restore dari Backup Terenkripsi'),
            subtitle: const Text('Pulihkan data dari backup terenkripsi'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const RestoreEncryptedBackupDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat Aktivitas'),
            subtitle: const Text('Lihat riwayat aktivitas aplikasi'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ActivityLogScreen(),
                ),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Auto Backup'),
            subtitle: const Text('Backup otomatis setiap 7 hari'),
            value: _autoBackupEnabled,
            onChanged: (value) async {
              setState(() {
                _autoBackupEnabled = value;
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('auto_backup_enabled', value);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Tentang Aplikasi'),
            onTap: () {
              // Tampilkan info aplikasi
            },
          ),
        ],
      ),
    );
  }
}
