import 'package:flutter/material.dart';

class BloodGlucoseInfoScreen extends StatelessWidget {
  const BloodGlucoseInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kiến thức về đường huyết"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Đường huyết là gì?",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Đường huyết là lượng đường (glucose) có trong máu, là nguồn năng lượng chính cho cơ thể.\n\n"
            "Các loại thời điểm đo đường huyết:\n"
            "- Lúc đói (Fasting): Sau ít nhất 8 giờ không ăn.\n"
            "- Sau ăn 2 giờ (Postprandial): Để đánh giá khả năng xử lý đường sau bữa ăn.\n"
            "- Ngẫu nhiên (Random): Đo ở bất kỳ thời điểm nào trong ngày.",
          ),
          const SizedBox(height: 20),
          Text(
            "Phân loại đường huyết (mmol/L)",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildTable(context),
          const SizedBox(height: 20),
          Text(
            "Lời khuyên",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          _tip("Duy trì chế độ ăn cân bằng, hạn chế đường"),
          _tip("Tập thể dục thường xuyên"),
          _tip("Kiểm tra đường huyết định kỳ"),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final rows = [
      // Lúc đói
      ["Hạ đường huyết (lúc đói)", "< 3.9", Colors.blue],
      ["Bình thường (lúc đói)", "3.9 - 5.6", Colors.green],
      ["Tiền đái tháo đường (lúc đói)", "5.7 - 6.9", Colors.orange],
      ["Đái tháo đường (lúc đói)", "≥ 7.0", Colors.red],

      // Sau ăn 2h
      ["Bình thường (sau ăn 2h)", "<= 7.7", Colors.green],
      ["Tiền đái tháo đường (sau ăn 2h)", "7.8 - 11.0", Colors.orange],
      ["Đái tháo đường (sau ăn 2h)", "> 11.0", Colors.red],

      // Ngẫu nhiên
      ["Đái tháo đường (ngẫu nhiên)", "≥ 11.1", Colors.red],
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
                "Chỉ số",
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
