import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:ui' as ui; // Untuk mendapatkan locale bahasa

/// Kelas helper statis untuk semua logika terkait geolokasi.
///
/// Menggunakan package [geolocator] untuk mendapatkan koordinat,
/// dan [http] (untuk Nominatim) serta [geocoding] (sebagai fallback)
/// untuk melakukan reverse geocoding (koordinat ke alamat).
class LocationService {
  /// Memeriksa izin lokasi dan memintanya jika belum diberikan.
  ///
  /// Mengembalikan `true` jika izin diberikan (baik `whileInUse` atau `always`).
  /// Mengembalikan `false` jika layanan GPS mati, izin ditolak,
  /// atau ditolak permanen.
  static Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah layanan lokasi (GPS) di perangkat aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Cek status izin
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Memeriksa apakah layanan lokasi (GPS) di perangkat aktif.
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Mendapatkan lokasi pengguna saat ini (koordinat dan alamat).
  ///
  /// Ini adalah fungsi kompleks yang melakukan:
  /// 1. Pengecekan izin dan status layanan GPS.
  /// 2. Upaya mendapatkan posisi (Current, LastKnown, atau via Stream).
  /// 3. Upaya Reverse Geocoding via Nominatim (HTTP) dengan fallback zoom.
  /// 4. Upaya Reverse Geocoding via Geocoding package (jika Nominatim gagal).
  ///
  /// Mengembalikan [Map<String, dynamic>] yang berisi:
  /// - `success: true`, `latitude`, `longitude`, `address`, `country`, dll.
  /// - `success: false`, `error` (String pesan error).
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      // --- 1. Handle Izin Lokasi ---
      bool hasPermission = await handleLocationPermission();
      if (!hasPermission) {
        bool serviceEnabled = await isLocationServiceEnabled();
        if (!serviceEnabled) {
          return {
            'success': false,
            'error': 'GPS tidak aktif. Silakan aktifkan GPS di pengaturan.',
          };
        } else {
          return {
            'success': false,
            'error': 'Izin lokasi ditolak. Aktifkan di pengaturan aplikasi.',
          };
        }
      }

      // --- 2. Dapatkan Posisi (dengan fallback dan peningkatan akurasi) ---
      Position? position;
      bool usedLastKnown = false;

