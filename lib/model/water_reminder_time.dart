class WaterReminderTime {
  final int hour;
  final int minute;
  final bool enabled;

  WaterReminderTime({
    required this.hour,
    required this.minute,
    required this.enabled,
  });

  WaterReminderTime copyWith({int? hour, int? minute, bool? enabled}) {
    return WaterReminderTime(
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

  factory WaterReminderTime.fromJson(Map<String, dynamic> json) {
    return WaterReminderTime(
      hour: json['hour'],
      minute: json['minute'],
      enabled: json['enabled'],
    );
  }
}
