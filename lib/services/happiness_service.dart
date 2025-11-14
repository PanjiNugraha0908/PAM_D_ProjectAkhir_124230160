

/// Service untuk mengambil data World Happiness Index
/// NOTE: Data ini di-hardcode karena World Happiness Report tidak memiliki API publik
class HappinessService {
  // Data World Happiness Report 2023 (Top 50 negara)
  // Source: https://worldhappiness.report/ed/2023/
  static const Map<String, Map<String, dynamic>> _happinessData = {
    'Finland': {'score': 7.804, 'rank': 1},
    'Denmark': {'score': 7.586, 'rank': 2},
    'Iceland': {'score': 7.530, 'rank': 3},
    'Israel': {'score': 7.473, 'rank': 4},
    'Netherlands': {'score': 7.403, 'rank': 5},
    'Sweden': {'score': 7.395, 'rank': 6},
    'Norway': {'score': 7.315, 'rank': 7},
    'Switzerland': {'score': 7.240, 'rank': 8},
    'Luxembourg': {'score': 7.228, 'rank': 9},
    'New Zealand': {'score': 7.123, 'rank': 10},
    'Austria': {'score': 7.097, 'rank': 11},
    'Australia': {'score': 7.095, 'rank': 12},
    'Canada': {'score': 6.961, 'rank': 13},
    'Ireland': {'score': 6.911, 'rank': 14},
    'United States': {'score': 6.894, 'rank': 15},
    'Germany': {'score': 6.892, 'rank': 16},
    'Belgium': {'score': 6.859, 'rank': 17},
    'Czechia': {'score': 6.845, 'rank': 18},
    'United Kingdom': {'score': 6.796, 'rank': 19},
    'Lithuania': {'score': 6.763, 'rank': 20},
    'France': {'score': 6.661, 'rank': 21},
    'Slovenia': {'score': 6.650, 'rank': 22},
    'Costa Rica': {'score': 6.609, 'rank': 23},
    'Romania': {'score': 6.589, 'rank': 24},
    'United Arab Emirates': {'score': 6.571, 'rank': 25},
    'Estonia': {'score': 6.455, 'rank': 26},
    'Poland': {'score': 6.442, 'rank': 27},
    'Bahrain': {'score': 6.227, 'rank': 28},
    'Slovakia': {'score': 6.215, 'rank': 29},
    'Spain': {'score': 6.491, 'rank': 30},
    'Italy': {'score': 6.405, 'rank': 31},
    'Chile': {'score': 6.172, 'rank': 32},
    'Mexico': {'score': 6.128, 'rank': 33},
    'Malta': {'score': 6.602, 'rank': 34},
    'Panama': {'score': 6.180, 'rank': 35},
    'Brazil': {'score': 6.125, 'rank': 36},
    'Argentina': {'score': 5.967, 'rank': 37},
    'Thailand': {'score': 5.891, 'rank': 38},
    'Malaysia': {'score': 5.339, 'rank': 39},
    'China': {'score': 5.818, 'rank': 40},
    'Japan': {'score': 6.129, 'rank': 41},
    'South Korea': {'score': 5.951, 'rank': 42},
    'Singapore': {'score': 6.587, 'rank': 43},
    'Indonesia': {'score': 5.240, 'rank': 44},
    'Philippines': {'score': 5.904, 'rank': 45},
    'Vietnam': {'score': 5.763, 'rank': 46},
    'India': {'score': 4.036, 'rank': 47},
    'Russia': {'score': 5.661, 'rank': 48},
    'Turkey': {'score': 4.744, 'rank': 49},
    'Saudi Arabia': {'score': 6.523, 'rank': 50},
  };

  /// Mendapatkan happiness score berdasarkan nama negara
  static Map<String, dynamic> getHappinessScore(String countryName) {
    try {
      // Cari exact match dulu
      if (_happinessData.containsKey(countryName)) {
        return {
          'success': true,
          'score': _happinessData[countryName]!['score'],
          'rank': _happinessData[countryName]!['rank'],
        };
      }

      // Cari dengan case-insensitive
      final key = _happinessData.keys.firstWhere(
        (k) => k.toLowerCase() == countryName.toLowerCase(),
        orElse: () => '',
      );

      if (key.isNotEmpty) {
        return {
          'success': true,
          'score': _happinessData[key]!['score'],
          'rank': _happinessData[key]!['rank'],
        };
      }

      return {
        'success': false,
        'error': 'Data tidak tersedia untuk negara ini',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Mendapatkan semua data happiness (untuk sorting/filtering)
  static Map<String, Map<String, dynamic>> getAllHappinessData() {
    return _happinessData;
  }
}
