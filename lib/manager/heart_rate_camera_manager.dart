import 'package:flutter/material.dart';
import '../service/heart_rate_camera_service.dart';
import 'package:provider/provider.dart';
import '../manager/heart_rate_manager.dart';
import '../model/heart_rate_record.dart';

class HeartRateCameraManager extends ChangeNotifier {
  final HeartRateCameraService _service = HeartRateCameraService();

  int? bpm;
  bool isMeasuring = false;
  int progress = 0;
  bool fingerOnCamera = false;

  final int totalSeconds = 20;

  Future<void> startMeasurement(BuildContext context, {String? userId}) async {
    bpm = null;
    progress = 0;
    isMeasuring = true;
    fingerOnCamera = false;
    notifyListeners();

    await _service.resetMeasurementData();
    await _service.initializeCamera();
    await _service.turnOnFlash();

    final stream = _service.measureBPM((hasFinger) {
      fingerOnCamera = hasFinger;
      if (!hasFinger) {
        progress = 0;
      }
      notifyListeners();
    });

    _updateProgressWhileMeasuring();

    stream.listen((value) async {
      bpm = value > 0 ? value : null;
      isMeasuring = false;
      notifyListeners();

      if (bpm != null && userId != null) {
        // ✅ Tạo record mới
        final record = HeartRateRecord(date: DateTime.now(), bpm: bpm!);

        // ✅ Lưu vào Firebase + cập nhật local
        final hrManager = Provider.of<HeartRateManager>(context, listen: false);
        hrManager.history.insert(0, record); // thêm vào đầu
        await hrManager.service
            .saveLatestHeartRateToFirebase(userId, bpm!); // lưu vào Firestore
        await hrManager.service.saveHeartRateToHealthConnect(bpm!);
        hrManager.latestHeartRate =
            await hrManager.service.fetchLatestHeartRate();
        hrManager.notifyListeners();
      }
    });
  }

  Future<void> _updateProgressWhileMeasuring() async {
    progress = 0;
    int seconds = 0;
    while (isMeasuring && seconds < totalSeconds) {
      await Future.delayed(const Duration(seconds: 1));
      if (fingerOnCamera) {
        seconds++;
        progress = ((seconds / totalSeconds) * 100).toInt();
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
