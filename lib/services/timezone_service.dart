class TimezoneService {
  // Zona waktu Indonesia dan Inggris dengan offset UTC
  static const Map<String, int> timezoneOffsets = {
    'WIB': 7, // UTC+7
    'WITA': 8, // UTC+8
    'WIT': 9, // UTC+9
    'GMT': 0, // UTC+0
  };

  // List zona waktu yang tersedia untuk dipilih
  static List<String> getAvailableTimezones() {
    return ['WIB', 'WITA', 'WIT', 'GMT'];
  }

  // Mengekstrak offset UTC dari string timezone
  static int getTimezoneOffset(String timezone) {
    // Format timezone bisa "UTC+XX:XX" atau "UTC-XX:XX" atau "+XX:XX" atau "-XX:XX"
    String normalizedTimezone = timezone.toUpperCase();
    if (normalizedTimezone.startsWith('UTC')) {
      normalizedTimezone = normalizedTimezone.substring(3);
    }

    try {
      // Cari tanda + atau -
      int sign = normalizedTimezone.startsWith('-') ? -1 : 1;
      String offsetStr = normalizedTimezone.replaceAll(RegExp(r'[^\d:]'), '');

      if (offsetStr.contains(':')) {
        List<String> parts = offsetStr.split(':');
        int hours = int.parse(parts[0]);
        return sign * hours;
      } else if (offsetStr.isNotEmpty) {
        return sign * int.parse(offsetStr);
      }
    } catch (e) {
      // Jika gagal parse, coba cek apakah ini timezone Indonesia
      if (normalizedTimezone.contains('WIB')) return 7;
      if (normalizedTimezone.contains('WITA')) return 8;
      if (normalizedTimezone.contains('WIT')) return 9;
    }

    return 0; // Default ke GMT
  }

  // Mendapatkan waktu berdasarkan timezone negara
  static String getCurrentTimeForCountry(String countryTimezone) {
    DateTime utcNow = DateTime.now().toUtc();
    int offset = getTimezoneOffset(countryTimezone);
    DateTime localTime = utcNow.add(Duration(hours: offset));
    return formatTime(localTime);
  }

  // Mendapatkan waktu untuk timezone yang dipilih
  static String getTimeForSelectedTimezone(
    String countryTimezone,
    String selectedTimezone,
  ) {
    // Untuk mendapatkan waktu di timezone yang dipilih pada saat yang sama
    // cukup tambahkan offset timezone yang dipilih ke waktu UTC saat ini.
    // Contoh: jika saat ini di Jepang (UTC+9) jam 18:25, maka UTC = 09:25.
    // Untuk WIB (UTC+7) waktu yang sama = UTC + 7 = 16:25.
    DateTime utcNow = DateTime.now().toUtc();
    int selectedOffset = timezoneOffsets[selectedTimezone] ?? 0;
    DateTime localTime = utcNow.add(Duration(hours: selectedOffset));
    return formatTime(localTime);
  }

  // Format waktu ke string
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  // Mendapatkan waktu saat ini untuk semua zona waktu
  static Map<String, String> getCurrentTimes() {
    DateTime utcNow = DateTime.now().toUtc();
    Map<String, String> results = {};

    timezoneOffsets.forEach((timezone, offset) {
      DateTime localTime = utcNow.add(Duration(hours: offset));
      results[timezone] = formatTime(localTime);
    });

    return results;
  }

  // Mendapatkan nama lengkap zona waktu
  static String getTimezoneName(String code) {
    switch (code) {
      case 'WIB':
        return 'Waktu Indonesia Barat';
      case 'WITA':
        return 'Waktu Indonesia Tengah';
      case 'WIT':
        return 'Waktu Indonesia Timur';
      case 'GMT':
        return 'Greenwich Mean Time (Inggris)';
      default:
        return code;
    }
  }
}
