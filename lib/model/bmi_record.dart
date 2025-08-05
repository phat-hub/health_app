class BmiRecord {
  final double height; // cm
  final double weight; // kg
  final double bmi; // Chỉ số BMI
  final DateTime date;

  BmiRecord({
    required this.height,
    required this.weight,
    required this.bmi,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'height': height,
        'weight': weight,
        'bmi': bmi,
        'date': date.toIso8601String(),
      };

  static BmiRecord fromJson(Map<String, dynamic> json) {
    return BmiRecord(
      height: json['height'],
      weight: json['weight'],
      bmi: json['bmi'],
      date: DateTime.parse(json['date']),
    );
  }
}
