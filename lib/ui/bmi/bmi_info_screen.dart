import 'package:flutter/material.dart';

class BmiInfoScreen extends StatelessWidget {
  const BmiInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kiến thức về BMI"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- BMI là gì ---
          Text(
            "BMI là gì?",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "BMI (Body Mass Index) là chỉ số khối cơ thể, được tính bằng công thức:\n\n"
            "BMI = Cân nặng (kg) / [Chiều cao (m)]²\n\n"
            "Chỉ số này được dùng để phân loại tình trạng cân nặng và đánh giá nguy cơ sức khỏe.",
          ),

          const SizedBox(height: 20),

          // --- Phân loại ---
          Text(
            "Phân loại BMI (theo WHO)",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildBmiTable(context),

          const SizedBox(height: 20),

          // --- Lời khuyên ---
          Text(
            "Lời khuyên duy trì BMI hợp lý",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          _tip("Duy trì chế độ ăn uống lành mạnh."),
          _tip("Tập thể dục đều đặn ít nhất 30 phút mỗi ngày."),
          _tip("Kiểm soát cân nặng, tránh tăng/giảm đột ngột."),
          _tip("Theo dõi BMI định kỳ, đặc biệt khi có thay đổi cân nặng."),
        ],
      ),
    );
  }

  Widget _buildBmiTable(BuildContext context) {
    final rows = [
      ["Gầy độ III", "< 16", Colors.deepPurple],
      ["Gầy độ II", "16 - 16.9", Colors.purple],
      ["Gầy độ I", "17 - 18.4", Colors.lightBlue],
      ["Bình thường", "18.5 - 24.9", Colors.green],
      ["Thừa cân", "25 - 29.9", Colors.orange],
      ["Béo phì độ I", "30 - 34.9", Colors.deepOrange],
      ["Béo phì độ II", "35 - 39.9", Colors.redAccent],
      ["Béo phì độ III", "≥ 40", Colors.red],
    ];

    return Table(
      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          children: const [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "Phân loại",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "BMI (kg/m²)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
        ...rows.map(
          (r) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  r[0] as String,
                  style: TextStyle(
                    color: r[2] as Color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  r[1] as String,
                  style: TextStyle(
                    color: r[2] as Color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _tip(String text) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text),
      ),
    );
  }
}
