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

// Halaman Utama: Menampilkan daftar negara dan menyediakan fitur pencarian
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

  // Definisi Palet Warna
  final Color backgroundColor = Color(
    0xFF1A202C,
  ); // Latar Belakang Utama Aplikasi
  final Color surfaceColor = Color(
    0xFF2D3748,
  ); // Warna Permukaan (Card, Input Field)
  final Color accentColor = Color(
    0xFF66B3FF,
  ); // Aksen Utama (Logo, Judul, Ikon Penting)
  final Color primaryButtonColor = Color(0xFF4299E1); // Warna Tombol Utama
  final Color textColor = Color(0xFFE2E8F0); // Warna Teks Standar
  final Color hintColor = Color(0xFFA0AEC0); // Warna Teks Petunjuk

  @override
  void initState() {
    super.initState();
    // Memperbarui waktu aktif terakhir saat halaman dimuat
    ActivityTracker.updateLastActive();
    // Memuat semua data negara dari API
    _loadAllCountries();
    // Menambahkan listener untuk memfilter daftar saat teks pencarian berubah
    _searchController.addListener(_filterCountries);
  }

  // Fungsi untuk mengambil semua data negara dari API eksternal
  Future<void> _loadAllCountries() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      print('🌍 Fetching all countries from API...');

      // Memanggil API restcountries.com untuk mendapatkan semua negara
      final response = await http
          .get(
            Uri.parse('https://restcountries.com/v3.1/all'),
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'ExploreUnity/1.0 (Flutter App)',
              'Accept-Encoding': 'gzip, deflate, br',
            },
          )
          // Menetapkan batas waktu untuk request
          .timeout(
            Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Koneksi timeout. Periksa internet Anda.');
            },
          );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Country> countries = [];

        for (var json in data) {
          try {
            // Memparsing data JSON ke model Country
            countries.add(Country.fromJson(json));
          } catch (e) {
            print(
              '⚠️ Error parsing country: ${json['name']?['common'] ?? 'Unknown'} - $e',
            );
          }
        }

        // Mengurutkan negara berdasarkan nama secara alfabetis
        countries.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );

        if (mounted) {
          setState(() {
            _allCountries = countries;
            _filteredCountries = countries;
            _isLoading = false;
          });
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error loading countries: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Fungsi untuk memfilter daftar negara berdasarkan input pencarian
  void _filterCountries() {
    if (mounted) {
      setState(() {
        final query = _searchController.text.trim().toLowerCase();

        if (query.isEmpty) {
          _filteredCountries = _allCountries;
        } else {
          // Logika filter: mencari berdasarkan nama, ibu kota, atau region
          _filteredCountries = _allCountries
              .where(
                (country) =>
                    // Menggunakan startsWith untuk performa lebih baik dan hasil yang relevan
                    country.name.toLowerCase().startsWith(query) ||
                    country.capital.toLowerCase().startsWith(query) ||
                    country.region.toLowerCase().startsWith(query),
              )
              .toList();
        }
      });
    }
  }

  // Fungsi alternatif untuk pencarian langsung ke API jika mode 'load all' gagal
  Future<void> _searchCountriesByName(String query) async {
    if (query.trim().isEmpty) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await http
          .get(
            Uri.parse('https://restcountries.com/v3.1/name/$query'),
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'ExploreUnity/1.0 (Flutter App)',
            },
          )
          .timeout(Duration(seconds: 10));

      if (mounted) {
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          final List<Country> countries = data
              .map((json) => Country.fromJson(json))
              .toList();

          setState(() {
            _filteredCountries = countries;
            _isLoading = false;
          });
        } else if (response.statusCode == 404) {
          setState(() {
            _filteredCountries = [];
            _isLoading = false;
          });
        } else {
          throw Exception('Search failed: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Search error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Filter cepat berdasarkan huruf awal
  void _filterByAlphabet(String letter) {
    setState(() {
      _searchController.clear();
      _filteredCountries = _allCountries
          .where((country) => country.name.toUpperCase().startsWith(letter))
          .toList();
    });
  }

  // Mengembalikan filter ke kondisi awal
  void _resetFilter() {
    setState(() {
      _searchController.clear();
      _filteredCountries = _allCountries;
    });
  }

  // Fungsi Logout
  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      // Kembali ke halaman Login dan menghapus semua rute sebelumnya
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  // Menampilkan detail negara dan mencatatnya sebagai history
  void _showCountryDetail(Country country) async {
    String username = widget.username;

    // 1. Hitung negara unik yang sudah dilihat sebelum penambahan history
    List<HistoryItem> historySebelum = DatabaseService.getHistoryForUser(
      username,
    );
    var negaraUnikSebelum = historySebelum
        .map((item) => item.countryName)
        .toSet();
    final int totalUnikSebelum = negaraUnikSebelum.length;

    // 2. Tambahkan entri riwayat baru
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

    // Memperbarui waktu aktif terakhir pengguna
    ActivityTracker.updateLastActive();

    // 3. Hitung negara unik sesudah penambahan
    List<HistoryItem> historySesudah = DatabaseService.getHistoryForUser(
      username,
    );
    var negaraUnikSesudah = historySesudah
        .map((item) => item.countryName)
        .toSet();
    final int totalUnikSesudah = negaraUnikSesudah.length;

    // LOGIKA NOTIFIKASI: Tampilkan notifikasi setiap kelipatan 3 negara unik yang baru dilihat
    if (totalUnikSesudah > 0 && totalUnikSesudah % 3 == 0) {
      if (totalUnikSebelum % 3 != 0) {
        NotificationService.showNotification(
          id: totalUnikSesudah,
          title: 'Wawasan Bertambah! 🌍',
          body: 'Selamat, kamu sudah melihat $totalUnikSesudah negara baru!',
        );
      }
    }

    if (mounted) {
      // Menampilkan dialog detail negara
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => CountryDetailDialog(country: country),
      );
    }
  }

  // Fungsi Navigasi Tab
  void _openHistory() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  void _openLocation() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LocationPage()),
    );
  }

  void _openProfile() {
    Navigator.pushReplacement(
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
      resizeToAvoidBottomInset: false,
      // Implementasi Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: surfaceColor,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: hintColor,
        // Di halaman Home, semua ikon tidak perlu di-highlight secara visual
        selectedItemColor: hintColor,
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
        color: backgroundColor, // Menggunakan warna latar belakang datar
        child: SafeArea(
          child: Column(
            children: [
              // Header Aplikasi (Settings, Logo, Logout)
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
                    prefixIcon: Icon(
                      Icons.search,
                      color: accentColor,
                    ), // Icon search tetap accent (biru cerah)
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: hintColor),
                            onPressed: _resetFilter,
                          )
                        : null,
                    filled: true,
                    fillColor: surfaceColor, // Warna isian field
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: primaryButtonColor,
                        width: 2,
                      ), // Fokus warna tombol
                    ),
                  ),
                  // Memungkinkan pencarian langsung jika data negara kosong
                  onSubmitted:
                      (_allCountries.isEmpty &&
                          _searchController.text.isNotEmpty)
                      ? (value) => _searchCountriesByName(value)
                      : null,
                ),
              ),

              SizedBox(height: 8),

              // Alphabet Filter (hanya tampil jika data sudah dimuat)
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
                          backgroundColor: surfaceColor.withOpacity(0.5),
                          selectedColor: primaryButtonColor, // Warna tombol
                          disabledColor: surfaceColor.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              SizedBox(height: 8),

              // Info jumlah negara dan tombol Reset
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
                              color: accentColor, // Warna aksen
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              // Menampilkan Loading, Empty State, atau Daftar Negara
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: primaryButtonColor, // Warna tombol
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
              else if (_filteredCountries.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: surfaceColor,
                            ),
                            child: Image.asset(
                              'assets/Logoprojek.png',
                              height: 80,
                              width: 80,
                              color: accentColor.withOpacity(
                                0.8,
                              ), // Ikon warna aksen
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
                            _allCountries.isEmpty
                                ? 'Cari negara yang ingin kamu ketahui'
                                : 'untuk "${_searchController.text}"',
                            style: TextStyle(color: hintColor, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          if (_allCountries.isEmpty) ...[
                            SizedBox(height: 32),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: surfaceColor.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: accentColor.withOpacity(0.3),
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
                // Daftar Negara (ListView.builder)
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];

                      // Logika untuk menampilkan header abjad (A, B, C, dst)
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
                              // Menampilkan huruf awal sebagai header
                              child: Text(
                                country.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor, // Warna aksen
                                ),
                              ),
                            ),

                          Card(
                            color: surfaceColor, // Warna permukaan
                            margin: EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            // InkWell untuk efek visual saat diklik
                            child: InkWell(
                              onTap: () => _showCountryDetail(country),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Bendera Negara
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        country.flagUrl,
                                        width: 60,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        // Error Builder: menampilkan ikon jika gambar gagal dimuat
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                width: 60,
                                                height: 40,
                                                color: surfaceColor.withOpacity(
                                                  0.8,
                                                ),
                                                child: Icon(
                                                  Icons.flag,
                                                  color: hintColor,
                                                  size: 24,
                                                ),
                                              );
                                            },
                                        // Loading Builder: menampilkan progress saat gambar dimuat
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Container(
                                                width: 60,
                                                height: 40,
                                                color: surfaceColor.withOpacity(
                                                  0.8,
                                                ),
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
                                    // Info Nama, Ibu Kota, dan Region
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
                                    // Ikon Navigasi
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
