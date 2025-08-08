import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../screen.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  @override
  void initState() {
    super.initState();
    final manager = context.read<SleepManager>();
    manager.init();
    manager.loadSleepData(DateTime.now());
  }

  void _showReminderDialog(SleepManager manager) {
    ReminderTime tempReminder = manager.reminder;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Nhắc nhở đi ngủ"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text("Bật nhắc nhở"),
                value: tempReminder.enabled,
                onChanged: (v) {
                  setState(
                      () => tempReminder = tempReminder.copyWith(enabled: v));
                },
              ),
              if (tempReminder.enabled)
                ListTile(
                  title: Text(
                      "Giờ nhắc: ${TimeOfDay(hour: tempReminder.hour, minute: tempReminder.minute).format(context)}"),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: tempReminder.hour, minute: tempReminder.minute),
                    );
                    if (picked != null) {
                      setState(() => tempReminder = tempReminder.copyWith(
                          hour: picked.hour, minute: picked.minute));
                    }
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Lưu"),
              onPressed: () async {
                await manager.toggleReminder(tempReminder);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<SleepManager>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Giấc ngủ"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_active,
              color: manager.reminder.enabled ? Colors.yellow : Colors.white,
            ),
            onPressed: () => _showReminderDialog(manager),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/sleepInfo');
            },
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/sleepStats');
            },
          ),
        ],
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: manager.isLoading
          ? const Center(child: CircularProgressIndicator())
          : manager.sleepData == null
              ? const Center(child: Text("Không có dữ liệu giấc ngủ"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDateSelector(manager, theme),
                      const SizedBox(height: 16),
                      _buildRecoveryGauge(manager, theme),
                      const SizedBox(height: 16),
                      _buildMainInfo(manager, theme),
                      const SizedBox(height: 16),
                      _buildDetails(manager, theme),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDateSelector(SleepManager manager, ThemeData theme) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: manager.selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          manager.loadSleepData(picked);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, color: theme.colorScheme.primary),
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
    );
  }

  Widget _buildRecoveryGauge(SleepManager manager, ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          width: 160,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (manager.hasData)
                CircularProgressIndicator(
                  value: manager.recoveryScore / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade300,
                  color: manager.recoveryColor,
                )
              else
                CircularProgressIndicator(
                  value: 0,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.grey,
                ),
              Center(
                child: Text(
                  manager.hasData
                      ? "${manager.recoveryScore.toStringAsFixed(0)}%"
                      : "Không có\ndữ liệu",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        manager.hasData ? manager.recoveryColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (manager.hasData) ...[
          const SizedBox(height: 8),
          Text(
            manager.recoveryLabel,
            style: TextStyle(
              color: manager.recoveryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildMainInfo(SleepManager manager, ThemeData theme) {
    final data = manager.sleepData!;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _infoCard(
          "Thời gian ngủ",
          manager.hasData ? manager.formatDuration(data.total) : "0g 0p",
          Colors.green,
        ),
        _infoCard(
          "Giờ ngủ",
          manager.hasData && data.bedTime != null
              ? DateFormat.Hm().format(data.bedTime!)
              : "0:00",
          Colors.blue,
        ),
        _infoCard(
          "Giờ thức",
          manager.hasData && data.wakeTime != null
              ? DateFormat.Hm().format(data.wakeTime!)
              : "0:00",
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildDetails(SleepManager manager, ThemeData theme) {
    final data = manager.sleepData!;
    return Column(
      children: [
        _metricCard(
          "Ngủ REM",
          manager.hasData ? manager.formatDuration(data.rem) : "0g 0p",
          Colors.green,
        ),
        _metricCard(
          "Ngủ nông",
          manager.hasData ? manager.formatDuration(data.light) : "0g 0p",
          Colors.orange,
        ),
        _metricCard(
          "Ngủ sâu",
          manager.hasData ? manager.formatDuration(data.deep) : "0g 0p",
          Colors.blue,
        ),
        _metricCard(
          "Thức giấc",
          manager.hasData ? "${data.awakeCount} lần" : "0 lần",
          Colors.red,
        ),
      ],
    );
  }

  Widget _infoCard(String label, String value, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 8),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value),
      ),
    );
  }
}
