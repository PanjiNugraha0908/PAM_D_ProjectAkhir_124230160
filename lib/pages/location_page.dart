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
  bool _isLoading = true;
  String _address = '';
  String _country = '';
  double _accuracy = 0.0;

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

    try {
      final Map<String, dynamic> locationData =
          await LocationService.getCurrentLocation();

      if (mounted) {
        if (locationData['success']) {
          setState(() {
            _currentPosition = latLng.LatLng(
              locationData['latitude'],
              locationData['longitude'],
            );
            _address = locationData['address'] ?? 'Alamat tidak tersedia';
            _country = locationData['country'] ?? 'Unknown';
            _accuracy = locationData['accuracy'] ?? 0.0;
            _errorMessage = '';
            _isLoading = false;
          });

          // Animasi ke posisi dengan smooth transition
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted && _currentPosition != null) {
              _mapController.move(_currentPosition!, 15.0);
            }
          });
        } else {
          setState(() {
            _errorMessage = locationData['error'] ?? 'Gagal mendapatkan lokasi';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _animateToPosition(latLng.LatLng position) {
    _mapController.move(position, 15.0);
  }

  void _openHome() {
    // --- PERBAIKAN: Hapus parameter 'username' ---
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
    // --- AKHIR PERBAIKAN ---
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentPosition != null)
            FloatingActionButton(
              heroTag: 'center',
              onPressed: () {
                if (_currentPosition != null) {
                  _animateToPosition(_currentPosition!);
                }
              },
              backgroundColor: Color(0xFF2D3748),
              child: Icon(Icons.center_focus_strong, color: Color(0xFFE2E8F0)),
              tooltip: 'Kembali ke Pusat',
            ),
          SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: _getCurrentLocation,
            backgroundColor: Color(0xFF4299E1),
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Color(0xFFE2E8F0),
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.my_location, color: Color(0xFFE2E8F0)),
            tooltip: 'Perbarui Lokasi',
          ),
        ],
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
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: Icon(Icons.refresh),
                label: Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4299E1),
                  foregroundColor: Color(0xFFE2E8F0),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading || _currentPosition == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF4299E1)),
            SizedBox(height: 16),
            Text(
              'Mencari lokasi Anda...',
              style: TextStyle(color: Color(0xFFA0AEC0)),
            ),
            SizedBox(height: 8),
            Text(
              'Pastikan GPS aktif',
              style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Info Card
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF2D3748),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: Color(0xFF66B3FF), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _country,
                      style: TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                _address,
                style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
              ),
              SizedBox(height: 12),
              Divider(color: Color(0xFFA0AEC0).withOpacity(0.3)),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(
                    icon: Icons.my_location,
                    label: 'Akurasi',
                    value: '${_accuracy.toStringAsFixed(0)}m',
                  ),
                  _buildInfoChip(
                    icon: Icons.explore,
                    label: 'Koordinat',
                    value:
                        '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                  ),
                ],
              ),
            ],
          ),
        ),

        // Map
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition!,
                initialZoom: 15.0,
                minZoom: 5.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.mobileprojek',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _currentPosition!,
                      radius: _accuracy > 100 ? 100 : _accuracy,
                      color: Color(0xFF4299E1).withOpacity(0.2),
                      borderColor: Color(0xFF4299E1).withOpacity(0.5),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentPosition!,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF2D3748),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Anda di sini',
                              style: TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF66B3FF), size: 16),
        SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 10),
            ),
            Text(
              value,
              style: TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
