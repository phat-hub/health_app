class BloodPressureRecord {
  final int systolic; // Tâm thu
  final int diastolic; // Tâm trương
  final int pulse; // Nhịp tim
  final DateTime date;

  BloodPressureRecord({
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'systolic': systolic,
        'diastolic': diastolic,
        'pulse': pulse,
        'date': date.toIso8601String(),
      };

  static BloodPressureRecord fromJson(Map<String, dynamic> json) {
    return BloodPressureRecord(
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      pulse: json['pulse'],
      date: DateTime.parse(json['date']),
    );
  }
}
