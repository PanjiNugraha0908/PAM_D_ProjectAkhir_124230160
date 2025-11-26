import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      print("🔧 NotificationService: Menginisialisasi...");

      tzdata.initializeTimeZones();
      print("✅ Timezone data initialized");

      try {
        final String timeZoneName = DateTime.now().timeZoneName;
        print("🌍 Timezone sistem: $timeZoneName");

        if (timeZoneName == 'WIB' ||
            timeZoneName == 'WITA' ||
            timeZoneName == 'WIT') {
          print("🇮🇩 Indonesian timezone detected, using Asia/Jakarta");
          tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
        } else {
          try {
            tz.setLocalLocation(tz.getLocation(timeZoneName));
            print("✅ Timezone set to: $timeZoneName");
          } catch (e) {
            print("⚠️ Unknown timezone, using UTC");
            tz.setLocalLocation(tz.getLocation('UTC'));
          }
        }
      } catch (e) {
        print("⚠️ Error setting timezone: $e");
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) async {
          print("🔔 Notifikasi diketuk: ${response.payload}");
        },
      );

      print("✅ NotificationService initialized successfully");
    } catch (e) {
      print("❌ NotificationService initialization error: $e");
      rethrow;
    }
  }

  static Future<bool> requestPermission() async {
    try {
      // --- PERBAIKAN DI SINI (Menambahkan '<') ---
      final platform = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      // ---------------------------------------------

      if (platform != null) {
        final granted = await platform.requestNotificationsPermission();
        print("🔐 Permission request result: ${granted ?? true}");
        return granted ?? true;
      }
    } catch (e) {
      print("⚠️ Permission request error: $e");
    }
    return true;
  }

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
      print("✅ Notifikasi ditampilkan: $title");
    } catch (e) {
      print("❌ Error showing notification: $e");
    }
  }

  static Future<void> scheduleInactivityReminder({
    Duration? after,
    required String username,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final when = now.add(after ?? Duration(hours: 24));

      print("⏰ === SCHEDULING NOTIFICATION ===");
      print("👤 Username: $username");
      print("📅 Current time: ${now.toString()}");
      print("🔔 Scheduled for: ${when.toString()}");
      print("⏱️ Duration: ${after ?? Duration(hours: 24)}");

      const androidDetails = AndroidNotificationDetails(
        'inactivity_channel',
        'Inactivity reminders',
        channelDescription: 'Pengingat jika pengguna tidak aktif',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
      );

      final details = NotificationDetails(android: androidDetails);

      final String notificationBody =
          'Hai $username, masih banyak negara menarik untuk kamu jelajahi! ✈️🌍';

      await _plugin.zonedSchedule(
        1000,
        'Kami merindukanmu!',
        notificationBody,
        when,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      // Verifikasi penjadwalan
      final pendingNotifications = await _plugin.pendingNotificationRequests();
      print("📋 Pending notifications: ${pendingNotifications.length}");
      for (var notif in pendingNotifications) {
        print("   - ID: ${notif.id}, Title: ${notif.title}");
      }

      print("✅ Notifikasi berhasil dijadwalkan!");
    } catch (e) {
      print("❌ Error scheduling notification: $e");
      print("Stack trace: ${StackTrace.current}");
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
      print("🚫 Notifikasi $id dibatalkan");
    } catch (e) {
      print("❌ Error cancelling notification: $e");
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
      print("🚫 Semua notifikasi dibatalkan");
    } catch (e) {
      print("❌ Error cancelling all notifications: $e");
    }
  }

  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }
}
