import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/password_provider.dart';
import '../../../data/models/password_model.dart';

class PasswordHealthScreen extends StatelessWidget {
  const PasswordHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kesehatan Password'),
      ),
      body: Consumer<PasswordProvider>(
        builder: (context, passwordProvider, _) {
          final passwords = passwordProvider.passwords;
          if (passwords.isEmpty) {
            return const Center(
              child: Text('Belum ada password yang tersimpan'),
            );
          }

          // Kategorikan password berdasarkan kekuatan
          final weakPasswords =
              passwords.where((p) => p.strength < 0.4).toList();
          final mediumPasswords = passwords
              .where((p) => p.strength >= 0.4 && p.strength < 0.7)
              .toList();
          final strongPasswords =
              passwords.where((p) => p.strength >= 0.7).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Distribusi Kekuatan Password
              _buildStrengthDistributionCard(
                context,
                weakPasswords.length,
                mediumPasswords.length,
                strongPasswords.length,
                passwords.length,
              ),
              const SizedBox(height: 16),

              // Password Lemah
              if (weakPasswords.isNotEmpty)
                _buildPasswordStrengthCard(
                  context,
                  'Password Lemah',
                  'Tingkatkan keamanan password ini',
                  weakPasswords,
                  Colors.red,
                  Icons.warning,
                ),
              const SizedBox(height: 16),

              // Password Sedang
              if (mediumPasswords.isNotEmpty)
                _buildPasswordStrengthCard(
                  context,
                  'Password Sedang',
                  'Password cukup kuat tapi masih bisa ditingkatkan',
                  mediumPasswords,
                  Colors.orange,
                  Icons.info,
                ),
              const SizedBox(height: 16),

              // Password Kuat
              if (strongPasswords.isNotEmpty)
                _buildPasswordStrengthCard(
                  context,
                  'Password Kuat',
                  'Password sudah sangat aman',
                  strongPasswords,
                  Colors.green,
                  Icons.check_circle,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPasswordStrengthCard(
    BuildContext context,
    String title,
    String subtitle,
    List<Password> passwords,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(subtitle),
            leading: Icon(icon, color: color),
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: passwords.length,
            itemBuilder: (context, index) {
              final password = passwords[index];
              return ListTile(
                title: Text(
                  password.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  password.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/passwords/detail',
                    arguments: password,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthDistributionCard(
    BuildContext context,
    int weak,
    int medium,
    int strong,
    int total,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribusi Kekuatan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStrengthBar('Lemah', weak, total, Colors.red),
            const SizedBox(height: 8),
            _buildStrengthBar('Sedang', medium, total, Colors.orange),
            const SizedBox(height: 8),
            _buildStrengthBar('Kuat', strong, total, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ($count)'),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}
