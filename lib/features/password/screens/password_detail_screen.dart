import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/password_model.dart';
import '../../../data/models/category_model.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/providers/password_provider.dart';

class PasswordDetailScreen extends StatefulWidget {
  const PasswordDetailScreen({super.key});

  @override
  State<PasswordDetailScreen> createState() => _PasswordDetailScreenState();
}

class _PasswordDetailScreenState extends State<PasswordDetailScreen> {
  bool _obscurePassword = true;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label disalin ke clipboard')),
    );
  }

  void _deletePassword(Password password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Password'),
        content: const Text(
          'Anda yakin ingin menghapus password ini? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context
                    .read<PasswordProvider>()
                    .deletePassword(password.id);
                if (mounted) {
                  Navigator.of(context).popUntil(
                    ModalRoute.withName('/home'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password berhasil dihapus'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Gagal menghapus password: ${e.toString()}'),
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final password = ModalRoute.of(context)!.settings.arguments as Password;
    final category = password.categoryId != null
        ? context.read<CategoryProvider>().getCategoryById(password.categoryId!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Password'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/passwords/edit',
                arguments: password,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deletePassword(password),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDetailItem(
            context: context,
            label: 'Judul',
            value: password.title,
            onCopy: () => _copyToClipboard(password.title, 'Judul'),
          ),
          _buildDetailItem(
            context: context,
            label: 'Username/Email',
            value: password.username,
            onCopy: () => _copyToClipboard(password.username, 'Username'),
          ),
          _buildDetailItem(
            context: context,
            label: 'Password',
            value: password.password,
            obscure: _obscurePassword,
            onCopy: () => _copyToClipboard(password.password, 'Password'),
            trailing: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          if (category != null)
            _buildDetailItem(
              context: context,
              label: 'Kategori',
              value: category.name,
              color: Color(category.color),
            ),
          if (password.url != null && password.url!.isNotEmpty)
            _buildDetailItem(
              context: context,
              label: 'URL',
              value: password.url!,
              onCopy: () => _copyToClipboard(password.url!, 'URL'),
            ),
          if (password.notes != null && password.notes!.isNotEmpty)
            _buildDetailItem(
              context: context,
              label: 'Catatan',
              value: password.notes!,
              onCopy: () => _copyToClipboard(password.notes!, 'Catatan'),
            ),
          const SizedBox(height: 16),
          Text(
            'Dibuat pada: ${_formatDate(password.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (password.lastModified != null)
            Text(
              'Terakhir diubah: ${_formatDate(password.lastModified!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required String label,
    required String value,
    Color? color,
    bool obscure = false,
    VoidCallback? onCopy,
    Widget? trailing,
  }) {
    return Card(
      child: ListTile(
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        subtitle: Text(
          obscure ? '••••••••' : value,
          style: TextStyle(
            color: color,
            fontSize: 16,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onCopy != null)
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: onCopy,
              ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
