class ReminderTime {
  final int hour;
  final int minute;
  final bool enabled;

  ReminderTime({
    required this.hour,
    required this.minute,
    required this.enabled,
  });

  ReminderTime copyWith({int? hour, int? minute, bool? enabled}) {
    return ReminderTime(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'hour': hour,
        'minute': minute,
        'enabled': enabled,
      };

  factory ReminderTime.fromJson(Map<String, dynamic> json) {
    return ReminderTime(
      hour: json['hour'],
      minute: json['minute'],
      enabled: json['enabled'],
    );
  }
}
