import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'services/database_service.dart';
import 'services/activity_tracker.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart'; // TAMBAHAN

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Inisialisasi Database
    await DatabaseService.init();

    // Inisialisasi Layanan Pendukung
    try {
      await ActivityTracker.initialize();
      await NotificationService.initialize();
      await NotificationService.requestPermission();
    } catch (e) {
      print('Warning: Gagal inisialisasi layanan pendukung: $e');
    }

    runApp(MyApp());
  } catch (e, stackTrace) {
    print('Fatal error during initialization: $e');
    print('Stack trace: $stackTrace');
    runApp(ErrorApp(error: e));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Country Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // ============== PERUBAHAN KUNCI DI SINI ==============
      home: FutureBuilder<bool>(
        // Cek apakah user sudah login
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          // Tampilkan loading saat mengecek
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Color(0xFF1A202C),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Logoprojek.png',
                      height: 100,
                      width: 100,
                      color: Color(0xFFE2E8F0),
                    ),
                    SizedBox(height: 24),
                    CircularProgressIndicator(color: Color(0xFF4299E1)),
                    SizedBox(height: 16),
                    Text(
                      'Memuat...',
                      style: TextStyle(color: Color(0xFFE2E8F0)),
                    ),
                  ],
                ),
              ),
            );
          }

          // Jika sudah login, langsung ke HomePage
          if (snapshot.data == true) {
            String? username = AuthService.getCurrentUsername();
            if (username != null) {
              return HomePage(username: username);
            }
          }

          // Jika belum login, ke LoginPage
          return LoginPage();
        },
      ),
      // =====================================================
      debugShowCheckedModeBanner: false,
    );
  }

  // Fungsi helper untuk mengecek status login
  Future<bool> _checkLoginStatus() async {
    // Tunggu sebentar untuk memastikan database sudah siap
    await Future.delayed(Duration(milliseconds: 100));

    // Cek apakah ada user yang sedang login
    String? currentUser = AuthService.getCurrentUsername();

    if (currentUser != null && currentUser.isNotEmpty) {
      print('✅ User sudah login: $currentUser');
      return true;
    }

    print('❌ User belum login');
    return false;
  }
}

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
