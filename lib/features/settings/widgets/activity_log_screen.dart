import 'package:flutter/material.dart';
import '../../../core/services/activity_log_service.dart';
import '../../../data/models/activity_log_model.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = ActivityLogService.getRecentLogs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Aktivitas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Riwayat'),
                  content: const Text(
                    'Anda yakin ingin menghapus semua riwayat aktivitas?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await ActivityLogService.clearLogs();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Riwayat aktivitas dihapus'),
                            ),
                          );
                        }
                      },
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return ActivityLogItem(log: log);
        },
      ),
    );
  }
}

class ActivityLogItem extends StatelessWidget {
  final ActivityLog log;

  const ActivityLogItem({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _getIcon(),
      title: Text(log.description),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (log.details != null) Text(log.details!),
          Text(
            _formatDateTime(log.timestamp),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Icon _getIcon() {
    switch (log.type) {
      case ActivityType.passwordCreated:
        return const Icon(Icons.add);
      case ActivityType.passwordModified:
        return const Icon(Icons.edit);
      case ActivityType.passwordDeleted:
        return const Icon(Icons.delete);
      case ActivityType.passwordShared:
        return const Icon(Icons.share);
      case ActivityType.categoryModified:
        return const Icon(Icons.category);
      case ActivityType.securityAlert:
        return const Icon(Icons.warning, color: Colors.orange);
      case ActivityType.settingsChanged:
        return const Icon(Icons.settings);
      case ActivityType.backup:
        return const Icon(Icons.backup);
      case ActivityType.restore:
        return const Icon(Icons.restore);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
