import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

import '../screen.dart';

class SleepService {
  final Health _health = Health();

  Future<SleepRecord?> getSleepDataForDate(DateTime date) async {
    await Permission.activityRecognition.request();
    await _health.configure();

    final types = [
      HealthDataType.SLEEP_SESSION,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_AWAKE,
    ];
    final permissions = List.filled(types.length, HealthDataAccess.READ);

    bool authorized =
        await _health.requestAuthorization(types, permissions: permissions);
    if (!authorized) return null;

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final data = await _health.getHealthDataFromTypes(
      types: types,
      startTime: start,
      endTime: end,
    );

    Duration total = Duration.zero;
    Duration light = Duration.zero;
    Duration deep = Duration.zero;
    Duration rem = Duration.zero;
    int awakeCount = 0;
    DateTime? bedTime;
    DateTime? wakeTime;

    for (var d in data) {
      final duration = d.dateTo.difference(d.dateFrom);

      if (d.type == HealthDataType.SLEEP_SESSION) {
        total += duration;
        bedTime ??= d.dateFrom;
        wakeTime = d.dateTo;
      } else if (d.type == HealthDataType.SLEEP_LIGHT) {
        light += duration;
      } else if (d.type == HealthDataType.SLEEP_DEEP) {
        deep += duration;
      } else if (d.type == HealthDataType.SLEEP_REM) {
        rem += duration;
      } else if (d.type == HealthDataType.SLEEP_AWAKE) {
        awakeCount++;
      }
    }

    return SleepRecord(
      total: total,
      light: light,
      deep: deep,
      rem: rem,
      awakeCount: awakeCount,
      bedTime: bedTime,
      wakeTime: wakeTime,
    );
  }
}
