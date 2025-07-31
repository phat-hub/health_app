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

    await _service.initializeCamera();
    await _service.startFlash();

    final stream = _service.measureBPM((hasFinger) {
      fingerOnCamera = hasFinger;
      if (!hasFinger) {
        progress = 0; // reset tiến độ
      }
      notifyListeners();
    });

    stream.listen((value) {
      bpm = value;
      notifyListeners();
    }, onDone: () {
      stopMeasurement();
    });

    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (fingerOnCamera) {
        progress = ((i + 1) / 10 * 100).toInt();
      } else {
        progress = 0; // reset nếu mất ngón tay
      }
      notifyListeners();
    }
  }

  void stopMeasurement() {
    isMeasuring = false;
    _service.stopFlash();
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
