import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
// Impor untuk navigasi BottomNavBar
import 'profile_page.dart';
import 'location_page.dart';
import 'login_page.dart';
import 'home_page.dart';

/// Halaman (Page) Stateful untuk menampilkan riwayat pencarian negara
/// yang telah dilihat oleh pengguna yang sedang login.
class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // --- State ---
  List<HistoryItem> _history = [];

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
    _loadHistory();
  }

  // --- Logika Halaman (Page Logic) ---

  /// Mengambil data history dari [DatabaseService] untuk pengguna
  /// yang sedang login (dari [AuthService]) dan memperbarui state [_history].
  void _loadHistory() {
    String? username = AuthService.getCurrentUsername();
    if (username != null) {
      setState(() {
        _history = DatabaseService.getHistoryForUser(username);
      });
    }
  }

  /// Menampilkan dialog konfirmasi dan menghapus semua history
  /// jika pengguna setuju.
  Future<void> _clearHistory() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Hapus History', style: TextStyle(color: textColor)),
        content: Text(
          'Apakah Anda yakin ingin menghapus semua history?',
          style: TextStyle(color: hintColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Batal
            child: Text('Batal', style: TextStyle(color: hintColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Konfirmasi
            child: Text(
              'Hapus',
              style: TextStyle(color: accentColor),
            ),
          ),
        ],
      ),
    );

    // Jika pengguna menekan "Hapus"
    if (confirm == true) {
      String? username = AuthService.getCurrentUsername();
      if (username != null) {
        await DatabaseService.clearHistoryForUser(username);
        _loadHistory(); // Muat ulang list (yang sekarang kosong)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('History berhasil dihapus'),
            backgroundColor: primaryButtonColor,
          ),
        );
      }
    }
  }

  // --- Navigasi ---

  /// Navigasi kembali ke [HomePage].
  /// Ini digunakan oleh tombol 'back' kustom di AppBar.
  void _openHome() {
    String? username = AuthService.getCurrentUsername();
    if (username != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(username: username)),
      );
    } else {
      // Fallback jika session hilang, kembali ke Login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  /// Navigasi ke [ProfilePage] menggunakan [pushReplacement]
  /// untuk pengalaman seperti 'tab'.
  void _openProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  /// Navigasi ke [LocationPage] menggunakan [pushReplacement]
  /// untuk pengalaman seperti 'tab'.
  void _openLocation() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LocationPage()),
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
      case 2: // History (Halaman ini)
        // Tidak melakukan apa-apa karena sudah di halaman ini
        break;
    }
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // --- 1. AppBar ---
      appBar: AppBar(
        // Tombol 'leading' ini dikustomisasi untuk kembali ke Home,
        // bukan 'pop' stack seperti bawaan.
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: _openHome,
        ),
        title: Text('History Pencarian', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        actions: [
          // Hanya tampilkan tombol hapus jika ada history
          if (_history.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete_sweep,
                color: accentColor,
              ),
              onPressed: _clearHistory,
              tooltip: 'Hapus Semua History',
            ),
        ],
      ),

      // --- 2. Body ---
      body: Container(
        color: backgroundColor,
        child: _history.isEmpty
            // --- 2A. Tampilan Kosong (Empty State) ---
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
            // --- 2B. Tampilan Daftar History ---
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
                              _formatDate(item.viewedAt), // Format waktu
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
                        color: surfaceColor,
                        height: 16,
                        indent: 16,
                        endIndent: 16,
                      ),
                    ],
                  );
                },
              ),
      ),

      // --- 3. Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: surfaceColor,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: hintColor,
        selectedItemColor: accentColor,
        currentIndex: 2, // Menandai 'History' sebagai tab aktif
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
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }

  // --- Helper ---

  /// Mengubah [DateTime] menjadi format waktu relatif (misal: "5 menit yang lalu").
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
      // Format tanggal standar jika sudah lebih dari seminggu
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}