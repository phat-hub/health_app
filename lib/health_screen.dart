import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({Key? key}) : super(key: key);

  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final Health health = Health();
  int? steps;
  double? heartRate;
  Duration? sleepDuration;

  @override
  void initState() {
    super.initState();
    initHealth();
  }

  Future<void> initHealth() async {
    await Permission.activityRecognition.request();

    await health.configure();

    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.SLEEP_SESSION,
    ];

    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    bool authorized =
        await health.requestAuthorization(types, permissions: permissions);
    if (!authorized) return;

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    int totalSteps = 0;

    final data = await health.getHealthDataFromTypes(
      types: types,
      startTime: yesterday,
      endTime: now,
    );

    for (var d in data) {
      print(
          "Type: ${d.type}, Value: ${d.value}, Unit: ${d.unit}, Time: ${d.dateFrom}");
    }

    double? latestHeartRate;
    DateTime? latestHrTime;
    Duration totalSleep = Duration.zero;

    for (var d in data) {
      if (d.type == HealthDataType.HEART_RATE &&
          d.value is NumericHealthValue) {
        final hrValue = d.value as NumericHealthValue;
        if (latestHrTime == null || d.dateFrom.isAfter(latestHrTime)) {
          latestHeartRate = hrValue.numericValue.toDouble();
          latestHrTime = d.dateFrom;
        }
      }

      if (d.type == HealthDataType.SLEEP_SESSION) {
        final sleepSegment = d.dateTo.difference(d.dateFrom);
        totalSleep += sleepSegment;
      }

      if (d.type == HealthDataType.STEPS && d.value is NumericHealthValue) {
        totalSteps += (d.value as NumericHealthValue).numericValue.toInt();
      }
    }

    setState(() {
      steps = totalSteps;
      heartRate = latestHeartRate;
      sleepDuration = totalSleep;
    });
  }

  String formatSleep(Duration? duration) {
    if (duration == null || duration.inMinutes == 0) return "Đang tải...";
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return "$hours giờ $minutes phút";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sức khỏe hôm nay")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            HealthTile(
              label: "Số bước",
              value: steps?.toString() ?? "Đang tải...",
            ),
            const SizedBox(height: 16),
            HealthTile(
              label: "Nhịp tim",
              value: heartRate != null
                  ? "${heartRate!.toStringAsFixed(1)} bpm"
                  : "Đang tải...",
            ),
            const SizedBox(height: 16),
            HealthTile(
              label: "Giấc ngủ",
              value: formatSleep(sleepDuration),
            ),
          ],
        ),
      ),
    );
  }
}

class HealthTile extends StatelessWidget {
  final String label;
  final String value;

  const HealthTile({required this.label, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Text(value, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
