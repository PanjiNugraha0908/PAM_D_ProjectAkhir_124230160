import 'package:flutter/material.dart'; // Diperlukan untuk WidgetsBindingObserver
import 'package:hive/hive.dart';
import 'notification_service.dart';
import 'auth_service.dart'; // Diperlukan untuk cek status login

// --- Kelas Observer Internal ---
// Kelas privat ini yang akan mendengarkan siklus hidup aplikasi.
// Kita hanya buat satu instance statis dari ini.
class _ActivityObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // --- Aplikasi Dibuka Lagi ---
      print("ActivityTracker: App Resumed");
      // Panggil fungsi pengecekan statis
      ActivityTracker._checkInactivityOnResume();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // --- Aplikasi Ditutup atau Masuk Background ---
      print("ActivityTracker: App Paused/Detached");
      // Perbarui timestamp terakhir kali aktif
      ActivityTracker._updateLastActiveTimestamp();
    }
  }
}

/// Kelas helper statis untuk melacak aktivitas pengguna (VERSI DIPERBAIKI).
///
/// Menggunakan [WidgetsBindingObserver] dan [Hive] untuk
/// pelacakan aktivitas yang persisten (tahan app-kill).
/// API publik (nama fungsi) dijaga agar tetap sama dengan versi lama
/// untuk kompatibilitas.
class ActivityTracker {
  // Box 'app_state' (dari database_service)
  static const String _boxName = 'app_state';
  // Key untuk simpan waktu
  static const String _lastActiveKey = 'lastActiveTime';
  // Key untuk simpan setting notif (dari file aslimu)
  static const String _notificationEnabledKey = 'notification_enabled';

  // --- PERMINTAAN BARU: 5 MENIT ---
  // Durasi untuk tes
  static final Duration _inactivityDuration = const Duration(minutes: 5);
  // Durasi asli (bisa kamu kembalikan nanti)
  // static final Duration _inactivityDuration = const Duration(hours: 24);

  // ID Notifikasi unik untuk inaktivitas (sama seperti di notification_service.dart)
  static const int _inactivityNotificationId = 1000;

  static Box? _box;
  // Buat satu instance statis dari observer privat kita
  static final _ActivityObserver _observer = _ActivityObserver();

  /// [PUBLIK] Menginisialisasi Box Hive dan mendaftarkan observer.
  /// Dipanggil oleh main.dart
  static Future<void> initialize() async {
    // 1. Pastikan box 'app_state' terbuka
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    _box = Hive.box(_boxName);

    // 2. Atur default notifikasi (logika dari file aslimu)
    if (_box!.get(_notificationEnabledKey) == null) {
      await _box!.put(_notificationEnabledKey, true);
    }

    // 3. Daftarkan observer siklus hidup aplikasi
    WidgetsBinding.instance.addObserver(_observer);

    // 4. Langsung cek inaktivitas saat aplikasi pertama kali dimulai
    _checkInactivityOnResume();
  }

  /// [PUBLIK] Memperbarui stempel waktu 'terakhir aktif'.
  /// Dipanggil oleh home_page.dart saat ada aksi.
  static Future<void> updateLastActive() async {
    if (_box == null) await initialize();

    // 1. Update timestamp di Hive
    await _updateLastActiveTimestamp();

    // 2. Atur ulang notifikasi (jadwalkan yang baru / batalkan)
    await _resetInactivityNotification();
  }

  /// [PUBLIK] Mengatur preferensi pengguna untuk notifikasi pengingat.
  /// Dipanggil oleh settings_page.dart
  static Future<void> setNotificationEnabled(bool enabled) async {
    if (_box == null) await initialize();
    await _box!.put(_notificationEnabledKey, enabled);

    // Atur ulang notifikasi berdasarkan pengaturan baru
    await _resetInactivityNotification();
  }

  /// [PUBLIK] Memeriksa apakah pengguna mengizinkan notifikasi pengingat.
  /// Dipanggil oleh settings_page.dart
  static Future<bool> isNotificationEnabled() async {
    if (_box == null) await initialize();
    return _box!.get(_notificationEnabledKey, defaultValue: true);
  }

