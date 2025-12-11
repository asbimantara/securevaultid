import 'package:flutter/material.dart';
import '../../../data/models/password_model.dart';
import 'package:fl_chart/fl_chart.dart';

class PasswordStatisticsDialog extends StatelessWidget {
  final List<Password> passwords;

  const PasswordStatisticsDialog({
    super.key,
    required this.passwords,
  });

  @override
  Widget build(BuildContext context) {
    final categoryStats = _getCategoryStats();
    final strengthStats = _getStrengthStats();
    final timeStats = _getTimeStats();

    return AlertDialog(
      title: const Text('Statistik Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryCard(context),
            const SizedBox(height: 16),
            _buildCategoryChart(categoryStats),
            const SizedBox(height: 16),
            _buildStrengthChart(strengthStats),
            const SizedBox(height: 16),
            _buildTimeChart(timeStats),
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

  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Total Password: ${passwords.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Password Favorit: ${passwords.where((p) => p.isFavorite).length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Password dengan Website: ${passwords.where((p) => p.website != null).length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(Map<String, int> stats) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: stats.entries.map((e) {
            return PieChartSectionData(
              value: e.value.toDouble(),
              title: '${e.key}\n${e.value}',
              radius: 100,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStrengthChart(Map<String, int> stats) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final titles = ['Lemah', 'Sedang', 'Kuat'];
                  return Text(titles[value.toInt()]);
                },
              ),
            ),
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: stats['weak']?.toDouble() ?? 0,
                  color: Colors.red,
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: stats['medium']?.toDouble() ?? 0,
                  color: Colors.orange,
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: stats['strong']?.toDouble() ?? 0,
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChart(Map<String, int> stats) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: stats.entries.map((e) {
                return FlSpot(
                  double.parse(e.key),
                  e.value.toDouble(),
                );
              }).toList(),
              isCurved: true,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _getCategoryStats() {
    final stats = <String, int>{};
    for (final password in passwords) {
      stats[password.category] = (stats[password.category] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, int> _getStrengthStats() {
    final stats = {'weak': 0, 'medium': 0, 'strong': 0};
    // Implement strength calculation logic
    return stats;
  }

  Map<String, int> _getTimeStats() {
    final stats = <String, int>{};
    // Implement time-based statistics
    return stats;
  }
}
