import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../screen.dart';

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key});

  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  @override
  void initState() {
    super.initState();
    final manager = context.read<BloodPressureManager>();

    Future.microtask(() async {
      await manager.initFirstOpenDate();
      manager.loadRecords(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<BloodPressureManager>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Huyết áp"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/bloodPressureInfo');
            },
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/bloodPressureStats');
            },
          ),
        ],
      ),
      body: manager.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final firstDate = await manager.getDatePickerFirstDate();

                    final picked = await showDatePicker(
                      context: context,
                      initialDate: manager.selectedDate,
                      firstDate: firstDate,
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      await manager.loadRecords(picked);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd/MM/yyyy').format(manager.selectedDate),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: manager.records.isNotEmpty
                      ? ListView.builder(
                          itemCount: manager.records.length,
                          itemBuilder: (context, index) {
                            final rec = manager.records[index];
                            final status = manager.getStatus(rec);

                            return Dismissible(
                              key: ValueKey(rec.date.toIso8601String()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.blue,
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Xác nhận"),
                                    content: const Text(
                                        "Bạn có chắc muốn xóa bản ghi này?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Hủy"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                        ),
                                        child: const Text("Xóa"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) async {
                                await manager.deleteRecord(rec);
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center, // 🔹 Căn giữa toàn bộ
                                    children: [
                                      // Tiêu đề
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center, // 🔹 Căn giữa
                                        children: const [
                                          Expanded(
                                              child: Center(
                                                  child: Text("Tâm thu",
                                                      style: TextStyle(
                                                          fontSize: 16)))),
                                          Expanded(
                                              child: Center(
                                                  child: Text("Tâm trương",
                                                      style: TextStyle(
                                                          fontSize: 16)))),
                                          Expanded(
                                              child: Center(
                                                  child: Text("Xung",
                                                      style: TextStyle(
                                                          fontSize: 16)))),
                                        ],
                                      ),
                                      const SizedBox(height: 4),

                                      // Giá trị
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              child: Center(
                                                  child: Text("${rec.systolic}",
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                          Expanded(
                                              child: Center(
                                                  child: Text(
                                                      "${rec.diastolic}",
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                          Expanded(
                                              child: Center(
                                                  child: Text("${rec.pulse}",
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                        ],
                                      ),
                                      const SizedBox(height: 4),

                                      // Đơn vị
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Expanded(
                                              child:
                                                  Center(child: Text("mmHg"))),
                                          Expanded(
                                              child:
                                                  Center(child: Text("mmHg"))),
                                          Expanded(
                                              child:
                                                  Center(child: Text("bpm"))),
                                        ],
                                      ),
                                      const SizedBox(height: 4),

                                      // Trạng thái
                                      Center(
                                          child: Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: getStatusColor(status),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            "Chưa có dữ liệu",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                )
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.pushNamed(context, '/bloodPressureAdd');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Color getStatusColor(String status) {
  switch (status) {
    case "Huyết áp tối ưu":
      return Colors.green;
    case "Bình thường":
      return Colors.lightGreen;
    case "Tiền tăng huyết áp":
      return Colors.orange;
    case "Tăng huyết áp độ 1":
      return Colors.deepOrange;
    case "Tăng huyết áp độ 2":
      return Colors.redAccent;
    case "Tăng huyết áp độ 3":
      return Colors.red;
    case "Huyết áp thấp":
      return Colors.blue;
    default:
      return Colors.grey;
  }
}
