import 'package:flutter/material.dart';

import '../screen.dart';

class SleepManager extends ChangeNotifier {
  final SleepService _service = SleepService();

  SleepRecord? sleepData;
  bool isLoading = false;
  DateTime selectedDate = DateTime.now();

  bool get hasData => sleepData != null && sleepData!.total.inMinutes > 0;

  Future<void> loadSleepData(DateTime date) async {
    isLoading = true;
    notifyListeners();

    sleepData = await _service.getSleepDataForDate(date);

    selectedDate = date;
    isLoading = false;
    notifyListeners();
  }

  String formatDuration(Duration d) {
    return "${d.inHours}g ${d.inMinutes % 60}p";
  }

  double get remPercent {
    if (sleepData == null || sleepData!.total.inMinutes == 0) return 0;
    final totalKnown = sleepData!.rem + sleepData!.light + sleepData!.deep;
    if (totalKnown.inMinutes == 0) return 0;
    return (sleepData!.rem.inMinutes / totalKnown.inMinutes) * 100;
  }

  double get lightPercent {
    if (sleepData == null || sleepData!.total.inMinutes == 0) return 0;
    final totalKnown = sleepData!.rem + sleepData!.light + sleepData!.deep;
    if (totalKnown.inMinutes == 0) return 0;
    return (sleepData!.light.inMinutes / totalKnown.inMinutes) * 100;
  }

  double get deepPercent {
    if (sleepData == null || sleepData!.total.inMinutes == 0) return 0;
    final totalKnown = sleepData!.rem + sleepData!.light + sleepData!.deep;
    if (totalKnown.inMinutes == 0) return 0;
    return (sleepData!.deep.inMinutes / totalKnown.inMinutes) * 100;
  }

  double get recoveryScore {
    if (sleepData == null) return 0;
    double score = 0;

    final totalHours =
        sleepData!.total.inHours + sleepData!.total.inMinutes % 60 / 60;
    if (totalHours >= 7 && totalHours <= 9) {
      score += 40; // thời gian ngủ hợp lý
    } else if (totalHours >= 5) {
      score += 25;
    } else {
      score += 10;
    }

    if (remPercent >= 15 && remPercent <= 25) score += 20;
    if (deepPercent >= 13 && deepPercent <= 23) score += 20;

    if (sleepData!.awakeCount <= 10) {
      score += 20;
    } else if (sleepData!.awakeCount <= 20) {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  String get recoveryLabel {
    final score = recoveryScore;
    if (score >= 80) return "Tốt";
    if (score >= 60) return "Vừa phải";
    return "Kém";
  }

  Color get recoveryColor {
    final score = recoveryScore;
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
