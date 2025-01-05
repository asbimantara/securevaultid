import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/password_provider.dart';
import '../widgets/password_list_item.dart';

class PasswordListScreen extends StatefulWidget {
  const PasswordListScreen({super.key});

  @override
  State<PasswordListScreen> createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    await context.read<PasswordProvider>().loadPasswords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Password'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/passwords/add'),
          ),
        ],
      ),
      body: Consumer<PasswordProvider>(
        builder: (context, passwordProvider, child) {
          if (passwordProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final passwords = passwordProvider.passwords;

          if (passwords.isEmpty) {
            return const Center(
              child: Text('Belum ada password yang tersimpan'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadPasswords,
            child: ListView.builder(
              itemCount: passwords.length,
              itemBuilder: (context, index) {
                return PasswordListItem(
                  password: passwords[index],
                  onTap: () {
                    // Tambahkan navigasi ke detail password
                    Navigator.pushNamed(
                      context,
                      '/passwords/detail',
                      arguments: passwords[index],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/passwords/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
