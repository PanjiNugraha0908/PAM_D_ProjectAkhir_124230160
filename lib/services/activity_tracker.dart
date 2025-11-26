import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'notification_service.dart';
import 'auth_service.dart';

class _ActivityObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      print("✅ ActivityTracker: App RESUMED - Membatalkan notifikasi");
      ActivityTracker._cancelScheduledNotification();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      print(
          "⏸️ ActivityTracker: App PAUSED/DETACHED - Menjadwalkan notifikasi");
      ActivityTracker._scheduleInactivityNotification();
    }
  }
}

class ActivityTracker {
  static const String _boxName = 'app_state';
  static const String _lastActiveKey = 'last_active';
  static const String _notificationEnabledKey = 'notification_enabled';

  // ⚠️ PERUBAHAN UTAMA: TRIGGER NOTIFIKASI 5 MENIT (UNTUK TESTING)
  static final Duration _inactivityDuration = const Duration(minutes: 5);
  // Untuk production, kembalikan ke: const Duration(days: 1)

  static const int _inactivityNotificationId = 1000;

  static Box? _box;
  static final _ActivityObserver _observer = _ActivityObserver();

  static Future<void> initialize() async {
    print("🔧 ActivityTracker: Menginisialisasi...");

    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    _box = Hive.box(_boxName);

    if (_box!.get(_notificationEnabledKey) == null) {
      await _box!.put(_notificationEnabledKey, true);
      print("✅ Notifikasi diaktifkan secara default");
    }

    WidgetsBinding.instance.addObserver(_observer);
    print("✅ Observer lifecycle aplikasi terdaftar");

    _cancelScheduledNotification();
  }

  static Future<void> updateLastActive() async {
    // Fungsi deprecated - tidak melakukan apa-apa
  }

  static Future<void> setNotificationEnabled(bool enabled) async {
    if (_box == null) await initialize();
    await _box!.put(_notificationEnabledKey, enabled);
    print("⚙️ Notifikasi ${enabled ? 'DIAKTIFKAN' : 'DINONAKTIFKAN'}");

    if (!enabled) {
      _cancelScheduledNotification();
    }
  }

  static Future<bool> isNotificationEnabled() async {
    if (_box == null) await initialize();
    return _box!.get(_notificationEnabledKey, defaultValue: true);
  }

  static DateTime? getLastActive() {
    if (_box == null) return null;
    String? lastActiveStr = _box!.get(_lastActiveKey);
    if (lastActiveStr == null) return null;
    return DateTime.parse(lastActiveStr);
  }

  static int getDaysSinceLastActive() {
    DateTime? lastActive = getLastActive();
    if (lastActive == null) return 0;
    return DateTime.now().difference(lastActive).inDays;
  }

  static int getMinutesSinceLastActive() {
    DateTime? lastActive = getLastActive();
    if (lastActive == null) return 0;
    return DateTime.now().difference(lastActive).inMinutes;
  }

  static bool isInactiveForOneDay() {
    return getDaysSinceLastActive() >= 1;
  }

  static bool isInactiveForFiveMinutes() {
    return getMinutesSinceLastActive() >= 5;
  }

  static Future<void> _scheduleInactivityNotification() async {
    if (_box == null) {
      print("⚠️ Box belum siap, skip schedule");
      return;
    }

    final now = DateTime.now();
    await _box!.put(_lastActiveKey, now.toIso8601String());
    print("💾 Last active disimpan: ${now.toString()}");

    final bool enabled = await isNotificationEnabled();

    if (enabled) {
      String? username = AuthService.getCurrentUsername();

      if (username != null) {
        await NotificationService.cancelNotification(_inactivityNotificationId);
        await NotificationService.scheduleInactivityReminder(
          after: _inactivityDuration,
          username: username,
        );

        final scheduledTime = now.add(_inactivityDuration);
        print("⏰ Notifikasi DIJADWALKAN untuk $username");
        print("📅 Waktu sekarang: ${now.toString()}");
        print("🔔 Notifikasi akan muncul pada: ${scheduledTime.toString()}");
        print("⏱️ Durasi: $_inactivityDuration");
      } else {
        print("⚠️ User belum login, notifikasi tidak dijadwalkan");
      }
    } else {
      print("⚠️ Notifikasi nonaktif di pengaturan");
    }
  }

  static Future<void> _cancelScheduledNotification() async {
    await NotificationService.cancelNotification(_inactivityNotificationId);
    print("🚫 Notifikasi terjadwal DIBATALKAN");
  }
}
