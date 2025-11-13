// lib/services/country_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/country.dart';

class CountryService {
  static const String _baseUrl = 'https://restcountries.com/v3.1';

  /// Mencari satu negara berdasarkan nama
  static Future<Country> searchCountryByName(String name) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/name/$name'));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          // Ambil hasil yang paling relevan (biasanya yang pertama)
          return Country.fromJson(data.firstWhere(
            (c) =>
                c['name']['common'].toString().toLowerCase() ==
                name.toLowerCase(),
            orElse: () =>
                data[0], // fallback ke data pertama jika tidak ada yg persis
          ));
        } else {
          throw Exception('Negara tidak ditemukan.');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Negara tidak ditemukan.');
      } else {
        throw Exception('Gagal memuat data (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error CountryService: $e');
      throw Exception('Gagal mencari negara: $e');
    }
  }
}
