import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen.dart';

class BloodPressureManager extends ChangeNotifier {
  final BloodPressureService _service = BloodPressureService();

  static const String firstOpenKey = 'first_open_bp_date';
  static const String cleanedKey = 'bp_data_cleaned';

  List<BloodPressureRecord> records = [];
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  /// Khởi tạo ngày mở lần đầu
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

  /// Giới hạn ngày chọn
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

  /// Xóa dữ liệu cũ hơn 30 ngày (chỉ làm 1 lần)
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

  Future<void> saveRecord(int systolic, int diastolic, int pulse) async {
    final record = BloodPressureRecord(
      systolic: systolic,
      diastolic: diastolic,
      pulse: pulse,
      date: DateTime.now(),
    );
    await _service.saveRecord(record);
    await loadRecords(selectedDate);
  }

  Future<void> deleteRecord(BloodPressureRecord record) async {
    await _service.deleteSpecificRecord(record);
    await loadRecords(selectedDate);
  }

  String getStatus(BloodPressureRecord rec) {
    final sys = rec.systolic;
    final dia = rec.diastolic;

    if (sys < 90 || dia < 60) return "Huyết áp thấp";
    if (sys < 120 && dia < 80) return "Huyết áp tối ưu";
    if (sys < 130 && dia < 85) return "Bình thường";
    if (sys < 140 && dia < 90) return "Tiền tăng huyết áp";
    if (sys < 160 && dia < 100) return "Tăng huyết áp độ 1";
    if (sys < 180 && dia < 110) return "Tăng huyết áp độ 2";
    return "Tăng huyết áp độ 3";
  }
}
