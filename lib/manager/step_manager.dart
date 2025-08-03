import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screen.dart';

class StepManager extends ChangeNotifier {
  final StepService _service = StepService();

  bool _isLoading = false;
  bool hasHealthData = false;
  int steps = 0;
  int goal = 6000; // mặc định
  double calories = 0;
  double distance = 0;
  Duration activeTime = Duration.zero;

  DateTime selectedDate = DateTime.now();
  Timer? _pollingTimer;

  StepManager() {
    _loadGoalFromPrefs(); // <-- đọc goal ngay khi tạo object
  }

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> initSteps() async {
    await loadStepsForDate(selectedDate);

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
    await prefs.setInt('daily_goal', goal); // lưu lại
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
    distance = steps * 0.7;
    calories = steps * 0.035;
    activeTime = Duration(minutes: (steps / 100).round());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
