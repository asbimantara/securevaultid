import 'package:flutter/material.dart';

class IconPickerDialog extends StatelessWidget {
  final IconData? initialIcon;

  const IconPickerDialog({
    super.key,
    this.initialIcon,
  });

  static final List<IconData> _icons = [
    Icons.lock,
    Icons.security,
    Icons.password,
    Icons.key,
    Icons.account_circle,
    Icons.credit_card,
    Icons.shopping_bag,
    Icons.work,
    Icons.school,
    Icons.home,
    Icons.phone,
    Icons.email,
    Icons.public,
    Icons.games,
    Icons.folder,
    // Tambahkan icon lainnya sesuai kebutuhan
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Ikon'),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _icons.length,
          itemBuilder: (context, index) {
            final icon = _icons[index];
            return InkWell(
              onTap: () => Navigator.pop(context, icon),
              child: CircleAvatar(
                backgroundColor: initialIcon == icon
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                child: Icon(
                  icon,
                  color: initialIcon == icon
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          },
        ),
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
