import 'package:intl/intl.dart';

class TimezoneService {
  // Daftar offset jam dari UTC
  static final Map<String, int> _timezoneOffsets = {
    'UTC': 0, 'WIB': 7, 'WITA': 8, 'WIT': 9,
    // PDT, EDT, JST, KST, AEST, NZST, IST DIBUANG
    'LONDON': 0, // London Standard Time (GMT/UTC+0)
  };

  // Nama lengkap untuk zona waktu
  static final Map<String, String> _timezoneNames = {
    'WIB': 'Waktu Indonesia Barat',
    'WITA': 'Waktu Indonesia Tengah',
    'WIT': 'Waktu Indonesia Timur',
    'UTC': 'Universal Terkoordinasi',
    'LONDON': 'London (GMT)',
  };

  static List<String> getAvailableTimezones() {
    // Hanya kembalikan daftar yang diminta untuk dropdown
    return ['WIB', 'WITA', 'WIT', 'LONDON'];
  }

  // =================================================================
  // ===== PERBAIKAN UTAMA: FUNGSI INI KINI DIDEFINISIKAN KEMBALI =====
  // =================================================================
  static String getTimezoneName(String timezone) {
    return _timezoneNames[timezone] ?? timezone;
  }
  // =================================================================

  // Helper untuk format HH:mm:ss
  static String _formatTime(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  // FUNGSI _parseOffset (AMAN)
  static int _parseOffset(String timezone) {
    try {
      if (timezone == 'UTC') {
        return 0;
      }
      if (timezone.startsWith('UTC')) {
        String offsetStr = timezone.substring(3); 
        List<String> parts = offsetStr.split(':');
        if (parts.isNotEmpty) {
          return int.parse(parts[0]); 
        }
      }
    } catch (e) {
      print('Error parsing timezone offset "$timezone": $e');
    }
    return 0;
  }

  static String getCurrentTimeForCountry(String countryTimezone) {
    final offset = _parseOffset(countryTimezone);
    final now = DateTime.now().toUtc().add(Duration(hours: offset));
    return _formatTime(now);
  }

  static String getTimeForSelectedTimezone(String countryTimezone, String selectedTimezone) {
    final selectedOffset = _timezoneOffsets[selectedTimezone] ?? 0;
    final nowUtc = DateTime.now().toUtc();
    final convertedTime = nowUtc.add(Duration(hours: selectedOffset));
    return _formatTime(convertedTime);
  }
}