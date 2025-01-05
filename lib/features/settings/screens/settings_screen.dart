import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/password_provider.dart';
import '../../../features/settings/widgets/import_dialog.dart';
import '../widgets/change_pin_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          // Keamanan
          const ListTile(
            title: Text(
              'Keamanan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) => SwitchListTile(
              title: const Text('Kunci Otomatis'),
              subtitle: const Text('Kunci aplikasi saat tidak aktif'),
              value: settings.autoLock,
              onChanged: (value) => settings.setAutoLock(value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.pin),
            title: const Text('Ubah PIN'),
            subtitle: const Text('Ubah PIN untuk mengakses aplikasi'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ChangePinDialog(),
              );
            },
          ),
          const Divider(),

          // Data
          const ListTile(
            title: Text(
              'Data',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            title: const Text('Ekspor Data'),
            subtitle: const Text('Simpan salinan data password Anda'),
            leading: const Icon(Icons.upload),
            onTap: () async {
              try {
                await context.read<PasswordProvider>().exportPasswords();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Gagal mengekspor data: ${e.toString()}')),
                  );
                }
              }
            },
          ),
          ListTile(
            title: const Text('Impor Data'),
            subtitle: const Text('Muat data password dari file'),
            leading: const Icon(Icons.download),
            onTap: () async {
              final result = await showDialog(
                context: context,
                builder: (context) => const ImportDialog(),
              );

              if (result != null && context.mounted) {
                try {
                  await context
                      .read<PasswordProvider>()
                      .importPasswords(result);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data berhasil diimpor')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              }
            },
          ),
          const Divider(),

          // Tentang & Keluar (tetap sama seperti sebelumnya)
          ListTile(
            title: const Text('Tentang Aplikasi'),
            subtitle: const Text('SecureVault ID v1.0.0'),
            leading: const Icon(Icons.info),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SecureVault ID',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.lock, size: 48),
                children: [
                  const Text(
                    'Aplikasi pengelola password yang aman dan mudah digunakan. '
                    'Simpan dan kelola password Anda dengan lebih terorganisir.',
                  ),
                ],
              );
            },
          ),
          ListTile(
            title: const Text('Keluar'),
            subtitle: const Text('Keluar dari aplikasi'),
            leading: const Icon(Icons.logout),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar'),
                  content: const Text('Anda yakin ingin keluar dari aplikasi?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthProvider>().logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/auth',
                          (route) => false,
                        );
                      },
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
