import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'services/database_service.dart';
import 'services/activity_tracker.dart';
import 'services/notification_service.dart';

// Fungsi utama untuk menjalankan aplikasi Flutter
void main() async {
  try {
    print('Starting app initialization...');
    // Memastikan Flutter engine telah terikat (binding) sebelum memanggil native code
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter binding initialized');

    // Inisialisasi Hive Database untuk penyimpanan lokal (user, history, dll.)
    print('Initializing Hive...');
    await DatabaseService.init();
    print('Hive initialized');

    // Inisialisasi layanan opsional yang mungkin gagal (misalnya, tanpa izin)
    try {
      print('Initializing Activity Tracker...');
      await ActivityTracker.initialize();
      print('Activity Tracker initialized');
      // Inisialisasi layanan notifikasi lokal
      try {
        print('Initializing NotificationService...');
        await NotificationService.initialize();
        // Meminta izin notifikasi kepada pengguna (penting untuk Android 13+)
        await NotificationService.requestPermission();
        print('NotificationService initialized');
      } catch (e) {
        print('Warning: NotificationService init failed: $e');
      }
    } catch (e) {
      print('Warning: Error initializing optional services: $e');
    }

    print('Starting app UI...');
    // Menjalankan widget utama aplikasi
    runApp(MyApp());
  } catch (e, stackTrace) {
    print('Fatal error during initialization: $e');
    print('Stack trace: $stackTrace');
    // Menampilkan UI error jika terjadi kesalahan fatal saat inisialisasi, mencegah aplikasi crash
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan saat memulai aplikasi',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    e.toString(),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget utama aplikasi
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MaterialApp adalah root dari aplikasi Flutter
    return MaterialApp(
      title: 'Country Explorer',
      theme: ThemeData(
        // Tema utama aplikasi menggunakan warna biru
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Halaman awal yang ditampilkan saat aplikasi pertama kali dibuka
      home: LoginPage(),
      // Menyembunyikan banner 'Debug' di pojok kanan atas
      debugShowCheckedModeBanner: false,
    );
  }
}