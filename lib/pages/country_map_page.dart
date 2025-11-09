import 'package:flutter/material.dart';
// --- IMPORT YANG SAYA LUPAKAN ---
import 'package:google_maps_flutter/google_maps_flutter.dart';
// --- AKHIR IMPORT ---
import '../models/country.dart';

/// Halaman yang menampilkan lokasi sebuah [Country] di [GoogleMap].
class CountryMapPage extends StatefulWidget {
  final Country country;

  CountryMapPage({required this.country});

  @override
  _CountryMapPageState createState() => _CountryMapPageState();
}

class _CountryMapPageState extends State<CountryMapPage> {
  late GoogleMapController _mapController;
  late LatLng _countryPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _countryPosition = LatLng(
      widget.country.latitude,
      widget.country.longitude,
    );

    _markers.add(
      Marker(
        markerId: MarkerId(widget.country.name),
        position: _countryPosition,
        infoWindow: InfoWindow(
          title: widget.country.name,
          snippet: widget.country.capital,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController.setMapStyle(mapStyle); // Set style Peta ke mode gelap
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A202C), // backgroundColor
      appBar: AppBar(
        title: Text(
          'Lokasi ${widget.country.name}',
          style: TextStyle(color: Color(0xFFE2E8F0)), // textColor
        ),
        backgroundColor: Color(0xFF2D3748), // surfaceColor
        iconTheme: IconThemeData(color: Color(0xFFE2E8F0)), // textColor
        elevation: 0,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _countryPosition,
          zoom: 4.0,
        ),
        markers: _markers,
        mapType: MapType.normal,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.animateCamera(
            CameraUpdate.newLatLngZoom(_countryPosition, 4.0),
          );
        },
        backgroundColor: Color(0xFF4299E1), // primaryButtonColor
        child: Icon(Icons.center_focus_strong, color: Color(0xFFE2E8F0)), // textColor
        tooltip: 'Kembali ke tengah',
      ),
    );
  }
}

/// JSON String untuk style Google Maps mode gelap.
const String mapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
''';