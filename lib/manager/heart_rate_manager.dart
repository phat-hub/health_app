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

    // Dùng microtask để không chặn UI init
    await Future.microtask(() async {
      latestHeartRate = await _service.fetchLatestHeartRate();
    });

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadHistoryWithAutoRange(String userId) async {
    isLoading = true;
    notifyListeners();

    // Kiểm tra đã có dữ liệu Firebase chưa
    final hasData = await _hasFirebaseData(userId);

    DateTime start;
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);

    if (hasData) {
      // Lần sau → chỉ lấy từ 00:00 hôm nay
      start = DateTime(now.year, now.month, now.day);
    } else {
      // Lần đầu → lấy 7 ngày gần nhất
      start = todayMidnight.subtract(const Duration(days: 7));
    }

    // Lấy dữ liệu từ Health Connect
    final result = await _service.fetchHeartRateHistory(start: start, end: now);

    // Lịch sử hiện có trong Firebase
    final firebaseHistory = await _service.getHistoryFromFirebase(userId);

    // Chỉ giữ lại bản ghi mới chưa có trong Firebase
    final newRecords = result.where((h) {
      return !firebaseHistory.any((f) =>
          (f.date.difference(h.date).inSeconds).abs() < 30 && f.bpm == h.bpm);
    }).toList();

    // Lưu nếu có dữ liệu mới
    if (newRecords.isNotEmpty) {
      await _service.saveHistoryToFirebase(userId, newRecords);
    }

    // Cập nhật state
    history = [...firebaseHistory, ...newRecords]
      ..sort((a, b) => b.date.compareTo(a.date));

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

  Future<bool> _hasFirebaseData(String userId) async {
    final history = await _service.getHistoryFromFirebase(userId);
    return history.isNotEmpty;
  }

  /// Xóa dữ liệu cũ hơn 7 ngày trên Firebase
  Future<void> deleteOldHistory(String userId) async {
    await _service.deleteOldHeartRateData(userId);
  }
}
