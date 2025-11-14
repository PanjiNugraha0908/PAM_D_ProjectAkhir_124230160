import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service untuk mengambil data ekonomi dari World Bank API
class WorldBankService {
  static const String _baseUrl = 'https://api.worldbank.org/v2';

  /// Mendapatkan GDP dan GDP per capita dari World Bank
  /// countryCode: ISO 3166-1 alpha-2 code (misal: "ID" untuk Indonesia)
  static Future<Map<String, dynamic>> getEconomicData(
    String countryCode,
  ) async {
    try {
      // World Bank API menggunakan ISO Alpha-2 code (2 huruf)
      final String code = countryCode.toUpperCase();

      // Ambil GDP Total (NY.GDP.MKTP.CD)
      final gdpResponse = await http
          .get(
            Uri.parse(
              '$_baseUrl/country/$code/indicator/NY.GDP.MKTP.CD?format=json&date=2022:2023&per_page=1',
            ),
          )
          .timeout(Duration(seconds: 10));

      // Ambil GDP per Capita (NY.GDP.PCAP.CD)
      final gdpPerCapitaResponse = await http
          .get(
            Uri.parse(
              '$_baseUrl/country/$code/indicator/NY.GDP.PCAP.CD?format=json&date=2022:2023&per_page=1',
            ),
          )
          .timeout(Duration(seconds: 10));

      // Ambil Income Level
      final countryInfoResponse = await http
          .get(
            Uri.parse('$_baseUrl/country/$code?format=json'),
          )
          .timeout(Duration(seconds: 10));

      double? gdpTotal;
      double? gdpPerCapita;
      String? incomeLevel;

      // Parse GDP Total
      if (gdpResponse.statusCode == 200) {
        final data = json.decode(gdpResponse.body);
        if (data is List && data.length > 1 && data[1] is List) {
          final gdpData = data[1];
          if (gdpData.isNotEmpty && gdpData[0]['value'] != null) {
            gdpTotal = (gdpData[0]['value'] as num).toDouble();
          }
        }
      }

      // Parse GDP per Capita
      if (gdpPerCapitaResponse.statusCode == 200) {
        final data = json.decode(gdpPerCapitaResponse.body);
        if (data is List && data.length > 1 && data[1] is List) {
          final gdpData = data[1];
          if (gdpData.isNotEmpty && gdpData[0]['value'] != null) {
            gdpPerCapita = (gdpData[0]['value'] as num).toDouble();
          }
        }
      }

      // Parse Income Level
      if (countryInfoResponse.statusCode == 200) {
        final data = json.decode(countryInfoResponse.body);
        if (data is List && data.length > 1 && data[1] is List) {
          final countryData = data[1];
          if (countryData.isNotEmpty && countryData[0]['incomeLevel'] != null) {
            incomeLevel = countryData[0]['incomeLevel']['value'];
          }
        }
      }

      return {
        'success': true,
        'gdpTotal': gdpTotal,
        'gdpPerCapita': gdpPerCapita,
        'incomeLevel': incomeLevel,
      };
    } catch (e) {
      print('Error fetching World Bank data: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Mendapatkan Human Development Index dari UNDP (simulasi dengan World Bank)
  /// Note: World Bank tidak memiliki HDI langsung, ini adalah simplified version
  static Future<Map<String, dynamic>> getHDI(String countryCode) async {
    try {
      final String code = countryCode.toUpperCase();

      // Life Expectancy (SP.DYN.LE00.IN)
      final lifeExpectancyResponse = await http
          .get(
            Uri.parse(
              '$_baseUrl/country/$code/indicator/SP.DYN.LE00.IN?format=json&date=2022:2023&per_page=1',
            ),
          )
          .timeout(Duration(seconds: 10));

      // Literacy Rate (SE.ADT.LITR.ZS) sebagai proxy untuk education
      final literacyResponse = await http
          .get(
            Uri.parse(
              '$_baseUrl/country/$code/indicator/SE.ADT.LITR.ZS?format=json&date=2020:2023&per_page=1',
            ),
          )
          .timeout(Duration(seconds: 10));

      double? lifeExpectancy;
      double? literacyRate;

      // Parse Life Expectancy
      if (lifeExpectancyResponse.statusCode == 200) {
        final data = json.decode(lifeExpectancyResponse.body);
        if (data is List && data.length > 1 && data[1] is List) {
          final leData = data[1];
          if (leData.isNotEmpty && leData[0]['value'] != null) {
            lifeExpectancy = (leData[0]['value'] as num).toDouble();
          }
        }
      }

      // Parse Literacy Rate
      if (literacyResponse.statusCode == 200) {
        final data = json.decode(literacyResponse.body);
        if (data is List && data.length > 1 && data[1] is List) {
          final litData = data[1];
          if (litData.isNotEmpty && litData[0]['value'] != null) {
            literacyRate = (litData[0]['value'] as num).toDouble();
          }
        }
      }

      // Simplified HDI calculation (bukan rumus resmi UNDP)
      double? hdi;
      if (lifeExpectancy != null && literacyRate != null) {
        // Normalisasi sederhana (0-1)
        double lifeIndex = (lifeExpectancy - 20) / 65; // Asumsi range 20-85
        double eduIndex = literacyRate / 100; // Sudah dalam persen
        hdi = (lifeIndex + eduIndex) / 2; // Average sederhana
        hdi = hdi.clamp(0.0, 1.0); // Pastikan 0-1
      }

      return {
        'success': true,
        'hdi': hdi,
        'lifeExpectancy': lifeExpectancy,
        'literacyRate': literacyRate,
      };
    } catch (e) {
      print('Error fetching HDI data: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