      try {
        // 2a. Coba dapatkan posisi saat ini
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 20),
        );

        // 2b. Jika akurasi buruk, coba gunakan stream untuk perbaikan
        if (position.accuracy > 50) {
          StreamSubscription<Position>? sub;
          try {
            final completer = Completer<Position>();
            Position best = position;
            sub =
                Geolocator.getPositionStream(
                  locationSettings: LocationSettings(
                    accuracy: LocationAccuracy.best,
                    distanceFilter: 0,
                  ),
                ).listen((pos) {
                  if (pos.accuracy < best.accuracy) {
                    best = pos;
                  }
                  // Selesaikan jika akurasi sudah (< 25m)
                  if (pos.accuracy <= 25 && !completer.isCompleted) {
                    completer.complete(pos);
                  }
                });

            // Tunggu hingga 20 detik untuk akurasi lebih baik
            final Position newPos = await completer.future.timeout(
              Duration(seconds: 20),
              onTimeout: () {
                return best; // Kembalikan akurasi terbaik yang didapat
              },
            );
            position = newPos;
            usedLastKnown = false;
          } catch (e) {
            // Biarkan, gunakan 'position' awal jika stream gagal
          } finally {
            await sub?.cancel();
          }
        }
      } catch (e) {
        // 2c. Fallback ke Last Known Position jika getCurrentPosition gagal
        position = await Geolocator.getLastKnownPosition();
        usedLastKnown = true;
        if (position == null) {
          return {
            'success': false,
            'error':
                'Tidak dapat mendapatkan lokasi. Pastikan GPS aktif dan sinyal baik.',
          };
        }

        final timestamp = position.timestamp;
        final age = DateTime.now().difference(timestamp);
        final bool isStale = age.inSeconds > 120; // > 2 menit
        final bool poorAccuracy = position.accuracy > 100;

        // 2d. Jika Last Known sudah usang atau akurasi buruk, coba stream
        if (isStale || poorAccuracy) {
          StreamSubscription<Position>? sub;
          try {
            final completer = Completer<Position>();
            sub =
                Geolocator.getPositionStream(
                  locationSettings: LocationSettings(
                    accuracy: LocationAccuracy.best,
                    distanceFilter: 0,
                  ),
                ).listen((pos) {
                  if (pos.accuracy <= 50) {
                    if (!completer.isCompleted) completer.complete(pos);
                  }
                });

            // Tunggu hingga 12 detik
            final Position newPos = await completer.future.timeout(
              Duration(seconds: 12),
            );
            position = newPos;
            usedLastKnown = false;
          } catch (e) {
            // Biarkan, gunakan 'position' (last known) jika stream gagal
          } finally {
            await sub?.cancel();
          }
        }
      }

      if (position == null) {
        return {
          'success': false,
          'error':
              'Tidak dapat mendapatkan lokasi. Pastikan GPS aktif dan sinyal baik.',
        };
      }

      // --- 3. Reverse Geocode - Strategi Utama (Nominatim) ---
      try {
        final language = ui.PlatformDispatcher.instance.locale.languageCode;
        // Coba zoom dari yang paling detail (18) ke yang lebih umum
        List<int> zooms = [18, 16, 14];
        Map<String, dynamic>? nominatimResult;

        for (final zoom in zooms) {
          final uri = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}&addressdetails=1&zoom=$zoom',
          );

          final response = await http.get(
            uri,
            headers: {
              'User-Agent': 'projekteorimobile/1.0',
              'Accept-Language': language, // Minta hasil dalam bahasa perangkat
            },
          );

          if (response.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(response.body);
            final display = (data['display_name'] ?? '').toString();

            // Jika display_name informatif (lebih dari 2 bagian), gunakan
            if (display.isNotEmpty && display.split(',').length > 2) {
              nominatimResult = data;
              break;
            }
            // Jika ini zoom terakhir, terima apa adanya
            if (zoom == zooms.last) {
              nominatimResult = data;
              break;
            }
          }
        }

        if (nominatimResult != null) {
          final data = nominatimResult;
          final Map<String, dynamic>? addr =
              data['address'] as Map<String, dynamic>?;

          final country = addr?['country'] ?? data['display_name'] ?? 'Unknown';
          final countryCode = (addr?['country_code'] ?? '')
              .toString()
              .toUpperCase();
          final locality =
              addr?['city'] ??
              addr?['town'] ??
              addr?['village'] ??
              addr?['hamlet'] ??
              '';
          final administrative = addr?['state'] ?? addr?['region'] ?? '';
          final subAdministrative = addr?['county'] ?? '';
          final addrDisplay = data['display_name'] ?? '';

          return {
            'success': true,
            'latitude': position.latitude,
            'longitude': position.longitude,
            'accuracy': position.accuracy,
            'country': country,
            'countryCode': countryCode,
            'locality': locality,
            'administrativeArea': administrative,
            'subAdministrativeArea': subAdministrative,
            'address': addrDisplay,
            'usedLastKnown': usedLastKnown,
          };
        }
      } catch (e) {
        // Abaikan error Nominatim dan lanjut ke fallback
      }

      // --- 4. Fallback: Geocoding package (jika Nominatim gagal) ---
      try {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks[0];
          final country = place.country ?? 'Unknown';
          final countryCode = place.isoCountryCode ?? '';
          final locality = place.locality ?? '';
          final administrative = place.administrativeArea ?? '';
          final subAdministrative = place.subAdministrativeArea ?? '';
          // Buat alamat tampilan manual
          final address = [
            if (place.locality != null && place.locality!.isNotEmpty)
              place.locality,
            if (place.administrativeArea != null &&
                place.administrativeArea!.isNotEmpty)
              place.administrativeArea,
            if (place.country != null && place.country!.isNotEmpty)
              place.country,
          ].whereType<String>().join(', ');

          return {
            'success': true,
            'latitude': position.latitude,
            'longitude': position.longitude,
            'accuracy': position.accuracy,
            'country': country,
            'countryCode': countryCode,
            'locality': locality,
            'administrativeArea': administrative,
            'subAdministrativeArea': subAdministrative,
            'address': address,
            'usedLastKnown': usedLastKnown,
          };
        }
      } catch (e) {
        // Abaikan error Geocoding
      }

      // --- 5. Fallback Terakhir (jika semua gagal, kembalikan koordinat saja) ---
      return {
        'success': true,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'country': 'Unknown',
        'countryCode': '',
        'locality': '',
        'administrativeArea': '',
        'subAdministrativeArea': '',
        'address': '',
        'usedLastKnown': usedLastKnown,
      };
    } catch (e) {
      return {'success': false, 'error': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  /// Menghitung jarak lurus (haversine) antara dua titik koordinat.
  ///
  /// Mengembalikan jarak dalam **kilometer**.
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Geolocator.distanceBetween mengembalikan jarak dalam meter
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Memformat jarak (dalam km) menjadi string yang mudah dibaca.
  ///
  /// - Kurang dari 1 km akan ditampilkan sebagai meter (misal: "800 meter").
  /// - Kurang dari 100 km akan ditampilkan dengan 1 desimal (misal: "12.5 km").
  /// - 100 km atau lebih akan dibulatkan (misal: "150 km").
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} meter';
    } else if (distanceInKm < 100) {
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceInKm.toStringAsFixed(0)} km';
    }
  }

  /// Mendapatkan nama negara saja dari koordinat (versi ringan dari `getCurrentLocation`).
  static Future<String> getCountryFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // Prioritaskan Nominatim
    try {
      final language = ui.PlatformDispatcher.instance.locale.languageCode;
      List<int> zooms = [18, 16, 14];
      for (final zoom in zooms) {
        try {
          final uri = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$latitude&lon=$longitude&addressdetails=1&zoom=$zoom',
          );
          final response = await http.get(
            uri,
            headers: {
              'User-Agent': 'projekteorimobile/1.0',
              'Accept-Language': language,
            },
          );
          if (response.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(response.body);
            final addr = data['address'] as Map<String, dynamic>?;
            // Jika ada info alamat, ambil negara
            if (addr != null && addr['country'] != null) {
              return addr['country'];
            }
            // Jika tidak, coba parse dari display_name
            final display = (data['display_name'] ?? '').toString();
            if (display.isNotEmpty && display.split(',').length > 0) {
              final parts = display.split(',').map((s) => s.trim()).toList();
              if (parts.isNotEmpty) return parts.last; // Bagian terakhir
            }
          }
        } catch (e) {
          // Coba zoom berikutnya
        }
      }
    } catch (e) {
      // Abaikan dan lanjut ke fallback
    }

    // Fallback ke Geocoding
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      return placemarks.isNotEmpty
          ? (placemarks[0].country ?? 'Unknown')
          : 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Membuka pengaturan lokasi perangkat (GPS).
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Membuka pengaturan aplikasi ini di perangkat (untuk izin).
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
