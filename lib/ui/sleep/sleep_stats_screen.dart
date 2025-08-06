import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../screen.dart';

class SleepStatsScreen extends StatefulWidget {
  const SleepStatsScreen({super.key});

  @override
  State<SleepStatsScreen> createState() => _SleepStatsScreenState();
}

class _SleepStatsScreenState extends State<SleepStatsScreen> {
  // Mặc định lấy 7 ngày gần nhất
  DateTime startDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime endDate = DateTime.now();

  bool isLoading = false;
  Map<String, int> stats = {};
  List<DateTime> daysWithoutData = [];

  @override
  void initState() {
    super.initState();
    // Chuẩn hóa ngày (đưa về 00:00 để tránh lệch dữ liệu)
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
    endDate = DateTime(endDate.year, endDate.month, endDate.day);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats();
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );

    if (picked != null) {
      setState(() {
        // Chuẩn hóa ngày chọn
        startDate =
            DateTime(picked.start.year, picked.start.month, picked.start.day);
        endDate = DateTime(picked.end.year, picked.end.month, picked.end.day);
      });
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    setState(() {
      isLoading = true;
      stats.clear();
      daysWithoutData.clear();
    });

    final manager = context.read<SleepManager>();

    // Lấy dữ liệu 1 lần
    final dataMap = await manager.getSleepRecordsInRange(startDate, endDate);

    DateTime current = startDate;
    while (!current.isAfter(endDate)) {
      if (dataMap.containsKey(current) &&
          dataMap[current]!.total.inMinutes > 0) {
        final tempManager = SleepManager();
        tempManager.sleepData = dataMap[current];
        String label = tempManager.recoveryLabel;

        stats[label] = (stats[label] ?? 0) + 1;
      } else {
        daysWithoutData.add(current);
      }
      current = current.add(const Duration(days: 1));
    }

    setState(() {
      isLoading = false;
    });
  }

  Color getStatusColor(String label) {
    switch (label) {
      case "Tốt":
        return Colors.green;
      case "Vừa phải":
        return Colors.orange;
      case "Kém":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Số ngày thực tế (bao gồm cả start và end)
    final totalDays = endDate.difference(startDate).inDays + 1;
    final daysWithData = totalDays - daysWithoutData.length;
    final totalRecords = stats.values.fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thống kê giấc ngủ"),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : totalRecords == 0
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
                          sections: stats.entries.map((e) {
                            return PieChartSectionData(
                              value: e.value.toDouble(),
                              title:
                                  "${((e.value / totalDays) * 100).toStringAsFixed(1)}%",
                              color: getStatusColor(e.key),
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Thông tin tổng
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tổng số ngày: $totalDays"),
                          Text("Số ngày có dữ liệu: $daysWithData"),
                          Text(
                              "Số ngày không có dữ liệu: ${daysWithoutData.length}"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Danh sách chú thích
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          ...stats.entries.map(
                            (e) => Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: getStatusColor(e.key),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "${e.key} (${e.value} ngày)",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
