import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../screen.dart';

class StepStatsScreen extends StatelessWidget {
  const StepStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<StepManager>();

    final List<StepRecord> stats = manager.stepRecords;
    final goal = manager.goal;
    final theme = Theme.of(context);

    if (stats.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Thống kê bước chân"),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text("Chưa có dữ liệu")),
      );
    }

    final totalAll = stats.fold(0, (sum, record) => sum + record.steps);

    final extra = (goal * 0.1 > 1000) ? (goal * 0.1) : 1000;

    final rawMaxY = (([...stats.map((r) => r.steps), goal]
                .reduce((a, b) => a > b ? a : b)) +
            extra)
        .toDouble();

    final maxY = ((rawMaxY / 1000).ceil() * 1000).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thống kê bước chân"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem("Tổng cộng", "$totalAll bước"),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey.shade300,
                ),
                _summaryItem("Mục tiêu", "$goal bước"),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: (stats.length * 60).toDouble().clamp(350, 9999),
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 40),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index < 0 || index >= stats.length) {
                              return const SizedBox();
                            }
                            final record = stats[index];
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat('dd/MM').format(record.date),
                                  style: const TextStyle(fontSize: 10),
                                ),
                                const SizedBox(height: 2),
                                Icon(
                                  record.steps >= goal
                                      ? Icons.emoji_events
                                      : Icons.emoji_events_outlined,
                                  size: 14,
                                  color: record.steps >= goal
                                      ? Colors.amber
                                      : Colors.grey,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: goal.toDouble(),
                          color: Colors.red,
                          strokeWidth: 2,
                          dashArray: [5, 5],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                            labelResolver: (_) => 'Mục tiêu $goal bước',
                          ),
                        ),
                      ],
                    ),
                    barGroups: List.generate(stats.length, (i) {
                      final record = stats[i];
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: record.steps.toDouble(),
                            color: record.steps >= goal
                                ? Colors.green
                                : theme.colorScheme.primary,
                            width: 18,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ),
      ],
    );
  }
}
