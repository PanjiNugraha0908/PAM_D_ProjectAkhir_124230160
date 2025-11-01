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
import 'home_page.dart';

/// Halaman (Page) Stateful untuk menampilkan lokasi pengguna saat ini
/// menggunakan [LocationService] dan menampilkannya di [FlutterMap].
class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  // --- State ---
  bool _isLoading = false;
  Map<String, dynamic>? _locationData;
  String _errorMessage = '';

  // --- Palet Warna Halaman ---
  // Catatan: Sebaiknya palet warna ini dipindahkan ke file theme/constants terpisah
  // agar konsisten dan mudah dikelola di seluruh aplikasi.
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
    _getCurrentLocation();
  }

  // --- Logika Halaman (Page Logic) ---

  /// Mengambil data lokasi (koordinat dan alamat) dari [LocationService].
  ///
  /// Memperbarui state [_isLoading] selama proses, dan mengisi
  /// [_locationData] atau [_errorMessage] berdasarkan hasil.
  Future<void> _getCurrentLocation() async {
    // Pastikan widget masih ada di tree sebelum setState
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    Map<String, dynamic> result = await LocationService.getCurrentLocation();

    // Pastikan widget masih ada di tree sebelum setState
    if (mounted) {
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
  }

  // --- Fungsi Navigasi ---

  /// Melakukan proses logout dan mengarahkan pengguna ke [LoginPage].
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

  /// Navigasi kembali ke [HomePage].
  /// Menggunakan [pushReplacement] untuk menukar halaman ini dengan [HomePage].
  void _openHome() {
    String? username = AuthService.getCurrentUsername();
    if (username != null) {
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

  /// Navigasi ke [HistoryPage] (Tab).
  void _openHistory() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  /// Navigasi ke [ProfilePage] (Tab).
  void _openProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  /// Navigasi ke [SettingsPage] (Membuka halaman baru di atas).
  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  /// Handler untuk [BottomNavigationBar] onTap.
  void _onItemTapped(int index) {
    switch (index) {
      case 0: // Profil
        _openProfile();
        break;
      case 1: // Lokasi (Halaman ini)
        // Tidak melakukan apa-apa
        break;
      case 2: // History
        _openHistory();
        break;
    }
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 1. Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: surfaceColor,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: hintColor,
        selectedItemColor: accentColor,
        currentIndex: 1, // Menandai 'Lokasi' sebagai tab aktif
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

      // --- 2. Body ---
      body: Container(
        color: backgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              // --- 2A. Header Aplikasi (Settings, Logo, Logout) ---
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

              // --- 2B. Title Bar Halaman ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: _openHome, // Kembali ke Home
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

              // --- 2C. Konten Utama (Loading, Error, atau Map) ---
              Expanded(
                child: _isLoading
                    ? Center(
                        // --- Tampilan Loading ---
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: primaryButtonColor,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Mendapatkan lokasi Anda...',
                              style: TextStyle(color: textColor),
                            ),
                          ],
                        ),
                      )
                    : _errorMessage.isNotEmpty
                    ? _buildErrorWidget() // --- Tampilan Error ---
                    : _buildLocationContent(), // --- Tampilan Sukses (Map & Data) ---
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  /// [Helper Widget] Membangun tampilan utama saat data lokasi berhasil didapat.
  /// Terdiri dari Peta [FlutterMap] dan Kartu Detail Lokasi.
  Widget _buildLocationContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Peta ---
          Card(
            elevation: 4,
            color: surfaceColor,
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
                                  color: accentColor,
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

          // --- Kartu Detail Lokasi ---
          Card(
            elevation: 4,
            color: surfaceColor,
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
                      color: accentColor,
                    ),
                  ),
                  Divider(height: 24, color: hintColor.withOpacity(0.5)),
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

  /// [Helper Widget] Membangun tampilan 'Error' saat gagal mendapat lokasi.
  /// Menampilkan pesan error dan tombol 'Coba Lagi' & 'Buka Pengaturan'.
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: accentColor),
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
              ),
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

  /// [Helper Widget] Membangun baris info (Label dan Value)
  /// untuk kartu detail lokasi.
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
