import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/password_provider.dart';
import '../../password/widgets/password_list_item.dart';

class RecentPasswords extends StatelessWidget {
  const RecentPasswords({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Password Terbaru',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/passwords'),
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Consumer<PasswordProvider>(
              builder: (context, provider, child) {
                final recentPasswords = provider.passwords.take(5).toList();

                if (recentPasswords.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('Belum ada password tersimpan'),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentPasswords.length,
                  itemBuilder: (context, index) {
                    return PasswordListItem(
                      password: recentPasswords[index],
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/password/form',
                        arguments: recentPasswords[index],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
