import 'dart:async';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';

class StepService {
  final Health _health = Health();
  StreamSubscription<StepCount>? _pedometerSubscription;

  /// Lấy số bước từ Health Connect cho 1 ngày cụ thể
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

  /// Ghi số bước vào Health Connect
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

    // Ghi dữ liệu số bước cho hôm nay
    return await _health.writeHealthData(
      value: steps.toDouble(),
      unit: HealthDataUnit.COUNT,
      type: HealthDataType.STEPS,
      startTime: today,
      endTime: now,
    );
  }

  /// Lắng nghe số bước từ Pedometer
  void listenPedometer(Function(int) onStepChanged) {
    _pedometerSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        onStepChanged(event.steps);
      },
      onError: (error) {
        print("Pedometer error: $error");
      },
      cancelOnError: false,
    );
  }

  void stopPedometer() {
    _pedometerSubscription?.cancel();
  }

  Future<Map<DateTime, int>> getStepStatsLast30Days() async {
    final Map<DateTime, int> stats = {};
    final now = DateTime.now();

    // Lấy 30 ngày gần nhất, bao gồm hôm nay
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final steps = await getStepsForDate(date) ?? 0;
      stats[DateTime(date.year, date.month, date.day)] = steps;
    }

    // Sắp xếp từ cũ → mới
    final sortedKeys = stats.keys.toList()..sort();
    return {
      for (var k in sortedKeys) k: stats[k]!,
    };
  }
}
