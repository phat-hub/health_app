import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screen.dart';

class StepScreen extends StatelessWidget {
  const StepScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<StepManager>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Bộ đếm bước")),
      body: manager.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: manager.steps / manager.goal,
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
