import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/providers/password_provider.dart';
import '../../../core/utils/date_formatter.dart';

class PasswordAnalyticsScreen extends StatelessWidget {
  const PasswordAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisis Password'),
      ),
      body: Consumer<PasswordProvider>(
        builder: (context, provider, child) {
          final passwords = provider.passwords;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStrengthDistribution(passwords),
              const SizedBox(height: 16),
              _buildAgeDistribution(passwords),
              const SizedBox(height: 16),
              _buildSecuritySuggestions(passwords),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStrengthDistribution(List<Password> passwords) {
    // Implementasi chart distribusi kekuatan password
    return const Card();
  }

  Widget _buildAgeDistribution(List<Password> passwords) {
    // Implementasi chart distribusi umur password
    return const Card();
  }

  Widget _buildSecuritySuggestions(List<Password> passwords) {
    // Implementasi saran keamanan
    return const Card();
  }
}
