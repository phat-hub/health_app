import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen.dart';

class BloodGlucoseManager extends ChangeNotifier {
  final BloodGlucoseService _service = BloodGlucoseService();

  static const String firstOpenKey = 'first_open_bg_date';
  static const String cleanedKey = 'bg_data_cleaned';

  List<BloodGlucoseRecord> records = [];
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  Future<void> initFirstOpenDate() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(firstOpenKey) == null) {
      await prefs.setString(firstOpenKey, DateTime.now().toIso8601String());
    }
  }

  Future<DateTime> getFirstOpenDate() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(firstOpenKey);
    return str != null ? DateTime.parse(str) : DateTime.now();
  }

  Future<DateTime> getDatePickerFirstDate() async {
    final firstOpen = await getFirstOpenDate();
    final now = DateTime.now();
    final daysUsed = now.difference(firstOpen).inDays;
    if (daysUsed > 30) {
      await cleanOldDataOnce();
      return now.subtract(const Duration(days: 30));
    } else {
      return firstOpen;
    }
  }

  Future<void> cleanOldDataOnce() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(cleanedKey) ?? false)) {
      await _service.deleteOlderThan30Days();
      await prefs.setBool(cleanedKey, true);
    }
  }

  Future<void> loadRecords(DateTime date) async {
    isLoading = true;
    notifyListeners();
    selectedDate = date;
    records = await _service.getRecordsForDate(date);
    isLoading = false;
    notifyListeners();
  }

  Future<void> saveRecord(double glucose, String type) async {
    final record = BloodGlucoseRecord(
      glucose: glucose,
      measurementType: type,
      date: DateTime.now(),
    );
    await _service.saveRecord(record);
    await loadRecords(selectedDate);
  }

  Future<void> deleteRecord(BloodGlucoseRecord record) async {
    await _service.deleteSpecificRecord(record);
    await loadRecords(selectedDate);
  }

  String getGlucoseStatus(BloodGlucoseRecord rec) {
    final g = rec.glucose;
    final type = rec.measurementType;

    switch (type) {
      case "fasting": // Lúc đói
        if (g < 3.9) return "Hạ đường huyết";
        if (g <= 5.5) return "Bình thường";
        if (g <= 6.9) return "Tiền đái tháo đường";
        return "Đái tháo đường";

      case "post_meal": // Sau ăn 2h
        if (g < 7.8) return "Bình thường";
        if (g <= 11.0) return "Tiền đái tháo đường";
        return "Đái tháo đường";

      case "random": // Ngẫu nhiên
        if (g < 7.8) return "Bình thường";
        if (g >= 11.1) return "Đái tháo đường";
        return "Tiền đái tháo đường";

      default:
        return "Không xác định";
    }
  }

  Future<Map<String, int>> getStatusStatistics(
      DateTime start, DateTime end) async {
    final recordsInRange = await _service.getRecordsInRange(start, end);

    Map<String, int> stats = {
      "Hạ đường huyết": 0,
      "Bình thường": 0,
      "Tiền đái tháo đường": 0,
      "Đái tháo đường": 0,
      "Không xác định": 0,
    };

    for (var rec in recordsInRange) {
      final status = getGlucoseStatus(rec);
      stats[status] = (stats[status] ?? 0) + 1;
    }

    return stats;
  }
}
