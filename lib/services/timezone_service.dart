import 'package:intl/intl.dart';

/// Kelas helper statis untuk logika terkait zona waktu (timezone).
///
/// Catatan: Layanan ini menggunakan offset UTC tetap (hardcoded)
/// dan tidak menangani Daylight Saving Time (DST).
class TimezoneService {
  /// Daftar offset jam (integer) dari UTC.
  /// Kunci: Singkatan (internal), Nilai: Offset jam.
  static final Map<String, int> _timezoneOffsets = {
    'UTC': 0,
    'WIB': 7,
    'WITA': 8,
    'WIT': 9,
    'LONDON': 0,
  };

  /// Peta nama tampilan (nama panjang) untuk zona waktu.
  static final Map<String, String> _timezoneNames = {
    'WIB': 'Waktu Indonesia Barat',
    'WITA': 'Waktu Indonesia Tengah',
    'WIT': 'Waktu Indonesia Timur',
    'UTC': 'Universal Terkoordinasi',
    'LONDON': 'London (GMT)', // LONDON (GMT) lebih deskriptif
  };

  /// Mengembalikan daftar zona waktu (hardcoded) yang tersedia
  /// untuk dipilih pengguna (misal: di dropdown).
  static List<String> getAvailableTimezones() {
    return ['WIB', 'WITA', 'WIT', 'LONDON'];
  }

  /// Mendapatkan nama panjang (nama tampilan) dari singkatan zona waktu.
  ///
  /// Contoh: "WIB" -> "Waktu Indonesia Barat".
  /// Jika tidak ditemukan, kembalikan singkatan aslinya.
  static String getTimezoneName(String timezone) {
    return _timezoneNames[timezone] ?? timezone;
  }

  /// [Helper] Memformat [DateTime] menjadi string "HH:mm:ss".
  static String _formatTime(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  /// [Helper] Mengurai string timezone dari API (misal: "UTC+07:00" atau "UTC")
  /// menjadi offset integer (misal: 7 atau 0).
  static int _parseOffset(String timezone) {
    try {
      if (timezone == 'UTC') {
        return 0;
      }
      // Cek format "UTC+XX:XX"
      if (timezone.startsWith('UTC')) {
        String offsetStr = timezone.substring(
          3,
        ); // Hasil: "+07:00" atau "-05:00"
        List<String> parts = offsetStr.split(':'); // Hasil: ["+07", "00"]
        if (parts.isNotEmpty) {
          return int.parse(parts[0]); // Mengurai "+07" menjadi integer 7
        }
      }
    } catch (e) {
      // Catat error jika parsing gagal
      print('Error parsing timezone offset "$timezone": $e');
    }
    // Default ke UTC jika gagal parsing
    return 0;
  }

  /// Menghitung waktu saat ini untuk zona waktu negara.
  ///
  /// [countryTimezone] adalah string dari API (misal: "UTC+07:00").
  static String getCurrentTimeForCountry(String countryTimezone) {
    final offset = _parseOffset(countryTimezone);
    final now = DateTime.now().toUtc().add(Duration(hours: offset));
    return _formatTime(now);
  }

  /// Menghitung waktu saat ini untuk zona waktu yang *dipilih* pengguna dari dropdown.
  ///
  /// [selectedTimezone] adalah singkatan dari Peta (misal: "WIB").
  /// (Catatan: Parameter [countryTimezone] saat ini tidak digunakan di fungsi ini).
  static String getTimeForSelectedTimezone(
    String countryTimezone,
    String selectedTimezone,
  ) {
    // Ambil offset dari map internal, bukan dari string "UTC+..."
    final selectedOffset = _timezoneOffsets[selectedTimezone] ?? 0;
    final nowUtc = DateTime.now().toUtc();
    final convertedTime = nowUtc.add(Duration(hours: selectedOffset));
    return _formatTime(convertedTime);
  }
}
