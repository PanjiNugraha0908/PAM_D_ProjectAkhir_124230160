import 'package:flutter/material.dart';
import '../services/location_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Import untuk Navigasi
import '../services/auth_service.dart';
import 'login_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'feedback_page.dart';
import 'settings_page.dart';
// import 'package:intl/intl.dart'; <-- Import ini sudah dihapus atau tidak diperlukan

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _locationData;
  String _errorMessage = '';

  // Palet Warna (Sudah Gelap)
  final Color primaryColor = Color(0xFF010A1E); 
  final Color secondaryColor = Color(0xFF103070); 
  final Color tertiaryColor = Color(0xFF2A364B); 
  final Color cardColor = Color(0xFF21252F);
  final Color textColor = Color(0xFFD9D9D9);
  final Color hintColor = Color(0xFF898989);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    Map<String, dynamic> result = await LocationService.getCurrentLocation();

    if (result['success']) {
      setState(() {
        _locationData = result;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['error'];
        _isLoading = false;
      });
    }
  }


  // --- Fungsi Navigasi ---
  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void _openFeedback() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeedbackPage()),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  // --- Handler untuk Bottom Nav Bar ---
  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        _openProfile();
        break;
      case 1:
        _openFeedback();
        break;
      case 2:
        // Sudah di halaman ini
        break;
      case 3:
        _openHistory();
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cardColor,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: hintColor,
        selectedItemColor: secondaryColor,
        currentIndex: 2,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.my_location),
            label: 'Lokasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
      body: Container(
        // Background Gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor,
              secondaryColor,
              tertiaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- Header Kustom (dari Home) ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.settings, color: hintColor),
                      onPressed: _openSettings,
                      tooltip: 'Pengaturan',
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/Logoprojek.png',
                          height: 24,
                          width: 24,
                          color: textColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'ExploreUnity',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, color: hintColor),
                      onPressed: _logout,
                      tooltip: 'Logout',
                    ),
                  ],
                ),
              ),
              
              // --- Title Bar Halaman ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Lokasi Saya',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // --- Konten (Loading, Error, Map) ---
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: textColor),
                            SizedBox(height: 16),
                            Text('Mendapatkan lokasi Anda...', style: TextStyle(color: textColor)),
                          ],
                        ),
                      )
                    : _errorMessage.isNotEmpty
                        ? _buildErrorWidget()
                        : _buildLocationContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan Peta dan Detail Lokasi
  Widget _buildLocationContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Peta
          Card(
            elevation: 4,
            color: tertiaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 300,
                child: _locationData != null
                    ? FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                            _locationData!['latitude'] as double,
                            _locationData!['longitude'] as double,
                          ),
                          initialZoom: 16,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                            userAgentPackageName: 'projekteorimobile',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 80,
                                height: 80,
                                point: LatLng(
                                  _locationData!['latitude'] as double,
                                  _locationData!['longitude'] as double,
                                ),
                                child: Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          'Data peta tidak tersedia',
                          style: TextStyle(color: hintColor),
                        ),
                      ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Kartu Lokasi
          Card(
            elevation: 4,
            color: cardColor, // Warna card gelap
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lokasi Anda Saat Ini',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Divider(height: 24, color: tertiaryColor),
                  _buildLocationRow(
                    'Alamat',
                    _locationData?['address'] ?? '-',
                  ),
                  Divider(height: 16, color: tertiaryColor.withOpacity(0.5)),
                  _buildLocationRow(
                    'Negara',
                    _locationData?['country'] ?? '-',
                  ),
                  Divider(height: 16, color: tertiaryColor.withOpacity(0.5)),
                  _buildLocationRow(
                    'Kota/Daerah',
                    _locationData?['locality'] ?? '-',
                  ),
                  Divider(height: 16, color: tertiaryColor.withOpacity(0.5)),
                  _buildLocationRow(
                    'Koordinat',
                    '${_locationData?['latitude']?.toStringAsFixed(6) ?? '-'}, ${_locationData?['longitude']?.toStringAsFixed(6) ?? '-'}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan pesan error
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.red.shade300,
            ),
            SizedBox(height: 16),
            Text(
              'Gagal Mendapatkan Lokasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: hintColor),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: Icon(Icons.refresh, color: textColor),
              label: Text('Coba Lagi', style: TextStyle(color: textColor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
              ),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await LocationService.openLocationSettings();
              },
              icon: Icon(Icons.settings, color: hintColor),
              label: Text('Buka Pengaturan Lokasi', style: TextStyle(color: hintColor)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: hintColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk baris info lokasi (sesuai screenshot)
  Widget _buildLocationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16, 
              color: textColor,
              // FIX TYPO: w60 -> w600
              fontWeight: FontWeight.w600, 
            ),
          ),
        ],
      ),
    );
  }
}