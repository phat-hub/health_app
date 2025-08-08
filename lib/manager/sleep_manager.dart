import 'package:flutter/material.dart';
import '../screen.dart';

class SleepManager extends ChangeNotifier {
  final SleepService _service = SleepService();

  SleepRecord? sleepData;
  bool isLoading = false;
  DateTime selectedDate = DateTime.now();

  ReminderTime reminder = ReminderTime(hour: 22, minute: 0, enabled: false);

  bool get hasData => sleepData != null && sleepData!.total.inMinutes > 0;

  Future<void> init() async {
    await _service.initNotifications();
    reminder = await _service.getReminder() ?? reminder;
    notifyListeners();
  }

  Future<void> toggleReminder(ReminderTime newReminder) async {
    reminder = newReminder;
    await _service.setReminder(newReminder);
    notifyListeners();
  }

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

  /// Tính điểm giấc ngủ theo chuẩn y tế
  double get recoveryScore {
    if (sleepData == null) return 0;
    double score = 0;

    // Tổng thời gian ngủ (giờ)
    final totalHours =
        sleepData!.total.inHours + sleepData!.total.inMinutes % 60 / 60;

    // 1. Thời lượng ngủ
    if (totalHours >= 7 && totalHours <= 9) {
      score += 40; // chuẩn y tế
    } else if (totalHours >= 6) {
      score += 25;
    } else {
      score += 10;
    }

    // 2. Giấc ngủ sâu (Deep Sleep)
    if (sleepData!.deep.inMinutes >= 60 && sleepData!.deep.inMinutes <= 110) {
      score += 20;
    } else if (sleepData!.deep.inMinutes >= 40) {
      score += 10;
    }

    // 3. Giấc ngủ REM
    if (sleepData!.rem.inMinutes >= 80 && sleepData!.rem.inMinutes <= 110) {
      score += 20;
    } else if (sleepData!.rem.inMinutes >= 60) {
      score += 10;
    }

    // 4. Số lần thức giấc
    if (sleepData!.awakeCount <= 5) {
      score += 20;
    } else if (sleepData!.awakeCount <= 10) {
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

  Future<Map<DateTime, SleepRecord>> getSleepRecordsInRange(
      DateTime start, DateTime end) async {
    return await _service.getSleepDataInRange(start, end);
  }
}
