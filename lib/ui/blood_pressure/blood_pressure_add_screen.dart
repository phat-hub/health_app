import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screen.dart';

class BloodPressureAddScreen extends StatefulWidget {
  const BloodPressureAddScreen({super.key});

  @override
  State<BloodPressureAddScreen> createState() => _BloodPressureAddScreenState();
}

class _BloodPressureAddScreenState extends State<BloodPressureAddScreen> {
  final _sysController = TextEditingController();
  final _diaController = TextEditingController();
  final _pulseController = TextEditingController();

  String status = "";
  Color statusColor = Colors.grey;

  // Hàm xác định trạng thái theo chuẩn WHO/AHA
  void _updateStatus() {
    final sys = int.tryParse(_sysController.text) ?? 0;
    final dia = int.tryParse(_diaController.text) ?? 0;

    if (sys == 0 || dia == 0) {
      status = "";
      statusColor = Colors.grey;
    } else if (sys < 90 || dia < 60) {
      status = "Huyết áp thấp";
      statusColor = Colors.blue;
    } else if (sys < 120 && dia < 80) {
      status = "Huyết áp tối ưu";
      statusColor = Colors.green;
    } else if (sys < 130 && dia < 85) {
      status = "Bình thường";
      statusColor = Colors.lightGreen;
    } else if (sys < 140 && dia < 90) {
      status = "Tiền tăng huyết áp";
      statusColor = Colors.orange;
    } else if (sys < 160 && dia < 100) {
      status = "Tăng huyết áp độ 1";
      statusColor = Colors.deepOrange;
    } else if (sys < 180 && dia < 110) {
      status = "Tăng huyết áp độ 2";
      statusColor = Colors.redAccent;
    } else {
      status = "Tăng huyết áp độ 3";
      statusColor = Colors.red;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.read<BloodPressureManager>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm bản ghi"),
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
                    controller: _sysController,
                    label: "Tâm thu (mmHg)",
                    onChanged: (_) => _updateStatus(),
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    controller: _diaController,
                    label: "Tâm trương (mmHg)",
                    onChanged: (_) => _updateStatus(),
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    controller: _pulseController,
                    label: "Xung (bpm)",
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card trạng thái
            if (status.isNotEmpty) _buildStatusCard(theme),

            const SizedBox(height: 40),

            // Nút lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final sys = int.tryParse(_sysController.text) ?? 0;
                  final dia = int.tryParse(_diaController.text) ?? 0;
                  final pulse = int.tryParse(_pulseController.text) ?? 0;

                  final isValid = sys >= 50 &&
                      sys <= 250 &&
                      dia >= 30 &&
                      dia <= 150 &&
                      pulse >= 30 &&
                      pulse <= 220;

                  if (isValid) {
                    await manager.saveRecord(sys, dia, pulse);
                    Navigator.pop(context);
                  } else {
                    String errorMessage = "Giá trị nhập không hợp lệ.\n";
                    errorMessage += "- Tâm thu: 50 – 250 mmHg\n"
                        "- Tâm trương: 30 – 150 mmHg\n"
                        "- Nhịp tim: 30 – 220 bpm";

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.blue,
                        duration: const Duration(seconds: 4),
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
        child: Text(
          status,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
      ),
    );
  }
}
