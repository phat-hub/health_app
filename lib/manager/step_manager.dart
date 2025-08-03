import 'dart:async';
import 'package:flutter/material.dart';
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

  Timer? _healthPollingTimer;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> initSteps() async {
    setLoading(true);

    // Thử lấy dữ liệu từ Health Connect
    int? healthSteps = await _service.getStepsFromHealthConnect();

    if (healthSteps != null) {
      hasHealthData = true;
      steps = healthSteps;
      _calculateMetrics();
    } else {
      hasHealthData = false;
    }
    notifyListeners();

    // Polling 10s/lần để thử đọc lại
    _healthPollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) async {
        int? updatedSteps = await _service.getStepsFromHealthConnect();
        if (updatedSteps != null) {
          if (!hasHealthData || updatedSteps != steps) {
            hasHealthData = true;
            steps = updatedSteps;
            _calculateMetrics();
            notifyListeners();
          }
        } else {
          if (hasHealthData) {
            hasHealthData = false;
            notifyListeners();
          }
        }
      },
    );

    setLoading(false);
  }

  void updateGoal(int newGoal) {
    goal = newGoal;
    notifyListeners();
  }

  void _calculateMetrics() {
    distance = steps * 0.7;
    calories = steps * 0.035;
    activeTime = Duration(minutes: (steps / 100).round());
  }

  @override
  void dispose() {
    _healthPollingTimer?.cancel();
    super.dispose();
  }
}
