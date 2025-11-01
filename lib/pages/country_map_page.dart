import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/country.dart';

/// Halaman (Page) untuk menampilkan lokasi geografis suatu negara pada peta.
///
/// Halaman ini menerima data [Country] melalui constructor untuk
/// menentukan titik tengah peta dan lokasi marker.
class CountryMapPage extends StatelessWidget {
  final Country country;

  CountryMapPage({required this.country});

  // --- Palet Warna Halaman ---
  // Catatan: Sebaiknya palet warna ini dipindahkan ke file theme/constants terpisah
  // agar konsisten dan mudah dikelola di seluruh aplikasi.
  final Color backgroundColor = Color(0xFF1A202C);
  final Color surfaceColor = Color(0xFF2D3748);
  final Color accentColor = Color(0xFF66B3FF);
  final Color primaryButtonColor = Color(0xFF4299E1);
  final Color textColor = Color(0xFFE2E8F0);
  final Color hintColor = Color(0xFFA0AEC0);

  @override
  Widget build(BuildContext context) {
    // Ambil koordinat dari objek negara yang diterima
    final LatLng countryLocation = LatLng(country.latitude, country.longitude);

    return Scaffold(
      // --- 1. AppBar ---
      appBar: AppBar(
        title: Text(
          'Peta: ${country.name}',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      // --- 2. Body ---
      body: Container(
        color: backgroundColor,
        child: FlutterMap(
          // --- 2A. Opsi Peta ---
          options: MapOptions(
            initialCenter: countryLocation, // Pusatkan peta ke lokasi negara
            initialZoom: 4.0,
            minZoom: 1.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),

          // --- 2B. Layer-layer Peta ---
          // Ditampilkan dari bawah ke atas (index 0 adalah yang paling bawah)
          children: [
            // [Layer 1] Layer Tile (Dasar Peta)
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.mobileprojek',
            ),

            // [Layer 2] Layer Marker (Penanda Lokasi)
            MarkerLayer(
              markers: [
                Marker(
                  width: 100,
                  height: 100,
                  point: countryLocation,
                  child: Column(
                    children: [
                      // Ikon Pin
                      Icon(Icons.location_pin, color: accentColor, size: 40),
                      // Label Nama Negara
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white70, // Semi-transparan
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
                            overflow: TextOverflow
                                .ellipsis, // Cegah teks terlalu panjang
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // [Layer 3] Layer Atribusi/Copyright
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                    backgroundColor: Colors.white70, // Semi-transparan
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
