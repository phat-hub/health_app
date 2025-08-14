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

  int _stepOffset = 0; // offset reset 0h

  StepManager() {
    _loadGoalFromPrefs();
    _loadStepOffset();
  }

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _loadStepOffset() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateToString(DateTime.now());
    _stepOffset = prefs.getInt('stepOffset_$todayKey') ?? 0;
  }

  Future<void> _saveStepOffset(int offset) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateToString(DateTime.now());
    await prefs.setInt('stepOffset_$todayKey', offset);
    _stepOffset = offset;
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

    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateToString(DateTime.now());
    int? savedOffset = prefs.getInt('stepOffset_$todayKey');

    int pedometerSteps = 0;

    if (_isToday(date)) {
      pedometerSteps = await _service.getStepsFromPedometerNow();

      // Nếu offset chưa lưu cho ngày mới hoặc ngày đã thay đổi → reset
      if (savedOffset == null) {
        await _saveStepOffset(pedometerSteps);
      }
    }

    int? healthSteps = await _service.getStepsForDate(date);

    if (healthSteps != null) {
      hasHealthData = true;
      steps = healthSteps;
    } else {
      if (_isToday(date)) {
        steps = pedometerSteps - _stepOffset;
        if (steps < 0) steps = 0;

        // Ghi lại Health Connect
        await _service.writeStepsToHealthConnect(steps);
        hasHealthData = true;
      } else {
        steps = 0;
      }
    }

    selectedDate = date;
    setLoading(false);
    _calculateMetrics();
    notifyListeners();
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
    _service.stopPedometer();
    super.dispose();
  }
}
