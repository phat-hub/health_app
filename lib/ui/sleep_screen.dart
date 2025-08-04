import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../screen.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SleepManager>().loadSleepData(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<SleepManager>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Giấc ngủ"),
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
              CircularProgressIndicator(
                value: manager.recoveryScore / 100,
                strokeWidth: 12,
                backgroundColor: Colors.grey.shade300,
                color: manager.recoveryColor,
              ),
              Center(
                child: Text(
                  "${manager.recoveryScore.toStringAsFixed(0)}%",
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: manager.recoveryColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          manager.recoveryLabel,
          style: TextStyle(
            color: manager.recoveryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            "Thời gian ngủ", manager.formatDuration(data.total), Colors.green),
        _infoCard(
            "Giờ ngủ",
            DateFormat.Hm().format(data.bedTime ?? DateTime.now()),
            Colors.blue),
        _infoCard(
            "Giờ thức",
            DateFormat.Hm().format(data.wakeTime ?? DateTime.now()),
            Colors.orange),
      ],
    );
  }

  Widget _buildDetails(SleepManager manager, ThemeData theme) {
    final data = manager.sleepData!;
    return Column(
      children: [
        _metricCard(
            "Ngủ REM",
            "${manager.formatDuration(data.rem)}, ${manager.remPercent.toStringAsFixed(1)}%",
            Colors.green),
        _metricCard(
            "Ngủ nông",
            "${manager.formatDuration(data.light)}, ${manager.lightPercent.toStringAsFixed(1)}%",
            Colors.orange),
        _metricCard(
            "Ngủ sâu",
            "${manager.formatDuration(data.deep)}, ${manager.deepPercent.toStringAsFixed(1)}%",
            Colors.blue),
        _metricCard("Thức giấc", "${data.awakeCount} lần", Colors.red),
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
