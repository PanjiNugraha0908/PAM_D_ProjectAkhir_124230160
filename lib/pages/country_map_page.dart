import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:intl/intl.dart';
import '../models/country.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../models/history_item.dart';

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

  List<Country> _visitedCountries = [];
  bool _showVisitedCountries = false;

  @override
  void initState() {
    super.initState();
    _countryPosition = latLng.LatLng(
      widget.country.latitude,
      widget.country.longitude,
    );

    _markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: _countryPosition,
        child: Tooltip(
          message:
              '${widget.country.name}\nIbu Kota: ${widget.country.capital}',
          child: Icon(Icons.location_pin, color: Colors.red.shade700, size: 40),
        ),
      ),
    );

    _loadVisitedCountries();
  }

  Future<void> _loadVisitedCountries() async {
    String? username = AuthService.getCurrentUsername();
    if (username == null) return;

    List<HistoryItem> historyList = DatabaseService.getHistoryForUser(username);

    setState(() {
      _visitedCountries = [];
      print('Total history: ${historyList.length}');
    });
  }

  void _toggleVisitedCountries() {
    setState(() {
      _showVisitedCountries = !_showVisitedCountries;

      if (_showVisitedCountries) {
        for (int i = 0; i < _visitedCountries.length; i++) {
          print('Processing visited country index: $i');
        }
      } else {
        _markers.removeRange(1, _markers.length);
      }
    });
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
        actions: [
          IconButton(
            icon: Icon(
              _showVisitedCountries ? Icons.layers : Icons.layers_outlined,
              color:
                  _showVisitedCountries ? Color(0xFF66B3FF) : Color(0xFFA0AEC0),
            ),
            onPressed: _toggleVisitedCountries,
            tooltip: 'Tampilkan Negara yang Dikunjungi',
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _countryPosition,
          initialZoom: 4.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.mobileprojek',
          ),
          if (_showVisitedCountries)
            CircleLayer(
              circles: [
                CircleMarker(
                  point: _countryPosition,
                  radius: 100,
                  useRadiusInMeter: true,
                  color: Color(0xFF4299E1).withOpacity(0.3),
                  borderColor: Color(0xFF4299E1).withOpacity(0.6),
                  borderStrokeWidth: 2,
                ),
              ],
            ),
          MarkerLayer(markers: _markers),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Color(0xFF2D3748),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Informasi Negara',
                  style: TextStyle(
                    color: Color(0xFF66B3FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Populasi: ${_formatNumber(widget.country.population)}',
                  style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 11),
                ),
                Text(
                  'Luas: ${_formatNumber(widget.country.area)} km²',
                  style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 11),
                ),
                Text(
                  'Kepadatan: ${_calculateDensity()} orang/km²',
                  style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 11),
                ),
              ],
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              _mapController.move(_countryPosition, 4.0);
            },
            backgroundColor: Color(0xFF4299E1),
            child: Icon(Icons.center_focus_strong, color: Color(0xFFE2E8F0)),
            tooltip: 'Kembali ke tengah',
          ),
        ],
      ),
    );
  }

  String _formatNumber(num number) {
    if (number == 0) return 'N/A';
    return NumberFormat.decimalPattern('id_ID').format(number);
  }

  String _calculateDensity() {
    if (widget.country.area == 0) return 'N/A';
    double density = widget.country.population / widget.country.area;
    return _formatNumber(density.round());
  }
}
