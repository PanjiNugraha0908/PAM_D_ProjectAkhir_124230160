import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyService {
  // Menggunakan API exchangerate-api.com (gratis, tidak perlu API key)
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';

  // Konversi mata uang
  static Future<Map<String, dynamic>> convertCurrency(
    String fromCurrency,
    String toCurrency,
    double amount,
  ) async {
    try {
      final url = '$_baseUrl/$fromCurrency';
      print('Fetching: $url');
      
      final response = await http.get(Uri.parse(url));
      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['rates'] != null && data['rates'][toCurrency] != null) {
          double rate = data['rates'][toCurrency].toDouble();
          double result = amount * rate;
          return {
            'success': true,
            'result': result,
            'rate': rate,
          };
        }
      }
      return {'success': false, 'result': 0.0, 'error': 'Gagal mendapatkan rate'};
    } catch (e) {
      print('Error converting currency: $e');
      return {'success': false, 'result': 0.0, 'error': e.toString()};
    }
  }
}