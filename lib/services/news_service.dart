import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsService {
  // API Key GRATIS dari NewsAPI.org
  static const String _apiKey = 'af3497dfe2774fcaa42f2015e16bfa07';
  static const String _baseUrl = 'https://newsapi.org/v2';

  /// Mendapatkan berita global top headlines (bahasa Inggris)
  ///
  /// CATATAN PENTING tentang Real-time:
  /// - API NewsAPI versi GRATIS memiliki delay ~15-30 menit dari publikasi asli
  /// - Artikel ditandai dengan timestamp 'publishedAt'
  /// - Untuk berita truly real-time, perlu versi berbayar ($449/bulan)
  /// - Versi gratis: max 100 request/hari, hanya top headlines
  static Future<Map<String, dynamic>> getGlobalNews({
    int pageSize = 5,
    String category = 'general',
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/top-headlines?language=en&pageSize=$pageSize&category=$category&apiKey=$_apiKey',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'ExploreUnity/1.0',
          'Accept': 'application/json',
        },
      ).timeout(
        Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'ok') {
          // Filter artikel yang valid (ada title, url, dan gambar)
          final articles = (data['articles'] as List)
              .where((article) =>
                  article['title'] != null &&
                  article['title'] != '[Removed]' &&
                  article['url'] != null &&
                  article['url'].toString().isNotEmpty &&
                  _isValidUrl(article['url']) && // Validasi URL
                  article['urlToImage'] != null)
              .toList();

          return {
            'success': true,
            'articles': articles,
            'totalResults': data['totalResults'] ?? 0,
            'lastUpdated': DateTime.now().toIso8601String(),
          };
        } else {
          return {
            'success': false,
            'error': data['message'] ?? 'Unknown error from API',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Invalid API key',
        };
      } else if (response.statusCode == 429) {
        return {
          'success': false,
          'error': 'Batas request harian tercapai (100/hari)',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load news (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ Error fetching news: $e');
      return {
        'success': false,
        'error': 'Kesalahan koneksi: ${e.toString()}',
      };
    }
  }

  /// Validasi apakah URL valid dan aman untuk dibuka
  static bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      // Hanya terima http/https
      return uri.scheme == 'http' || uri.scheme == 'https';
    } catch (e) {
      return false;
    }
  }

  /// Format tanggal artikel menjadi relatif (contoh: "2 hours ago")
  ///
  /// CATATAN: Timestamp dari API adalah waktu publikasi asli artikel,
  /// bukan waktu saat API mengindeks artikel tersebut
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

  /// Mendapatkan nama sumber berita yang lebih rapi
  static String getSourceName(Map<String, dynamic> article) {
    try {
      if (article['source'] != null && article['source']['name'] != null) {
        return article['source']['name'];
      }
      return 'Unknown Source';
    } catch (e) {
      return 'Unknown Source';
    }
  }
}
