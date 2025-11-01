// lib/models/country.dart

class Country {
  final String name;
  final String officialName; // <-- DIBUTUHKAN
  final String flagUrl;
  final String capital;
  final String region;
  final String subregion; // <-- DIBUTUHKAN
  final int population;
  final double area; // <-- DIBUTUHKAN
  final List<String> languages; // <-- DIBUTUHKAN
  final Map<String, dynamic> currencies; // <-- DIBUTUHKAN
  final List<String> timezones;
  final String callingCode;
  final List<String> tld;
  // ⌄ BARU: Koordinat Negara
  final double latitude;
  final double longitude;
  // ⌃ AKHIR BARU

  Country({
    required this.name,
    required this.officialName,
    required this.flagUrl,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.population,
    required this.area,
    required this.languages,
    required this.currencies,
    required this.timezones,
    required this.callingCode,
    required this.tld,
    // ⌄ BARU
    required this.latitude,
    required this.longitude,
    // ⌃ AKHIR BARU
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    List<String> languageList = [];
    if (json['languages'] != null) {
      languageList = (json['languages'] as Map).values.toList().cast<String>();
    }

    String callingCode = '';
    if (json['idd'] != null) {
      callingCode = (json['idd']['root'] ?? '') + 
                    (json['idd']['suffixes'] != null && json['idd']['suffixes'].isNotEmpty 
                        ? json['idd']['suffixes'][0] 
                        : '');
    }
    
    // ⌄ BARU: Parsing latlng dari API (asumsi menggunakan restcountries.com/v3.1)
    final List<dynamic>? latlng = json['latlng'] as List<dynamic>?;
    // Ambil latitude (indeks 0) dan longitude (indeks 1)
    final double lat = latlng != null && latlng.length >= 1 ? (json['latlng'][0] as num).toDouble() : 0.0;
    final double lng = latlng != null && latlng.length >= 2 ? (json['latlng'][1] as num).toDouble() : 0.0;
    // ⌃ AKHIR BARU

    return Country(
      name: json['name']['common'] ?? '',
      officialName: json['name']['official'] ?? '',
      flagUrl: json['flags']['png'] ?? '',
      capital: json['capital'] != null && json['capital'].isNotEmpty 
          ? json['capital'][0] 
          : 'N/A',
      region: json['region'] ?? '',
      subregion: json['subregion'] ?? 'N/A',
      population: json['population'] ?? 0,
      area: (json['area'] ?? 0).toDouble(),
      languages: languageList,
      currencies: json['currencies'] ?? {},
      timezones: List<String>.from(json['timezones'] ?? []),
      callingCode: callingCode,
      tld: List<String>.from(json['tld'] ?? []),
      // ⌄ BARU
      latitude: lat,
      longitude: lng,
      // ⌃ AKHIR BARU
    );
  }
}