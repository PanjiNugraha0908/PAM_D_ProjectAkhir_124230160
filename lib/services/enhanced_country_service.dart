import '../models/country.dart';
import 'world_bank_service.dart';
import 'happiness_service.dart';

/// Service untuk meng-enrich data Country dengan metrik tambahan
class EnhancedCountryService {
  /// Meng-enrich satu Country object dengan semua metrik tambahan
  static Future<Country> enrichCountryData(Country country) async {
    // Ambil country code (ISO Alpha-2) dari cca2 field
    // NOTE: RestCountries API menyediakan cca2, tapi kita perlu update Country model
    // Untuk sementara, kita gunakan mapping manual
    String countryCode = _getCountryCode(country.name);

    // Parallel fetch semua data
    final results = await Future.wait([
      WorldBankService.getEconomicData(countryCode),
      WorldBankService.getHDI(countryCode),
    ]);

    final economicData = results[0];
    final hdiData = results[1];
    final happinessData = HappinessService.getHappinessScore(country.name);

    // Update country dengan data baru
    return country.copyWith(
      gdpTotal: economicData['gdpTotal'],
      gdpPerCapita: economicData['gdpPerCapita'],
      incomeLevel: economicData['incomeLevel'],
      hdi: hdiData['hdi'],
      happinessScore: happinessData['success'] ? happinessData['score'] : null,
      happinessRank: happinessData['success'] ? happinessData['rank'] : null,
    );
  }

  /// Mapping nama negara ke ISO Alpha-2 code (untuk World Bank API)
  static String _getCountryCode(String countryName) {
    const Map<String, String> countryCodeMap = {
      'Indonesia': 'ID',
      'United States': 'US',
      'United Kingdom': 'GB',
      'Australia': 'AU',
      'Canada': 'CA',
      'Germany': 'DE',
      'France': 'FR',
      'Italy': 'IT',
      'Spain': 'ES',
      'Japan': 'JP',
      'China': 'CN',
      'India': 'IN',
      'Brazil': 'BR',
      'Mexico': 'MX',
      'Russia': 'RU',
      'South Korea': 'KR',
      'Singapore': 'SG',
      'Malaysia': 'MY',
      'Thailand': 'TH',
      'Philippines': 'PH',
      'Vietnam': 'VN',
      'Saudi Arabia': 'SA',
      'Turkey': 'TR',
      'Argentina': 'AR',
      'Chile': 'CL',
      'Netherlands': 'NL',
      'Switzerland': 'CH',
      'Sweden': 'SE',
      'Norway': 'NO',
      'Denmark': 'DK',
      'Finland': 'FI',
      'Belgium': 'BE',
      'Austria': 'AT',
      'Poland': 'PL',
      'New Zealand': 'NZ',
      // Tambahkan mapping lainnya sesuai kebutuhan
    };

    return countryCodeMap[countryName] ?? 'ID'; // Default ke Indonesia
  }
}
