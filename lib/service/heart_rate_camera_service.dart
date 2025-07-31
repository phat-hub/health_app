import 'package:camera/camera.dart';
import 'dart:async';

class HeartRateCameraService {
  CameraController? _cameraController;
  bool _isMeasuring = false;
  final int _sampleSeconds = 10;

  final _brightnessData = <double>[];
  final double _brightnessThreshold = 80;
  final double _redThreshold = 150;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera =
        cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back);

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();
  }

  Future<void> turnOnFlash() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      await _cameraController!.setFlashMode(FlashMode.torch);
    }
  }

  Future<void> turnOffFlash() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      await _cameraController!.setFlashMode(FlashMode.off);
    }
  }

  Future<void> dispose() async {
    await _cameraController?.dispose();
    _cameraController = null;
  }

  bool _isFingerOn(CameraImage image) {
    final yBytes = image.planes[0].bytes;
    final vBytes = image.planes.length > 2 ? image.planes[2].bytes : [];

    double avgY = 0, avgV = 0;
    for (int i = 0; i < yBytes.length; i += 100) {
      avgY += yBytes[i];
    }
    if (vBytes.isNotEmpty) {
      for (int i = 0; i < vBytes.length; i += 100) {
        avgV += vBytes[i];
      }
    }
    avgY /= (yBytes.length / 100);
    avgV = vBytes.isNotEmpty ? avgV / (vBytes.length / 100) : 0;

    return avgY < _brightnessThreshold && avgV > _redThreshold;
  }

  int _calculateBPM(List<double> data) {
    if (data.isEmpty) return 0;
    List<double> smooth = [];
    for (int i = 1; i < data.length - 1; i++) {
      smooth.add((data[i - 1] + data[i] + data[i + 1]) / 3);
    }
    int peaks = 0;
    for (int i = 1; i < smooth.length - 1; i++) {
      if (smooth[i] > smooth[i - 1] && smooth[i] > smooth[i + 1]) {
        peaks++;
      }
    }
    return ((peaks / _sampleSeconds) * 60).round();
  }

  Future<void> resetMeasurementData() async {
    _brightnessData.clear();
    _isMeasuring = false;
  }

  /// Khi bắt đầu đo → gọi hàm này
  Stream<int> measureBPM(Function(bool) onFingerDetected) async* {
    // Reset dữ liệu mỗi lần bắt đầu đo
    _brightnessData.clear();

    _isMeasuring = true;
    bool fingerDetected = false;
    int stableFrames = 0;
    int noFingerFrames = 0;

    final completer = Completer<int>();

    await turnOnFlash();

    int validSeconds = 0;
    int lastSecond = DateTime.now().second;

    await _cameraController?.startImageStream((CameraImage image) {
      if (!_isMeasuring) return;

      final hasFinger = _isFingerOn(image);
      onFingerDetected(hasFinger);

      if (!hasFinger) {
        validSeconds = 0; // Reset nếu mất tay
        _brightnessData.clear();
        return;
      }

      // Lấy độ sáng
      final yBytes = image.planes[0].bytes;
      double avgY = 0;
      for (int i = 0; i < yBytes.length; i += 100) {
        avgY += yBytes[i];
      }
      avgY /= (yBytes.length / 100);
      _brightnessData.add(avgY);

      // Tăng thời gian hợp lệ
      if (DateTime.now().second != lastSecond) {
        lastSecond = DateTime.now().second;
        validSeconds++;
      }

      // Nếu đã đủ 10 giây hợp lệ
      if (validSeconds >= _sampleSeconds) {
        _cameraController?.stopImageStream();
        int bpm = _calculateBPM(_brightnessData);
        turnOffFlash();
        completer.complete(bpm);
        _isMeasuring = false;
      }
    });

    final result = await completer.future;
    yield result;
  }

  void stopMeasurement() async {
    _isMeasuring = false;
    await _cameraController?.stopImageStream();
    await turnOffFlash(); // 🔹 Tắt flash khi dừng
  }
}
