import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen.dart';

class StepManager extends ChangeNotifier {
  final StepService _service = StepService();

  bool _isLoading = false;
  bool hasHealthData = false;
  int steps = 0; // bước chân trong ngày
  int goal = 6000;
  double calories = 0;
  double distance = 0;
  Duration activeTime = Duration.zero;

  DateTime selectedDate = DateTime.now();
  Timer? _pollingTimer;

  List<StepRecord> stepRecords = [];

  int _stepCountAtStartOfDay = 0; // offset bước chân đầu ngày để reset 0h

  StepManager() {
    _loadGoalFromPrefs();
    _loadStepCountAtStartOfDay();
  }

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _loadStepCountAtStartOfDay() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateToString(DateTime.now());
    _stepCountAtStartOfDay =
        prefs.getInt('stepCountAtStartOfDay_$todayKey') ?? 0;
  }

  Future<void> _saveStepCountAtStartOfDay(int stepCount) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateToString(DateTime.now());
    await prefs.setInt('stepCountAtStartOfDay_$todayKey', stepCount);
    _stepCountAtStartOfDay = stepCount;
  }

  Future<void> initSteps() async {
    await loadStepsForDate(selectedDate);
    await loadStepStats();

    if (_isToday(selectedDate)) {
      _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        loadStepsForDate(selectedDate);
      });
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  String _dateToString(DateTime date) {
    return '${date.year}_${date.month}_${date.day}';
  }

  Future<void> loadStepsForDate(DateTime date) async {
    setLoading(true);

    int? healthSteps = await _service.getStepsForDate(date);

    if (healthSteps != null) {
      // Có dữ liệu Health Connect
      hasHealthData = true;

      steps = healthSteps;

      _calculateMetrics();
      setLoading(false);
    } else {
      // Không có dữ liệu Health Connect
      hasHealthData = false;

      if (_isToday(date)) {
        try {
          // Lấy tổng bước realtime từ pedometer
          int pedometerSteps = await _service.getStepsFromPedometerToday();

          if (_stepCountAtStartOfDay == 0) {
            // Lưu bước chân đầu ngày = pedometerSteps
            await _saveStepCountAtStartOfDay(pedometerSteps);
          }

          // Tính bước chân trong ngày
          steps = pedometerSteps - _stepCountAtStartOfDay;
          if (steps < 0) steps = 0;

          // Ghi vào Health Connect
          bool writeSuccess = await _service.writeStepsToHealthConnect(steps);

          if (writeSuccess) {
            // Đọc lại từ Health Connect cho đồng bộ
            int? updatedSteps = await _service.getStepsForDate(date);
            steps = updatedSteps ?? steps;
          }

          _calculateMetrics();
          setLoading(false);
          hasHealthData = true;
        } catch (e) {
          print("Error getting pedometer steps: $e");
          steps = 0;
          setLoading(false);
        }
      } else {
        steps = 0;
        setLoading(false);
      }
    }

    selectedDate = date;
  }

  void updateGoal(int newGoal) async {
    goal = newGoal;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_goal', goal);
  }

  Future<void> _loadGoalFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGoal = prefs.getInt('daily_goal');
    if (savedGoal != null) {
      goal = savedGoal;
      notifyListeners();
    }
  }

  void _calculateMetrics() {
    const stepLengthMeters = 0.762;
    const kcalPerStep = 0.04;

    distance = steps * stepLengthMeters;
    calories = steps * kcalPerStep;
    activeTime = Duration(minutes: (steps / 100).round());
  }

  Future<void> loadStepStats() async {
    stepRecords = await _service.getStepRecordsLast30Days();
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
