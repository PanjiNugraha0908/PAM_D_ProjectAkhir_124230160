import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsService {
  static const String _apiKey = 'af3497dfe2774fcaa42f2015e16bfa07';
  static const String _baseUrl = 'https://newsapi.org/v2';

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
          final articles = (data['articles'] as List)
              .where((article) =>
                  article['title'] != null &&
                  article['title'] != '[Removed]' &&
                  article['url'] != null &&
                  article['url'].toString().isNotEmpty &&
                  _isValidUrl(article['url']) &&
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

  static bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'http' || uri.scheme == 'https';
    } catch (e) {
      return false;
    }
  }

  // ============== PERBAIKAN TIMESTAMP DI SINI ==============
  static String formatPublishedDate(String? dateStr) {
    if (dateStr == null) return 'Waktu tidak diketahui';

    try {
      final publishedDate = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(publishedDate);

      // TAMBAHKAN KETERANGAN UNTUK API DELAY
      String timeAgo;

      if (diff.inMinutes < 1) {
        timeAgo = 'Baru saja';
      } else if (diff.inMinutes < 60) {
        timeAgo = '${diff.inMinutes} menit yang lalu';
      } else if (diff.inHours < 24) {
        timeAgo = '${diff.inHours} jam yang lalu';
      } else if (diff.inDays < 7) {
        timeAgo = '${diff.inDays} hari yang lalu';
      } else {
        // Untuk berita lebih dari seminggu, tampilkan tanggal
        return '${publishedDate.day}/${publishedDate.month}/${publishedDate.year}';
      }

      // TAMBAHAN: Tampilkan jam publikasi untuk konteks
      final hour = publishedDate.hour.toString().padLeft(2, '0');
      final minute = publishedDate.minute.toString().padLeft(2, '0');

      return '$timeAgo ($hour:$minute)';
    } catch (e) {
      return dateStr;
    }
  }
  // =========================================================

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
