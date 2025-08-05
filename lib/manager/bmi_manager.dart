import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen.dart';

class BmiManager extends ChangeNotifier {
  final BmiService _service = BmiService();

  static const String firstOpenKey = 'first_open_bmi_date';
  static const String cleanedKey = 'bmi_data_cleaned';

  List<BmiRecord> records = [];
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  Future<void> initFirstOpenDate() async {
    final prefs = await SharedPreferences.getInstance();
    final firstOpenStr = prefs.getString(firstOpenKey);

    if (firstOpenStr == null) {
      await prefs.setString(firstOpenKey, DateTime.now().toIso8601String());
    }
  }

  Future<DateTime> getFirstOpenDate() async {
    final prefs = await SharedPreferences.getInstance();
    final firstOpenStr = prefs.getString(firstOpenKey);
    return firstOpenStr != null ? DateTime.parse(firstOpenStr) : DateTime.now();
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
    final cleaned = prefs.getBool(cleanedKey) ?? false;

    if (!cleaned) {
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

  Future<void> saveRecord(double height, double weight) async {
    final bmi = weight / ((height / 100) * (height / 100));
    final record = BmiRecord(
      height: height,
      weight: weight,
      bmi: bmi,
      date: DateTime.now(),
    );
    await _service.saveRecord(record);
    await loadRecords(selectedDate);
  }

  Future<void> deleteRecord(BmiRecord record) async {
    await _service.deleteSpecificRecord(record);
    await loadRecords(selectedDate);
  }

  String getStatus(double bmi) {
    if (bmi < 16) return "Gầy độ III";
    if (bmi < 17) return "Gầy độ II";
    if (bmi < 18.5) return "Gầy độ I";
    if (bmi < 25) return "Bình thường";
    if (bmi < 30) return "Thừa cân";
    if (bmi < 35) return "Béo phì độ I";
    if (bmi < 40) return "Béo phì độ II";
    return "Béo phì độ III";
  }
}
