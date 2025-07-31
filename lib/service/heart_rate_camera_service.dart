import 'package:camera/camera.dart';
import 'package:torch_light/torch_light.dart';

class HeartRateCameraService {
  CameraController? _cameraController;
  bool _isMeasuring = false;
  final int _sampleSeconds = 10;

  final _redIntensities = <double>[];
  final double _fingerThreshold =
      80; // Ngưỡng phát hiện ngón tay (thấp hơn là ngón tay che kín)

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back),
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, // đọc kênh sáng
    );
    await _cameraController!.initialize();
  }

  Future<void> startFlash() async {
    try {
      await TorchLight.enableTorch();
    } catch (_) {}
  }

  Future<void> stopFlash() async {
    try {
      await TorchLight.disableTorch();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _cameraController?.dispose();
    await stopFlash();
  }

  /// Kiểm tra xem ngón tay đã che kín camera chưa
  bool _isFingerOn(CameraImage image) {
    final avg = _calculateBrightness(image);
    return avg < _fingerThreshold;
  }

  /// Tính độ sáng trung bình từ kênh Y
  double _calculateBrightness(CameraImage image) {
    final bytes = image.planes[0].bytes;
    double sum = 0;
    for (int i = 0; i < bytes.length; i += 100) {
      sum += bytes[i];
    }
    return sum / (bytes.length / 100);
  }

  /// Tính BPM
  int _calculateBPM(List<double> data) {
    if (data.isEmpty) return 0;

    List<double> smooth = [];
    for (int i = 1; i < data.length - 1; i++) {
      smooth.add((data[i - 1] + data[i] + data[i + 1]) / 3);
    }

    int peakCount = 0;
    for (int i = 1; i < smooth.length - 1; i++) {
      if (smooth[i] > smooth[i - 1] && smooth[i] > smooth[i + 1]) {
        peakCount++;
      }
    }

    double seconds = _sampleSeconds.toDouble();
    return ((peakCount / seconds) * 60).round();
  }

  /// Đo BPM nhưng yêu cầu luôn che kín camera
  Stream<int> measureBPM(Function(bool) onFingerDetected) async* {
    _isMeasuring = true;
    _redIntensities.clear();

    bool fingerDetected = false;
    int stableFrames = 0;

    await _cameraController?.startImageStream((CameraImage image) {
      if (!_isMeasuring) return;

      bool hasFinger = _isFingerOn(image);
      onFingerDetected(hasFinger);

      if (!hasFinger) {
        // Nếu mất ngón tay → reset dữ liệu
        fingerDetected = false;
        stableFrames = 0;
        _redIntensities.clear();
        return;
      }

      if (!fingerDetected) {
        stableFrames++;
        if (stableFrames > 10) {
          fingerDetected = true; // Đã phát hiện ổn định ngón tay
        }
        return;
      }

      final avgBrightness = _calculateBrightness(image);
      _redIntensities.add(avgBrightness);
    });

    await Future.delayed(Duration(seconds: _sampleSeconds));

    await _cameraController?.stopImageStream();

    if (_redIntensities.isEmpty) {
      yield 0;
    } else {
      yield _calculateBPM(_redIntensities);
    }

    _isMeasuring = false;
  }

  void stopMeasurement() {
    _isMeasuring = false;
  }
}
