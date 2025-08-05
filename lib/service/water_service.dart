import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WaterService {
  static const String firstOpenKey = 'water_first_open_date';

  String _getHistoryKey(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return 'water_history_${year}-${month}-${day}';
  }

  Future<List<int>> getDrinkHistory(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_getHistoryKey(date));
    if (data != null) {
      return List<int>.from(jsonDecode(data));
    }
    return [];
  }

  Future<void> saveDrinkHistory(DateTime date, List<int> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_getHistoryKey(date), jsonEncode(history));
  }

  /// Ngày mở app lần đầu
  Future<void> saveFirstOpenDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(firstOpenKey)) {
      await prefs.setString(firstOpenKey, date.toIso8601String());
    }
  }

  Future<DateTime> getFirstOpenDate() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(firstOpenKey)) {
      return DateTime.parse(prefs.getString(firstOpenKey)!);
    }
    return DateTime.now();
  }

  /// Xóa dữ liệu cũ hơn
  Future<void> deleteOldData(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final keys = prefs.getKeys();

    for (var key in keys) {
      if (key.startsWith('water_history_') && key != firstOpenKey) {
        try {
          final dateStr = key.replaceFirst('water_history_', '');
          final parts = dateStr.split('-');
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          if (now.difference(date).inDays > days) {
            await prefs.remove(key);
          }
        } catch (_) {}
      }
    }
  }
}
