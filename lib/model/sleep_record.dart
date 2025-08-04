class SleepRecord {
  final Duration total;
  final Duration light;
  final Duration deep;
  final Duration rem;
  final int awakeCount;
  final DateTime? bedTime;
  final DateTime? wakeTime;

  SleepRecord({
    required this.total,
    required this.light,
    required this.deep,
    required this.rem,
    required this.awakeCount,
    this.bedTime,
    this.wakeTime,
  });
}
