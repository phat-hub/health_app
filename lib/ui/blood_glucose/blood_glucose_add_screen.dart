import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screen.dart';

class BloodGlucoseAddScreen extends StatefulWidget {
  const BloodGlucoseAddScreen({super.key});

  @override
  State<BloodGlucoseAddScreen> createState() => _BloodGlucoseAddScreenState();
}

class _BloodGlucoseAddScreenState extends State<BloodGlucoseAddScreen> {
  final _glucoseController = TextEditingController();
  String measurementType = "fasting"; // Mặc định là lúc đói

  String status = "";
  Color statusColor = Colors.grey;

  // Hàm xác định trạng thái theo chuẩn y tế
  void _updateStatus() {
    final g = double.tryParse(_glucoseController.text) ?? 0;
    if (g <= 0) {
      status = "";
      statusColor = Colors.grey;
      setState(() {});
      return;
    }

    // Logic trạng thái dựa trên loại đo
    switch (measurementType) {
      case "fasting": // Lúc đói
        if (g < 3.9) {
          status = "Hạ đường huyết";
          statusColor = Colors.blue;
        } else if (g <= 5.6) {
          status = "Bình thường";
          statusColor = Colors.green;
        } else if (g <= 6.9) {
          status = "Tiền đái tháo đường";
          statusColor = Colors.orange;
        } else {
          status = "Đái tháo đường";
          statusColor = Colors.red;
        }
        break;

      case "post_meal": // Sau ăn 2h
        if (g < 3.9) {
          status = "Hạ đường huyết";
          statusColor = Colors.blue;
        } else if (g <= 7.7) {
          status = "Bình thường";
          statusColor = Colors.green;
        } else if (g <= 11.0) {
          status = "Tiền đái tháo đường";
          statusColor = Colors.orange;
        } else {
          status = "Đái tháo đường";
          statusColor = Colors.red;
        }
        break;

      case "random": // Ngẫu nhiên
        if (g < 3.9) {
          status = "Hạ đường huyết";
          statusColor = Colors.blue;
        } else if (g <= 7.7) {
          status = "Bình thường";
          statusColor = Colors.green;
        } else if (g <= 11.0) {
          status = "Tiền đái tháo đường";
          statusColor = Colors.orange;
        } else {
          status = "Đái tháo đường";
          statusColor = Colors.red;
        }
        break;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.read<BloodGlucoseManager>();
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
                  // Loại đo
                  DropdownButtonFormField<String>(
                    value: measurementType,
                    decoration: const InputDecoration(
                      labelText: "Loại đo",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "fasting", child: Text("Lúc đói")),
                      DropdownMenuItem(
                          value: "post_meal", child: Text("Sau ăn 2h")),
                      DropdownMenuItem(
                          value: "random", child: Text("Ngẫu nhiên")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        measurementType = val;
                        _updateStatus();
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Giá trị đường huyết
                  _buildNumberField(
                    controller: _glucoseController,
                    label: "Đường huyết (mmol/L)",
                    onChanged: (_) => _updateStatus(),
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
                  final g = double.tryParse(_glucoseController.text) ?? 0;
                  if (g > 0) {
                    await manager.saveRecord(g, measurementType);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Vui lòng nhập đầy đủ và chính xác giá trị đường huyết"),
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
      keyboardType: const TextInputType.numberWithOptions(
          decimal: true), // Cho phép nhập số thập phân
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
