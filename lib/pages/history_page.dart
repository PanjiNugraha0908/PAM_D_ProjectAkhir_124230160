import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'profile_page.dart';
import 'location_page.dart';
import 'login_page.dart';
import 'home_page.dart';

/// Halaman untuk menampilkan riwayat pencarian negara
class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryItem> _history = [];

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
        backgroundColor: Color(0xFF2D3748), // surfaceColor
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Hapus History',
          style: TextStyle(color: Color(0xFFE2E8F0)),
        ), // textColor
        content: Text(
          'Apakah Anda yakin ingin menghapus semua history?',
          style: TextStyle(color: Color(0xFFA0AEC0)), // hintColor
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(color: Color(0xFFA0AEC0)),
            ), // hintColor
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: TextStyle(color: Color(0xFF66B3FF)), // accentColor
            ),
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
            backgroundColor: Color(0xFF4299E1), // primaryButtonColor
          ),
        );
      }
    }
  }

  // --- Navigasi ---
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void _openLocation() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LocationPage()),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A202C), // backgroundColor
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFE2E8F0)), // textColor
          onPressed: _openHome,
        ),
        title: Text(
          'History Pencarian',
          style: TextStyle(color: Color(0xFFE2E8F0)),
        ), // textColor
        backgroundColor: Color(0xFF1A202C), // backgroundColor
        iconTheme: IconThemeData(color: Color(0xFFE2E8F0)), // textColor
        elevation: 0,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete_sweep,
                color: Color(0xFF66B3FF), // accentColor
              ),
              onPressed: _clearHistory,
              tooltip: 'Hapus Semua History',
            ),
        ],
      ),
      body: _history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Color(0xFFA0AEC0),
                  ), // hintColor
                  SizedBox(height: 16),
                  Text(
                    'Belum ada history',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFA0AEC0),
                    ), // hintColor
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cari negara untuk menambah history',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFA0AEC0).withOpacity(0.7), // hintColor
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
                          color: Color(0xFFE2E8F0), // textColor
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            'Ibu Kota: ${item.capital}',
                            style: TextStyle(
                              color: Color(0xFFA0AEC0),
                            ), // hintColor
                          ),
                          Text(
                            'Region: ${item.region}',
                            style: TextStyle(
                              color: Color(0xFFA0AEC0),
                            ), // hintColor
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatDate(item.viewedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(
                                0xFFA0AEC0,
                              ).withOpacity(0.7), // hintColor
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                    Divider(
                      color: Color(0xFF2D3748), // surfaceColor
                      height: 16,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF2D3748), // surfaceColor
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Color(0xFFA0AEC0), // hintColor
        selectedItemColor: Color(0xFF66B3FF), // accentColor
        currentIndex: 2,
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
