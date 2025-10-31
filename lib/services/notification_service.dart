import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Call once at app startup
  static Future<void> initialize() async {
    // initialize timezone data
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));

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
  }

  // Request permission (Android 13+ and iOS)
  static Future<bool> requestPermission() async {
    try {
      final platform = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (platform != null) {
        // --- INI YANG DIUBAH ---
        final granted = await platform.requestNotificationsPermission();
        // ---------------------
        return granted ?? true;
      }
    } catch (_) {}
    return true;
  }

  // --- METODE BARU UNTUK MENAMPILKAN NOTIFIKASI SEGERA ---
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // Tentukan detail notifikasi (Anda bisa membuat channel baru)
    const androidDetails = AndroidNotificationDetails(
      'general_channel', // ID channel
      'General Notifications', // Nama channel
      channelDescription: 'Channel default untuk notifikasi aplikasi',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher', // Gunakan ikon yang sama dengan inisialisasi
    );

    final details = NotificationDetails(android: androidDetails);

    // Panggil metode .show() dari plugin
    await _plugin.show(id, title, body, details);
  }
  // --- AKHIR DARI METODE BARU ---

  // Schedule a one-off inactivity reminder after [duration]
  // Default: 24 hours
  static Future<void> scheduleInactivityReminder({Duration? after}) async {
    final when = tz.TZDateTime.now(tz.local).add(after ?? Duration(hours: 24));

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
      1000, // id
      'We miss you!',
      'It seems you haven\'t opened the app recently — come back and explore.',
      when,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: null,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
