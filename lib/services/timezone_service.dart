import 'package:intl/intl.dart';

class TimezoneService {
  // Daftar offset jam dari UTC
  static final Map<String, int> _timezoneOffsets = {
    'UTC': 0, 'WIB': 7, 'WITA': 8, 'WIT': 9,
    'PDT': -7, 'EDT': -4, 'CET': 1, 'EET': 2,
    'JST': 9, 'KST': 9, 'AEST': 10, 'NZST': 12,
    'IST': 5, // India Standard Time (UTC+5:30) - Disederhanakan ke 5
  };

  // Nama lengkap untuk zona waktu
  static final Map<String, String> _timezoneNames = {
    'WIB': 'Waktu Indonesia Barat',
    'WITA': 'Waktu Indonesia Tengah',
    'WIT': 'Waktu Indonesia Timur',
    'UTC': 'Universal Terkoordinasi',
    'PDT': 'Waktu Siang Pasifik',
    'EDT': 'Waktu Siang Timur',
    'CET': 'Waktu Eropa Tengah',
    'EET': 'Waktu Eropa Timur',
    'JST': 'Waktu Standar Jepang',
    'KST': 'Waktu Standar Korea',
    'AEST': 'Waktu Standar Australia Timur',
    'NZST': 'Waktu Standar Selandia Baru',
    'IST': 'Waktu Standar India',
  };

  static List<String> getAvailableTimezones() {
    return _timezoneOffsets.keys.toList();
  }

  static String getTimezoneName(String timezone) {
    return _timezoneNames[timezone] ?? timezone;
  }

  // Helper untuk format HH:mm:ss
  static String _formatTime(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  // =================================================================
  // ===== FUNGSI INI DIPERBAIKI AGAR LEBIH AMAN (ROBUST) =====
  // =================================================================
  static int _parseOffset(String timezone) {
    // Contoh: "UTC+09:00", "UTC-05:00", "UTC"
    try {
      if (timezone == 'UTC') {
        return 0;
      }
      if (timezone.startsWith('UTC')) {
        // Hapus "UTC", sisa: "+09:00" atau "-05:00"
        String offsetStr = timezone.substring(3); 
        // Pisahkan berdasarkan ':' -> ["+09", "00"]
        List<String> parts = offsetStr.split(':');
        // Ambil bagian jam
        if (parts.isNotEmpty) {
          // int.parse("+09") -> 9
          // int.parse("-05") -> -5
          // Ini aman karena int.parse bisa menangani tanda '+' atau '-'
          return int.parse(parts[0]); 
        }
      }
    } catch (e) {
      print('Error parsing timezone offset "$timezone": $e');
      // Kembali ke 0 jika gagal
    }
    return 0; // Default ke UTC jika parsing gagal
  }
  // =================================================================
  // ===== AKHIR PERBAIKAN =====
  // =================================================================


  static String getCurrentTimeForCountry(String countryTimezone) {
    // countryTimezone looks like "UTC+09:00"
    final offset = _parseOffset(countryTimezone);
    final now = DateTime.now().toUtc().add(Duration(hours: offset));
    return _formatTime(now);
  }

  static String getTimeForSelectedTimezone(String countryTimezone, String selectedTimezone) {
    // Fungsi ini BUKAN mengkonversi dari waktu negara,
    // tapi menampilkan waktu SAAT INI di zona waktu yang dipilih (WIB, WITA, dll)
    
    final selectedOffset = _timezoneOffsets[selectedTimezone] ?? 0;
    
    final nowUtc = DateTime.now().toUtc();
    final convertedTime = nowUtc.add(Duration(hours: selectedOffset));
    return _formatTime(convertedTime);
  }
}