import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

import '../screen.dart';

class HeartRateService {
  final Health _health = Health();

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
