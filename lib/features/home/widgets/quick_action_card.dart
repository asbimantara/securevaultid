import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  final VoidCallback onAddPassword;
  final VoidCallback onAddCategory;
  final VoidCallback onHealthCheck;

  const QuickActionCard({
    super.key,
    required this.onAddPassword,
    required this.onAddCategory,
    required this.onHealthCheck,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aksi Cepat',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuickActionButton(
                  icon: Icons.password,
                  label: 'Password',
                  onTap: onAddPassword,
                ),
                _QuickActionButton(
                  icon: Icons.folder_open,
                  label: 'Kategori',
                  onTap: onAddCategory,
                ),
                _QuickActionButton(
                  icon: Icons.health_and_safety,
                  label: 'Health Check',
                  onTap: onHealthCheck,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
