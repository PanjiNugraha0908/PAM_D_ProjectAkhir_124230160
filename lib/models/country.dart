// Model Data untuk merepresentasikan informasi detail Negara
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
  // Koordinat Negara (untuk peta)
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

  // Factory constructor untuk membuat objek Country dari data JSON (API Response)
  factory Country.fromJson(Map<String, dynamic> json) {
    List<String> languageList = [];
    if (json['languages'] != null) {
      // Mengambil nilai (nama bahasa) dari map languages
      languageList = (json['languages'] as Map).values.toList().cast<String>();
    }

    String callingCode = '';
    if (json['idd'] != null) {
      // Menggabungkan root dan suffix untuk kode panggilan penuh
      callingCode =
          (json['idd']['root'] ?? '') +
          (json['idd']['suffixes'] != null && json['idd']['suffixes'].isNotEmpty
              ? json['idd']['suffixes'][0]
              : '');
    }

    // Parsing latlng (koordinat) dari API
    final List<dynamic>? latlng = json['latlng'] as List<dynamic>?;
    // Mengambil latitude (indeks 0) dan longitude (indeks 1), default 0.0 jika tidak ada
    final double lat = latlng != null && latlng.length >= 1
        ? (json['latlng'][0] as num).toDouble()
        : 0.0;
    final double lng = latlng != null && latlng.length >= 2
        ? (json['latlng'][1] as num).toDouble()
        : 0.0;

    return Country(
      name: json['name']['common'] ?? '',
      officialName: json['name']['official'] ?? '',
      flagUrl: json['flags']['png'] ?? '',
      // Mengambil ibu kota pertama, default 'N/A'
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
      latitude: lat,
      longitude: lng,
    );
  }
}
