import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:ui' as ui;

class LocationService {
  // Cek dan request permission menggunakan geolocator
  static Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah location service aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Cek permission status
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

  // Cek apakah GPS/Location Service aktif
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Dapatkan posisi saat ini dan reverse-geocode menggunakan Nominatim
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      // Handle permission
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
            'error':
                'Permission lokasi ditolak. Aktifkan di pengaturan aplikasi.',
          };
        }
      }

      // Dapatkan posisi (coba current, fallback ke last known)
      Position? position;
      bool usedLastKnown = false;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 20),
        );
        print(
          'LocationService: obtained current position: ${position.latitude}, ${position.longitude} timestamp=${position.timestamp} accuracy=${position.accuracy}',
        );

        // If the current position has poor accuracy, try a short position stream to get a better sample
        if (position.accuracy > 50) {
          print(
            'LocationService: currentPosition accuracy=${position.accuracy} >50m, attempting short position stream to improve fix',
          );
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
                  print(
                    'LocationService: stream position update accuracy=${pos.accuracy} at ${pos.latitude}, ${pos.longitude}',
                  );
                  if (pos.accuracy < best.accuracy) {
                    best = pos;
                    print('LocationService: new best accuracy=${pos.accuracy}');
                  }
                  // Complete immediately if we get excellent accuracy
                  if (pos.accuracy <= 25 && !completer.isCompleted) {
                    print(
                      'LocationService: obtained excellent fix (${pos.accuracy}m), using immediately',
                    );
                    completer.complete(pos);
                  }
                });

            // Wait up to 20s for a better fix; if timed out use the best sample we saw
            print('LocationService: waiting up to 20s for position updates...');
            final Position newPos = await completer.future.timeout(
              Duration(seconds: 20),
              onTimeout: () {
                print(
                  'LocationService: timeout reached, using best sample (accuracy=${best.accuracy}m)',
                );
                return best;
              },
            );
            position = newPos;
            usedLastKnown = false;
            print(
              'LocationService: obtained improved position from stream: ${position.latitude}, ${position.longitude} accuracy=${position.accuracy}',
            );
          } catch (e) {
            print(
              'LocationService: did not obtain better stream position within timeout: $e',
            );
          } finally {
            await sub?.cancel();
          }
        }
      } catch (e) {
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
        print(
          'LocationService: using lastKnownPosition (age=${age.inSeconds}s) ${position.latitude}, ${position.longitude} accuracy=${position.accuracy}',
        );

        // If last-known is stale (>2 minutes) OR accuracy is poor (>100m), try a short position stream to get a better fix
        final bool isStale = age.inSeconds > 120;
        final bool poorAccuracy = position.accuracy > 100;
        if (isStale || poorAccuracy) {
          print(
            'LocationService: attempting short position stream to get better fix (isStale=$isStale, poorAccuracy=$poorAccuracy)',
          );
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
                  print(
                    'LocationService: stream position update accuracy=${pos.accuracy}',
                  );
                  if (pos.accuracy <= 50) {
                    if (!completer.isCompleted) completer.complete(pos);
                  }
                });

            // Wait up to 12s for a better fix
            final Position newPos = await completer.future.timeout(
              Duration(seconds: 12),
            );
            position = newPos;
            usedLastKnown = false;
            print(
              'LocationService: obtained improved position from stream: ${position.latitude}, ${position.longitude} accuracy=${position.accuracy}',
            );
          } catch (e) {
            print(
              'LocationService: did not obtain better stream position within timeout: $e',
            );
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

      // Sekarang reverse-geocode dengan Nominatim. Use Accept-Language and zoom to prefer street-level results.
      try {
        final language = ui.PlatformDispatcher.instance.locale.languageCode;
        // try progressively lower zoom if result seems generic
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
              'Accept-Language': language,
            },
          );

          if (response.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(response.body);
            final display = (data['display_name'] ?? '').toString();
            print(
              'LocationService: Nominatim zoom=$zoom display_name="$display"',
            );

            // If display name seems informative (more than 2 comma-separated parts), accept it
            if (display.isNotEmpty && display.split(',').length > 2) {
              nominatimResult = data;
              break;
            }

            // otherwise keep trying with lower zoom
            // but if this is the last zoom, accept whatever we have
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
        print('LocationService: nominatim error $e');
        // fallthrough to geocoding fallback
      }

      // Fallback: use geocoding package
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
        // ignore
      }

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
      print('Error in getCurrentLocation: $e');
      return {'success': false, 'error': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Hitung jarak antara dua koordinat (dalam kilometer)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  // Format jarak
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} meter';
    } else if (distanceInKm < 100) {
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceInKm.toStringAsFixed(0)} km';
    }
  }

  // Dapatkan negara berdasarkan koordinat
  static Future<String> getCountryFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Try Nominatim first with Accept-Language and zoom fallbacks
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
            final display = (data['display_name'] ?? '').toString();
            print(
              'LocationService.getCountryFromCoordinates: zoom=$zoom display_name="$display"',
            );
            if (addr != null && addr['country'] != null) {
              return addr['country'];
            }
            // if display is informative, try parse country from it
            if (display.isNotEmpty && display.split(',').length > 0) {
              final parts = display.split(',').map((s) => s.trim()).toList();
              if (parts.isNotEmpty) return parts.last;
            }
          }
        } catch (e) {
          // try next zoom
        }
      }
    } catch (e) {
      // ignore and fallback
    }

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

  // Open location settings
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
