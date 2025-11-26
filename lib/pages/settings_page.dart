import 'package:flutter/material.dart';
import '../services/activity_tracker.dart';

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
          backgroundColor: Color(0xFF4299E1),
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
    int minutesSinceActive = ActivityTracker.getMinutesSinceLastActive();

    return Scaffold(
      backgroundColor: Color(0xFF1A202C),
      appBar: AppBar(
        title: Text('Pengaturan', style: TextStyle(color: Color(0xFFE2E8F0))),
        backgroundColor: Color(0xFF1A202C),
        iconTheme: IconThemeData(color: Color(0xFFE2E8F0)),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // NOTIFIKASI SETTINGS
          Card(
            color: Color(0xFF2D3748),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications, color: Color(0xFF66B3FF)),
                  title: Text('Notifikasi',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE2E8F0))),
                ),
                Divider(height: 1, color: Color(0xFFA0AEC0).withOpacity(0.5)),
                SwitchListTile(
                  secondary: Icon(Icons.alarm, color: Color(0xFFA0AEC0)),
                  title: Text('Pengingat Aktivitas',
                      style: TextStyle(color: Color(0xFFE2E8F0))),
                  subtitle: Text(
                      'Kirim notifikasi jika tidak membuka aplikasi selama 1 hari',
                      style: TextStyle(color: Color(0xFFA0AEC0))),
                  value: _notificationEnabled,
                  onChanged: _toggleNotification,
                  activeColor: Color(0xFF4299E1),
                  inactiveThumbColor: Color(0xFFA0AEC0),
                ),
              ],
            ),
          ),

          // INFORMASI AKTIVITAS
          Card(
            color: Color(0xFF2D3748),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info, color: Color(0xFF66B3FF)),
                  title: Text('Informasi Aktivitas',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE2E8F0))),
                ),
                Divider(height: 1, color: Color(0xFFA0AEC0).withOpacity(0.5)),
                ListTile(
                  title: Text('Terakhir Aktif',
                      style: TextStyle(color: Color(0xFFE2E8F0))),
                  subtitle: Text(
                      lastActive != null
                          ? _formatDateTime(lastActive)
                          : 'Belum ada data',
                      style: TextStyle(color: Color(0xFFA0AEC0))),
                  trailing: Icon(Icons.access_time, color: Color(0xFFA0AEC0)),
                ),
                ListTile(
                  title: Text('Waktu Sejak Terakhir Aktif',
                      style: TextStyle(color: Color(0xFFE2E8F0))),
                  subtitle: Text('$minutesSinceActive menit',
                      style: TextStyle(color: Color(0xFFA0AEC0))),
                  trailing: Icon(Icons.timelapse, color: Color(0xFFA0AEC0)),
                ),
                ListTile(
                  title: Text('Hari Sejak Terakhir Aktif',
                      style: TextStyle(color: Color(0xFFE2E8F0))),
                  subtitle: Text('$daysSinceActive hari',
                      style: TextStyle(color: Color(0xFFA0AEC0))),
                  trailing:
                      Icon(Icons.calendar_today, color: Color(0xFFA0AEC0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
