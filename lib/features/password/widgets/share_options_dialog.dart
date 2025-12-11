import 'package:flutter/material.dart';
import '../../../core/services/share_service.dart';
import '../../../data/models/password_model.dart';

class ShareOptionsDialog extends StatelessWidget {
  final Password password;

  const ShareOptionsDialog({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bagikan Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility_off),
            title: const Text('Tanpa Password'),
            subtitle: const Text('Hanya bagikan username dan website'),
            onTap: () {
              Navigator.pop(context);
              ShareService.sharePassword(context, password);
            },
          ),
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Dengan Password'),
            subtitle: const Text('Bagikan semua informasi'),
            onTap: () {
              Navigator.pop(context);
              ShareService.sharePassword(
                context,
                password,
                includePassword: true,
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
      ],
    );
  }
}
