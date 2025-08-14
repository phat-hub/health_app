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

  SleepService() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  }

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

  /// Lấy reminder từ SharedPreferences
  Future<ReminderTime?> getReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_sleepReminderKey);
    if (jsonStr == null) return null;
    return ReminderTime.fromJson(json.decode(jsonStr));
  }

  /// Lưu reminder và đặt/cancel thông báo
  Future<void> setReminder(ReminderTime reminder) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sleepReminderKey, json.encode(reminder.toJson()));

    if (reminder.enabled) {
      bool granted = await requestExactAlarmPermission();
      if (!granted) {
        debugPrint("⚠ Quyền exact alarm chưa bật → cần bật rồi vào lại app.");
        return;
      }
      await requestNotificationPermission();
      await scheduleReminder(reminder);
    } else {
      await cancelReminder();
    }
  }

  /// Đặt thông báo nhắc nhở đi ngủ
  Future<void> scheduleReminder(ReminderTime reminder) async {
    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      reminder.hour,
      reminder.minute,
    );

    // Nếu thời gian đã qua, cộng sang ngày hôm sau
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      0,
      "Nhắc nhở đi ngủ",
      "Đã đến giờ đi ngủ rồi!",
      tz.TZDateTime.from(scheduled, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sleep_channel_id',
          'Sleep Reminders',
          channelDescription: 'Nhắc bạn đi ngủ đúng giờ',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          ticker: 'ticker',
        ),
      ),
      androidAllowWhileIdle: true, // chạy khi device idle
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // lặp lại hàng ngày
    );

    debugPrint("✅ Đã đặt nhắc nhở lúc: $scheduled");
  }

  /// Hủy tất cả thông báo nhắc nhở
  Future<void> cancelReminder() async {
    await _notifications.cancelAll();
  }

  /// Yêu cầu quyền exact alarm trên Android 12+
  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt < 31) return true;

    if (await Permission.scheduleExactAlarm.isGranted) return true;

    try {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();
      // Chờ vài giây và check lại quyền
      await Future.delayed(const Duration(seconds: 2));
      return await Permission.scheduleExactAlarm.isGranted;
    } catch (e) {
      debugPrint("Không thể mở trang quyền exact alarm: $e");
      return false;
    }
  }

  /// Khởi tạo notification plugin
  Future<void> initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);

    // 🔹 Tạo channel cho Android 8+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'sleep_channel_id', // phải trùng với khi schedule
      'Sleep Reminders',
      description: 'Nhắc bạn đi ngủ đúng giờ',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await requestNotificationPermission();
  }

  /// Yêu cầu quyền thông báo
  Future<void> requestNotificationPermission() async {
    _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
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
