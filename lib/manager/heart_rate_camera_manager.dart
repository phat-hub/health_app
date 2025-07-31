import 'package:flutter/material.dart';
import '../service/heart_rate_camera_service.dart';

class HeartRateCameraManager extends ChangeNotifier {
  final HeartRateCameraService _service = HeartRateCameraService();

  int? bpm;
  bool isMeasuring = false;
  int progress = 0;
  bool fingerOnCamera = false;

  Future<void> startMeasurement() async {
    bpm = null;
    progress = 0;
    isMeasuring = true;
    fingerOnCamera = false;
    notifyListeners();

    // Reset dữ liệu đo trong service
    await _service.resetMeasurementData();

    await _service.initializeCamera();
    await _service.turnOnFlash();

    final stream = _service.measureBPM((hasFinger) {
      fingerOnCamera = hasFinger;
      if (!hasFinger) {
        progress = 0; // Reset thanh tiến trình nếu mất tay
      }
      notifyListeners();
    });

    _updateProgressWhileMeasuring();

    stream.listen((value) {
      bpm = value > 0 ? value : null;
      isMeasuring = false;
      notifyListeners();
    });
  }

  Future<void> _updateProgressWhileMeasuring() async {
    progress = 0;
    int seconds = 0;
    while (isMeasuring && seconds < 10) {
      await Future.delayed(const Duration(seconds: 1));
      if (fingerOnCamera) {
        seconds++;
        progress = ((seconds / 10) * 100).toInt();
      } else {
        seconds = 0;
        progress = 0;
      }
      notifyListeners();
    }
  }

  void stopMeasurement() {
    isMeasuring = false;
    _service.stopMeasurement();
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
