import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../screen.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  @override
  void initState() {
    super.initState();
    final manager = context.read<BmiManager>();

    Future.microtask(() async {
      await manager.initFirstOpenDate();
      manager.loadRecords(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<BmiManager>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉ số BMI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/bmiInfo');
            },
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/bmiStats');
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
                            final status = manager.getStatus(rec.bmi);

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
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Expanded(
                                              child: Center(
                                                  child: Text("Chiều cao",
                                                      style: TextStyle(
                                                          fontSize: 16)))),
                                          Expanded(
                                              child: Center(
                                                  child: Text("Cân nặng",
                                                      style: TextStyle(
                                                          fontSize: 16)))),
                                          Expanded(
                                              child: Center(
                                                  child: Text("BMI",
                                                      style: TextStyle(
                                                          fontSize: 16)))),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              child: Center(
                                                  child: Text(
                                                      "${rec.height.toStringAsFixed(1)}",
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                          Expanded(
                                              child: Center(
                                                  child: Text(
                                                      "${rec.weight.toStringAsFixed(1)}",
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                          Expanded(
                                              child: Center(
                                                  child: Text(
                                                      rec.bmi
                                                          .toStringAsFixed(1),
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Expanded(
                                              child: Center(child: Text("cm"))),
                                          Expanded(
                                              child: Center(child: Text("kg"))),
                                          Expanded(
                                              child:
                                                  Center(child: Text("kg/m²"))),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Center(
                                          child: Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: getBmiStatusColor(status),
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
        onPressed: () {
          Navigator.pushNamed(context, '/bmiAdd');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Color getBmiStatusColor(String status) {
  switch (status) {
    case "Gầy độ III":
      return Colors.deepPurple;
    case "Gầy độ II":
      return Colors.purple;
    case "Gầy độ I":
      return Colors.lightBlue;
    case "Bình thường":
      return Colors.green;
    case "Thừa cân":
      return Colors.orange;
    case "Béo phì độ I":
      return Colors.deepOrange;
    case "Béo phì độ II":
      return Colors.redAccent;
    case "Béo phì độ III":
      return Colors.red;
    default:
      return Colors.grey;
  }
}
