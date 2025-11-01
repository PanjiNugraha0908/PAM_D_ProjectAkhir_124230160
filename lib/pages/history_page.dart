import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
// Tambahkan import halaman lain untuk navigasi BottomNavBar dan kembali ke Home
import 'profile_page.dart';
import 'location_page.dart';
import 'login_page.dart';
import 'home_page.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryItem> _history = [];

  // Palet Warna (DIPERBARUI)
  final Color primaryColor = Color(0xFF010A1E); // LEBIH GELAP
  final Color secondaryColor = Color(0xFF103070); // LEBIH GELAP
  final Color tertiaryColor = Color(0xFF2A364B); // LEBIH GELAP
  final Color cardColor = Color(0xFF21252F);
  final Color textColor = Color(0xFFD9D9D9);
  final Color hintColor = Color(0xFF898989);

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    String? username = AuthService.getCurrentUsername();
    if (username != null) {
      setState(() {
        _history = DatabaseService.getHistoryForUser(username);
      });
    }
  }

  Future<void> _clearHistory() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Hapus History', style: TextStyle(color: textColor)),
        content: Text(
          'Apakah Anda yakin ingin menghapus semua history?',
          style: TextStyle(color: hintColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: hintColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      String? username = AuthService.getCurrentUsername();
      if (username != null) {
        await DatabaseService.clearHistoryForUser(username);
        _loadHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('History berhasil dihapus'),
            backgroundColor: secondaryColor,
          ),
        );
      }
    }
  }

  // Tambahkan navigasi helper untuk BottomNavBar dan kembali ke Home
  void _openHome() {
    String? username = AuthService.getCurrentUsername();
    if (username != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(username: username)),
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  void _openProfile() {
    // Menggunakan pushReplacement untuk navigasi antar tab utama agar stack tetap bersih
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void _openLocation() {
    // Menggunakan pushReplacement untuk navigasi antar tab utama agar stack tetap bersih
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LocationPage()),
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0: // Profil
        _openProfile();
        break;
      case 1: // Lokasi
        _openLocation();
        break;
      case 2: // History (Tetap di halaman ini)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // === Tambahkan BottomNavigationBar di sini ===
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cardColor,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: hintColor,
        selectedItemColor: hintColor, // Agar semua icon seragam/tidak berwarna
        currentIndex: 2, // Index untuk 'History'
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
      backgroundColor: Colors.transparent, // Untuk gradient
      appBar: AppBar(
        // Tambahkan tombol kembali dan fungsi _openHome
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: _openHome,
        ),
        title: Text('History Pencarian', style: TextStyle(color: textColor)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: hintColor),
              onPressed: _clearHistory,
              tooltip: 'Hapus Semua History',
            ),
        ],
      ),
      body: Container(
        // Background Gradient (DIPERBARUI)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, secondaryColor, tertiaryColor],
          ),
        ),
        child: _history.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: hintColor),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada history',
                      style: TextStyle(fontSize: 18, color: hintColor),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Cari negara untuk menambah history',
                      style: TextStyle(
                        fontSize: 14,
                        color: hintColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return Column(
                    children: [
                      ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.flagUrl,
                            width: 60,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          item.countryName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              'Ibu Kota: ${item.capital}',
                              style: TextStyle(color: hintColor),
                            ),
                            Text(
                              'Region: ${item.region}',
                              style: TextStyle(color: hintColor),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _formatDate(item.viewedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: hintColor.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                      Divider(
                        color: tertiaryColor.withOpacity(0.5),
                        height: 16,
                        indent: 16,
                        endIndent: 16,
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return 'Baru saja';
        }
        return '${diff.inMinutes} menit yang lalu';
      }
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari yang lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
