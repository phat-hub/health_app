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
                return ListTile(
                  leading: const Icon(Icons.alarm),
                  title: Text(_formatTime(r.hour, r.minute)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: r.enabled,
                        onChanged: (v) {
                          manager.toggleReminder(index, v);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          manager.removeReminder(index);
                        },
                      ),
                    ],
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
