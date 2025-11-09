import 'package:flutter/material.dart';
import '../services/activity_tracker.dart';
import '../services/notification_service.dart';

/// Halaman untuk mengelola pengaturan aplikasi.
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    bool enabled = await ActivityTracker.isNotificationEnabled();
    if (mounted) {
      setState(() {
        _notificationEnabled = enabled;
      });
    }
  }

  Future<void> _toggleNotification(bool value) async {
    await ActivityTracker.setNotificationEnabled(value);
    if (mounted) {
      setState(() {
        _notificationEnabled = value;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Notifikasi pengingat diaktifkan'
                : 'Notifikasi pengingat dinonaktifkan',
          ),
          backgroundColor: Color(0xFF4299E1), // primaryButtonColor
        ),
      );
    }
  }

  Future<void> _testNotification() async {
    await NotificationService.showNotification(
      id: 999,
      title: '🌍 Test Notifikasi',
      body:
          'Hai Test, notifikasi berhasil! Sistem notifikasi berfungsi dengan baik.',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifikasi test dikirim!'),
          backgroundColor: Color(0xFF4299E1), // primaryButtonColor
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastActive = ActivityTracker.getLastActive();
    int daysSinceActive = ActivityTracker.getDaysSinceLastActive();

    return Scaffold(
      backgroundColor: Color(0xFF1A202C), // backgroundColor
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: TextStyle(color: Color(0xFFE2E8F0)),
        ), // textColor
        backgroundColor: Color(0xFF1A202C), // backgroundColor
        iconTheme: IconThemeData(color: Color(0xFFE2E8F0)), // textColor
        elevation: 0,
      ),
      body: ListView(
        children: [
          Card(
            color: Color(0xFF2D3748), // surfaceColor
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: Color(0xFF66B3FF),
                  ), // accentColor
                  title: Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2E8F0), // textColor
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: Color(0xFFA0AEC0).withOpacity(0.5),
                ), // hintColor
                SwitchListTile(
                  secondary: Icon(
                    Icons.alarm,
                    color: Color(0xFFA0AEC0),
                  ), // hintColor
                  title: Text(
                    'Pengingat Aktivitas',
                    style: TextStyle(color: Color(0xFFE2E8F0)), // textColor
                  ),
                  subtitle: Text(
                    'Kirim notifikasi jika tidak aktif selama 5 menit',
                    style: TextStyle(color: Color(0xFFA0AEC0)), // hintColor
                  ),
                  value: _notificationEnabled,
                  onChanged: _toggleNotification,
                  activeColor: Color(0xFF4299E1), // primaryButtonColor
                  inactiveThumbColor: Color(0xFFA0AEC0), // hintColor
                ),
                ListTile(
                  leading: Icon(
                    Icons.send,
                    color: Color(0xFFA0AEC0),
                  ), // hintColor
                  title: Text(
                    'Test Notifikasi',
                    style: TextStyle(color: Color(0xFFE2E8F0)), // textColor
                  ),
                  subtitle: Text(
                    'Kirim notifikasi test',
                    style: TextStyle(color: Color(0xFFA0AEC0)), // hintColor
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFFA0AEC0), // hintColor
                  ),
                  onTap: _testNotification,
                ),
              ],
            ),
          ),
          Card(
            color: Color(0xFF2D3748), // surfaceColor
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.info,
                    color: Color(0xFF66B3FF),
                  ), // accentColor
                  title: Text(
                    'Informasi Aktivitas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2E8F0), // textColor
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: Color(0xFFA0AEC0).withOpacity(0.5),
                ), // hintColor
                ListTile(
                  title: Text(
                    'Terakhir Aktif (Saat App Ditutup)',
                    style: TextStyle(color: Color(0xFFE2E8F0)), // textColor
                  ),
                  subtitle: Text(
                    lastActive != null
                        ? _formatDateTime(lastActive)
                        : 'Belum ada data',
                    style: TextStyle(color: Color(0xFFA0AEC0)), // hintColor
                  ),
                  trailing: Icon(
                    Icons.access_time,
                    color: Color(0xFFA0AEC0),
                  ), // hintColor
                ),
                ListTile(
                  title: Text(
                    'Hari Sejak Terakhir Aktif',
                    style: TextStyle(color: Color(0xFFE2E8F0)), // textColor
                  ),
                  subtitle: Text(
                    '$daysSinceActive hari',
                    style: TextStyle(color: Color(0xFFA0AEC0)), // hintColor
                  ),
                  trailing: Icon(
                    Icons.calendar_today,
                    color: Color(0xFFA0AEC0),
                  ), // hintColor
                ),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.all(16),
            color: Color(0xFF2D3748).withOpacity(0.8), // surfaceColor
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF4299E1),
                      ), // primaryButtonColor
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
