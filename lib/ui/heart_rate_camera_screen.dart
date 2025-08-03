import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../screen.dart';

class HeartRateCameraScreen extends StatelessWidget {
  const HeartRateCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<HeartRateCameraManager>();

    return WillPopScope(
      onWillPop: () async {
        m.stopMeasurement();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Đo nhịp tim"),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!m.isMeasuring && m.bpm == null)
                  _buildBeforeMeasure(context, m),
                if (m.isMeasuring) _buildDuringMeasure(context, m),
                if (!m.isMeasuring && m.bpm != null)
                  _buildAfterMeasure(context, m),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeforeMeasure(BuildContext context, HeartRateCameraManager m) {
    return Column(
      children: [
        Lottie.asset('assets/animations/heart-beat.json', width: 180),
        const SizedBox(height: 20),
        const Text(
          "Đặt ngón tay che kín camera & flash\nGiữ yên trong quá trình đo",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          ),
          onPressed: () {
            final userId =
                context.read<AuthManager>().userId; // lấy userId đăng nhập
            m.startMeasurement(context, userId: userId);
          },
          child: const Text("Bắt đầu đo"),
        ),
      ],
    );
  }

  Widget _buildDuringMeasure(BuildContext context, HeartRateCameraManager m) {
    return Column(
      children: [
        if (!m.fingerOnCamera) ...[
          const Icon(Icons.touch_app, size: 80, color: Colors.orange),
          const SizedBox(height: 12),
          const Text(
            "Hãy đặt ngón tay che kín camera & flash",
            textAlign: TextAlign.center,
          ),
        ] else ...[
          Lottie.asset('assets/animations/heart-beat.json', width: 180),
          const SizedBox(height: 12),
          const Text("Đang đo..."),
        ],
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: m.progress / 100,
          minHeight: 8,
          backgroundColor: Colors.grey[300],
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 10),
        Text(
          m.fingerOnCamera
              ? "Tiến trình: ${m.progress}% (${(m.progress / 100 * m.totalSeconds).round()}/${m.totalSeconds} giây)"
              : "Chưa phát hiện ngón tay",
        ),
      ],
    );
  }

  Widget _buildAfterMeasure(BuildContext context, HeartRateCameraManager m) {
    String status = "Bình thường";
    Color color = Colors.green;

    if (m.bpm! < 60) {
      status = "Thấp";
      color = Colors.orange;
    } else if (m.bpm! > 100) {
      status = "Cao";
      color = Colors.red;
    }

    return Column(
      children: [
        Icon(Icons.favorite, color: color, size: 100),
        const SizedBox(height: 20),
        Text("${m.bpm} BPM", style: const TextStyle(fontSize: 32)),
        Text(status, style: TextStyle(color: color, fontSize: 18)),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          ),
          onPressed: () {
            final userId = context.read<AuthManager>().userId;
            m.startMeasurement(context, userId: userId);
          },
          child: const Text("Đo lại"),
        ),
      ],
    );
  }
}
