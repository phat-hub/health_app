import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screen.dart';

class BmiAddScreen extends StatefulWidget {
  const BmiAddScreen({super.key});

  @override
  State<BmiAddScreen> createState() => _BmiAddScreenState();
}

class _BmiAddScreenState extends State<BmiAddScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String status = "";
  Color statusColor = Colors.grey;
  double? bmi;

  void _updateStatus() {
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;

    if (height <= 0 || weight <= 0) {
      status = "";
      bmi = null;
      statusColor = Colors.grey;
    } else {
      bmi = weight / ((height / 100) * (height / 100));
      if (bmi! < 16) {
        status = "Gầy độ III";
        statusColor = Colors.deepPurple;
      } else if (bmi! < 17) {
        status = "Gầy độ II";
        statusColor = Colors.purple;
      } else if (bmi! < 18.5) {
        status = "Gầy độ I";
        statusColor = Colors.lightBlue;
      } else if (bmi! < 25) {
        status = "Bình thường";
        statusColor = Colors.green;
      } else if (bmi! < 30) {
        status = "Thừa cân";
        statusColor = Colors.orange;
      } else if (bmi! < 35) {
        status = "Béo phì độ I";
        statusColor = Colors.deepOrange;
      } else if (bmi! < 40) {
        status = "Béo phì độ II";
        statusColor = Colors.redAccent;
      } else {
        status = "Béo phì độ III";
        statusColor = Colors.red;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.read<BmiManager>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm chỉ số BMI"),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputCard(
              context,
              child: Column(
                children: [
                  _buildNumberField(
                    controller: _heightController,
                    label: "Chiều cao (cm)",
                    onChanged: (_) => _updateStatus(),
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    controller: _weightController,
                    label: "Cân nặng (kg)",
                    onChanged: (_) => _updateStatus(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (status.isNotEmpty) _buildStatusCard(theme),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final h = double.tryParse(_heightController.text) ?? 0;
                  final w = double.tryParse(_weightController.text) ?? 0;

                  if (h > 0 && w > 0) {
                    await manager.saveRecord(h, w);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Vui lòng nhập đầy đủ và chính xác giá trị"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Lưu bản ghi"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }

  Widget _buildInputCard(BuildContext context, {required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Theme.of(context).shadowColor.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    return Card(
      color: statusColor.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(
              status,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            if (bmi != null)
              Text(
                "BMI: ${bmi!.toStringAsFixed(1)} kg/m²",
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
