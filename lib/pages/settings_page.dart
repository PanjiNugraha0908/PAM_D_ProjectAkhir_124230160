import 'package:flutter/material.dart';
import '../services/activity_tracker.dart';
import '../services/notification_service.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationEnabled = true;

  // Palet Warna BARU (Datar dan Kontras)
  // Palet Warna BARU (Datar dan Kontras)
  final Color backgroundColor = Color(
    0xFF1A202C,
  ); // Latar Belakang Utama Aplikasi (Biru Sangat Gelap)
  final Color surfaceColor = Color(
    0xFF2D3748,
  ); // Warna Permukaan (Card, Input Field, Bottom Navigation)
  final Color accentColor = Color(
    0xFF66B3FF,
  ); // Aksen Utama (Logo, Judul, Ikon Penting, Selected Item)
  final Color primaryButtonColor = Color(0xFF4299E1); // Warna Tombol Utama
  final Color textColor = Color(0xFFE2E8F0); // Warna Teks Standar
  final Color hintColor = Color(
    0xFFA0AEC0,
  ); // Warna Teks Petunjuk (Hint text, ikon minor)

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
        backgroundColor: primaryButtonColor, // Warna tombol
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
      SnackBar(
        content: Text('Notifikasi test dikirim!'),
        backgroundColor: primaryButtonColor, // Warna tombol
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastActive = ActivityTracker.getLastActive();
    int daysSinceActive = ActivityTracker.getDaysSinceLastActive();

    return Scaffold(
      backgroundColor: backgroundColor, // Untuk latar belakang datar
      appBar: AppBar(
        title: Text('Pengaturan', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor, // Latar belakang datar
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: Container(
        color: backgroundColor, // Latar belakang datar
        child: ListView(
          children: [
            // Notification Settings
            Card(
              color: surfaceColor, // Warna permukaan
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: accentColor,
                    ), // Ikon warna aksen
                    title: Text(
                      'Notifikasi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: hintColor.withOpacity(0.5),
                  ), // Divider warna hint
                  SwitchListTile(
                    secondary: Icon(Icons.alarm, color: hintColor),
                    title: Text(
                      'Pengingat Aktivitas',
                      style: TextStyle(color: textColor),
                    ),
                    subtitle: Text(
                      'Kirim notifikasi jika tidak aktif selama 1 hari',
                      style: TextStyle(color: hintColor),
                    ),
                    value: _notificationEnabled,
                    onChanged: _toggleNotification,
                    activeColor: primaryButtonColor, // Warna tombol
                    inactiveThumbColor: hintColor,
                  ),
                  ListTile(
                    leading: Icon(Icons.send, color: hintColor),
                    title: Text(
                      'Test Notifikasi',
                      style: TextStyle(color: textColor),
                    ),
                    subtitle: Text(
                      'Kirim notifikasi test',
                      style: TextStyle(color: hintColor),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: hintColor,
                    ),
                    onTap: _testNotification,
                  ),
                ],
              ),
            ),

            // Activity Info
            Card(
              color: surfaceColor, // Warna permukaan
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.info,
                      color: accentColor,
                    ), // Ikon warna aksen
                    title: Text(
                      'Informasi Aktivitas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: hintColor.withOpacity(0.5),
                  ), // Divider warna hint
                  ListTile(
                    title: Text(
                      'Terakhir Aktif',
                      style: TextStyle(color: textColor),
                    ),
                    subtitle: Text(
                      lastActive != null
                          ? _formatDateTime(lastActive)
                          : 'Belum ada data',
                      style: TextStyle(color: hintColor),
                    ),
                    trailing: Icon(Icons.access_time, color: hintColor),
                  ),
                  ListTile(
                    title: Text(
                      'Hari Sejak Terakhir Aktif',
                      style: TextStyle(color: textColor),
                    ),
                    subtitle: Text(
                      '$daysSinceActive hari',
                      style: TextStyle(color: hintColor),
                    ),
                    trailing: Icon(Icons.calendar_today, color: hintColor),
                  ),
                ],
              ),
            ),

            // Info Card
            Card(
              margin: EdgeInsets.all(16),
              color: surfaceColor.withOpacity(
                0.8,
              ), // Warna permukaan yang diredupkan
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
                          color: primaryButtonColor,
                        ), // Ikon warna tombol
                        SizedBox(width: 8),
                        Text(
                          'Tentang Notifikasi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Notifikasi pengingat akan dikirim setelah 1 hari tidak membuka aplikasi. Pesan: "Masih banyak negara menarik untuk kamu jelajahi! ✈️🌍"',
                      style: TextStyle(fontSize: 14, color: hintColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
