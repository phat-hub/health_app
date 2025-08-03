import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screen.dart';

class HeartRateService {
  final Health _health = Health();
  final _firestore = FirebaseFirestore.instance;

  Future<int?> fetchLatestHeartRate() async {
    await Permission.activityRecognition.request();
    await _health.configure();

    final types = [HealthDataType.HEART_RATE];
    final permissions = [HealthDataAccess.READ];

    bool authorized =
        await _health.requestAuthorization(types, permissions: permissions);
    if (!authorized) return null;

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    final data = await _health.getHealthDataFromTypes(
      types: types,
      startTime: yesterday,
      endTime: now,
    );

    // Xử lý nặng → đưa sang isolate
    return compute(_findLatestHeartRate, data);
  }

  /// Lấy lịch sử nhịp tim trong khoảng ngày
  Future<List<HeartRateRecord>> fetchHeartRateHistory({
    required DateTime start,
    required DateTime end,
  }) async {
    await Permission.activityRecognition.request();
    await _health.configure();

    final types = [HealthDataType.HEART_RATE];
    final permissions = [HealthDataAccess.READ];

    bool authorized =
        await _health.requestAuthorization(types, permissions: permissions);
    if (!authorized) return [];

    final data = await _health.getHealthDataFromTypes(
      types: types,
      startTime: start,
      endTime: end,
    );

    // Chuyển sang isolate để xử lý
    return compute(_parseHeartRateHistory, data);
  }

  /// Lưu lịch sử lên Firebase
  Future<void> saveHistoryToFirebase(
      String userId, List<HeartRateRecord> history) async {
    if (history.isEmpty) return; // Không có gì để lưu thì thoát luôn

    final colRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('heart_rate_history');

    const int batchSize =
        500; // Firestore giới hạn mỗi batch tối đa 500 thao tác
    for (var i = 0; i < history.length; i += batchSize) {
      final batch = _firestore.batch();

      // Xác định điểm kết thúc nhóm
      final end =
          (i + batchSize > history.length) ? history.length : i + batchSize;

      // Lấy nhóm bản ghi tối đa 500
      final batchRecords = history.sublist(i, end);

      // Thêm từng bản ghi vào batch
      for (var record in batchRecords) {
        final docRef = colRef.doc(record.date.toIso8601String());
        batch.set(docRef, record.toMap(), SetOptions(merge: true));
      }

      // Lưu nhóm này lên Firestore
      await batch.commit();
    }
  }

  /// Lấy lịch sử từ Firebase
  Future<List<HeartRateRecord>> getHistoryFromFirebase(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('heart_rate_history')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => HeartRateRecord.fromMap(doc.data()))
        .toList();
  }

  Future<void> saveHeartRateToHealthConnect(int bpm) async {
    await _health.configure();

    final types = [HealthDataType.HEART_RATE];
    final permissions = [HealthDataAccess.WRITE];

    bool authorized = await _health.requestAuthorization(
      types,
      permissions: permissions,
    );
    if (!authorized) return;

    final now = DateTime.now();
    await _health.writeHealthData(
      value: bpm.toDouble(),
      unit: HealthDataUnit.BEATS_PER_MINUTE, // đơn vị BPM
      type: HealthDataType.HEART_RATE,
      startTime: now.subtract(const Duration(seconds: 20)),
      endTime: now,
    );
  }

  Future<void> saveLatestHeartRateToFirebase(String userId, int bpm) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('heart_rate_history');

    // Kiểm tra bản ghi gần nhất
    final latestDoc =
        await docRef.orderBy('date', descending: true).limit(1).get();
    if (latestDoc.docs.isNotEmpty) {
      final latest = HeartRateRecord.fromMap(latestDoc.docs.first.data());
      // Nếu dữ liệu không thay đổi trong vòng 1 phút → không ghi
      if ((bpm - latest.bpm).abs() < 1 &&
          DateTime.now().difference(latest.date).inMinutes < 1) {
        return;
      }
    }

    // Lưu bản ghi mới
    await docRef.doc(DateTime.now().toIso8601String()).set({
      'date': DateTime.now().toIso8601String(),
      'bpm': bpm,
    });
  }

  Future<void> deleteOldHeartRateData(String userId) async {
    final todayMidnight =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final sevenDaysAgo = todayMidnight.subtract(const Duration(days: 7));

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('heart_rate_history')
        .where('date', isLessThan: sevenDaysAgo.toIso8601String())
        .get();

    if (snapshot.docs.isEmpty) return;

    // Chia nhỏ danh sách thành từng nhóm 500 document
    const int batchSize = 500;
    for (var i = 0; i < snapshot.docs.length; i += batchSize) {
      final batch = _firestore.batch();

      // Lấy tối đa 500 document cho mỗi batch
      final end = (i + batchSize > snapshot.docs.length)
          ? snapshot.docs.length
          : i + batchSize;

      final batchDocs = snapshot.docs.sublist(i, end);

      // Thêm lệnh xóa cho mỗi document
      for (var doc in batchDocs) {
        batch.delete(doc.reference);
      }

      // Commit batch xóa
      await batch.commit();
    }
  }
}

/// Hàm xử lý tìm nhịp tim mới nhất (chạy trong isolate)
int? _findLatestHeartRate(List<HealthDataPoint> data) {
  int? hr;
  DateTime? latestTime;

  for (var d in data) {
    if (d.type == HealthDataType.HEART_RATE && d.value is NumericHealthValue) {
      final hrValue = d.value as NumericHealthValue;
      final value = hrValue.numericValue.round();
      if (latestTime == null || d.dateFrom.isAfter(latestTime)) {
        hr = value;
        latestTime = d.dateFrom;
      }
    }
  }

  return hr;
}

/// Hàm xử lý trong isolate
List<HeartRateRecord> _parseHeartRateHistory(List<HealthDataPoint> data) {
  return data
      .where((d) =>
          d.type == HealthDataType.HEART_RATE && d.value is NumericHealthValue)
      .map((d) {
    final hrValue = d.value as NumericHealthValue;
    return HeartRateRecord(
      date: d.dateFrom,
      bpm: hrValue.numericValue.round(),
    );
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date)); // Mới nhất lên đầu
}
