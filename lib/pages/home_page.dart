import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/country.dart';
import '../models/history_item.dart';
import '../widgets/country_card.dart';
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
// 👇 IMPORT SERVICE NOTIFIKASI
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
      // 👇 PERUBAHAN DI SINI: Membersihkan spasi sebelum mencari
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

  // 👇 FUNGSI INI KITA MODIFIKASI 👇
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
      for (var item in historySesudah) {
        negaraUnik.add(item.countryName);
      }

      print('DEBUG: Negara unik baru terdeteksi. Jumlah unik sekarang: ${negaraUnik.length}');

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
      builder: (context) => CountryDetailDialog(country: country),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.public),
            SizedBox(width: 8),
            Text('Country Explorer'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _openLocation,
            tooltip: 'Lokasi Saya',
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _openHistory,
            tooltip: 'History',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: 'Pengaturan',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle),
            tooltip: 'Akun',
            onSelected: (value) {
              if (value == 'profile') {
                _openProfile();
              } else if (value == 'feedback') {
                _openFeedback();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Profil Pembuat'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'feedback',
                child: Row(
                  children: [
                    Icon(Icons.feedback, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Saran dan Masukan'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Center(child: Text('Halo, ${widget.username}')),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari negara... (contoh: Indonesia, Japan)',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) => _searchCountries(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchCountries,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Cari'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Mencari negara...'),
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
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else if (_countries.isNotEmpty)
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600
                      ? 3
                      : 1,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _countries.length,
                itemBuilder: (context, index) {
                  final country = _countries[index];
                  return CountryCard(
                    country: country,
                    onTap: () => _showCountryDetail(country),
                  );
                },
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Cari negara untuk melihat informasi',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
