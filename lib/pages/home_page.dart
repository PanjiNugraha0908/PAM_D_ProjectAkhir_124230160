// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/country.dart';
import '../models/history_item.dart';
import '../widgets/country_detail_dialog.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/activity_tracker.dart';
import 'login_page.dart';
import 'history_page.dart';
import 'location_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import '../services/notification_service.dart';

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  List<Country> _allCountries = [];
  List<Country> _filteredCountries = [];
  bool _isLoading = false;
  // HAPUS: String _errorMessage = '';

  // Palet Warna
  final Color primaryColor = Color(0xFF010A1E);
  final Color secondaryColor = Color(0xFF103070);
  final Color tertiaryColor = Color(0xFF2A364B);
  final Color cardColor = Color(0xFF21252F);
  final Color textColor = Color(0xFFD9D9D9);
  final Color hintColor = Color(0xFF898989);

  @override
  void initState() {
    super.initState();
    ActivityTracker.updateLastActive();
    _loadAllCountries();
    _searchController.addListener(_filterCountries);
  }

  Future<void> _loadAllCountries() async {
    setState(() {
      _isLoading = true;
      // HAPUS: _errorMessage = '';
    });

    try {
      print('🌍 Fetching all countries from API...');

      final response = await http
          .get(
            Uri.parse('https://restcountries.com/v3.1/all'),
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'ExploreUnity/1.0 (Flutter App)',
              'Accept-Encoding': 'gzip, deflate, br',
            },
          )
          .timeout(
            Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Koneksi timeout. Periksa internet Anda.');
            },
          );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response length: ${response.body.length} bytes');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Berhasil decode ${data.length} negara');

        final List<Country> countries = [];

        int successCount = 0;
        int errorCount = 0;

        for (var json in data) {
          try {
            countries.add(Country.fromJson(json));
            successCount++;
          } catch (e) {
            errorCount++;
            print(
              '⚠️ Error parsing country #$errorCount: ${json['name']?['common'] ?? 'Unknown'} - $e',
            );
          }
        }

        print('✅ Successfully parsed: $successCount countries');
        if (errorCount > 0) {
          print('⚠️ Failed to parse: $errorCount countries');
        }

        countries.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );

        setState(() {
          _allCountries = countries;
          _filteredCountries = countries;
          _isLoading = false;
        });

        print('🎉 UI updated with ${countries.length} countries');
      } else {
        // JIKA GAGAL: Tidak perlu set error message, cukup pastikan _allCountries tetap kosong.
        print('❌ Server error: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // JIKA EXCEPTION (Network error dll.): Cukup log error dan nonaktifkan loading.
      print('❌ Error loading countries: $e');
      setState(() {
        _isLoading = false;
      });
    }
    // Tidak ada return value, _allCountries akan kosong jika gagal.
  }

  // FUNGSI INI SUDAH TIDAK DIGUNAKAN KARENA _errorMessage DIHAPUS
  // String _getErrorMessage(dynamic error) {
  //   String errorStr = error.toString();

  //   if (errorStr.contains('SocketException') ||
  //       errorStr.contains('NetworkException')) {
  //     return 'Tidak ada koneksi internet.\nPastikan WiFi/data seluler aktif.';
  //   } else if (errorStr.contains('timeout') ||
  //       errorStr.contains('TimeoutException')) {
  //     return 'Koneksi terlalu lambat.\nCoba lagi dengan koneksi lebih baik.';
  //   } else if (errorStr.contains('FormatException')) {
  //     return 'Data dari server tidak valid.\nCoba lagi nanti.';
  //   } else if (errorStr.contains('400') || errorStr.contains('Bad Request')) {
  //     return 'Gagal memuat semua negara.\nGunakan fitur search untuk mencari negara tertentu.';
  //   } else {
  //     return 'Gagal memuat data.\nCoba gunakan search atau refresh.';
  //   }
  // }

  void _filterCountries() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredCountries = _allCountries;
      });
    } else {
      setState(() {
        _filteredCountries = _allCountries
            .where(
              (country) =>
                  // PERBAIKAN: Mengganti .contains() dengan .startsWith() untuk filtering yang benar.
                  country.name.toLowerCase().startsWith(query) ||
                  country.capital.toLowerCase().startsWith(query) ||
                  country.region.toLowerCase().startsWith(query),
            )
            .toList();
      });
    }
  }

  // FUNGSI BARU: Search by name (alternatif jika load all gagal)
  Future<void> _searchCountriesByName(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      // HAPUS: _errorMessage = '';
    });

    try {
      print('🔍 Searching for: $query');

      final response = await http
          .get(
            Uri.parse('https://restcountries.com/v3.1/name/$query'),
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'ExploreUnity/1.0 (Flutter App)',
            },
          )
          .timeout(Duration(seconds: 10));

      print('📡 Search response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Country> countries = data
            .map((json) => Country.fromJson(json))
            .toList();

        setState(() {
          _filteredCountries = countries;
          _isLoading = false;
        });

        print('✅ Found ${countries.length} countries');
      } else if (response.statusCode == 404) {
        setState(() {
          _filteredCountries = [];
          _isLoading = false;
        });
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Search error: $e');
      setState(() {
        // HAPUS: _errorMessage = 'Pencarian gagal. Coba kata kunci lain.';
        _isLoading = false;
      });
    }
  }

  void _filterByAlphabet(String letter) {
    setState(() {
      _searchController.clear();
      _filteredCountries = _allCountries
          .where((country) => country.name.toUpperCase().startsWith(letter))
          .toList();
    });
  }

  void _resetFilter() {
    setState(() {
      _searchController.clear();
      _filteredCountries = _allCountries;
      // HAPUS: _errorMessage = '';
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  void _showCountryDetail(Country country) async {
    String username = widget.username;

    List<HistoryItem> historySebelum = DatabaseService.getHistoryForUser(
      username,
    );
    bool sudahDilihat = historySebelum.any(
      (item) => item.countryName == country.name,
    );

    await DatabaseService.addHistory(
      HistoryItem(
        username: username,
        countryName: country.name,
        flagUrl: country.flagUrl,
        capital: country.capital,
        region: country.region,
        viewedAt: DateTime.now(),
      ),
    );

    ActivityTracker.updateLastActive();

    if (!sudahDilihat) {
      List<HistoryItem> historySesudah = DatabaseService.getHistoryForUser(
        username,
      );
      var negaraUnik = <String>{};
      for (var item in historySesudah) {
        negaraUnik.add(item.countryName);
      }

      if (negaraUnik.length == 3) {
        NotificationService.showNotification(
          id: 3,
          title: 'Wawasan Bertambah!',
          body: 'Selamat kamu telah menambah wawasanmu!',
        );
      }
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => CountryDetailDialog(country: country),
      );
    }
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  void _openLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationPage()),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        _openProfile();
        break;
      case 1:
        _openLocation();
        break;
      case 2:
        _openHistory();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cardColor,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: hintColor,
        selectedItemColor: secondaryColor,
        currentIndex: 0,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.my_location),
            label: 'Lokasi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, secondaryColor, tertiaryColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.settings, color: hintColor),
                      onPressed: _openSettings,
                      tooltip: 'Pengaturan',
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/Logoprojek.png',
                          height: 24,
                          width: 24,
                          color: textColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'ExploreUnity',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, color: hintColor),
                      onPressed: _logout,
                      tooltip: 'Logout',
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Cari negara...',
                    hintStyle: TextStyle(color: hintColor.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.search, color: hintColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: hintColor),
                            onPressed: _resetFilter,
                          )
                        : null,
                    filled: true,
                    fillColor: tertiaryColor.withOpacity(0.5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: secondaryColor, width: 2),
                    ),
                  ),
                  // PERBAIKAN: Gunakan search API jika load all gagal
                  onSubmitted:
                      (_allCountries.isEmpty &&
                          _searchController.text.isNotEmpty)
                      ? (value) => _searchCountriesByName(value)
                      : null,
                ),
              ),

              SizedBox(height: 8),

              // Alphabet Filter (hanya jika data sudah loaded)
              if (!_isLoading && _allCountries.isNotEmpty)
                Container(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: 26,
                    itemBuilder: (context, index) {
                      final letter = String.fromCharCode(65 + index);
                      final hasCountries = _allCountries.any(
                        (c) => c.name.toUpperCase().startsWith(letter),
                      );

                      return Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            letter,
                            style: TextStyle(
                              color: hasCountries
                                  ? textColor
                                  : hintColor.withOpacity(0.3),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onSelected: hasCountries
                              ? (_) => _filterByAlphabet(letter)
                              : null,
                          backgroundColor: tertiaryColor.withOpacity(0.3),
                          selectedColor: secondaryColor,
                          disabledColor: tertiaryColor.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              SizedBox(height: 8),

              // Info jumlah negara
              if (!_isLoading && _filteredCountries.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _allCountries.isNotEmpty
                            ? 'Menampilkan ${_filteredCountries.length} dari ${_allCountries.length} negara'
                            : '${_filteredCountries.length} hasil',
                        style: TextStyle(color: hintColor, fontSize: 12),
                      ),
                      if (_filteredCountries.length != _allCountries.length &&
                          _allCountries.isNotEmpty)
                        TextButton(
                          onPressed: _resetFilter,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size(0, 30),
                          ),
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              // Content
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: secondaryColor,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 24),
                        Text(
                          _allCountries.isEmpty
                              ? 'Memuat data negara...'
                              : 'Mencari...',
                          style: TextStyle(color: textColor, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Mohon tunggu sebentar',
                          style: TextStyle(color: hintColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              // HAPUS BLOK ERROR STATE. Fallthrough ke default state jika _allCountries kosong.
              else if (_filteredCountries.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo Proyek
                          Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  secondaryColor.withOpacity(0.3),
                                  tertiaryColor.withOpacity(0.3),
                                ],
                              ),
                            ),
                            // Mengganti Icons.public dengan Logoprojek.png
                            child: Image.asset(
                              'assets/Logoprojek.png',
                              height: 80,
                              width: 80,
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 32),
                          Text(
                            _allCountries.isEmpty
                                ? 'Jelajahi Dunia'
                                : 'Tidak Ada Hasil',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            // Teks yang akan ditampilkan saat gagal muat SEMUA negara atau saat hasil pencarian kosong.
                            _allCountries.isEmpty
                                ? 'Cari negara yang ingin kamu ketahui'
                                : 'untuk "${_searchController.text}"',
                            style: TextStyle(color: hintColor, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          // Bagian instruksi pencarian (Gambar Kedua)
                          if (_allCountries.isEmpty) ...[
                            SizedBox(height: 32),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: tertiaryColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: secondaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: hintColor,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Ketik di search bar dan tekan Enter',
                                      style: TextStyle(
                                        color: hintColor,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];

                      bool showHeader = false;
                      if (_allCountries.isNotEmpty && index == 0) {
                        showHeader = true;
                      } else if (_allCountries.isNotEmpty && index > 0) {
                        final currentLetter = country.name[0].toUpperCase();
                        final prevLetter = _filteredCountries[index - 1].name[0]
                            .toUpperCase();
                        showHeader = currentLetter != prevLetter;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader)
                            Padding(
                              padding: EdgeInsets.only(
                                top: 16,
                                bottom: 8,
                                left: 4,
                              ),
                              child: Text(
                                country.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: secondaryColor,
                                ),
                              ),
                            ),

                          Card(
                            color: cardColor.withOpacity(0.5),
                            margin: EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () => _showCountryDetail(country),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        country.flagUrl,
                                        width: 60,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                width: 60,
                                                height: 40,
                                                color: tertiaryColor,
                                                child: Icon(
                                                  Icons.flag,
                                                  color: hintColor,
                                                  size: 24,
                                                ),
                                              );
                                            },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Container(
                                                width: 60,
                                                height: 40,
                                                color: tertiaryColor,
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: hintColor,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            country.name,
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '🏛️ ${country.capital}',
                                            style: TextStyle(
                                              color: hintColor,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '🌏 ${country.region}',
                                            style: TextStyle(
                                              color: hintColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: hintColor,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCountries);
    _searchController.dispose();
    super.dispose();
  }
}
