import 'package:flutter/material.dart';
import '../auth/auth_screen.dart';
import '../../data/providers/auth_provider.dart';
import '../../core/utils/page_transitions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () async {
        if (mounted) {
          final authProvider = context.read<AuthProvider>();
          await authProvider.init();

          if (authProvider.useBiometrics) {
            final authenticated = await authProvider.authenticate();
            if (authenticated && mounted) {
              _navigateToHome();
            } else if (mounted) {
              _navigateToAuth();
            }
          } else {
            _navigateToAuth();
          }
        }
      });
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      FadePageRoute(child: const HomeScreen()),
    );
  }

  void _navigateToAuth() {
    Navigator.pushReplacement(
      context,
      FadePageRoute(child: const AuthScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: const Icon(
                Icons.lock,
                size: 80,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _opacityAnimation,
              child: Column(
                children: [
                  Text(
                    'SecureVault ID',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Simpan Password Anda dengan Aman',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
