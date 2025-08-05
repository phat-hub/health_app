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

  Future<Map<DateTime, int>> getWaterStatsLast30Days(
      DateTime firstOpenDate) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Số ngày cần lấy: từ ngày mở đầu tiên hoặc tối đa 30 ngày gần nhất
    int daysDiff = now.difference(firstOpenDate).inDays + 1;
    int daysToFetch = daysDiff > 30 ? 30 : daysDiff;

    Map<DateTime, int> stats = {};

    for (int i = 0; i < daysToFetch; i++) {
      final date = now.subtract(Duration(days: i));
      final data = prefs.getString(_getHistoryKey(date));
      int total = 0;
      if (data != null) {
        List<int> history = List<int>.from(jsonDecode(data));
        total = history.fold(0, (sum, e) => sum + e);
      }
      stats[DateTime(date.year, date.month, date.day)] = total;
    }

    // Đảo ngược thứ tự để từ cũ -> mới
    final sortedKeys = stats.keys.toList()..sort();
    Map<DateTime, int> sortedStats = {
      for (var key in sortedKeys) key: stats[key]!,
    };

    return sortedStats;
  }
}
