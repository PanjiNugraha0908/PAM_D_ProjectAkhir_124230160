import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsService {
  // API Key GRATIS dari NewsAPI.org (Ganti dengan API key Anda)
  // Daftar di: https://newsapi.org/register
  static const String _apiKey = 'af3497dfe2774fcaa42f2015e16bfa07'; // ⚠️ GANTI INI!
  static const String _baseUrl = 'https://newsapi.org/v2';

  /// Mendapatkan berita global top headlines (bahasa Inggris)
  static Future<Map<String, dynamic>> getGlobalNews({
    int pageSize = 10,
    String category = 'general',
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/top-headlines?language=en&pageSize=$pageSize&category=$category&apiKey=$_apiKey',
      );

      final response = await http.get(uri).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'ok') {
          final articles = (data['articles'] as List)
              .where((article) => 
                article['title'] != null && 
                article['title'] != '[Removed]' &&
                article['urlToImage'] != null)
              .toList();

          return {
            'success': true,
            'articles': articles,
            'totalResults': data['totalResults'] ?? 0,
          };
        } else {
          return {
            'success': false,
            'error': data['message'] ?? 'Unknown error',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Invalid API key. Please check your NewsAPI key.',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load news (${response.statusCode})',
        };
      }
    } catch (e) {
      print('Error fetching news: $e');
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Format tanggal artikel menjadi relatif (contoh: "2 hours ago")
  static String formatPublishedDate(String? dateStr) {
    if (dateStr == null) return 'Unknown date';
    
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 0) {
        return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateStr;
    }
  }
}