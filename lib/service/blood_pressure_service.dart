import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen.dart';

class BloodPressureService {
  static const String storageKey = 'blood_pressure_records';

  /// Lấy tất cả bản ghi của 1 ngày
  Future<List<BloodPressureRecord>> getRecordsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(storageKey) ?? [];

    return data
        .map((item) => BloodPressureRecord.fromJson(jsonDecode(item)))
        .where((record) => _isSameDay(record.date, date))
        .toList();
  }

  /// Lưu bản ghi mới
  Future<void> saveRecord(BloodPressureRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(storageKey) ?? [];

    data.add(jsonEncode(record.toJson()));
    await prefs.setStringList(storageKey, data);
  }

  /// Xóa bản ghi cụ thể
  Future<void> deleteSpecificRecord(BloodPressureRecord target) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(storageKey) ?? [];

    data.removeWhere((item) {
      final existing = BloodPressureRecord.fromJson(jsonDecode(item));
      return existing.date == target.date;
    });

    await prefs.setStringList(storageKey, data);
  }

  /// Xóa dữ liệu cũ hơn 30 ngày
  Future<void> deleteOlderThan30Days() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(storageKey) ?? [];

    final cutoff = DateTime.now().subtract(const Duration(days: 30));

    data.removeWhere((item) {
      final existing = BloodPressureRecord.fromJson(jsonDecode(item));
      return existing.date.isBefore(cutoff);
    });

    await prefs.setStringList(storageKey, data);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<List<BloodPressureRecord>> getRecordsInRange(
      DateTime start, DateTime end) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(BloodPressureService.storageKey) ?? [];

    // Chuẩn hóa start & end
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return data
        .map((item) => BloodPressureRecord.fromJson(jsonDecode(item)))
        .where(
            (rec) => !rec.date.isBefore(startDay) && !rec.date.isAfter(endDay))
        .toList();
  }
}
