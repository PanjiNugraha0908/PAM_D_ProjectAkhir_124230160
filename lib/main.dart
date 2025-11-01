// lib/main.dart

import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'services/database_service.dart';
import 'services/activity_tracker.dart';
import 'services/notification_service.dart';

/// Titik masuk (entry point) utama aplikasi Flutter.
///
/// Fungsi [main] ini bertanggung jawab untuk menginisialisasi
/// semua layanan penting (seperti Database dan Notifikasi)
/// sebelum menjalankan UI aplikasi [MyApp].
void main() async {
  try {
    // 1. Pastikan Flutter Binding siap
    // Ini wajib dipanggil sebelum `await` untuk layanan platform.
    WidgetsFlutterBinding.ensureInitialized();

    // 2. Inisialisasi Database (Wajib)
    // Inisialisasi Hive untuk penyimpanan lokal (user, history, dll.)
    await DatabaseService.init();

    // 3. Inisialisasi Layanan Pendukung (Opsional)
    // Menggunakan try-catch terpisah agar kegagalan di sini
    // tidak menghentikan aplikasi (misal: gagal init notifikasi).
    try {
      await ActivityTracker.initialize();
      await NotificationService.initialize();
      // Meminta izin notifikasi (penting untuk Android 13+)
      await NotificationService.requestPermission();
    } catch (e) {
      // Catat error layanan opsional tetapi jangan hentikan aplikasi
      print('Warning: Gagal inisialisasi layanan pendukung: $e');
    }

    // 4. Jalankan UI Aplikasi
    runApp(MyApp());
  } catch (e, stackTrace) {
    // Tangani kesalahan fatal saat inisialisasi (misal: Hive gagal)
    print('Fatal error during initialization: $e');
    print('Stack trace: $stackTrace');
    // Tampilkan UI Error sederhana jika inisialisasi inti gagal
    runApp(ErrorApp(error: e));
  }
}

/// Widget root (akar) dari aplikasi.
///
/// Mengatur [MaterialApp], tema, dan halaman awal aplikasi.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Country Explorer',
      theme: ThemeData(
        // Tema utama aplikasi
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Halaman awal aplikasi adalah LoginPage
      home: LoginPage(),
      // Menyembunyikan banner 'Debug'
      debugShowCheckedModeBanner: false,
    );
  }
}

/// [Widget] StatelessWidget yang ditampilkan jika terjadi error fatal
/// saat proses inisialisasi di [main].
class ErrorApp extends StatelessWidget {
  final Object error;

  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                  error.toString(),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