  /// [PUBLIK] Mengambil [DateTime] kapan pengguna terakhir kali aktif.
  /// Dipanggil oleh settings_page.dart
  static DateTime? getLastActive() {
    if (_box == null) return null;
    String? lastActiveStr = _box!.get(_lastActiveKey);
    if (lastActiveStr == null) return null;
    return DateTime.parse(lastActiveStr);
  }

  /// [PUBLIK] Mendapatkan jumlah hari (dibulatkan ke bawah) sejak pengguna terakhir aktif.
  /// Dipanggil oleh settings_page.dart
  static int getDaysSinceLastActive() {
    DateTime? lastActive = getLastActive();
    if (lastActive == null) return 0;
    return DateTime.now().difference(lastActive).inDays;
  }

  /// [PUBLIK] Memeriksa apakah pengguna sudah tidak aktif selama 1 hari (>= 24 jam).
  /// Dipanggil oleh settings_page.dart
  static bool isInactiveForOneDay() {
    return getDaysSinceLastActive() >= 1;
  }

  // --- LOGIKA INTERNAL (PRIVAT) ---

  /// [Internal] Memeriksa selisih waktu dan mengirim notifikasi jika perlu.
  /// Dipanggil saat app 'resume' (dibuka)
  static Future<void> _checkInactivityOnResume() async {
    if (_box == null) await initialize();

    // 1. Hanya cek jika user sudah login
    if (AuthService.isLoggedIn() == false) {
      print("ActivityTracker: User not logged in, skipping check.");
      return;
    }

    // 2. Cek apakah notifikasi diaktifkan
    final bool enabled = await isNotificationEnabled();
    if (!enabled) {
      print("ActivityTracker: Notifications disabled, skipping check.");
      // Saat app dibuka, langsung update waktu & reset notif
      await updateLastActive();
      return;
    }

    // 3. Ambil data waktu terakhir
    final lastActiveString = _box!.get(_lastActiveKey) as String?;
    if (lastActiveString == null) {
      print("ActivityTracker: No last active time found. Updating timestamp.");
      await updateLastActive(); // Pertama kali, update & jadwalkan
      return;
    }

    // 4. Hitung selisih
    final lastActiveTime = DateTime.parse(lastActiveString);
    final now = DateTime.now();
    final difference = now.difference(lastActiveTime);

    print(
      'ActivityTracker: Check! Last active: $lastActiveTime, Difference: $difference',
    );

    // 5. Kirim notifikasi jika > 5 menit
    if (difference > _inactivityDuration) {
      print('ActivityTracker: Inactivity detected! Sending notification.');
      // --- PERBAIKAN ERROR ---
      // Menggunakan 'showNotification' (dari file-mu)
      // bukan 'showSimpleNotification' (yang saya buat-buat)
      NotificationService.showNotification(
        id: 99, // ID Notifikasi Inaktivitas (berbeda dari ID terjadwal)
        title: 'Kami Merindukanmu!',
        body: 'Kamu sudah lama tidak mampir. Yuk, cek info negara terbaru!',
      );
    }

    // 6. Selalu update waktu dan jadwalkan ulang saat app dibuka
    await updateLastActive();
  }

  /// [Internal] Hanya memperbarui timestamp di Hive.
  static Future<void> _updateLastActiveTimestamp() async {
    if (_box == null) return; // Jangan inisialisasi jika app ditutup
    try {
      if (_box!.isOpen) {
        await _box!.put(_lastActiveKey, DateTime.now().toIso8601String());
        print('ActivityTracker: Timestamp updated to ${DateTime.now()}');
      }
    } catch (e) {
      print(
        "ActivityTracker: Error updating timestamp (box might be closed): $e",
      );
    }
  }

  /// [Internal] Menjadwal ulang atau membatalkan notif berdasarkan setting.
  static Future<void> _resetInactivityNotification() async {
    if (_box == null) await initialize();

    // Selalu batalkan notifikasi terjadwal yang lama
    await NotificationService.cancelNotification(_inactivityNotificationId);

    final bool enabled = await isNotificationEnabled();
    if (enabled) {
      // Jika diaktifkan, jadwalkan notifikasi baru
      print(
        "ActivityTracker: Scheduling new inactivity notification for $_inactivityDuration",
      );
      await NotificationService.scheduleInactivityReminder(
        after: _inactivityDuration,
      );
    } else {
      print("ActivityTracker: Notifications disabled, cancelling reminder.");
    }
  }
}
