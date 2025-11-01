// lib/pages/country_map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/country.dart';

class CountryMapPage extends StatelessWidget {
  final Country country;

  CountryMapPage({required this.country});

  // Warna-warna yang konsisten dengan desain aplikasi Anda
  final Color primaryColor = Color(0xFF010A1E);
  final Color secondaryColor = Color(0xFF103070);
  final Color tertiaryColor = Color(0xFF2A364B);
  final Color textColor = Color(0xFFD9D9D9);

  @override
  Widget build(BuildContext context) {
    // Gunakan koordinat dari model negara
    final LatLng countryLocation = LatLng(country.latitude, country.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Peta: ${country.name}',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, secondaryColor, tertiaryColor],
          ),
        ),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: countryLocation,
            initialZoom: 4.0,
            minZoom: 1.0, // <--- PERUBAHAN DI SINI (dari 2.0 menjadi 1.0)
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // Layer Peta OpenStreetMap
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.mobileprojek',
            ),
            // Marker Lokasi Negara
            MarkerLayer(
              markers: [
                Marker(
                  width: 100,
                  height: 100,
                  point: countryLocation,
                  child: Column(
                    children: [
                      Icon(Icons.location_pin, color: Colors.red, size: 40),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            country.name,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Informasi Copyright
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                    backgroundColor: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
