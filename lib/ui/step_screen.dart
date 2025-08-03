import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../screen.dart';

class StepScreen extends StatefulWidget {
  const StepScreen({super.key});

  @override
  State<StepScreen> createState() => _StepScreenState();
}

class _StepScreenState extends State<StepScreen> {
  @override
  void initState() {
    super.initState();
    final manager = context.read<StepManager>();

    // Luôn reset về hôm nay khi mở trang
    manager.selectedDate = DateTime.now();
    manager.initSteps();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<StepManager>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bộ đếm bước"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: manager.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: manager.selectedDate,
                          firstDate:
                              DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          await manager.loadStepsForDate(picked);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd/MM/yyyy')
                                .format(manager.selectedDate),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Hiển thị tiến trình
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: manager.goal > 0
                              ? (manager.steps / manager.goal).clamp(0, 1)
                              : 0,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey.shade300,
                          color: theme.colorScheme.primary,
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: manager.hasHealthData
                                ? [
                                    Text(
                                      "${manager.steps}",
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        "${manager.calories.toStringAsFixed(2)} Kcal"),
                                  ]
                                : [
                                    const Text(
                                      "Không có dữ liệu",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.grey),
                                    ),
                                  ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sửa mục tiêu
                  GestureDetector(
                    onTap: () => _editGoal(context, manager),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${manager.goal}",
                            style: theme.textTheme.titleLarge),
                        const SizedBox(width: 8),
                        const Icon(Icons.edit, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Thông tin phụ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _infoCard(Icons.access_time,
                          "${manager.activeTime.inHours}h ${manager.activeTime.inMinutes % 60}m"),
                      _infoCard(Icons.terrain,
                          "${manager.distance.toStringAsFixed(0)} m"),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void _editGoal(BuildContext context, StepManager manager) {
    final controller = TextEditingController(text: manager.goal.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Mục tiêu hàng ngày"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              final newGoal = int.tryParse(controller.text);
              if (newGoal != null && newGoal > 0) {
                manager.updateGoal(newGoal);
              }
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
