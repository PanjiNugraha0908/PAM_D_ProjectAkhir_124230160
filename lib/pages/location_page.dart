import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/country.dart';
import '../services/location_service.dart';
import '../widgets/country_detail_dialog.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _locationData;
  Country? _currentCountry;
  String _errorMessage = '';

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

    // Dapatkan lokasi
    Map<String, dynamic> result = await LocationService.getCurrentLocation();

    if (result['success']) {
      setState(() {
        _locationData = result;
      });

      // Cari informasi negara
      await _fetchCountryInfo(result['country']);
    } else {
      setState(() {
        _errorMessage = result['error'];
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCountryInfo(String countryName) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://restcountries.com/v3.1/name/$countryName?fullText=true',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _currentCountry = Country.fromJson(data[0]);
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCountryDetail() {
    if (_currentCountry != null) {
      showDialog(
        context: context,
        builder: (context) => CountryDetailDialog(country: _currentCountry!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lokasi Saya'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
            tooltip: 'Refresh Lokasi',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Mendapatkan lokasi Anda...'),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
          ? Center(
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: Icon(Icons.refresh),
                      label: Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await LocationService.openLocationSettings();
                      },
                      icon: Icon(Icons.settings),
                      label: Text('Buka Pengaturan Lokasi'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu Lokasi GPS
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.my_location,
                                color: Colors.blue.shade600,
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Lokasi Anda Saat Ini',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 24),
                          _buildLocationRow(
                            Icons.place,
                            'Alamat',
                            _locationData?['address'] ?? '-',
                          ),
                          SizedBox(height: 12),
                          _buildLocationRow(
                            Icons.public,
                            'Negara',
                            _locationData?['country'] ?? '-',
                          ),
                          SizedBox(height: 12),
                          _buildLocationRow(
                            Icons.location_city,
                            'Kota/Daerah',
                            _locationData?['locality'] ?? '-',
                          ),
                          SizedBox(height: 12),
                          _buildLocationRow(
                            Icons.gps_fixed,
                            'Koordinat',
                            '${_locationData?['latitude']?.toStringAsFixed(6) ?? '-'}, ${_locationData?['longitude']?.toStringAsFixed(6) ?? '-'}',
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),
                  // Map showing current location
                  if (_locationData != null) ...[
                    Text(
                      'Peta Lokasi Anda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 300,
                          child: FlutterMap(
                            options: MapOptions(
                              // use initialCenter/initialZoom for compatibility
                              initialCenter: LatLng(
                                _locationData!['latitude'] as double,
                                _locationData!['longitude'] as double,
                              ),
                              initialZoom: 15,
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
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],

                  SizedBox(height: 24),

                  // Informasi Negara
                  if (_currentCountry != null) ...[
                    Text(
                      'Informasi Negara Anda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: _showCountryDetail,
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                _currentCountry!.flagUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentCountry!.name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  _buildCountryInfoRow(
                                    'Ibu Kota',
                                    _currentCountry!.capital,
                                  ),
                                  _buildCountryInfoRow(
                                    'Region',
                                    _currentCountry!.region,
                                  ),
                                  _buildCountryInfoRow(
                                    'Populasi',
                                    _currentCountry!.population
                                        .toString()
                                        .replaceAllMapped(
                                          RegExp(
                                            r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                          ),
                                          (Match m) => '${m[1]}.',
                                        ),
                                  ),
                                  _buildCountryInfoRow(
                                    'Bahasa',
                                    _currentCountry!.languages.join(', '),
                                  ),
                                  SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _showCountryDetail,
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        backgroundColor: Colors.blue,
                                      ),
                                      child: Text(
                                        'Lihat Detail Lengkap',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Info LBS
                  Card(
                    color: Colors.blue.shade50,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Tentang Location Based Service',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            'LBS (Location Based Service) menggunakan GPS perangkat Anda untuk mendeteksi lokasi saat ini dan menampilkan informasi negara berdasarkan posisi Anda.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLocationRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountryInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
