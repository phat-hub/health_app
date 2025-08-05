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

    final stats = manager.stepStats;
    final goal = manager.goal;
    final theme = Theme.of(context);

    final dates = stats.keys.toList();
    final values = stats.values.toList();
    final totalAll = values.fold(0, (sum, e) => sum + e);

    final extra = (goal * 0.1 > 1000) ? (goal * 0.1) : 1000;

    final rawMaxY =
        (([...values, goal].reduce((a, b) => a > b ? a : b)) + extra)
            .toDouble();

    // Làm tròn lên bội số của 1000
    final maxY = ((rawMaxY / 1000).ceil() * 1000).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thống kê bước chân"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: stats.isEmpty
            ? const Center(child: Text("Chưa có dữ liệu"))
            : Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
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
                        width: (dates.length * 60).toDouble().clamp(350, 9999),
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxY,
                            barTouchData: BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true, reservedSize: 40),
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
                                    if (index < 0 || index >= dates.length) {
                                      return const SizedBox();
                                    }
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          DateFormat('dd/MM')
                                              .format(dates[index]),
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        const SizedBox(height: 2),
                                        Icon(
                                          values[index] >= goal
                                              ? Icons.emoji_events
                                              : Icons.emoji_events_outlined,
                                          size: 14,
                                          color: values[index] >= goal
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
                            barGroups: List.generate(dates.length, (i) {
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: values[i].toDouble(),
                                    color: values[i] >= goal
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
