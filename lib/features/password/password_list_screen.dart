import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/password_provider.dart';
import 'widgets/search_bar.dart';
import 'widgets/password_analytics_dialog.dart';
import 'widgets/import_shared_password_dialog.dart';
import 'widgets/password_health_dialog.dart';

class PasswordListScreen extends StatefulWidget {
  const PasswordListScreen({super.key});

  @override
  State<PasswordListScreen> createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  String _searchQuery = '';
  String _selectedTag = '';
  bool _showFavoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Password'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: _showFavoritesOnly ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Consumer<PasswordProvider>(
                  builder: (context, provider, child) {
                    return PasswordAnalyticsDialog(
                      passwords: provider.passwords,
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Import Password yang Dibagikan',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const ImportSharedPasswordDialog(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          PasswordSearchBar(
            onSearch: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Consumer<PasswordProvider>(
              builder: (context, provider, child) {
                final allTags = provider.getAllTags();
                return Row(
                  children: [
                    FilterChip(
                      label: const Text('Semua'),
                      selected: _selectedTag.isEmpty,
                      onSelected: (_) {
                        setState(() {
                          _selectedTag = '';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ...allTags.map((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(tag),
                          selected: _selectedTag == tag,
                          onSelected: (_) {
                            setState(() {
                              _selectedTag = tag;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<PasswordProvider>(
              builder: (context, provider, child) {
                var passwords = provider.passwords;

                // Apply filters
                if (_showFavoritesOnly) {
                  passwords = passwords.where((p) => p.isFavorite).toList();
                }
                if (_selectedTag.isNotEmpty) {
                  passwords = passwords
                      .where((p) => p.tags.contains(_selectedTag))
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  passwords = provider.searchPasswords(_searchQuery);
                }

                if (passwords.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.no_encryption,
                          size: 64,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Belum ada password tersimpan'
                              : 'Tidak ada password yang sesuai',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return AnimatedList(
                  initialItemCount: passwords.length,
                  itemBuilder: (context, index, animation) {
                    final password = passwords[index];
                    return SlideTransition(
                      position: animation.drive(
                        Tween(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ),
                      ),
                      child: PasswordListItem(
                        password: password,
                        onDelete: () async {
                          await context
                              .read<PasswordProvider>()
                              .deletePassword(password);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordListItem extends StatelessWidget {
  final Password password;
  final VoidCallback onDelete;

  const PasswordListItem({
    super.key,
    required this.password,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(password.key),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: Hero(
            tag: 'password_${password.key}',
            child: CircleAvatar(
              child: Text(
                password.title[0].toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          title: Text(password.title),
          subtitle: Text(password.username),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Salin Username'),
                onTap: () {
                  // Implementasi copy username
                },
              ),
              PopupMenuItem(
                child: const Text('Salin Password'),
                onTap: () {
                  // Implementasi copy password
                },
              ),
              PopupMenuItem(
                child: const Text('Edit'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PasswordFormScreen(
                        password: password,
                      ),
                    ),
                  );
                },
              ),
              PopupMenuItem(
                child: const Text('Hapus'),
                onTap: onDelete,
              ),
              PopupMenuItem(
                child: const Text('Health Check'),
                onTap: () {
                  Future.delayed(
                    const Duration(milliseconds: 10),
                    () => showDialog(
                      context: context,
                      builder: (context) =>
                          PasswordHealthDialog(password: password),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
