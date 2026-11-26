import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Kontrak service notifikasi aplikasi.
abstract class NotificationService {
  Future<void> init();
  Future<bool> requestPermission();
  Future<bool> areNotificationsEnabled();
  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
    String? payload,
  });
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  });
  Future<void> cancel(int id);
  Future<void> cancelDailyReminder();
}

/// Implementasi notifikasi lokal menggunakan package `flutter_local_notifications`.
class LocalNotificationService implements NotificationService {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const dailyReminderId = 1001;
  static const _channelId = 'worthbang_notifications';
  static const _channelName = 'Notifikasi WorthBang';
  static const _channelDesc = 'Notifikasi langsung dan pengingat harian WorthBang.';

  @override
  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      } catch (_) {
        // Fallback ke UTC jika nama zona waktu tidak ditemukan
      }
    }

    const androidSettings = AndroidInitializationSettings('ic_notification');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: initSettings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidPlugin?.requestNotificationsPermission();
    return granted ?? false;
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final enabled = await androidPlugin?.areNotificationsEnabled();
    return enabled ?? false;
  }

  @override
  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      payload: payload,
      notificationDetails: _details(),
    );
  }

  @override
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(id: dailyReminderId);
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_notification',
        largeIcon: DrawableResourceAndroidBitmap('ic_notification_large'),
        color: Color(0xFF161B22),
      ),
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

/// Implementasi in-memory untuk testing (tanpa memanggil native platform).
class FakeNotificationService implements NotificationService {
  final List<Map<String, dynamic>> immediateHistory = [];
  Map<String, dynamic>? scheduledReminder;
  bool permissionGranted = true;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<bool> areNotificationsEnabled() async => permissionGranted;

  @override
  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    immediateHistory.add({
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
    });
  }

  @override
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    scheduledReminder = {
      'id': id,
      'title': title,
      'body': body,
      'hour': hour,
      'minute': minute,
    };
  }

  @override
  Future<void> cancel(int id) async {
    immediateHistory.removeWhere((item) => item['id'] == id);
  }

  @override
  Future<void> cancelDailyReminder() async {
    scheduledReminder = null;
  }
}
