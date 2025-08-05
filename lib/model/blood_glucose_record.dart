class BloodGlucoseRecord {
  final double glucose; // mmol/L
  final String measurementType; // fasting / post_meal / random
  final DateTime date;

  BloodGlucoseRecord({
    required this.glucose,
    required this.measurementType,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'glucose': glucose,
        'measurementType': measurementType,
        'date': date.toIso8601String(),
      };

  static BloodGlucoseRecord fromJson(Map<String, dynamic> json) {
    return BloodGlucoseRecord(
      glucose: (json['glucose'] as num).toDouble(),
      measurementType: json['measurementType'] as String,
      date: DateTime.parse(json['date']),
    );
  }
}
