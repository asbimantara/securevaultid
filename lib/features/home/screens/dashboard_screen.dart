// - Quick actions
// - Recent passwords
// - Statistics overview

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/password_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../password/widgets/password_list_item.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recent_passwords.dart';
import '../widgets/statistics_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<PasswordProvider>().loadPasswords();
    await context.read<CategoryProvider>().loadCategories();
  }

  void _handleAddPassword() {
    Navigator.pushNamed(context, '/passwords/add');
  }

  void _handleAddCategory() {
    Navigator.pushNamed(context, '/categories/add');
  }

  void _handleHealthCheck() {
    Navigator.pushNamed(context, '/passwords/health');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SecureVault ID'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            QuickActionCard(
              onAddPassword: _handleAddPassword,
              onAddCategory: _handleAddCategory,
              onHealthCheck: _handleHealthCheck,
            ),
            const SizedBox(height: 16),
            const StatisticsCard(),
            const SizedBox(height: 16),
            Consumer<PasswordProvider>(
              builder: (context, passwordProvider, _) {
                final recentPasswords = passwordProvider.getRecentPasswords(5);

                if (recentPasswords.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: const Text('Password Terbaru'),
                        trailing: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/passwords');
                          },
                          child: const Text('Lihat Semua'),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentPasswords.length,
                        itemBuilder: (context, index) {
                          return PasswordListItem(
                            password: recentPasswords[index],
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/passwords/detail',
                                arguments: recentPasswords[index],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.password),
            label: 'Password',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Kategori',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/passwords');
              break;
            case 2:
              Navigator.pushNamed(context, '/categories');
              break;
          }
        },
      ),
    );
  }
}
