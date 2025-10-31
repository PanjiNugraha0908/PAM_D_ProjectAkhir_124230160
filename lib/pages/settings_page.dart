import 'package:flutter/material.dart';
import '../services/activity_tracker.dart';
import '../services/notification_service.dart';

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
    setState(() {
      _notificationEnabled = enabled;
    });
  }

  Future<void> _toggleNotification(bool value) async {
    await ActivityTracker.setNotificationEnabled(value);
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
      ),
    );
  }

  Future<void> _testNotification() async {
    await NotificationService.showNotification(
      id: 999,
      title: '🌍 Test Notifikasi',
      body: 'Notifikasi berhasil! Sistem notifikasi berfungsi dengan baik.',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notifikasi test dikirim!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastActive = ActivityTracker.getLastActive();
    int daysSinceActive = ActivityTracker.getDaysSinceLastActive();

    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          // Notification Settings
          Card(
            margin: EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications, color: Colors.blue),
                  title: Text(
                    'Notifikasi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(Icons.alarm),
                  title: Text('Pengingat Aktivitas'),
                  subtitle: Text(
                    'Kirim notifikasi jika tidak aktif selama 1 hari',
                  ),
                  value: _notificationEnabled,
                  onChanged: _toggleNotification,
                ),
                ListTile(
                  leading: Icon(Icons.send),
                  title: Text('Test Notifikasi'),
                  subtitle: Text('Kirim notifikasi test'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _testNotification,
                ),
              ],
            ),
          ),

          // Activity Info
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info, color: Colors.green),
                  title: Text(
                    'Informasi Aktivitas',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Terakhir Aktif'),
                  subtitle: Text(
                    lastActive != null
                        ? _formatDateTime(lastActive)
                        : 'Belum ada data',
                  ),
                  trailing: Icon(Icons.access_time),
                ),
                ListTile(
                  title: Text('Hari Sejak Terakhir Aktif'),
                  subtitle: Text('$daysSinceActive hari'),
                  trailing: Icon(Icons.calendar_today),
                ),
              ],
            ),
          ),

          // Info Card
          Card(
            margin: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      SizedBox(width: 8),
                      Text(
                        'Tentang Notifikasi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Notifikasi pengingat akan dikirim setelah 1 hari tidak membuka aplikasi. Pesan: "Masih banyak negara menarik untuk kamu jelajahi! ✈️🌍"',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
}