import 'package:flutter/material.dart';

class HeartRateInfoScreen extends StatelessWidget {
  const HeartRateInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kiến thức về nhịp tim"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- Nhịp tim là gì ---
          Text(
            "Nhịp tim là gì?",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Nhịp tim là số lần tim đập trong 1 phút (bpm - beats per minute). "
            "Nhịp tim phản ánh hoạt động của tim và hệ tuần hoàn. "
            "Nhịp tim có thể thay đổi tùy theo độ tuổi, mức độ hoạt động, cảm xúc và tình trạng sức khỏe.\n\n"
            "Có hai loại nhịp tim quan trọng:\n"
            "- Nhịp tim lúc nghỉ (Resting Heart Rate - RHR): đo khi cơ thể ở trạng thái nghỉ ngơi.\n"
            "- Nhịp tim khi vận động: tăng lên khi cơ thể hoạt động để đáp ứng nhu cầu oxy của cơ.",
          ),

          const SizedBox(height: 20),

          // --- Phân loại ---
          Text(
            "Phân loại nhịp tim lúc nghỉ (theo AHA)",
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
            "Lời khuyên để duy trì nhịp tim khỏe mạnh",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          _tip(
              "Tập thể dục đều đặn: đi bộ nhanh, bơi lội, đạp xe... giúp tăng sức bền tim mạch."),
          _tip("Giữ cân nặng hợp lý, tránh béo phì."),
          _tip("Hạn chế caffeine, rượu bia và thuốc lá."),
          _tip(
              "Quản lý căng thẳng bằng thiền, yoga hoặc các hoạt động thư giãn."),
          _tip(
              "Kiểm tra sức khỏe định kỳ, đặc biệt nếu có dấu hiệu nhịp tim bất thường."),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final rows = [
      ["Nhịp tim thấp (Bradycardia)", "< 60 bpm", Colors.blue],
      ["Bình thường", "60 - 100 bpm", Colors.green],
      ["Nhịp tim cao (Tachycardia)", "> 100 bpm", Colors.red],
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
                "Chỉ số (lúc nghỉ)",
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
