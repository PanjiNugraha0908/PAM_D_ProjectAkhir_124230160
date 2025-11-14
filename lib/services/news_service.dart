import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsService {
  static const String _apiKey = 'af3497dfe2774fcaa42f2015e16bfa07';
  static const String _baseUrl = 'https://newsapi.org/v2';

  static Future<Map<String, dynamic>> getTopHeadlines(String countryCode) async {
    try {
      final code = countryCode.toLowerCase();
      final uri = Uri.parse(
        '$_baseUrl/top-headlines?country=$code&apiKey=$_apiKey&pageSize=5',
      );

      final response = await http.get(uri).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'ok' && data['articles'] != null) {
          List articles = data['articles'];
          
          List<Map<String, dynamic>> validArticles = articles
              .where((article) => 
                  article['title'] != null && 
                  article['url'] != null &&
                  article['title'] != '[Removed]')
              .map((article) => {
                    'title': article['title'] ?? 'No Title',
                    'description': article['description'] ?? '',
                    'url': article['url'] ?? '',
                    'urlToImage': article['urlToImage'] ?? '',
                    'publishedAt': article['publishedAt'] ?? '',
                    'source': article['source']?['name'] ?? 'Unknown',
                  })
              .toList();

          return {
            'success': true,
            'articles': validArticles,
            'totalResults': validArticles.length,
          };
        } else {
          return {'success': false, 'error': 'Tidak ada berita tersedia'};
        }
      } else if (response.statusCode == 426) {
        return {'success': false, 'error': 'API Key memerlukan upgrade'};
      } else {
        return {
          'success': false,
          'error': 'Gagal mendapatkan berita (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> searchNews(String countryName) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/everything?q=$countryName&sortBy=publishedAt&apiKey=$_apiKey&pageSize=5',
      );

      final response = await http.get(uri).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'ok' && data['articles'] != null) {
          List articles = data['articles'];
          
          List<Map<String, dynamic>> validArticles = articles
              .where((article) => 
                  article['title'] != null && 
                  article['url'] != null &&
                  article['title'] != '[Removed]')
              .map((article) => {
                    'title': article['title'] ?? 'No Title',
                    'description': article['description'] ?? '',
                    'url': article['url'] ?? '',
                    'urlToImage': article['urlToImage'] ?? '',
                    'publishedAt': article['publishedAt'] ?? '',
                    'source': article['source']?['name'] ?? 'Unknown',
                  })
              .toList();

          return {
            'success': true,
            'articles': validArticles,
            'totalResults': validArticles.length,
          };
        } else {
          return {'success': false, 'error': 'Tidak ada berita tersedia'};
        }
      } else {
        return {
          'success': false,
          'error': 'Gagal mendapatkan berita (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  static String formatPublishedDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inSeconds < 60) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
      if (diff.inDays == 1) return 'Kemarin';
      if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}