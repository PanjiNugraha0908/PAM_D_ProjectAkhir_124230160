import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Kelas helper statis untuk mengelola semua fungsionalitas notifikasi lokal.
///
/// Menggunakan [flutter_local_notifications] untuk menampilkan dan
/// menjadwalkan notifikasi, serta [timezone] untuk penjadwalan yang akurat.
class NotificationService {
  // Constructor privat untuk mencegah instansiasi
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Menginisialisasi service notifikasi dan data timezone.
  ///
  /// Harus dipanggil sekali saat startup aplikasi (misal: di `main.dart`).
  /// Ini juga menangani pengaturan timezone lokal untuk penjadwalan.
  static Future<void> initialize() async {
    try {
      // 1. Inisialisasi data Timezone
      tzdata.initializeTimeZones();

      // 2. Set lokasi/timezone lokal
      try {
        final String timeZoneName = DateTime.now().timeZoneName;

        // Fallback khusus untuk timezone Indonesia (WIB, WITA, WIT)
        // yang mungkin tidak dikenali oleh package 'timezone'
        if (timeZoneName == 'WIB' ||
            timeZoneName == 'WITA' ||
            timeZoneName == 'WIT') {
          print('⚠️ Indonesian timezone detected, using Asia/Jakarta');
          tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
        } else {
          // Coba gunakan timezone dari sistem
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

      // 3. Inisialisasi plugin notifikasi
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) async {
          // Handle logika saat notifikasi diketuk di sini (jika diperlukan)
        },
      );
    } catch (e) {
      print('❌ NotificationService initialization error: $e');
      rethrow;
    }
  }

  /// Meminta izin notifikasi kepada pengguna (diperlukan untuk Android 13+).
  ///
  /// Mengembalikan `true` jika izin diberikan atau tidak diperlukan (Android < 13).
  static Future<bool> requestPermission() async {
    try {
      final platform = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (platform != null) {
        // Meminta izin notifikasi (baru di Android 13)
        final granted = await platform.requestNotificationsPermission();
        return granted ?? true;
      }
    } catch (e) {
      print('⚠️ Permission request error: $e');
    }
    return true; // Asumsikan true jika bukan platform Android
  }

  /// Menampilkan notifikasi instan (langsung).
  ///
  /// Digunakan untuk notifikasi umum, misal: "Anda telah melihat 3 negara baru!".
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'general_channel', // ID Channel
        'General Notifications', // Nama Channel
        channelDescription: 'Channel default untuk notifikasi aplikasi',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      final details = NotificationDetails(android: androidDetails);
      await _plugin.show(id, title, body, details);
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  /// Menjadwalkan notifikasi pengingat inaktivitas satu kali.
  ///
  /// Notifikasi akan dikirim setelah durasi [after] (default 24 jam).
  /// Menggunakan ID notifikasi statis (1000) sehingga penjadwalan
  /// baru akan menimpa (memperbarui) penjadwalan yang lama.
  //
  // --- PERUBAHAN DI SINI ---
  // Menambahkan parameter {required String username}
  static Future<void> scheduleInactivityReminder({
    Duration? after,
    required String username,
  }) async {
    // --- AKHIR PERUBAHAN ---
    try {
      final now = tz.TZDateTime.now(tz.local);
      final when = now.add(after ?? Duration(hours: 24));

      const androidDetails = AndroidNotificationDetails(
        'inactivity_channel', // ID Channel
        'Inactivity reminders', // Nama Channel
        channelDescription: 'Pengingat jika pengguna tidak aktif',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );

      final details = NotificationDetails(android: androidDetails);

      // --- PERUBAHAN DI SINI ---
      // Menggunakan username di dalam body notifikasi
      final String notificationBody =
          'Hai $username, masih banyak negara menarik untuk kamu jelajahi! ✈️🌍';
      // --- AKHIR PERUBAHAN ---

      await _plugin.zonedSchedule(
        1000, // ID notifikasi (statis agar bisa ditimpa/dibatalkan)
        'Kami merindukanmu!',
        notificationBody, // <-- Menggunakan body yang sudah dipersonalisasi
        when,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  /// Membatalkan notifikasi terjadwal berdasarkan [id] uniknya.
  static Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  /// Membatalkan SEMUA notifikasi terjadwal dari aplikasi ini.
  static Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }
}
