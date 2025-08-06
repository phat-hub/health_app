import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../screen.dart';

class BloodGlucoseScreen extends StatefulWidget {
  const BloodGlucoseScreen({super.key});

  @override
  State<BloodGlucoseScreen> createState() => _BloodGlucoseScreenState();
}

class _BloodGlucoseScreenState extends State<BloodGlucoseScreen> {
  @override
  void initState() {
    super.initState();
    final manager = context.read<BloodGlucoseManager>();

    Future.microtask(() async {
      await manager.initFirstOpenDate();
      manager.loadRecords(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<BloodGlucoseManager>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đường huyết"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/bloodGlucoseInfo');
            },
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/bloodGlucoseStats');
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
                            final status = manager.getGlucoseStatus(rec);

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
                                child: ListTile(
                                  title: Text(
                                    "${rec.glucose.toStringAsFixed(1)} mmol/L",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(status,
                                      style: TextStyle(
                                        color: getGlucoseStatusColor(status),
                                        fontWeight: FontWeight.bold,
                                      )),
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
          Navigator.pushNamed(context, '/bloodGlucoseAdd');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Color getGlucoseStatusColor(String status) {
  switch (status) {
    case "Bình thường":
      return Colors.green;
    case "Tiền đái tháo đường":
      return Colors.orange;
    case "Đái tháo đường":
      return Colors.red;
    case "Hạ đường huyết":
      return Colors.blue;
    default:
      return Colors.grey;
  }
}
