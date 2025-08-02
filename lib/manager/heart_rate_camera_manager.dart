import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screen.dart';

class HeartRateCameraManager extends ChangeNotifier {
  final HeartRateCameraService _service = HeartRateCameraService();

  int? bpm;
  bool isMeasuring = false;
  int progress = 0;
  bool fingerOnCamera = false;

  final int totalSeconds = 20;
  DateTime? _fingerStartTime; // 🔹 Thời điểm bắt đầu có ngón tay

  Future<void> startMeasurement(BuildContext context, {String? userId}) async {
    bpm = null;
    progress = 0;
    isMeasuring = true;
    fingerOnCamera = false;
    _fingerStartTime = null;
    notifyListeners();

    await _service.resetMeasurementData();
    await _service.initializeCamera();
    await _service.turnOnFlash();

    final stream = _service.measureBPM((hasFinger) {
      // 🔹 Xử lý ngay khi phát hiện thay đổi
      if (hasFinger) {
        // Nếu trước đó chưa có ngón tay => lưu thời điểm bắt đầu
        _fingerStartTime ??= DateTime.now();
      } else {
        // Mất ngón tay => reset tiến trình ngay lập tức
        _fingerStartTime = null;
        progress = 0;
      }
      fingerOnCamera = hasFinger;
      notifyListeners();
    });

    _updateProgressWhileMeasuring();

    stream.listen((value) async {
      bpm = value > 0 ? value : null;
      isMeasuring = false;
      notifyListeners();

      if (bpm != null && userId != null) {
        final record = HeartRateRecord(date: DateTime.now(), bpm: bpm!);

        final hrManager = Provider.of<HeartRateManager>(context, listen: false);
        hrManager.history.insert(0, record);
        await hrManager.service.saveLatestHeartRateToFirebase(userId, bpm!);
        await hrManager.service.saveHeartRateToHealthConnect(bpm!);
        hrManager.latestHeartRate =
            await hrManager.service.fetchLatestHeartRate();
        hrManager.notifyListeners();
      }
    });
  }

  Future<void> _updateProgressWhileMeasuring() async {
    while (isMeasuring) {
      await Future.delayed(
          const Duration(milliseconds: 200)); // 🔹 Kiểm tra nhanh hơn
      if (_fingerStartTime != null) {
        final elapsed = DateTime.now().difference(_fingerStartTime!).inSeconds;
        progress = ((elapsed / totalSeconds) * 100).clamp(0, 100).toInt();
        if (elapsed >= totalSeconds) break; // đủ thời gian đo
      } else {
        progress = 0;
      }
      notifyListeners();
    }
  }

  void stopMeasurement() {
    isMeasuring = false;
    _service.stopMeasurement();
    _fingerStartTime = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
