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

/// Halaman utama aplikasi.
///
/// Menampilkan daftar semua negara yang diambil dari API,
/// menyediakan fitur pencarian, filter, dan navigasi utama
/// aplikasi (via BottomNavBar).
class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- State dan Controller ---
  final _searchController = TextEditingController();
  List<Country> _allCountries = []; // Daftar master semua negara
  List<Country> _filteredCountries =
      []; // Daftar yang ditampilkan (hasil filter)
  bool _isLoading = false;

  // --- Palet Warna Halaman ---
  // Catatan: Sebaiknya palet warna ini dipindahkan ke file theme/constants terpisah
  // agar konsisten dan mudah dikelola di seluruh aplikasi.
  final Color backgroundColor = Color(0xFF1A202C);
  final Color surfaceColor = Color(0xFF2D3748);
  final Color accentColor = Color(0xFF66B3FF);
  final Color primaryButtonColor = Color(0xFF4299E1);
  final Color textColor = Color(0xFFE2E8F0);
  final Color hintColor = Color(0xFFA0AEC0);

  // --- Lifecycle Methods ---

  @override
  void initState() {
    super.initState();
    // 1. Perbarui waktu aktif pengguna
    ActivityTracker.updateLastActive();
    // 2. Mulai ambil data semua negara dari API
    _loadAllCountries();
    // 3. Tambahkan listener ke search bar untuk memfilter secara real-time
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCountries);
    _searchController.dispose();
    super.dispose();
  }

  // --- Logika Pengambilan Data (API) ---

  /// Mengambil semua data negara dari API restcountries.com.
  /// Ini adalah metode pemuatan data utama.
  Future<void> _loadAllCountries() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      print('🌍 Mengambil data semua negara dari API...');
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
            Duration(seconds: 20), // Batas waktu 20 detik
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
            // Parsing setiap item JSON ke model Country
            countries.add(Country.fromJson(json));
          } catch (e) {
            print(
              '⚠️ Error parsing negara: ${json['name']?['common'] ?? 'Unknown'} - $e',
            );
          }
        }

        // Urutkan daftar negara berdasarkan abjad
        countries.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );

        if (mounted) {
          setState(() {
            _allCountries = countries; // Simpan ke daftar master
            _filteredCountries = countries; // Tampilkan semua di awal
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
      print('❌ Error memuat negara: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// [Fallback] Pencarian langsung ke API jika data [_allCountries] gagal dimuat.
  /// Ini dipicu oleh `onSubmitted` di [TextField] jika [_allCountries] kosong.
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
            _filteredCountries = countries; // Tampilkan hasil pencarian API
            _isLoading = false;
          });
        } else if (response.statusCode == 404) {
          setState(() {
            _filteredCountries = []; // Tidak ditemukan
            _isLoading = false;
          });
        } else {
          throw Exception('Pencarian gagal: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Error pencarian: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Logika Filter dan UI ---

  /// Memfilter daftar [_allCountries] berdasarkan teks di [_searchController].
  /// Dipanggil oleh listener setiap kali teks berubah.
  void _filterCountries() {
    if (mounted) {
      setState(() {
        final query = _searchController.text.trim().toLowerCase();

        if (query.isEmpty) {
          _filteredCountries = _allCountries; // Tampilkan semua jika kosong
        } else {
          // Filter berdasarkan nama, ibu kota, atau region
          _filteredCountries = _allCountries
              .where(
                (country) =>
                    // Menggunakan startsWith untuk hasil yang lebih relevan
                    country.name.toLowerCase().startsWith(query) ||
                    country.capital.toLowerCase().startsWith(query) ||
                    country.region.toLowerCase().startsWith(query),
              )
              .toList();
        }
      });
    }
  }

  /// Memfilter daftar negara berdasarkan huruf awal yang dipilih.
  void _filterByAlphabet(String letter) {
    setState(() {
      _searchController.clear(); // Hapus teks pencarian
      _filteredCountries = _allCountries
          .where((country) => country.name.toUpperCase().startsWith(letter))
          .toList();
    });
  }

  /// Mengembalikan filter ke kondisi awal (menampilkan semua negara).
  void _resetFilter() {
    setState(() {
      _searchController.clear();
      _filteredCountries = _allCountries;
    });
  }

  /// Menampilkan dialog detail untuk [Country] yang dipilih.
  /// Juga mencatat item ini ke [DatabaseService] sebagai riwayat
  /// dan memicu notifikasi jika mencapai milestone.
  void _showCountryDetail(Country country) async {
    String username = widget.username;

    // 1. Hitung negara unik yang sudah dilihat SEBELUM menambah riwayat
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

    // Perbarui waktu aktif terakhir pengguna
    ActivityTracker.updateLastActive();

    // 3. Hitung negara unik SESUDAH menambah riwayat
    List<HistoryItem> historySesudah = DatabaseService.getHistoryForUser(
      username,
    );
    var negaraUnikSesudah = historySesudah
        .map((item) => item.countryName)
        .toSet();
    final int totalUnikSesudah = negaraUnikSesudah.length;

    // --- LOGIKA NOTIFIKASI ---
    // Tampilkan notifikasi setiap kelipatan 3 negara unik *baru* yang dilihat
    if (totalUnikSesudah > 0 && totalUnikSesudah % 3 == 0) {
      // Pastikan notifikasi tidak terpicu lagi jika pengguna membuka negara yang sama
      if (totalUnikSebelum % 3 != 0) {
        NotificationService.showNotification(
          id: totalUnikSesudah,
          title: 'Wawasan Bertambah! 🌍',
          body: 'Selamat, kamu sudah melihat $totalUnikSesudah negara baru!',
        );
      }
    }
    // --- AKHIR LOGIKA NOTIFIKASI ---

    if (mounted) {
      // Tampilkan dialog detail
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => CountryDetailDialog(country: country),
      );
    }
  }

  // --- Navigasi ---

  /// Melakukan proses logout dan mengarahkan pengguna ke [LoginPage].
  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      // Kembali ke halaman Login dan hapus semua rute sebelumnya
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  /// Navigasi ke [HistoryPage] (Tab)
  void _openHistory() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  /// Navigasi ke [LocationPage] (Tab)
  void _openLocation() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LocationPage()),
    );
  }

  /// Navigasi ke [ProfilePage] (Tab)
  void _openProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  /// Navigasi ke [SettingsPage] (Bukan tab, membuka di atas tumpukan)
  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  /// Handler untuk [BottomNavigationBar] onTap.
  void _onItemTapped(int index) {
    switch (index) {
      case 0: // Profil
        _openProfile();
        break;
      case 1: // Lokasi
        _openLocation();
        break;
      case 2: // History
        _openHistory();
        break;
    }
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Hindari UI terdorong keyboard
      // --- 1. Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: surfaceColor,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: hintColor,
        // Di halaman Home, semua ikon tidak di-highlight
        // karena Home dianggap sebagai "dasar"
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

      // --- 2. Body Utama (SafeArea) ---
      body: Container(
        color: backgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              // --- 2A. Header Aplikasi (Settings, Logo, Logout) ---
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

              // --- 2B. Search Bar ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Cari negara...',
                    hintStyle: TextStyle(color: hintColor.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.search, color: accentColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: hintColor),
                            onPressed: _resetFilter,
                          )
                        : null,
                    filled: true,
                    fillColor: surfaceColor,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: primaryButtonColor,
                        width: 2,
                      ),
                    ),
                  ),
                  // Jika data negara kosong (gagal load),
                  // gunakan onSubmitted untuk memicu pencarian API langsung
                  onSubmitted:
                      (_allCountries.isEmpty &&
                          _searchController.text.isNotEmpty)
                      ? (value) => _searchCountriesByName(value)
                      : null,
                ),
              ),
              SizedBox(height: 8),

              // --- 2C. Filter Alfabet ---
              // Hanya tampilkan jika data sudah dimuat
              if (!_isLoading && _allCountries.isNotEmpty)
                Container(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: 26,
                    itemBuilder: (context, index) {
                      final letter = String.fromCharCode(65 + index);
                      // Cek apakah ada negara yang dimulai dengan huruf ini
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
                          selectedColor: primaryButtonColor,
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

              // --- 2D. Info Hasil & Tombol Reset ---
              // Hanya tampilkan jika tidak loading dan ada hasil
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
                      // Tampilkan tombol "Reset" jika sedang memfilter
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
                            style: TextStyle(color: accentColor, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),

              // --- 2E. Konten Utama (List, Loading, atau Empty) ---
              // Menggunakan Expanded agar mengisi sisa ruang
              if (_isLoading)
                // --- Kondisi: Loading ---
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: primaryButtonColor,
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
                // --- Kondisi: Kosong (Tidak ada hasil / Awal) ---
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
                              color: accentColor.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 32),
                          Text(
                            _allCountries.isEmpty
                                ? 'Jelajahi Dunia' // Tampilan awal
                                : 'Tidak Ada Hasil', // Hasil filter 0
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
                          // Petunjuk tambahan jika data negara gagal dimuat
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
                // --- Kondisi: Menampilkan Daftar Negara ---
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];

                      // Logika untuk menampilkan header abjad (A, B, C, dst)
                      bool showHeader = false;
                      if (_allCountries.isNotEmpty && index == 0) {
                        showHeader =
                            true; // Selalu tampilkan header di item pertama
                      } else if (_allCountries.isNotEmpty && index > 0) {
                        // Tampilkan header jika huruf pertama berbeda dari item sebelumnya
                        final currentLetter = country.name[0].toUpperCase();
                        final prevLetter = _filteredCountries[index - 1].name[0]
                            .toUpperCase();
                        showHeader = currentLetter != prevLetter;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tampilkan Header Abjad jika perlu
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
                                  color: accentColor,
                                ),
                              ),
                            ),

                          // Card untuk setiap negara
                          Card(
                            color: surfaceColor,
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
                                    // Bendera Negara
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        country.flagUrl,
                                        width: 60,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        // Error Builder: Tampil jika gambar gagal dimuat
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
                                        // Loading Builder: Tampil saat gambar sedang dimuat
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
                                    // Info Teks (Nama, Ibu Kota, Region)
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
                                    // Ikon Navigasi (>)
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
}
