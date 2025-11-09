import 'package:flutter/material.dart';
import '../services/activity_tracker.dart';
import '../services/notification_service.dart';

/// Halaman (Page) Stateful untuk mengelola pengaturan aplikasi.
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // --- State ---
  bool _notificationEnabled = true;

  // --- Palet Warna Halaman ---
  final Color backgroundColor = Color(0xFF1A202C);
  final Color surfaceColor = Color(0xFF2D3748);
  final Color accentColor = Color(0xFF66B3FF);
  final Color primaryButtonColor = Color(0xFF4299E1);
  final Color textColor = Color(0xFFE2E8F0);
  final Color hintColor = Color(0xFFA0AEC0);

  // --- Lifecycle Methods ---

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // --- Logika Halaman (Page Logic) ---

  /// Memuat status pengaturan notifikasi dari [ActivityTracker]
  Future<void> _loadSettings() async {
    bool enabled = await ActivityTracker.isNotificationEnabled();
    if (mounted) {
      setState(() {
        _notificationEnabled = enabled;
      });
    }
  }

  /// Mengubah status notifikasi pengingat.
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
          backgroundColor: primaryButtonColor,
        ),
      );
    }
  }

  /// Memicu notifikasi tes secara manual menggunakan [NotificationService].
  Future<void> _testNotification() async {
    // --- PERUBAHAN ---
    // Menggunakan username "Test" untuk notifikasi manual
    await NotificationService.showNotification(
      id: 999,
      title: '🌍 Test Notifikasi',
      body:
          'Hai Test, notifikasi berhasil! Sistem notifikasi berfungsi dengan baik.',
    );
    // --- AKHIR PERUBAHAN ---

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifikasi test dikirim!'),
          backgroundColor: primaryButtonColor,
        ),
      );
    }
  }

  /// Memformat [DateTime] menjadi string waktu relatif (misal: "5 menit lalu").
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
      // Format tanggal standar jika sudah lama
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    // Ambil data aktivitas terakhir untuk ditampilkan
    DateTime? lastActive = ActivityTracker.getLastActive();
    int daysSinceActive = ActivityTracker.getDaysSinceLastActive();

    return Scaffold(
      backgroundColor: backgroundColor,
      // --- 1. AppBar ---
      appBar: AppBar(
        title: Text('Pengaturan', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),

      // --- 2. Body ---
      body: Container(
        color: backgroundColor,
        child: ListView(
          children: [
            // --- 2A. Kartu Pengaturan Notifikasi ---
            Card(
              color: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.notifications, color: accentColor),
                    title: Text(
                      'Notifikasi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  Divider(height: 1, color: hintColor.withOpacity(0.5)),
                  // Toggle Pengingat Aktivitas
                  SwitchListTile(
                    secondary: Icon(Icons.alarm, color: hintColor),
                    title: Text(
                      'Pengingat Aktivitas',
                      style: TextStyle(color: textColor),
                    ),
                    subtitle: Text(
                      'Kirim notifikasi jika tidak aktif selama 5 menit',
                      style: TextStyle(color: hintColor),
                    ),
                    value: _notificationEnabled,
                    onChanged: _toggleNotification,
                    activeColor: primaryButtonColor,
                    inactiveThumbColor: hintColor,
                  ),
                  // Tombol Test Notifikasi
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

            // --- 2B. Kartu Informasi Aktivitas ---
            Card(
              color: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.info, color: accentColor),
                    title: Text(
                      'Informasi Aktivitas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  Divider(height: 1, color: hintColor.withOpacity(0.5)),
                  ListTile(
                    title: Text(
                      'Terakhir Aktif (Saat App Ditutup)', // Teks diperjelas
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

            // --- 2C. Kartu Info Penjelasan Notifikasi ---
            Card(
              margin: EdgeInsets.all(16),
              color: surfaceColor.withOpacity(0.8),
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
                        Icon(Icons.info_outline, color: primaryButtonColor),
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

                    // --- PERUBAHAN TEKS PENJELASAN ---
                    Text(
                      'Notifikasi pengingat akan DIJADWALKAN setelah 5 menit kamu menutup aplikasi (jika sedang login). Pesan: "Hai [Username], masih banyak negara menarik untuk kamu jelajahi! ✈️🌍"',
                      style: TextStyle(fontSize: 14, color: hintColor),
                    ),
                    // --- AKHIR PERUBAHAN ---
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
