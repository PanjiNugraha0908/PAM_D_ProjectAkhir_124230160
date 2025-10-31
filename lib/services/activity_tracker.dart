import 'package:hive/hive.dart';
import 'notification_service.dart';

class ActivityTracker {
  static const String _boxName = 'activity_tracker';
  static const String _lastActiveKey = 'last_active';
  static const String _notificationEnabledKey = 'notification_enabled';

  static Box? _box;

  // Initialize
  static Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
    
    // Set notification enabled by default
    if (_box!.get(_notificationEnabledKey) == null) {
      await _box!.put(_notificationEnabledKey, true);
    }
  }

  // Update last active time
  static Future<void> updateLastActive() async {
    if (_box == null) await initialize();
    await _box!.put(_lastActiveKey, DateTime.now().toIso8601String());
    // When user becomes active, cancel any pending inactivity reminders
    final enabled = await isNotificationEnabled();
    if (enabled) {
      // schedule a new reminder 24 hours from now
      await NotificationService.scheduleInactivityReminder(after: Duration(hours: 24));
    } else {
      await NotificationService.cancelAllNotifications();
    }
  }

  // Get last active time
  static DateTime? getLastActive() {
    if (_box == null) return null;
    String? lastActiveStr = _box!.get(_lastActiveKey);
    if (lastActiveStr == null) return null;
    return DateTime.parse(lastActiveStr);
  }

  // Check if user inactive for 1 day
  static bool isInactiveForOneDay() {
    DateTime? lastActive = getLastActive();
    if (lastActive == null) return false;
    
    Duration difference = DateTime.now().difference(lastActive);
    return difference.inDays >= 1;
  }

  // Enable/disable notification
  static Future<void> setNotificationEnabled(bool enabled) async {
    if (_box == null) await initialize();
    await _box!.put(_notificationEnabledKey, enabled);
    if (enabled) {
      await NotificationService.scheduleInactivityReminder(after: Duration(hours: 24));
    } else {
      await NotificationService.cancelAllNotifications();
    }
  }

  // Check if notification enabled
  static Future<bool> isNotificationEnabled() async {
    if (_box == null) await initialize();
    return _box!.get(_notificationEnabledKey, defaultValue: true);
  }

  // Get days since last active
  static int getDaysSinceLastActive() {
    DateTime? lastActive = getLastActive();
    if (lastActive == null) return 0;
    
    Duration difference = DateTime.now().difference(lastActive);
    return difference.inDays;
  }
}