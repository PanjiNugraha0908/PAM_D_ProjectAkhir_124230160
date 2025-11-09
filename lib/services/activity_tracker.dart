// lib/services/activity_tracker.dart

import 'package:flutter/material.dart'; // Diperlukan untuk WidgetsBindingObserver
import 'package:hive/hive.dart';
import 'notification_service.dart';
// --- PERUBAHAN DI SINI ---
// Kita butuh AuthService untuk mendapatkan username yang sedang login
import 'auth_service.dart';
// --- AKHIR PERUBAHAN ---

// --- Kelas Observer Internal ---
// Kelas privat ini yang akan mendengarkan siklus hidup aplikasi.
// Kita only buat satu instance statis dari ini.
class _ActivityObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // --- Aplikasi Dibuka Lagi ---
      print("ActivityTracker: App Resumed. Membatalkan notifikasi terjadwal.");
      // Panggil fungsi pembatalan statis
      ActivityTracker._cancelScheduledNotification();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // --- Aplikasi Ditutup atau Masuk Background ---
      print("ActivityTracker: App Paused/Detached. Menjadwalkan notifikasi.");
      // Panggil fungsi penjadwalan statis
      ActivityTracker._scheduleInactivityNotification();
    }
  }
}

/// Kelas helper statis untuk melacak aktivitas pengguna (VERSI DIPERBAIKI).
///
/// Menggunakan [WidgetsBindingObserver] dan [Hive] untuk
/// pelacakan aktivitas yang persisten (tahan app-kill).
class ActivityTracker {
  // Box 'app_state' (dari database_service)
  static const String _boxName = 'app_state';
  // Key untuk simpan waktu
  static const String _lastActiveKey = 'last_active';
  // Key untuk simpan setting notif
  static const String _notificationEnabledKey = 'notification_enabled';

  // --- PERUBAHAN DI SINI: Diubah menjadi 1 hari ---
  static final Duration _inactivityDuration = const Duration(days: 1);
  // --- AKHIR PERUBAHAN ---

  // ID Notifikasi unik untuk inaktivitas (harus sama dengan di notification_service.dart)
  static const int _inactivityNotificationId = 1000;

  static Box? _box;
  // Buat satu instance statis dari observer privat kita
  static final _ActivityObserver _observer = _ActivityObserver();

  /// [PUBLIK] Menginisialisasi Box Hive dan mendaftarkan observer.
  /// Dipanggil oleh main.dart
  static Future<void> initialize() async {
    // 1. Pastikan box 'app_state' terbuka
    // (Box ini sudah dibuka di database_service.dart, tapi kita panggil lagi
    // di sini untuk memastikan _box ter-inisialisasi)
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

    // 4. Saat aplikasi baru dimulai, batalkan notifikasi yang mungkin tertunda
    // (misal, jika app crash sebelum sempat 'resume')
    _cancelScheduledNotification();
  }

  /// [PUBLIK] (DEPRECATED) Fungsi ini sengaja dikosongkan.
  /// Logika pelacakan sekarang otomatis via AppLifecycleState.
  static Future<void> updateLastActive() async {
    // Tidak melakukan apa-apa.
    // Panggilan dari home_page (jika belum dihapus) tidak akan berpengaruh.
    print("ActivityTracker: updateLastActive() is deprecated.");
  }

  /// [PUBLIK] Mengatur preferensi pengguna untuk notifikasi pengingat.
  /// Dipanggil oleh settings_page.dart
  static Future<void> setNotificationEnabled(bool enabled) async {
    if (_box == null) await initialize();
    await _box!.put(_notificationEnabledKey, enabled);

    if (!enabled) {
      // Jika dinonaktifkan, batalkan notifikasi yang sedang terjadwal
      _cancelScheduledNotification();
    }
    // Jika diaktifkan, notifikasi akan otomatis terjadwal
    // saat aplikasi ditutup berikutnya.
  }

  /// [PUBLIK] Memeriksa apakah pengguna mengizinkan notifikasi pengingat.
  static Future<bool> isNotificationEnabled() async {
    if (_box == null) await initialize();
    return _box!.get(_notificationEnabledKey, defaultValue: true);
  }

  /// [PUBLIK] Mengambil [DateTime] kapan pengguna terakhir kali aktif.
  static DateTime? getLastActive() {
    if (_box == null) {
      // Coba inisialisasi jika box null, untuk menghindari error
      // tapi ini seharusnya tidak terjadi jika initialize() dipanggil di main.dart
      return null;
    }
    String? lastActiveStr = _box!.get(_lastActiveKey);
    if (lastActiveStr == null) return null;
    return DateTime.parse(lastActiveStr);
  }

  /// [PUBLIK] Mendapatkan jumlah hari (dibulatkan ke bawah) sejak pengguna terakhir aktif.
  static int getDaysSinceLastActive() {
    DateTime? lastActive = getLastActive();
    if (lastActive == null) return 0;
    return DateTime.now().difference(lastActive).inDays;
  }

  /// [PUBLIK] Memeriksa apakah pengguna sudah tidak aktif selama 1 hari (>= 24 jam).
  static bool isInactiveForOneDay() {
    return getDaysSinceLastActive() >= 1;
  }

  // --- LOGIKA INTERNAL (PRIVAT) ---

  /// [Internal] Menjadwalkan notifikasi inaktivitas.
  /// Dipanggil saat app 'paused' atau 'detached'.
  static Future<void> _scheduleInactivityNotification() async {
    if (_box == null) {
      // Jika box belum siap (kasus langka), jangan lakukan apa-apa
      print("ActivityTracker: Box not ready, skipping schedule.");
      return;
    }

    // 1. Simpan waktu saat ini sebagai waktu 'terakhir aktif'
    await _box!.put(_lastActiveKey, DateTime.now().toIso8601String());

    // 2. Cek apakah notifikasi diaktifkan
    final bool enabled = await isNotificationEnabled();

    // --- PERUBAHAN DI SINI ---
    if (enabled) {
      // 3. Dapatkan username yang sedang login
      String? username = AuthService.getCurrentUsername();

      // 4. Hanya jadwalkan jika user SUDAH login
      if (username != null) {
        // Batalkan notifikasi lama (jika ada) dan jadwalkan yang baru
        await NotificationService.cancelNotification(_inactivityNotificationId);
        await NotificationService.scheduleInactivityReminder(
          after: _inactivityDuration,
          username: username, // <-- Kirim username ke service
        );
        print(
          "ActivityTracker: Notifikasi inaktivitas DIJADWALKAN untuk $username setelah $_inactivityDuration.",
        );
      } else {
        // Jika tidak ada user (misal: di halaman login), jangan kirim notif
        print(
          "ActivityTracker: User belum login, notifikasi tidak dijadwalkan.",
        );
      }
    } else {
      print("ActivityTracker: Notifikasi nonaktif, penjadwalan dibatalkan.");
    }
    // --- AKHIR PERUBAHAN ---
  }

  /// [Internal] Membatalkan notifikasi inaktivitas yang terjadwal.
  /// Dipanggil saat app 'resume' (dibuka).
  static Future<void> _cancelScheduledNotification() async {
    await NotificationService.cancelNotification(_inactivityNotificationId);
    print("ActivityTracker: Notifikasi inaktivitas terjadwal DIBATALKAN.");
  }
}
