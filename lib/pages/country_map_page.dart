// lib/pages/country_map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/country.dart';

class CountryMapPage extends StatelessWidget {
  final Country country;

  CountryMapPage({required this.country});

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
  Widget build(BuildContext context) {
    // Gunakan koordinat dari model negara
    final LatLng countryLocation = LatLng(country.latitude, country.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Peta: ${country.name}',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor, // Latar belakang datar
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Container(
        color: backgroundColor, // Latar belakang datar
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
                      Icon(
                        Icons.location_pin,
                        color: accentColor,
                        size: 40,
                      ), // Warna aksen
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
