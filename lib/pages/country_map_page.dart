import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import '../models/country.dart';

class CountryMapPage extends StatefulWidget {
  final Country country;

  CountryMapPage({required this.country});

  @override
  _CountryMapPageState createState() => _CountryMapPageState();
}

class _CountryMapPageState extends State<CountryMapPage> {
  final MapController _mapController = MapController();
  late latLng.LatLng _countryPosition;
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _countryPosition = latLng.LatLng(
      widget.country.latitude,
      widget.country.longitude,
    );

    // --- PERBAIKAN DI SINI ---
    _markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: _countryPosition,
        // Ganti 'builder' -> 'child'
        child: Tooltip(
          // Tambahkan Tooltip sebagai pengganti InfoWindow
          message:
              '${widget.country.name}\nIbu Kota: ${widget.country.capital}',
          child: Icon(Icons.location_pin, color: Colors.red.shade700, size: 40),
        ),
      ),
    );
    // --- AKHIR PERBAIKAN ---
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A202C),
      appBar: AppBar(
        title: Text(
          'Lokasi ${widget.country.name}',
          style: TextStyle(color: Color(0xFFE2E8F0)),
        ),
        backgroundColor: Color(0xFF2D3748),
        iconTheme: IconThemeData(color: Color(0xFFE2E8F0)),
        elevation: 0,
      ),
      // --- PERBAIKAN DI SINI ---
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _countryPosition, // Ganti 'center' -> 'initialCenter'
          initialZoom: 4.0, // Ganti 'zoom' -> 'initialZoom'
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.mobileprojek',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
      // --- AKHIR PERBAIKAN ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.move(_countryPosition, 4.0);
        },
        backgroundColor: Color(0xFF4299E1),
        child: Icon(Icons.center_focus_strong, color: Color(0xFFE2E8F0)),
        tooltip: 'Kembali ke tengah',
      ),
    );
  }
}
