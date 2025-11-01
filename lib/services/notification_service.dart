import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Call once at app startup
  static Future<void> initialize() async {
    try {
      print('🔔 Initializing timezone data...');

      // Initialize timezone data
      tzdata.initializeTimeZones();

      // Set local location dengan fallback
      try {
        // Coba gunakan timezone system
        final String timeZoneName = DateTime.now().timeZoneName;
        print('🌍 System timezone: $timeZoneName');

        // Fallback ke Asia/Jakarta jika timezone tidak dikenali
        if (timeZoneName == 'WIB' ||
            timeZoneName == 'WITA' ||
            timeZoneName == 'WIT') {
          print('⚠️ Indonesian timezone detected, using Asia/Jakarta');
          tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
        } else {
          try {
            tz.setLocalLocation(tz.getLocation(timeZoneName));
          } catch (e) {
            print('⚠️ Unknown timezone "$timeZoneName", defaulting to UTC');
            tz.setLocalLocation(tz.getLocation('UTC'));
          }
        }
      } catch (e) {
        print('⚠️ Error setting local timezone: $e, using UTC');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      print('✅ Timezone initialized successfully');

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) async {
          // handle notification tapped logic here, if needed
        },
      );

      print('✅ NotificationService initialized successfully');
    } catch (e) {
      print('❌ NotificationService initialization error: $e');
      rethrow;
    }
  }

  // Request permission (Android 13+ and iOS)
  static Future<bool> requestPermission() async {
    try {
      final platform = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (platform != null) {
        final granted = await platform.requestNotificationsPermission();
        return granted ?? true;
      }
    } catch (e) {
      print('⚠️ Permission request error: $e');
    }
    return true;
  }

  // Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'general_channel',
        'General Notifications',
        channelDescription: 'Channel default untuk notifikasi aplikasi',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      final details = NotificationDetails(android: androidDetails);

      await _plugin.show(id, title, body, details);
      print('✅ Notification shown: $title');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  // Schedule a one-off inactivity reminder after [duration]
  static Future<void> scheduleInactivityReminder({Duration? after}) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final when = now.add(after ?? Duration(hours: 24));

      print('📅 Scheduling notification for: $when');

      const androidDetails = AndroidNotificationDetails(
        'inactivity_channel',
        'Inactivity reminders',
        channelDescription: 'Reminders when user is inactive',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );

      final details = NotificationDetails(android: androidDetails);

      await _plugin.zonedSchedule(
        1000,
        'We miss you!',
        'It seems you haven\'t opened the app recently — come back and explore.',
        when,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('✅ Inactivity reminder scheduled');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
      print('✅ Notification $id cancelled');
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }
}
