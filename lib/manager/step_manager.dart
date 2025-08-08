import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen.dart';

class StepManager extends ChangeNotifier {
  final StepService _service = StepService();

  bool _isLoading = false;
  bool hasHealthData = false;
  int steps = 0;
  int goal = 6000;
  double calories = 0;
  double distance = 0;
  Duration activeTime = Duration.zero;

  DateTime selectedDate = DateTime.now();
  Timer? _pollingTimer;

  List<StepRecord> stepRecords = [];

  StepManager() {
    _loadGoalFromPrefs();
  }

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
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

  Future<void> loadStepsForDate(DateTime date) async {
    int? healthSteps = await _service.getStepsForDate(date);

    if (healthSteps != null) {
      hasHealthData = true;
      steps = healthSteps;
      _calculateMetrics();
    } else {
      hasHealthData = false;
      steps = 0;
    }

    selectedDate = date;
    setLoading(false);
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
