import 'package:camera/camera.dart';
import 'dart:async';

class HeartRateCameraService {
  CameraController? _cameraController;
  bool _isMeasuring = false;

  final int _sampleSeconds = 20; // 🔹 Đo 20 giây thay vì 10 giây
  final _redData = <double>[];

  final double _brightnessThreshold = 100; // Ngưỡng phát hiện tối ưu hơn
  final double _redThreshold = 140;

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

  double _extractAverageRed(CameraImage image) {
    final yBuffer = image.planes[0].bytes;
    final uBuffer = image.planes[1].bytes;
    final vBuffer = image.planes[2].bytes;

    int width = image.width;
    int height = image.height;
    int uvRowStride = image.planes[1].bytesPerRow;
    int uvPixelStride = image.planes[1].bytesPerPixel ?? 2;

    double totalRed = 0;
    int count = 0;

    for (int y = 0; y < height; y += 4) {
      for (int x = 0; x < width; x += 4) {
        int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
        int yIndex = y * image.planes[0].bytesPerRow + x;

        int Y = yBuffer[yIndex];
        int U = uBuffer[uvIndex];
        int V = vBuffer[uvIndex];

        // Công thức chuyển YUV -> Red
        double R = (Y + 1.402 * (V - 128)).clamp(0, 255).toDouble();
        totalRed += R;
        count++;
      }
    }

    return count > 0 ? totalRed / count : 0;
  }

  List<double> _smoothSignal(List<double> data, int window) {
    List<double> smooth = [];
    for (int i = 0; i < data.length; i++) {
      double sum = 0;
      int count = 0;
      for (int j = i - window; j <= i + window; j++) {
        if (j >= 0 && j < data.length) {
          sum += data[j];
          count++;
        }
      }
      smooth.add(sum / count);
    }
    return smooth;
  }

  int _calculateBPM(List<double> data) {
    if (data.isEmpty) return 0;

    final smooth = _smoothSignal(data, 5);
    final peaks = <int>[];

    for (int i = 1; i < smooth.length - 1; i++) {
      if (smooth[i] > smooth[i - 1] && smooth[i] > smooth[i + 1]) {
        if (peaks.isEmpty || (i - peaks.last) > 3) {
          // Loại đỉnh quá gần
          peaks.add(i);
        }
      }
    }

    return ((peaks.length / _sampleSeconds) * 60).round();
  }

  Future<void> resetMeasurementData() async {
    _redData.clear();
    _isMeasuring = false;
  }

  Stream<int> measureBPM(Function(bool) onFingerDetected) async* {
    _redData.clear();
    _isMeasuring = true;

    final completer = Completer<int>();
    await turnOnFlash();

    int validSeconds = 0;
    int lastSecond = DateTime.now().second;

    await _cameraController?.startImageStream((CameraImage image) {
      if (!_isMeasuring) return;

      final hasFinger = _isFingerOn(image);
      onFingerDetected(hasFinger);

      if (!hasFinger) {
        validSeconds = 0;
        _redData.clear();
        return;
      }

      final redValue = _extractAverageRed(image);
      _redData.add(redValue);

      if (DateTime.now().second != lastSecond) {
        lastSecond = DateTime.now().second;
        validSeconds++;
      }

      if (validSeconds >= _sampleSeconds) {
        _cameraController?.stopImageStream();
        int bpm = _calculateBPM(_redData);
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
    await turnOffFlash();
  }
}
