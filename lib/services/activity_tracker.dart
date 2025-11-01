import 'package:hive/hive.dart';
import 'notification_service.dart';

/// Kelas helper statis untuk melacak aktivitas pengguna dan mengelola
/// pengaturan notifikasi pengingat menggunakan Hive (penyimpanan lokal).
///
/// Kelas ini bertanggung jawab untuk:
/// - Menyimpan & mengambil stempel waktu 'terakhir aktif'.
/// - Mengelola flag 'notifikasi diaktifkan'.
/// - Memicu atau membatalkan notifikasi terjadwal (melalui [NotificationService])
///   berdasarkan aktivitas dan pengaturan pengguna.
class ActivityTracker {
  static const String _boxName = 'activity_tracker'; // Nama box Hive
  static const String _lastActiveKey = 'last_active'; // Key untuk stempel waktu
  static const String _notificationEnabledKey =
      'notification_enabled'; // Key untuk flag bool

  static Box? _box;

  /// Menginisialisasi [Box] Hive untuk ActivityTracker.
  ///
  /// Harus dipanggil (biasanya di main.dart) sebelum method lain digunakan.
  /// Jika pengaturan notifikasi belum ada, akan diatur ke `true` secara default.
  static Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);

    // Atur notifikasi ke 'true' secara default jika belum pernah diatur
    if (_box!.get(_notificationEnabledKey) == null) {
      await _box!.put(_notificationEnabledKey, true);
    }
  }

  /// Memperbarui stempel waktu 'terakhir aktif' ke waktu saat ini (DateTime.now()).
  ///
  /// Ini juga akan menjadwal ulang (atau membatalkan) notifikasi pengingat
  /// berdasarkan pengaturan pengguna saat ini.
  static Future<void> updateLastActive() async {
    if (_box == null) await initialize();
    await _box!.put(_lastActiveKey, DateTime.now().toIso8601String());

    // Saat pengguna aktif, atur ulang pengingat apa pun yang tertunda.
    final enabled = await isNotificationEnabled();
    if (enabled) {
      // Jadwalkan pengingat baru untuk 24 jam dari sekarang
      await NotificationService.scheduleInactivityReminder(
        after: Duration(hours: 24),
      );
    } else {
      // Jika notifikasi dimatikan, pastikan semua notifikasi dibatalkan
      await NotificationService.cancelAllNotifications();
    }
  }

  /// Mengambil [DateTime] kapan pengguna terakhir kali aktif.
  ///
  /// Mengembalikan `null` jika [Box] belum diinisialisasi atau
  /// jika belum ada data aktivitas yang tersimpan.
  static DateTime? getLastActive() {
    if (_box == null) return null;
    String? lastActiveStr = _box!.get(_lastActiveKey);
    if (lastActiveStr == null) return null;
    return DateTime.parse(lastActiveStr);
  }

  /// Memeriksa apakah pengguna sudah tidak aktif selama 1 hari (>= 24 jam).
  static bool isInactiveForOneDay() {
    DateTime? lastActive = getLastActive();
    if (lastActive == null) return false;

    Duration difference = DateTime.now().difference(lastActive);
    return difference.inDays >= 1;
  }

  /// Mengatur preferensi pengguna untuk notifikasi pengingat.
  ///
  /// Jika [enabled] adalah `true`, ini akan menjadwalkan notifikasi baru.
  /// Jika `false`, ini akan membatalkan semua notifikasi pengingat yang ada.
  static Future<void> setNotificationEnabled(bool enabled) async {
    if (_box == null) await initialize();
    await _box!.put(_notificationEnabledKey, enabled);

    if (enabled) {
      // Aktifkan dan jadwalkan notifikasi
      await NotificationService.scheduleInactivityReminder(
        after: Duration(hours: 24),
      );
    } else {
      // Nonaktifkan dan batalkan notifikasi yang ada
      await NotificationService.cancelAllNotifications();
    }
  }

  /// Memeriksa apakah pengguna mengizinkan notifikasi pengingat.
  ///
  /// Mengembalikan `true` secara default jika pengaturan belum pernah diatur.
  static Future<bool> isNotificationEnabled() async {
    if (_box == null) await initialize();
    return _box!.get(_notificationEnabledKey, defaultValue: true);
  }

  /// Mendapatkan jumlah hari (dibulatkan ke bawah) sejak pengguna terakhir aktif.
  ///
  /// Mengembalikan `0` jika belum ada data.
  static int getDaysSinceLastActive() {
    DateTime? lastActive = getLastActive();
    if (lastActive == null) return 0;

    Duration difference = DateTime.now().difference(lastActive);
    return difference.inDays;
  }
}
