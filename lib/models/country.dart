// lib/models/country.dart

/// Model data yang merepresentasikan satu negara.
///
/// Model ini berisi semua informasi detail yang relevan
/// yang didapat dari API restcountries.com.
class Country {
  final String name;
  final String officialName;
  final String flagUrl;
  final String capital;
  final String region;
  final String subregion;
  final int population;
  final double area;
  final List<String> languages;
  final Map<String, dynamic> currencies;
  final List<String> timezones;
  final String callingCode;
  final List<String> tld;
  final double latitude;
  final double longitude;

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
    required this.latitude,
    required this.longitude,
  });

  /// Factory constructor untuk membuat instance [Country] dari data JSON (Map).
  ///
  /// Ini menangani parsing data yang kompleks dan bersarang dari
  /// respons API restcountries.com, termasuk data opsional dan
  /// struktur data yang tidak konsisten.
  factory Country.fromJson(Map<String, dynamic> json) {
    // Parsing 'languages': API mengembalikan Map ({"fra": "French"}),
    // kita hanya ambil 'values' (["French"]).
    List<String> languageList = [];
    if (json['languages'] != null) {
      languageList = (json['languages'] as Map).values.toList().cast<String>();
    }

    // Parsing 'callingCode': API mengembalikan Map ('idd')
    // yang berisi 'root' dan 'suffixes'.
    String callingCode = '';
    if (json['idd'] != null) {
      callingCode =
          (json['idd']['root'] ?? '') +
          (json['idd']['suffixes'] != null && json['idd']['suffixes'].isNotEmpty
              ? json['idd']['suffixes'][0] // Ambil suffix pertama
              : '');
    }

    // Parsing 'latlng': API mengembalikan List [latitude, longitude].
    final List<dynamic>? latlng = json['latlng'] as List<dynamic>?;
    final double lat = latlng != null && latlng.length >= 1
        ? (json['latlng'][0] as num).toDouble()
        : 0.0; // Default jika data tidak ada
    final double lng = latlng != null && latlng.length >= 2
        ? (json['latlng'][1] as num).toDouble()
        : 0.0; // Default jika data tidak ada

    return Country(
      name: json['name']['common'] ?? '',
      officialName: json['name']['official'] ?? '',
      flagUrl: json['flags']['png'] ?? '',
      // Parsing 'capital': API mengembalikan List, kita ambil yg pertama.
      capital: json['capital'] != null && json['capital'].isNotEmpty
          ? json['capital'][0]
          : 'N/A', // Default jika tidak ada ibu kota
      region: json['region'] ?? '',
      subregion: json['subregion'] ?? 'N/A',
      population: json['population'] ?? 0,
      area: (json['area'] ?? 0).toDouble(),
      languages: languageList,
      currencies: json['currencies'] ?? {},
      timezones: List<String>.from(json['timezones'] ?? []),
      callingCode: callingCode,
      tld: List<String>.from(json['tld'] ?? []),
      latitude: lat,
      longitude: lng,
    );
  }
}
// <-- KURUNG KURAWAL '}' EKSTRA SUDAH SAYA HAPUS DARI SINI