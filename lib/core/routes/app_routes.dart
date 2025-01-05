import 'package:flutter/material.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/auth/screens/pin_setup_screen.dart';
import '../../features/home/screens/dashboard_screen.dart';
import '../../features/password/screens/password_list_screen.dart';
import '../../features/password/screens/password_form_screen.dart';
import '../../features/category/screens/category_list_screen.dart';
import '../../features/category/screens/category_form_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/password/screens/password_health_screen.dart';
import '../../features/welcome/screens/welcome_screen.dart';
import '../../features/password/screens/password_detail_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/': (context) => const WelcomeScreen(),
      '/auth': (context) => const AuthScreen(),
      '/pin-setup': (context) => const PinSetupScreen(),
      '/home': (context) => const DashboardScreen(),
      '/passwords': (context) => const PasswordListScreen(),
      '/passwords/add': (context) => const PasswordFormScreen(),
      '/passwords/edit': (context) => const PasswordFormScreen(),
      '/passwords/health': (context) => const PasswordHealthScreen(),
      '/categories': (context) => const CategoryListScreen(),
      '/categories/add': (context) => const CategoryFormScreen(),
      '/categories/edit': (context) => const CategoryFormScreen(),
      '/settings': (context) => const SettingsScreen(),
      '/passwords/detail': (context) => const PasswordDetailScreen(),
    };
  }
}
