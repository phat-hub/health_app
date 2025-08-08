class WaterRecord {
  final int amount; // ml
  final DateTime time;

  WaterRecord({
    required this.amount,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'time': time.toIso8601String(),
      };

  factory WaterRecord.fromJson(Map<String, dynamic> json) {
    return WaterRecord(
      amount: json['amount'],
      time: DateTime.parse(json['time']),
    );
  }
}
