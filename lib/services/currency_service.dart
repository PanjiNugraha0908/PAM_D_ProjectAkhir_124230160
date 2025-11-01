import 'package:http/http.dart' as http;
import 'dart:convert';

/// Kelas helper statis untuk menangani konversi mata uang.
///
/// Menggunakan API gratis dari exchangerate-api.com untuk mendapatkan
/// nilai tukar mata uang terbaru.
class CurrencyService {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';

  /// Mengkonversi sejumlah [amount] mata uang dari [fromCurrency] ke [toCurrency].
  ///
  /// [fromCurrency] dan [toCurrency] harus berupa kode mata uang 3-huruf (misal: "USD", "IDR").
  ///
  /// Mengembalikan [Map<String, dynamic>] yang berisi:
  /// - `success` (bool): Status konversi.
  /// - `result` (double): Hasil konversi.
  /// - `rate` (double, opsional): Nilai tukar yang digunakan.
  /// - `error` (String, opsional): Pesan error jika gagal.
  static Future<Map<String, dynamic>> convertCurrency(
    String fromCurrency,
    String toCurrency,
    double amount,
  ) async {
    try {
      final url = '$_baseUrl/$fromCurrency';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['rates'] != null && data['rates'][toCurrency] != null) {
          // Konversi rate ke double
          double rate = (data['rates'][toCurrency] as num).toDouble();
          double result = amount * rate;
          return {'success': true, 'result': result, 'rate': rate};
        }
      }
      // Gagal jika status code bukan 200 atau rate tidak ditemukan
      return {
        'success': false,
        'result': 0.0,
        'error': 'Gagal mendapatkan rate',
      };
    } catch (e) {
      // Menangani error jaringan atau parsing
      print('Error converting currency: $e');
      return {'success': false, 'result': 0.0, 'error': e.toString()};
    }
  }
}
