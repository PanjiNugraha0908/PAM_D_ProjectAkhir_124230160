import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  static const String _apiKey = '1f2991c687c1b1f1a67279adc8a8f9cf';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric&lang=id',
      );

      final response = await http.get(uri).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        return {
          'success': true,
          'temperature': data['main']['temp'],
          'feelsLike': data['main']['feels_like'],
          'tempMin': data['main']['temp_min'],
          'tempMax': data['main']['temp_max'],
          'humidity': data['main']['humidity'],
          'pressure': data['main']['pressure'],
          'description': data['weather'][0]['description'],
          'icon': data['weather'][0]['icon'],
          'windSpeed': data['wind']['speed'],
          'cloudiness': data['clouds']['all'],
          'cityName': data['name'],
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'error': 'Kota tidak ditemukan'};
      } else {
        return {
          'success': false,
          'error': 'Gagal mendapatkan data cuaca (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  static String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  static String getWeatherEmoji(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('cerah') || desc.contains('clear')) return '☀️';
    if (desc.contains('berawan') || desc.contains('cloud')) return '☁️';
    if (desc.contains('hujan') || desc.contains('rain')) return '🌧️';
    if (desc.contains('badai') || desc.contains('thunder')) return '⛈️';
    if (desc.contains('salju') || desc.contains('snow')) return '❄️';
    if (desc.contains('kabut') || desc.contains('fog') || desc.contains('mist')) return '🌫️';
    return '🌤️';
  }
}
