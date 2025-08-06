import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../screen.dart';

class BmiStatsScreen extends StatefulWidget {
  const BmiStatsScreen({super.key});

  @override
  State<BmiStatsScreen> createState() => _BmiStatsScreenState();
}

class _BmiStatsScreenState extends State<BmiStatsScreen> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  Map<String, int> stats = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);
    final manager = context.read<BmiManager>();
    final result = await manager.getStatusStatistics(startDate, endDate);
    setState(() {
      stats = result;
      isLoading = false;
    });
  }

  Future<void> _pickDateRange() async {
    final manager = context.read<BmiManager>();
    final firstDate = await manager.getDatePickerFirstDate();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = stats.values.fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thống kê BMI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : stats.isEmpty || total == 0
              ? const Center(child: Text("Không có dữ liệu thống kê"))
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Từ ${DateFormat('dd/MM/yyyy').format(startDate)} đến ${DateFormat('dd/MM/yyyy').format(endDate)}",
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),

                    // Biểu đồ tròn
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: stats.entries
                              .where((e) => e.value > 0)
                              .map((e) => PieChartSectionData(
                                    value: e.value.toDouble(),
                                    title:
                                        "${((e.value / total) * 100).toStringAsFixed(1)}%",
                                    color: getBmiStatusColor(e.key),
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Chú thích
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: stats.entries
                            .where((e) => e.value > 0)
                            .map((e) => Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: getBmiStatusColor(e.key),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "${e.key} (${e.value} lần)",
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
    );
  }
}
