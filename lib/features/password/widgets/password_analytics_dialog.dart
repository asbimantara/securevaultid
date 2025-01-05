import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/analytics_service.dart';
import '../../../data/models/password_model.dart';

class PasswordAnalyticsDialog extends StatelessWidget {
  final List<Password> passwords;

  const PasswordAnalyticsDialog({
    super.key,
    required this.passwords,
  });

  @override
  Widget build(BuildContext context) {
    final analytics = AnalyticsService.analyzePasswords(passwords);

    return AlertDialog(
      title: const Text('Analisis Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummarySection(analytics),
            const Divider(),
            _buildStrengthDistributionChart(analytics),
            const Divider(),
            _buildCategoryDistributionChart(analytics),
            if (analytics.duplicatePasswords.isNotEmpty) ...[
              const Divider(),
              _buildDuplicatePasswordsSection(analytics),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  Widget _buildSummarySection(PasswordAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total Password: ${analytics.totalPasswords}'),
        Text('Password Lemah: ${analytics.weakPasswords}'),
        Text('Password Kadaluarsa: ${analytics.expiredPasswords}'),
      ],
    );
  }

  Widget _buildStrengthDistributionChart(PasswordAnalytics analytics) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: _createStrengthSections(analytics),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionChart(PasswordAnalytics analytics) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: _createCategorySections(analytics),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildDuplicatePasswordsSection(PasswordAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password Duplikat:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...analytics.duplicatePasswords.map(
          (duplicate) => Text('• $duplicate'),
        ),
      ],
    );
  }

  List<PieChartSectionData> _createStrengthSections(
      PasswordAnalytics analytics) {
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.red,
    ];

    return analytics.strengthDistribution.entries
        .toList()
        .asMap()
        .entries
        .map((entry) {
      final value = entry.value.value.toDouble();
      final total = analytics.totalPasswords.toDouble();
      return PieChartSectionData(
        color: colors[entry.key],
        value: value,
        title: '${(value / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white),
      );
    }).toList();
  }

  List<PieChartSectionData> _createCategorySections(
      PasswordAnalytics analytics) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.yellow,
    ];

    return analytics.categoryDistribution.entries
        .toList()
        .asMap()
        .entries
        .map((entry) {
      final value = entry.value.value.toDouble();
      final total = analytics.totalPasswords.toDouble();
      return PieChartSectionData(
        color: colors[entry.key % colors.length],
        value: value,
        title: '${(value / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white),
      );
    }).toList();
  }
}
