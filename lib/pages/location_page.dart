import 'package:flutter/material.dart';
import '../services/location_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Import untuk Navigasi
import '../services/auth_service.dart';
import 'login_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'home_page.dart'; // <-- Pastikan ini ada

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _locationData;
  String _errorMessage = '';

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

  // PERBAIKAN: Fungsi untuk kembali ke HomePage
  void _openHome() {
    String? username = AuthService.getCurrentUsername();
    if (username != null) {
      // Menggunakan pushReplacement agar kembali ke HomePage dan mengganti LocationPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(username: username)),
      );
    } else {
      // Fallback ke Login Page jika sesi hilang
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  void _openHistory() {
    // FIX: Menggunakan pushReplacement untuk navigasi antar tab utama
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  void _openProfile() {
    // FIX: Menggunakan pushReplacement untuk navigasi antar tab utama
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
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
    // Index disesuaikan: Feedback (Index 1 lama) dihapus
    switch (index) {
      case 0:
        _openProfile();
        break;
      case 1: // Index 1 baru: Lokasi (Stay on page)
        // Sudah di halaman ini
        break;
      case 2: // Index 2 baru: History (Index 3 lama)
        _openHistory();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: surfaceColor, // Warna permukaan
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: hintColor,
        selectedItemColor: accentColor, // Warna aksen
        currentIndex: 1, // Lokasi sekarang di index 1
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
      body: Container(
        color: backgroundColor, // Latar belakang datar
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
                          color: textColor, // Icon warna aksen
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
                      // PERBAIKAN: Ganti Navigator.pop dengan _openHome
                      onPressed: _openHome,
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
                            CircularProgressIndicator(
                              color: primaryButtonColor,
                            ), // Warna tombol
                            SizedBox(height: 16),
                            Text(
                              'Mendapatkan lokasi Anda...',
                              style: TextStyle(color: textColor),
                            ),
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
            color: surfaceColor, // Warna permukaan
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
                                  color: accentColor, // Warna aksen
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
            color: surfaceColor, // Warna permukaan
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
                      color: accentColor, // Warna aksen
                    ),
                  ),
                  Divider(
                    height: 24,
                    color: hintColor.withOpacity(0.5),
                  ), // Divider warna hint
                  _buildLocationRow('Alamat', _locationData?['address'] ?? '-'),
                  Divider(height: 16, color: hintColor.withOpacity(0.5)),
                  _buildLocationRow('Negara', _locationData?['country'] ?? '-'),
                  Divider(height: 16, color: hintColor.withOpacity(0.5)),
                  _buildLocationRow(
                    'Kota/Daerah',
                    _locationData?['locality'] ?? '-',
                  ),
                  Divider(height: 16, color: hintColor.withOpacity(0.5)),
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
              color: accentColor,
            ), // Ikon warna aksen
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
                backgroundColor: primaryButtonColor,
              ), // Warna tombol
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await LocationService.openLocationSettings();
              },
              icon: Icon(Icons.settings, color: hintColor),
              label: Text(
                'Buka Pengaturan Lokasi',
                style: TextStyle(color: hintColor),
              ),
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
