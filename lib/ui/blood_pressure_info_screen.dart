import 'package:flutter/material.dart';

class BloodPressureInfoScreen extends StatelessWidget {
  const BloodPressureInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kiến thức về huyết áp"),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(
              "Huyết áp là áp lực của máu tác động lên thành động mạch khi tim co bóp và khi tim nghỉ giữa các nhịp.\n\n"
              "Có hai chỉ số quan trọng:\n"
              "- Tâm thu (SYS): Áp lực khi tim co bóp.\n"
              "- Tâm trương (DIA): Áp lực khi tim nghỉ.",
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),

            const SizedBox(height: 24),

            // --- Phân loại ---
            Text(
              "Phân loại huyết áp (theo WHO/AHA)",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildBpTable(context),

            const SizedBox(height: 24),

            // --- Lời khuyên ---
            Text(
              "Lời khuyên để giữ huyết áp khỏe mạnh",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildTipCard(context,
                "Ăn uống lành mạnh: Hạn chế muối, đường và chất béo bão hòa."),
            _buildTipCard(
                context, "Tập thể dục ít nhất 30 phút mỗi ngày, 5 ngày/tuần."),
            _buildTipCard(
                context, "Giữ cân nặng hợp lý và tránh căng thẳng kéo dài."),
            _buildTipCard(context,
                "Đo huyết áp định kỳ, đặc biệt nếu có tiền sử bệnh tim mạch."),
          ],
        ),
      ),
    );
  }

  Widget _buildBpTable(BuildContext context) {
    final rows = [
      ["Huyết áp thấp", "< 90 / < 60 mmHg", Colors.blue],
      ["Tối ưu", "< 120 / < 80 mmHg", Colors.green],
      ["Bình thường", "120-129 / 80-84 mmHg", Colors.lightGreen],
      ["Tiền tăng huyết áp", "130-139 / 85-89 mmHg", Colors.orange],
      ["Tăng HA độ 1", "140-159 / 90-99 mmHg", Colors.deepOrange],
      ["Tăng HA độ 2", "160-179 / 100-109 mmHg", Colors.redAccent],
      ["Tăng HA độ 3", "≥ 180 / ≥ 110 mmHg", Colors.red],
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(2),
        },
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(12),
                child: Text("Phân loại",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Text("Chỉ số",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          ),

          // Nội dung bảng
          ...rows.map(
            (row) {
              final Color color = row[2] as Color;
              return TableRow(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      row[0] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      row[1] as String,
                      style: TextStyle(
                        color: color,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: theme.colorScheme.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
