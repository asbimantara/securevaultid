import 'package:flutter/material.dart';
import '../../../data/models/password_history_model.dart';
import '../../../core/utils/clipboard_util.dart';

class PasswordHistoryDialog extends StatelessWidget {
  final List<PasswordHistory> history;

  const PasswordHistoryDialog({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Riwayat Password'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            return ListTile(
              title: Text(
                item.password,
                style: const TextStyle(fontFamily: 'Monospace'),
              ),
              subtitle: Text(
                'Diubah pada: ${_formatDate(item.changedAt)}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => ClipboardUtil.copyToClipboard(
                  context,
                  item.password,
                  'Password lama disalin ke clipboard',
                ),
              ),
            );
          },
        ),
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
