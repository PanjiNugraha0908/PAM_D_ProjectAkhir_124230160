import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'services/database_service.dart';
import 'services/activity_tracker.dart';
import 'services/notification_service.dart';

void main() async {
  try {
    print('Starting app initialization...');
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter binding initialized');

    // Initialize Hive Database
    print('Initializing Hive...');
    await DatabaseService.init();
    print('Hive initialized');

    // Initialize optional services
    try {
      print('Initializing Activity Tracker...');
      await ActivityTracker.initialize();
      print('Activity Tracker initialized');
      // Initialize notifications (restore behavior)
      try {
        print('Initializing NotificationService...');
        await NotificationService.initialize();
        await NotificationService.requestPermission();
        print('NotificationService initialized');
      } catch (e) {
        print('Warning: NotificationService init failed: $e');
      }
    } catch (e) {
      print('Warning: Error initializing optional services: $e');
    }

    print('Starting app UI...');
    runApp(MyApp());
  } catch (e, stackTrace) {
    print('Fatal error during initialization: $e');
    print('Stack trace: $stackTrace');
    // Show error UI instead of crashing
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Country Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
