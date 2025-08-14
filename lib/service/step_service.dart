import 'dart:async';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';

import '../screen.dart';

class StepService {
  final Health _health = Health();
  StreamSubscription<StepCount>? _pedometerSubscription;

  /// Lấy bước từ Health Connect
  Future<int?> getStepsForDate(DateTime date) async {
    await Permission.activityRecognition.request();
    await _health.configure();

    final types = [HealthDataType.STEPS];
    final permissions = [HealthDataAccess.READ];

    bool authorized =
        await _health.requestAuthorization(types, permissions: permissions);
    if (!authorized) return null;

    final start = DateTime(date.year, date.month, date.day);
    final end = date.isAtSameMomentAs(DateTime.now())
        ? DateTime.now()
        : start
            .add(const Duration(days: 1))
            .subtract(const Duration(seconds: 1));

    int totalSteps = 0;
    final data = await _health.getHealthDataFromTypes(
      types: types,
      startTime: start,
      endTime: end,
    );

    for (var d in data) {
      if (d.type == HealthDataType.STEPS && d.value is NumericHealthValue) {
        totalSteps += (d.value as NumericHealthValue).numericValue.toInt();
      }
    }

    return totalSteps > 0 ? totalSteps : null;
  }

  /// Ghi bước chân vào Health Connect
  Future<bool> writeStepsToHealthConnect(int steps) async {
    await Permission.activityRecognition.request();
    await _health.configure();

    final types = [HealthDataType.STEPS];
    final permissions = [HealthDataAccess.READ_WRITE];

    bool authorized =
        await _health.requestAuthorization(types, permissions: permissions);
    if (!authorized) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return await _health.writeHealthData(
      value: steps.toDouble(),
      unit: HealthDataUnit.COUNT,
      type: HealthDataType.STEPS,
      startTime: today,
      endTime: now,
    );
  }

  Future<int> getStepsFromPedometerNow() async {
    Completer<int> completer = Completer<int>();

    _pedometerSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        if (!completer.isCompleted) completer.complete(event.steps);
      },
      onError: (error) {
        if (!completer.isCompleted) completer.completeError(error);
      },
      cancelOnError: false,
    );

    return completer.future;
  }

  void stopPedometer() => _pedometerSubscription?.cancel();

  Future<List<StepRecord>> getStepRecordsLast30Days() async {
    final List<StepRecord> records = [];
    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final steps = await getStepsForDate(date) ?? 0;
      records.add(StepRecord.fromSteps(date, steps));
    }

    records.sort((a, b) => a.date.compareTo(b.date));
    return records;
  }
}
