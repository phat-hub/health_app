import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../screen.dart';

class WaterReminderScreen extends StatefulWidget {
  const WaterReminderScreen({Key? key}) : super(key: key);

  @override
  State<WaterReminderScreen> createState() => _WaterReminderScreenState();
}

class _WaterReminderScreenState extends State<WaterReminderScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi initNotifications khi vào màn hình
    Future.microtask(() {
      context.read<WaterManager>().initNotifications();
    });
  }

  String _formatTime(int h, int m) {
    final date = DateTime(0, 0, 0, h, m);
    return DateFormat.Hm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<WaterManager>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Nhắc nhở uống nước")),
      body: manager.reminders.isEmpty
          ? const Center(child: Text("Chưa có khung giờ nhắc nhở"))
          : ListView.builder(
              itemCount: manager.reminders.length,
              itemBuilder: (context, index) {
                final r = manager.reminders[index];

                return Dismissible(
                  key: ValueKey("${r.hour}:${r.minute}"),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Xác nhận"),
                        content:
                            const Text("Bạn có chắc muốn xóa nhắc nhở này?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Hủy"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
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
                    manager.removeReminder(index);
                  },
                  child: ListTile(
                    leading: const Icon(Icons.alarm),
                    title: Text(_formatTime(r.hour, r.minute)),
                    trailing: Switch(
                      value: r.enabled,
                      onChanged: (v) {
                        manager.toggleReminder(index, v);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final now = TimeOfDay.now();
          final picked = await showTimePicker(
            context: context,
            initialTime: now,
          );
          if (picked != null) {
            manager.addReminder(picked.hour, picked.minute);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
