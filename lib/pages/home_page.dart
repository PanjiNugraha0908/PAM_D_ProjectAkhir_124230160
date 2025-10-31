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
import 'feedback_page.dart';
import 'settings_page.dart';
// 燥 IMPORT SERVICE NOTIFIKASI
import '../services/notification_service.dart';

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  List<Country> _countries = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Palet Warna
  final Color primaryColor = Color(0xFF041C4A);
  final Color secondaryColor = Color(0xFF214894);
  final Color tertiaryColor = Color(0xFF394461);
  final Color cardColor = Color(0xFF21252F);
  final Color textColor = Color(0xFFD9D9D9);
  final Color hintColor = Color(0xFF898989);

  @override
  void initState() {
    super.initState();
    // Update last active setiap kali buka home page
    ActivityTracker.updateLastActive();
  }

  // MENJADI SEPERTI INI:
  Future<void> _searchCountries() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _countries = [];
    });

    try {
      // 燥 PERUBAHAN DI SINI: Membersihkan spasi sebelum mencari
      final String query = _searchController.text.trim();

      final response = await http.get(
        Uri.parse(
          'https://restcountries.com/v3.1/name/$query', // Gunakan query yang sudah bersih
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _countries = data.map((json) => Country.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Negara tidak ditemukan';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // (di dalam file lib/pages/home_page.dart)

  // 燥 FUNGSI YANG DIPERBAIKI 燥
  void _showCountryDetail(Country country) async {
    // 1. Dapatkan username (sudah ada)
    String? username = widget.username; // Menggunakan widget.username

    // 2. Cek history SEBELUM menambah
    List<HistoryItem> historySebelum = DatabaseService.getHistoryForUser(
      username,
    );
    bool sudahDilihat = historySebelum.any(
      (item) => item.countryName == country.name,
    );

    // 3. Tambah history (sudah ada)
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

    // 4. Update aktivitas (sudah ada)
    ActivityTracker.updateLastActive();

    // 5. LOGIKA NOTIFIKASI BARU
    // Cek jika ini adalah negara BARU yang dilihat
    if (!sudahDilihat) {
      // Ambil history LAGI (setelah ditambah) untuk menghitung jumlah unik
      List<HistoryItem> historySesudah = DatabaseService.getHistoryForUser(
        username,
      );

      // Hitung jumlah negara unik
      var negaraUnik = <String>{};

      // ===== PERBAIKAN DI SINI =====
      for (var item in historySesudah) {
        // <-- Typo 'historySesah' diperbaiki
        negaraUnik.add(item.countryName);
      }
      // =============================

      print(
        'DEBUG: Negara unik baru terdeteksi. Jumlah unik sekarang: ${negaraUnik.length}',
      );

      // Jika jumlah unik TEPAT 3, kirim notifikasi
      if (negaraUnik.length == 3) {
        NotificationService.showNotification(
          id: 3, // ID unik untuk notifikasi ini
          title: 'Wawasan Bertambah!',
          body: 'Selamat kamu telah menambah wawasanmu!',
        );
      }
    }

    // 6. Tampilkan dialog (sudah ada)
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // Latar belakang transparan
      builder: (context) => CountryDetailDialog(country: country),
    );
  }

  // --- Fungsi Navigasi ---
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

  void _openFeedback() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeedbackPage()),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  // --- Handler untuk Bottom Nav Bar ---
  void _onItemTapped(int index) {
    // Navigasi menggunakan Navigator.push,
    // jadi kita tidak perlu setState untuk _selectedIndex
    // `HomePage` selalu menjadi 'index 0' secara visual,
    // dan item lain mendorong halaman baru ke atasnya.
    switch (index) {
      case 0:
        _openProfile();
        break;
      case 1:
        _openFeedback();
        break;
      case 2:
        _openLocation();
        break;
      case 3:
        _openHistory();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hapus AppBar
      // appBar: ...,

      // Tambahkan BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cardColor,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: hintColor,
        selectedItemColor: secondaryColor,
        // Kita tidak melacak state, jadi set ke 0.
        // Atau bisa juga tidak diset (biarkan default)
        currentIndex: 0,
        // Kita set 'selectedFontSize' ke 0 agar label 'Home' tidak muncul
        // dan hanya label item lain yang ditekan yang akan muncul.
        // Atau, kita bisa set `showUnselectedLabels: true`
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.my_location),
            label: 'Lokasi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
      body: Container(
        // Background Gradient
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
              // --- Header Kustom ---
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

              // --- Search Bar ---
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Type your country name',
                    hintStyle: TextStyle(color: hintColor.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.search, color: hintColor),
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
                  onSubmitted: (_) => _searchCountries(),
                ),
              ),

              // --- Konten (Hasil, Loading, Error, Prompt) ---
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: textColor),
                        SizedBox(height: 16),
                        Text(
                          'Mencari negara...',
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_errorMessage.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Card(
                        color: Colors.red.shade900.withOpacity(0.5),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else if (_countries.isNotEmpty)
                // --- Daftar Hasil Pencarian ---
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _countries.length,
                    itemBuilder: (context, index) {
                      final country = _countries[index];
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(country.flagUrl),
                              backgroundColor: tertiaryColor,
                            ),
                            title: Text(
                              country.name,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () => _showCountryDetail(country),
                          ),
                          Divider(
                            color: tertiaryColor.withOpacity(0.5),
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                        ],
                      );
                    },
                  ),
                )
              else
                // --- Prompt Awal ---
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: hintColor),
                        SizedBox(height: 16),
                        Text(
                          'Cari negara untuk melihat informasi',
                          style: TextStyle(color: hintColor),
                        ),
                      ],
                    ),
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
    _searchController.dispose();
    super.dispose();
  }
}
