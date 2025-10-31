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
    );
  }
}