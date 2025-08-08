import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../screen.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  @override
  void initState() {
    super.initState();
    final manager = context.read<WaterManager>();
    manager.loadWaterForDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<WaterManager>(context);
    final theme = Theme.of(context);

    bool isToday = manager.selectedDate.year == DateTime.now().year &&
        manager.selectedDate.month == DateTime.now().month &&
        manager.selectedDate.day == DateTime.now().day;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Theo dõi uống nước"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/waterStats');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {
              Navigator.pushNamed(context, '/waterReminder');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Chọn ngày
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: manager.selectedDate,
                  firstDate: manager.getMinSelectableDate(),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  await manager.loadWaterForDate(picked);
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
            ),
            const SizedBox(height: 16),

            // Vòng tròn tiến độ
            SizedBox(
              height: 180,
              width: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: manager.goal > 0
                        ? (manager.totalDrank / manager.goal).clamp(0, 1)
                        : 0,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade300,
                    color: theme.colorScheme.primary,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${manager.totalDrank}ml",
                            style: theme.textTheme.headlineMedium),
                        const SizedBox(height: 4),
                        Text(
                          "${((manager.totalDrank / manager.goal) * 100).clamp(0, 100).toStringAsFixed(0)}%",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Mục tiêu + chỉnh
            GestureDetector(
              onTap: () => _editGoal(context, manager),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Mục tiêu: ${manager.goal}ml",
                      style: theme.textTheme.titleLarge),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, size: 18),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _infoRow(Icons.local_drink, "Thức uống cuối cùng:",
                        "${manager.lastDrink}ml"),
                    _infoRow(Icons.coffee, "Số ly:", "${manager.cupCount}"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 40),
                  onPressed: isToday ? () => manager.removeLastDrink() : null,
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: isToday
                      ? () => manager.addDrink(manager.defaultCupSize)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isToday ? theme.colorScheme.primary : Colors.grey,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => _editCupSize(context, manager),
                  child: Column(
                    children: [
                      const Icon(Icons.water, size: 40),
                      Text("${manager.defaultCupSize}ml"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _editGoal(BuildContext context, WaterManager manager) {
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
              if (newGoal != null && newGoal >= 500 && newGoal <= 5000) {
                manager.updateGoal(newGoal);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("Mục tiêu phải nằm trong khoảng 500 – 5000 ml"),
                    backgroundColor: Colors.blue,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _editCupSize(BuildContext context, WaterManager manager) {
    final controller =
        TextEditingController(text: manager.defaultCupSize.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Kích thước ly/chai"),
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
              final newSize = int.tryParse(controller.text);
              if (newSize != null && newSize >= 50 && newSize <= 1000) {
                manager.updateCupSize(newSize);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Kích thước ly/chai phải nằm trong khoảng 50 – 1000 ml"),
                    backgroundColor: Colors.blue,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
