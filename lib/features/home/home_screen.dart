import 'package:flutter/material.dart';
import '../password/password_list_screen.dart';
import '../category/category_screen.dart';
import '../settings/settings_screen.dart';
import '../../core/utils/page_transitions.dart';
import '../../data/providers/auth_provider.dart';
import '../../core/services/auto_logout_service.dart';

class HomeScreen extends StatelessWidget {
  final bool isEmergencyMode;

  const HomeScreen({
    super.key,
    this.isEmergencyMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmergencyMode) {
      return Banner(
        message: 'Mode Darurat',
        location: BannerLocation.topEnd,
        color: Colors.red,
        child: _buildNormalScreen(),
      );
    }
    return _buildNormalScreen();
  }

  Widget _buildNormalScreen() {
    int _currentIndex = 0;

    final List<Widget> _screens = [
      const PasswordListScreen(),
      const CategoryScreen(),
      const SettingsScreen(),
    ];

    return GestureDetector(
      onTapDown: (_) => AutoLogoutService.resetTimer(context),
      onTapUp: (_) => AutoLogoutService.resetTimer(context),
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            _currentIndex = index;
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.password),
              label: 'Password',
            ),
            NavigationDestination(
              icon: Icon(Icons.category),
              label: 'Kategori',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
          ],
        ),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
                onPressed: () {
                  // Navigate to add password screen
                },
                child: const Icon(Icons.add),
              )
            : null,
        appBar: AppBar(
          title: const Text('SecureVault ID'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthProvider>().logout();
                Navigator.pushReplacement(
                  context,
                  FadePageRoute(child: const AuthScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
