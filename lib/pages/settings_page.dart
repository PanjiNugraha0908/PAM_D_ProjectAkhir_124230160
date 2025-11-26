import 'package:flutter/material.dart';
// --- TAMBAHAN IMPORT ---
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// -----------------------
import '../services/activity_tracker.dart';
import '../services/notification_service.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationEnabled = true;
  List<PendingNotificationRequest> _pendingNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadPendingNotifications();
  }

  Future<void> _loadSettings() async {
    bool enabled = await ActivityTracker.isNotificationEnabled();
    if (mounted) {
      setState(() {
        _notificationEnabled = enabled;
      });
    }
  }

  Future<void> _loadPendingNotifications() async {
    final pending = await NotificationService.getPendingNotifications();
    if (mounted) {
      setState(() {
        _pendingNotifications = pending;
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

  Future<void> _testNotification() async {
    await NotificationService.showNotification(
      id: 999,
      title: '🌍 Test Notifikasi',
      body: 'Hai! Notifikasi berhasil! Sistem berfungsi dengan baik.',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifikasi test dikirim!'),
          backgroundColor: Color(0xFF4299E1),
        ),
      );
    }
  }

  Future<void> _forceScheduleNotification() async {
    await ActivityTracker.initialize();
    await _loadPendingNotifications();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifikasi dipaksa dijadwalkan! Tutup app sekarang.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF66B3FF)),
            onPressed: () {
              _loadPendingNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Data diperbarui')),
              );
            },
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: ListView(
        children: [
          // BANNER TESTING MODE
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade800,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade600, width: 2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.bug_report, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '⚠️ MODE TESTING AKTIF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Notifikasi akan muncul 5 MENIT setelah app ditutup (bukan 1 hari)',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),

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
                      'Kirim notifikasi jika tidak aktif selama 5 menit (MODE TESTING)',
                      style: TextStyle(color: Color(0xFFA0AEC0))),
                  value: _notificationEnabled,
                  onChanged: _toggleNotification,
                  activeColor: Color(0xFF4299E1),
                  inactiveThumbColor: Color(0xFFA0AEC0),
                ),
                ListTile(
                  leading: Icon(Icons.send, color: Color(0xFFA0AEC0)),
                  title: Text('Test Notifikasi Instant',
                      style: TextStyle(color: Color(0xFFE2E8F0))),
                  subtitle: Text('Kirim notifikasi test langsung',
                      style: TextStyle(color: Color(0xFFA0AEC0))),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: Color(0xFFA0AEC0)),
                  onTap: _testNotification,
                ),
                ListTile(
                  leading: Icon(Icons.schedule_send, color: Colors.orange),
                  title: Text('Paksa Jadwalkan Notifikasi',
                      style: TextStyle(color: Color(0xFFE2E8F0))),
                  subtitle: Text('Untuk testing - tutup app setelah ini',
                      style: TextStyle(color: Colors.orange.shade200)),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: Color(0xFFA0AEC0)),
                  onTap: _forceScheduleNotification,
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
                  title: Text('Menit Sejak Terakhir Aktif',
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

          // DEBUG INFO - PENDING NOTIFICATIONS
          Card(
            margin: EdgeInsets.all(16),
            color: Color(0xFF2D3748),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.pending_actions, color: Colors.amber),
                  title: Text('Notifikasi Terjadwal',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE2E8F0))),
                  subtitle: Text(
                      '${_pendingNotifications.length} notifikasi pending',
                      style: TextStyle(color: Color(0xFFA0AEC0))),
                ),
                Divider(height: 1, color: Color(0xFFA0AEC0).withOpacity(0.5)),
                if (_pendingNotifications.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Tidak ada notifikasi terjadwal',
                        style: TextStyle(
                            color: Color(0xFFA0AEC0),
                            fontStyle: FontStyle.italic)),
                  )
                else
                  ..._pendingNotifications
                      .map((notif) => ListTile(
                            leading: Icon(Icons.notifications_active,
                                color: Colors.green, size: 20),
                            title: Text(notif.title ?? 'No Title',
                                style: TextStyle(
                                    color: Color(0xFFE2E8F0), fontSize: 14)),
                            subtitle: Text(
                                'ID: ${notif.id} | Body: ${notif.body ?? "No Body"}',
                                style: TextStyle(
                                    color: Color(0xFFA0AEC0), fontSize: 12)),
                          ))
                      .toList(),
              ],
            ),
          ),

          // INSTRUKSI TESTING
          Card(
            margin: EdgeInsets.all(16),
            color: Color(0xFF2D3748).withOpacity(0.8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.yellow.shade700),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('Cara Testing Notifikasi:',
                            style: TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildInstructionStep(
                      '1', 'Pastikan notifikasi AKTIF di atas'),
                  _buildInstructionStep(
                      '2', 'Klik "Paksa Jadwalkan Notifikasi"'),
                  _buildInstructionStep(
                      '3', 'TUTUP aplikasi (swipe dari recent apps)'),
                  _buildInstructionStep('4', 'Tunggu 5 MENIT'),
                  _buildInstructionStep('5', 'Notifikasi akan muncul otomatis'),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade700),
                    ),
                    child: Text(
                      '⚠️ PENTING: Jangan buka aplikasi selama 5 menit! Jika dibuka, notifikasi otomatis dibatalkan.',
                      style:
                          TextStyle(color: Colors.red.shade200, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(0xFF4299E1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
