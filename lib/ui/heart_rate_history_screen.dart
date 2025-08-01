import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../manager/heart_rate_manager.dart';
import '../manager/auth_manager.dart';

class HeartRateHistoryScreen extends StatefulWidget {
  const HeartRateHistoryScreen({super.key});

  @override
  State<HeartRateHistoryScreen> createState() => _HeartRateHistoryScreenState();
}

class _HeartRateHistoryScreenState extends State<HeartRateHistoryScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    final authManager = context.read<AuthManager>();
    final userId = authManager.userId;

    // Lấy 7 ngày gần nhất từ Health Connect và đồng bộ Firebase
    final now = DateTime.now();
    final past = now.subtract(const Duration(days: 7));

    if (userId != null) {
      await context
          .read<HeartRateManager>()
          .loadHistory(past, now, userId: userId);
    } else {
      await context.read<HeartRateManager>().loadHistory(past, now);
    }
  }

  String getStatusLabel(int bpm) {
    if (bpm < 60) return "Thấp";
    if (bpm > 100) return "Cao";
    return "Bình thường";
  }

  Color getStatusColor(BuildContext context, int bpm) {
    if (bpm < 60) return Colors.blue;
    if (bpm > 100) return Colors.red;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final manager = context.watch<HeartRateManager>();

    final records = manager.filterByDate(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử nhịp tim"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: manager.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Chọn ngày
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: records.isEmpty
                      ? const Center(child: Text("Không có dữ liệu"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final record = records[index];
                            final status = getStatusLabel(record.bpm);
                            final color = getStatusColor(context, record.bpm);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: theme.brightness == Brightness.light
                                    ? [
                                        const BoxShadow(
                                          color: Color(0x22000000),
                                          blurRadius: 6,
                                          offset: Offset(2, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  // Vòng tròn BPM
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "${record.bpm}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Thông tin
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          status,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('HH:mm:ss dd/MM/yyyy')
                                              .format(record.date),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
