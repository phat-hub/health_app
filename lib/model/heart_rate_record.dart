class HeartRateRecord {
  final DateTime date;
  final int bpm;

  HeartRateRecord({required this.date, required this.bpm});

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'bpm': bpm,
    };
  }

  factory HeartRateRecord.fromMap(Map<String, dynamic> map) {
    return HeartRateRecord(
      date: DateTime.parse(map['date']),
      bpm: map['bpm'] ?? 0,
    );
  }
}
