import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import '../services/location_service.dart';
import 'profile_page.dart';
import 'history_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import '../services/auth_service.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final MapController _mapController = MapController();
  latLng.LatLng? _currentPosition;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final Map<String, dynamic> locationData =
          await LocationService.getCurrentLocation();

      if (locationData['success']) {
        if (mounted) {
          setState(() {
            _currentPosition = latLng.LatLng(
              locationData['latitude'],
              locationData['longitude'],
            );
            _errorMessage = '';
          });
          _animateToPosition(_currentPosition!);
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                locationData['error'] ?? 'Gagal mendapatkan lokasi';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _animateToPosition(latLng.LatLng position) {
    // Di v8, move() juga menerima zoom
    _mapController.move(position, 15.0);
  }

  // --- Navigasi (Tetap Sama) ---
  void _openHome() {
    String? username = AuthService.getCurrentUsername();
    if (username != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(username: username)),
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  void _openProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void _openHistory() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        _openProfile();
        break;
      case 1:
        break;
      case 2:
        _openHistory();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A202C),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFE2E8F0)),
          onPressed: _openHome,
        ),
        title: Text('Lokasi Saya', style: TextStyle(color: Color(0xFFE2E8F0))),
        backgroundColor: Color(0xFF1A202C),
        iconTheme: IconThemeData(color: Color(0xFFE2E8F0)),
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: Color(0xFF4299E1),
        child: Icon(Icons.my_location, color: Color(0xFFE2E8F0)),
        tooltip: 'Dapatkan Lokasi Saat Ini',
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF2D3748),
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Color(0xFFA0AEC0),
        selectedItemColor: Color(0xFF66B3FF),
        currentIndex: 1,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.my_location),
            label: 'Lokasi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        // ... (Widget Error State, tidak berubah) ...
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Color(0xFFA0AEC0)),
              SizedBox(height: 16),
              Text(
                'Gagal Mendapatkan Lokasi',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFE2E8F0),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                _errorMessage,
                style: TextStyle(color: Color(0xFFA0AEC0)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_currentPosition == null) {
      return Center(
        // ... (Widget Loading State, tidak berubah) ...
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF4299E1)),
            SizedBox(height: 16),
            Text(
              'Mencari lokasi Anda...',
              style: TextStyle(color: Color(0xFFA0AEC0)),
            ),
          ],
        ),
      );
    }

    // --- PERBAIKAN DI SINI ---
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition!, // Ganti 'center' -> 'initialCenter'
        initialZoom: 15.0, // Ganti 'zoom' -> 'initialZoom'
      ),
      children: [ // FlutterMap menggunakan 'children', bukan 'child'
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.mobileprojek',
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: _currentPosition!,
              // Ganti 'builder' -> 'child'
              child: Icon( 
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
    // --- AKHIR PERBAIKAN ---
  }
}