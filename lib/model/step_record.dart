class StepRecord {
  final DateTime date; // Ngày
  final int steps; // Số bước
  final double calories; // Calo tiêu hao (kcal)
  final double distance; // Quãng đường (mét)
  final Duration activeTime; // Thời gian hoạt động

  StepRecord({
    required this.date,
    required this.steps,
    required this.calories,
    required this.distance,
    required this.activeTime,
  });

  /// Tạo từ ngày + số bước
  factory StepRecord.fromSteps(DateTime date, int steps) {
    const stepLengthMeters = 0.762; // 76.2 cm
    const kcalPerStep = 0.04; // kcal/step

    final distance = steps * stepLengthMeters;
    final calories = steps * kcalPerStep;
    final activeTime = Duration(minutes: (steps / 100).round());

    return StepRecord(
      date: DateTime(date.year, date.month, date.day),
      steps: steps,
      calories: calories,
      distance: distance,
      activeTime: activeTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'steps': steps,
      'calories': calories,
      'distance': distance,
      'activeTime': activeTime.inMinutes,
    };
  }

  factory StepRecord.fromMap(Map<String, dynamic> map) {
    return StepRecord(
      date: DateTime.parse(map['date']),
      steps: map['steps'],
      calories: map['calories'],
      distance: map['distance'],
      activeTime: Duration(minutes: map['activeTime']),
    );
  }
}
