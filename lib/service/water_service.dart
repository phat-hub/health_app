import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';

import '../screen.dart';

class WaterService {
  static const String firstOpenKey = 'water_first_open_date';

  String _getHistoryKey(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return 'water_history_${year}-${month}-${day}';
  }

  Future<List<WaterRecord>> getDrinkHistory(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_getHistoryKey(date));

    if (data != null) {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        // Nếu là dữ liệu cũ dạng int
        if (decoded.isNotEmpty && decoded.first is int) {
          return decoded
              .map((e) => WaterRecord(amount: e, time: date))
              .toList();
        }
        // Nếu là dữ liệu mới dạng map
        return decoded
            .map((e) => WaterRecord.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
    return [];
  }

  Future<void> saveDrinkHistory(
      DateTime date, List<WaterRecord> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((e) => e.toJson()).toList();
    await prefs.setString(_getHistoryKey(date), jsonEncode(jsonList));
  }

  /// Ngày mở app lần đầu
  Future<void> saveFirstOpenDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(firstOpenKey)) {
      await prefs.setString(firstOpenKey, date.toIso8601String());
    }
  }

  Future<DateTime> getFirstOpenDate() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(firstOpenKey)) {
      return DateTime.parse(prefs.getString(firstOpenKey)!);
    }
    return DateTime.now();
  }

  /// Xóa dữ liệu cũ hơn
  Future<void> deleteOldData(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final keys = prefs.getKeys();

    for (var key in keys) {
      if (key.startsWith('water_history_') && key != firstOpenKey) {
        try {
          final dateStr = key.replaceFirst('water_history_', '');
          final parts = dateStr.split('-');
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          if (now.difference(date).inDays > days) {
            await prefs.remove(key);
          }
        } catch (_) {}
      }
    }
  }

  Future<Map<DateTime, int>> getWaterStatsLast30Days(
      DateTime firstOpenDate) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    int daysDiff = now.difference(firstOpenDate).inDays + 1;
    int daysToFetch = daysDiff > 30 ? 30 : daysDiff;

    Map<DateTime, int> stats = {};

    for (int i = 0; i < daysToFetch; i++) {
      final date = now.subtract(Duration(days: i));
      final data = prefs.getString(_getHistoryKey(date));
      int total = 0;

      if (data != null) {
        final decoded = jsonDecode(data);
        if (decoded is List) {
          if (decoded.isNotEmpty && decoded.first is int) {
            total = decoded.fold(0, (sum, e) => sum + e as int);
          } else {
            total = decoded.fold(
                0,
                (sum, e) =>
                    sum +
                    WaterRecord.fromJson(Map<String, dynamic>.from(e)).amount);
          }
        }
      }
      stats[DateTime(date.year, date.month, date.day)] = total;
    }

    final sortedKeys = stats.keys.toList()..sort();
    Map<DateTime, int> sortedStats = {
      for (var key in sortedKeys) key: stats[key]!,
    };

    return sortedStats;
  }

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _prefsKey = 'water_reminders';

  Future<void> initNotifications() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
    await requestNotificationPermission();
    await await requestExactAlarmPermission();
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<List<ReminderTime>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => ReminderTime.fromJson(e)).toList();
  }

  Future<void> saveReminders(List<ReminderTime> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(reminders.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, jsonStr);
  }

  Future<void> scheduleAllReminders() async {
    await _notifications.cancelAll();
    final reminders = await getReminders();
    for (int i = 0; i < reminders.length; i++) {
      final r = reminders[i];
      if (r.enabled) {
        await _scheduleReminder(r, i);
      }
    }
  }

  Future<void> _scheduleReminder(ReminderTime reminder, int id) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
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
      id,
      '💧 Uống nước ngay nào!',
      'Đã đến giờ uống nước để giữ sức khỏe 💙',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_channel',
          'Nhắc nhở uống nước',
          channelDescription: 'Thông báo nhắc nhở uống nước trong ngày',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
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
}
