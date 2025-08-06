import 'package:flutter/material.dart';

class SleepInfoScreen extends StatelessWidget {
  const SleepInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kiến thức về giấc ngủ"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- Giấc ngủ là gì ---
          Text(
            "Giấc ngủ là gì?",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Giấc ngủ là trạng thái sinh lý tự nhiên giúp cơ thể nghỉ ngơi, phục hồi năng lượng và tái tạo các chức năng sinh học.\n\n"
            "Một giấc ngủ chất lượng giúp cải thiện trí nhớ, tăng cường hệ miễn dịch và hỗ trợ sức khỏe tinh thần.",
          ),

          const SizedBox(height: 20),

          // --- Thời lượng ngủ khuyến nghị ---
          Text(
            "Thời lượng ngủ khuyến nghị (theo National Sleep Foundation)",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildTableSleepDuration(context),

          const SizedBox(height: 20),

          // --- Các giai đoạn giấc ngủ ---
          Text(
            "Các giai đoạn giấc ngủ",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          _tip(
              "Ngủ nông (Light sleep): Chiếm 50-60% tổng thời gian ngủ, giúp cơ thể thư giãn và dễ dàng thức dậy."),
          _tip(
              "Ngủ sâu (Deep sleep): Chiếm 13-23%, quan trọng cho phục hồi thể chất và tăng cường miễn dịch."),
          _tip(
              "Ngủ REM: Chiếm 20-25%, quan trọng cho trí nhớ, học tập và xử lý cảm xúc."),

          const SizedBox(height: 20),

          // --- Cách đánh giá giấc ngủ ---
          Text(
            "Cách đánh giá giấc ngủ (chuẩn y tế)",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          _tip("Thời lượng ngủ: Đủ khuyến nghị theo độ tuổi."),
          _tip(
              "Cấu trúc giấc ngủ: Có đủ 3 giai đoạn (nông, sâu, REM) với tỉ lệ hợp lý."),
          _tip("Chất lượng: Ít bị thức giấc giữa đêm, ngủ liền mạch."),
          _tip(
              "Cảm giác tỉnh táo: Thức dậy cảm thấy khoẻ khoắn, ít buồn ngủ ban ngày."),

          const SizedBox(height: 20),

          // --- Chúng tôi đánh giá chất lượng giấc ngủ của bạn như thế nào ---
          Text(
            "Chúng tôi đánh giá chất lượng giấc ngủ của bạn như thế nào?",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          _tip(
              "1. Thời lượng ngủ: 7-9 giờ đạt điểm tối đa (40 điểm). Nếu 5-7 giờ sẽ ít điểm hơn, dưới 5 giờ sẽ rất thấp."),
          _tip(
              "2. Tỉ lệ ngủ REM: 15-25% tổng thời gian ngủ đạt điểm tối đa (20 điểm). Ngoài khoảng này điểm giảm."),
          _tip(
              "3. Tỉ lệ ngủ sâu (Deep sleep): 13-23% đạt điểm tối đa (20 điểm)."),
          _tip(
              "4. Số lần thức giấc trong đêm: ≤ 10 lần đạt 20 điểm, 11-20 lần đạt 10 điểm, nhiều hơn sẽ mất điểm."),
          _tip(
              "Tổng điểm tối đa: 100 điểm.\n\n• 80-100 điểm: Giấc ngủ Tốt \n• 60-79 điểm: Giấc ngủ Vừa phải \n• Dưới 60 điểm: Giấc ngủ Kém "),

          const SizedBox(height: 20),

          // --- Lời khuyên ---
          Text(
            "Lời khuyên để có giấc ngủ tốt",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          _tip("Đi ngủ và thức dậy vào cùng một giờ mỗi ngày."),
          _tip("Tránh caffeine, rượu và thiết bị điện tử trước khi ngủ."),
          _tip("Tạo không gian ngủ yên tĩnh, tối và mát mẻ."),
          _tip("Tập thể dục thường xuyên nhưng tránh sát giờ ngủ."),
        ],
      ),
    );
  }

  /// Bảng thời lượng ngủ khuyến nghị
  Widget _buildTableSleepDuration(BuildContext context) {
    final rows = [
      ["Trẻ sơ sinh (0-3 tháng)", "14-17 giờ", Colors.purple],
      ["Trẻ nhỏ (4-11 tháng)", "12-15 giờ", Colors.indigo],
      ["Trẻ tập đi (1-2 tuổi)", "11-14 giờ", Colors.blue],
      ["Mẫu giáo (3-5 tuổi)", "10-13 giờ", Colors.teal],
      ["Học sinh (6-13 tuổi)", "9-11 giờ", Colors.green],
      ["Thanh thiếu niên (14-17 tuổi)", "8-10 giờ", Colors.lightGreen],
      ["Người trưởng thành (18-64 tuổi)", "7-9 giờ", Colors.orange],
      ["Người cao tuổi (65+ tuổi)", "7-8 giờ", Colors.redAccent],
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
                "Nhóm tuổi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "Thời lượng",
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

  /// Widget hiển thị lời khuyên hoặc thông tin
  Widget _tip(String text) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: const TextStyle(height: 1.4),
        ),
      ),
    );
  }
}
