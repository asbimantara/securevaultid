import 'package:flutter/material.dart';
import '../../../core/services/password_health_service.dart';
import '../../../data/models/password_model.dart';

class PasswordHealthDialog extends StatelessWidget {
  final Password password;

  const PasswordHealthDialog({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final health = PasswordHealthService.checkPasswordHealth(password);

    return AlertDialog(
      title: const Text('Password Health Check'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircularProgressIndicator(
                value: health.score / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(health.statusColor),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skor: ${health.score.toInt()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Status: ${health.status}',
                    style: TextStyle(color: health.statusColor),
                  ),
                ],
              ),
            ],
          ),
          if (health.issues.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Rekomendasi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...health.recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Terakhir diubah: ${_formatDate(health.lastChanged)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
