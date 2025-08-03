import 'package:flutter/material.dart';

import '../screen.dart';

class HeartRateManager extends ChangeNotifier {
  final HeartRateService _service = HeartRateService();

  int? latestHeartRate;
  bool isLoading = false;
  List<HeartRateRecord> history = [];

  HeartRateService get service => _service;

  Future<void> loadLatestHeartRate() async {
    isLoading = true;
    notifyListeners();

    latestHeartRate = await _service.fetchLatestHeartRate();

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadHistoryWithAutoRange() async {
    isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    DateTime start = todayMidnight.subtract(const Duration(days: 7));

    // Lấy dữ liệu từ Health Connect
    final result = await _service.fetchHeartRateHistory(start: start, end: now);

    history = result;

    isLoading = false;
    notifyListeners();
  }

  /// Lọc lịch sử theo ngày
  List<HeartRateRecord> filterByDate(DateTime date) {
    return history
        .where((r) =>
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day)
        .toList();
  }
}
