import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen.dart';

class BloodGlucoseService {
  static const String storageKey = 'blood_glucose_records';

  Future<List<BloodGlucoseRecord>> getRecordsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(storageKey) ?? [];

    return data
        .map((item) => BloodGlucoseRecord.fromJson(jsonDecode(item)))
        .where((record) => _isSameDay(record.date, date))
        .toList();
  }

  Future<void> saveRecord(BloodGlucoseRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(storageKey) ?? [];

    data.add(jsonEncode(record.toJson()));
    await prefs.setStringList(storageKey, data);
  }

  Future<void> deleteSpecificRecord(BloodGlucoseRecord target) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(storageKey) ?? [];

    data.removeWhere((item) {
      final existing = BloodGlucoseRecord.fromJson(jsonDecode(item));
      return existing.date == target.date;
    });

    await prefs.setStringList(storageKey, data);
  }

  Future<void> deleteOlderThan30Days() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(storageKey) ?? [];

    final cutoff = DateTime.now().subtract(const Duration(days: 30));

    data.removeWhere((item) {
      final existing = BloodGlucoseRecord.fromJson(jsonDecode(item));
      return existing.date.isBefore(cutoff);
    });

    await prefs.setStringList(storageKey, data);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
