import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 Notification tapped: ${response.payload}');
      },
    );

    // Create notification channels
    await _createNotificationChannels();

    // Request permissions for Android 13+
    await _requestNotificationPermissions();
  }

  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel prayerChannel = AndroidNotificationChannel(
      'prayer_channel',
      'Prayer Time Notifications',
      description: 'Notifies before prayer times',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    const AndroidNotificationChannel duaChannel = AndroidNotificationChannel(
      'daily_dua_channel',
      'Daily Dua Notifications',
      description: 'Random duas throughout the day',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(prayerChannel);
      await androidPlugin.createNotificationChannel(duaChannel);
    }
  }

  static Future<void> _requestNotificationPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImpl =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImpl != null) {
      // Request notification permission
      final bool permissionGranted =
          await androidImpl.requestNotificationsPermission() ?? false;
      debugPrint('🔔 Notification permission granted: $permissionGranted');

      // Request exact alarm permission for Android 12+
      final bool exactAlarmPermission =
          await androidImpl.requestExactAlarmsPermission() ?? false;
      debugPrint('⏰ Exact alarm permission granted: $exactAlarmPermission');
    }
  }

  static Future<void> schedulePrayerNotifications(
    Map<String, DateTime> prayerTimes,
  ) async {
    if (!await _checkPermissions()) {
      debugPrint('❌ Notification permissions not granted');
      return;
    }

    await cancelPrayerNotifications();
    int id = 101;

    for (var entry in prayerTimes.entries) {
      final name = entry.key;
      final time = entry.value;
      final notificationTime = time.subtract(const Duration(minutes: 10));

      // Create TZDateTime properly
      final tzTime = tz.TZDateTime.from(notificationTime, tz.local);

      // Skip if time has already passed
      if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) {
        // Schedule for next day
        final nextDay = tzTime.add(const Duration(days: 1));
        await _scheduleNotification(id++, name, nextDay);
      } else {
        await _scheduleNotification(id++, name, tzTime);
      }
    }

    debugPrint('✅ Prayer notifications scheduled successfully');
  }

  static Future<void> _scheduleNotification(
    int id,
    String prayerName,
    tz.TZDateTime scheduledTime,
  ) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      '🕌 ${prayerName.toUpperCase()} Prayer',
      '10 minutes left for ${prayerName.toUpperCase()} prayer',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Prayer Time Notifications',
          channelDescription: 'Notifies before prayer times',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.green,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleDailyDuas() async {
    if (!await _checkPermissions()) {
      debugPrint('❌ Notification permissions not granted for duas');
      return;
    }

    await cancelDuaNotifications();

    try {
      final times = [7, 12, 15]; // 7 AM, 12 PM, 3 PM
      final now = tz.TZDateTime.now(tz.local);

      final jsonString = await rootBundle.loadString(
        'assets/json/daily_duas.json',
      );
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      final allDuas =
          data.values
              .expand((e) => List<Map<String, dynamic>>.from(e))
              .toList();

      if (allDuas.isEmpty) {
        debugPrint('❌ No duas found in JSON file');
        return;
      }

      for (int i = 0; i < times.length; i++) {
        final dua = allDuas[Random().nextInt(allDuas.length)];

        var scheduledTime = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          times[i],
        );

        // If time has passed for today, schedule for tomorrow
        if (scheduledTime.isBefore(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }

        await _notificationsPlugin.zonedSchedule(
          200 + i,
          '📿 Daily Dua',
          dua['title'] ?? 'Dua Reminder',
          scheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_dua_channel',
              'Daily Dua Notifications',
              channelDescription: 'Random duas throughout the day',
              importance: Importance.high,
              priority: Priority.high,
              color: Colors.blue,
              enableVibration: true,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

          matchDateTimeComponents: DateTimeComponents.time,
        );
      }

      debugPrint('✅ Daily duas scheduled successfully');
    } catch (e) {
      debugPrint('❌ Error scheduling daily duas: $e');
    }
  }

  static Future<void> cancelPrayerNotifications() async {
    for (int i = 101; i <= 105; i++) {
      await _notificationsPlugin.cancel(i);
    }
    debugPrint('🗑️ Prayer notifications cancelled');
  }

  static Future<void> cancelDuaNotifications() async {
    for (int i = 200; i <= 202; i++) {
      await _notificationsPlugin.cancel(i);
    }
    debugPrint('🗑️ Dua notifications cancelled');
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('🗑️ All notifications cancelled');
  }

  static Future<bool> _checkPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImpl =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImpl != null) {
      final bool notificationEnabled =
          await androidImpl.areNotificationsEnabled() ?? false;
      final bool exactAlarmPermission =
          await androidImpl.canScheduleExactNotifications() ?? false;

      debugPrint('📱 Notification enabled: $notificationEnabled');
      debugPrint('⏰ Exact alarm permission: $exactAlarmPermission');

      return notificationEnabled && exactAlarmPermission;
    }

    return false;
  }

  // Get pending notifications for debugging
  static Future<void> getPendingNotifications() async {
    final List<PendingNotificationRequest> pending =
        await _notificationsPlugin.pendingNotificationRequests();

    debugPrint('📋 Pending notifications: ${pending.length}');
    for (var notification in pending) {
      debugPrint('   - ID: ${notification.id}, Title: ${notification.title}');
    }
  }
}
