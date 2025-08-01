import 'package:flutter/material.dart';
import '../service/heart_rate_service.dart';
import '../model/heart_rate_record.dart';

class HeartRateManager extends ChangeNotifier {
  final HeartRateService _service = HeartRateService();

  int? latestHeartRate;
  bool isLoading = false;
  List<HeartRateRecord> history = [];

  HeartRateService get service => _service;

  Future<void> loadLatestHeartRate() async {
    isLoading = true;
    notifyListeners();

    // Dùng microtask để không chặn UI init
    await Future.microtask(() async {
      latestHeartRate = await _service.fetchLatestHeartRate();
    });

    isLoading = false;
    notifyListeners();
  }

  /// Lấy lịch sử từ Health Connect
  Future<void> loadHistory(DateTime start, DateTime end,
      {String? userId}) async {
    isLoading = true;
    notifyListeners();

    final result = await _service.fetchHeartRateHistory(start: start, end: end);
    history = result;

    if (userId != null) {
      // Lấy lịch sử hiện tại trên Firebase
      final firebaseHistory = await _service.getHistoryFromFirebase(userId);

      // Nếu có dữ liệu mới → mới ghi
      final newRecords = history.where((h) {
        return !firebaseHistory.any((f) =>
            (f.date.difference(h.date).inSeconds).abs() < 30 && f.bpm == h.bpm);
      }).toList();

      if (newRecords.isNotEmpty) {
        await _service.saveHistoryToFirebase(userId, newRecords);
      }
    }

    isLoading = false;
    notifyListeners();
  }

  /// Lấy dữ liệu từ Firebase (offline sync)
  Future<void> loadFromFirebase(String userId) async {
    isLoading = true;
    notifyListeners();

    history = await _service.getHistoryFromFirebase(userId);

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
