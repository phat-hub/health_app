import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:convert';

import '../screen.dart';

class SleepService {
  final Health _health = Health();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const _sleepReminderKey = 'sleepReminder';

  Future<SleepRecord?> getSleepDataForDate(DateTime date) async {
    await Permission.activityRecognition.request();
    await _health.configure();

    final types = [
      HealthDataType.SLEEP_SESSION,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_AWAKE,
    ];
    final permissions = List.filled(types.length, HealthDataAccess.READ);

    bool authorized =
        await _health.requestAuthorization(types, permissions: permissions);
    if (!authorized) return null;

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final data = await _health.getHealthDataFromTypes(
      types: types,
      startTime: start,
      endTime: end,
    );

    Duration total = Duration.zero;
    Duration light = Duration.zero;
    Duration deep = Duration.zero;
    Duration rem = Duration.zero;
    int awakeCount = 0;
    DateTime? bedTime;
    DateTime? wakeTime;

    for (var d in data) {
      final duration = d.dateTo.difference(d.dateFrom);

      if (d.type == HealthDataType.SLEEP_SESSION) {
        total += duration;
        bedTime ??= d.dateFrom;
        wakeTime = d.dateTo;
      } else if (d.type == HealthDataType.SLEEP_LIGHT) {
        light += duration;
      } else if (d.type == HealthDataType.SLEEP_DEEP) {
        deep += duration;
      } else if (d.type == HealthDataType.SLEEP_REM) {
        rem += duration;
      } else if (d.type == HealthDataType.SLEEP_AWAKE) {
        awakeCount++;
      }
    }

    return SleepRecord(
      total: total,
      light: light,
      deep: deep,
      rem: rem,
      awakeCount: awakeCount,
      bedTime: bedTime,
      wakeTime: wakeTime,
    );
  }

  Future<void> initNotifications() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
    await requestNotificationPermission();
  }

  Future<ReminderTime?> getReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_sleepReminderKey);
    if (jsonStr == null) return null;
    return ReminderTime.fromJson(json.decode(jsonStr));
  }

  Future<void> setReminder(ReminderTime reminder) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sleepReminderKey, json.encode(reminder.toJson()));

    if (reminder.enabled) {
      bool granted = await requestExactAlarmPermission();
      if (!granted) {
        debugPrint("⚠ Quyền exact alarm chưa được bật → không thể đặt lịch.");
        return;
      }
      await scheduleReminder(reminder);
      await showTestNotification();
    } else {
      await cancelReminder();
    }
  }

  Future<void> scheduleReminder(ReminderTime reminder) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminder.hour,
      reminder.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      0,
      'Đã tới giờ đi ngủ',
      'Hãy chuẩn bị đi ngủ để có giấc ngủ ngon!',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sleep_channel',
          'Nhắc nhở đi ngủ',
          channelDescription: 'Thông báo nhắc nhở giờ đi ngủ mỗi ngày',
          importance: Importance.max,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder() async {
    await _notifications.cancelAll();
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<bool> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 31) {
        if (!await Permission.scheduleExactAlarm.isGranted) {
          try {
            final intent = AndroidIntent(
              action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
              package: 'com.example.health_app',
            );
            await intent.launch();
          } catch (e) {
            debugPrint("Không thể mở trang quyền exact alarm: $e");
          }
          return false;
        }
      }
    }
    return true;
  }

  Future<void> showTestNotification() async {
    await _notifications.show(
      999, // ID khác để không đè thông báo khác
      '📢 Test nhắc nhở ngủ',
      'Thông báo test này hiển thị ngay lập tức',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Kênh Test',
          importance: Importance.max,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
        ),
      ),
    );

    debugPrint("🛑 Test notification đã gửi ngay lập tức");
  }

  Future<Map<DateTime, SleepRecord>> getSleepDataInRange(
      DateTime start, DateTime end) async {
    await Permission.activityRecognition.request();
    await _health.configure();

    final types = [
      HealthDataType.SLEEP_SESSION,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_AWAKE,
    ];
    final permissions = List.filled(types.length, HealthDataAccess.READ);

    bool authorized =
        await _health.requestAuthorization(types, permissions: permissions);
    if (!authorized) return {};

    final data = await _health.getHealthDataFromTypes(
      types: types,
      startTime: start,
      endTime: end.add(const Duration(days: 1)),
    );

    // Gom dữ liệu theo từng ngày
    Map<DateTime, SleepRecord> result = {};

    for (var d in data) {
      final dayKey =
          DateTime(d.dateFrom.year, d.dateFrom.month, d.dateFrom.day);

      Duration total = Duration.zero;
      Duration light = Duration.zero;
      Duration deep = Duration.zero;
      Duration rem = Duration.zero;
      int awakeCount = 0;
      DateTime? bedTime;
      DateTime? wakeTime;

      if (result.containsKey(dayKey)) {
        // lấy bản ghi cũ nếu đã tồn tại
        final existing = result[dayKey]!;
        total = existing.total;
        light = existing.light;
        deep = existing.deep;
        rem = existing.rem;
        awakeCount = existing.awakeCount;
        bedTime = existing.bedTime;
        wakeTime = existing.wakeTime;
      }

      final duration = d.dateTo.difference(d.dateFrom);

      if (d.type == HealthDataType.SLEEP_SESSION) {
        total += duration;
        bedTime ??= d.dateFrom;
        wakeTime = d.dateTo;
      } else if (d.type == HealthDataType.SLEEP_LIGHT) {
        light += duration;
      } else if (d.type == HealthDataType.SLEEP_DEEP) {
        deep += duration;
      } else if (d.type == HealthDataType.SLEEP_REM) {
        rem += duration;
      } else if (d.type == HealthDataType.SLEEP_AWAKE) {
        awakeCount++;
      }

      result[dayKey] = SleepRecord(
        total: total,
        light: light,
        deep: deep,
        rem: rem,
        awakeCount: awakeCount,
        bedTime: bedTime,
        wakeTime: wakeTime,
      );
    }

    return result;
  }
}
