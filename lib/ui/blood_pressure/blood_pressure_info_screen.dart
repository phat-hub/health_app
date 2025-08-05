import 'package:flutter/material.dart';

class BloodPressureInfoScreen extends StatelessWidget {
  const BloodPressureInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kiến thức về huyết áp"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- Huyết áp là gì ---
          Text(
            "Huyết áp là gì?",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Huyết áp là áp lực của máu tác động lên thành động mạch khi tim co bóp và khi tim nghỉ giữa các nhịp.\n\n"
            "Có hai chỉ số quan trọng:\n"
            "- Tâm thu (SYS): Áp lực khi tim co bóp.\n"
            "- Tâm trương (DIA): Áp lực khi tim nghỉ.",
          ),

          const SizedBox(height: 20),

          // --- Phân loại ---
          Text(
            "Phân loại huyết áp (theo WHO/AHA)",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildTable(context),

          const SizedBox(height: 20),

          // --- Lời khuyên ---
          Text(
            "Lời khuyên để giữ huyết áp khỏe mạnh",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          _tip("Ăn uống lành mạnh: Hạn chế muối, đường và chất béo bão hòa."),
          _tip("Tập thể dục ít nhất 30 phút mỗi ngày, 5 ngày/tuần."),
          _tip("Giữ cân nặng hợp lý và tránh căng thẳng kéo dài."),
          _tip("Đo huyết áp định kỳ, đặc biệt nếu có tiền sử bệnh tim mạch."),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final rows = [
      ["Huyết áp thấp", "< 90 / < 60 mmHg", Colors.blue],
      ["Tối ưu", "< 120 / < 80 mmHg", Colors.green],
      ["Bình thường", "120-129 / 80-84 mmHg", Colors.lightGreen],
      ["Tiền tăng huyết áp", "130-139 / 85-89 mmHg", Colors.orange],
      ["Tăng HA độ 1", "140-159 / 90-99 mmHg", Colors.deepOrange],
      ["Tăng HA độ 2", "160-179 / 100-109 mmHg", Colors.redAccent],
      ["Tăng HA độ 3", "≥ 180 / ≥ 110 mmHg", Colors.red],
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
