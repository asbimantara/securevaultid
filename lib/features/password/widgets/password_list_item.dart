import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/password_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/providers/category_provider.dart';

class PasswordListItem extends StatelessWidget {
  final Password password;
  final VoidCallback? onTap;

  const PasswordListItem({
    super.key,
    required this.password,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Category? category = password.categoryId != null
        ? context.read<CategoryProvider>().getCategoryById(password.categoryId!)
        : null;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: category?.color != null
            ? Color(category!.color)
            : Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.lock,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      title: Text(
        password.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            password.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (password.url != null && password.url!.isNotEmpty)
            Text(
              password.url!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (category != null)
            Container(
              constraints: const BoxConstraints(maxWidth: 100),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Color(category.color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(category.color),
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
