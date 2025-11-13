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

  // TAMBAHAN BARU: Metrik Ekonomi & Pembangunan
  double? gdpTotal; // GDP Total (dalam USD)
  double? gdpPerCapita; // GDP per Kapita (dalam USD)
  double? hdi; // Human Development Index (0-1)
  double? happinessScore; // Happiness Score (0-10)
  int? happinessRank; // Peringkat Kebahagiaan
  String? incomeLevel; // Level pendapatan (High, Upper middle, etc)
  
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
    // Metrik opsional
    this.gdpTotal,
    this.gdpPerCapita,
    this.hdi,
    this.happinessScore,
    this.happinessRank,
    this.incomeLevel,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    List<String> languageList = [];
    if (json['languages'] != null) {
      languageList = (json['languages'] as Map).values.toList().cast<String>();
    }

    String callingCode = '';
    if (json['idd'] != null) {
      callingCode =
          (json['idd']['root'] ?? '') +
          (json['idd']['suffixes'] != null && json['idd']['suffixes'].isNotEmpty
              ? json['idd']['suffixes'][0]
              : '');
    }

    final List<dynamic>? latlng = json['latlng'] as List<dynamic>?;
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
      // Metrik tambahan (akan diisi dari API terpisah)
      gdpTotal: null,
      gdpPerCapita: null,
      hdi: null,
      happinessScore: null,
      happinessRank: null,
      incomeLevel: null,
    );
  }

  // Method untuk copy dengan metrik baru
  Country copyWith({
    double? gdpTotal,
    double? gdpPerCapita,
    double? hdi,
    double? happinessScore,
    int? happinessRank,
    String? incomeLevel,
  }) {
    return Country(
      name: this.name,
      officialName: this.officialName,
      flagUrl: this.flagUrl,
      capital: this.capital,
      region: this.region,
      subregion: this.subregion,
      population: this.population,
      area: this.area,
      languages: this.languages,
      currencies: this.currencies,
      timezones: this.timezones,
      callingCode: this.callingCode,
      tld: this.tld,
      latitude: this.latitude,
      longitude: this.longitude,
      gdpTotal: gdpTotal ?? this.gdpTotal,
      gdpPerCapita: gdpPerCapita ?? this.gdpPerCapita,
      hdi: hdi ?? this.hdi,
      happinessScore: happinessScore ?? this.happinessScore,
      happinessRank: happinessRank ?? this.happinessRank,
      incomeLevel: incomeLevel ?? this.incomeLevel,
    );
  }
}