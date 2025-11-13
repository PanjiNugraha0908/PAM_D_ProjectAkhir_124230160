// lib/pages/history_page.dart
import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'profile_page.dart';
import 'location_page.dart';
import 'login_page.dart';
import 'home_page.dart';

class HistoryPage extends StatefulWidget {
  // Constructor asli Anda (tanpa parameter)
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
        backgroundColor: Color(0xFF2D3748),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Hapus History',
          style: TextStyle(color: Color(0xFFE2E8F0)),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus semua history?',
          style: TextStyle(color: Color(0xFFA0AEC0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(color: Color(0xFFA0AEC0)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: TextStyle(color: Color(0xFF66B3FF)),
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
            backgroundColor: Color(0xFF4299E1),
          ),
        );
      }
    }
  }

  Future<void> _deleteHistoryItem(HistoryItem item, int index) async {
    final HistoryItem backup = HistoryItem(
      username: item.username,
      countryName: item.countryName,
      flagUrl: item.flagUrl,
      capital: item.capital,
      region: item.region,
      viewedAt: item.viewedAt,
      isFavorite: item.isFavorite,
    );

    setState(() {
      _history.removeAt(index);
    });

    await item.delete();

    ScaffoldMessenger.of(
      context,
    ).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.countryName} dihapus dari history'),
        backgroundColor: Color(0xFF4299E1),
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'BATAL',
          textColor: Colors.white,
          onPressed: () {
            DatabaseService.addHistory(backup);
            setState(() {
              _history.insert(index, backup);
            });
          },
        ),
      ),
    );
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
      backgroundColor: Color(0xFF1A202C),
      appBar: AppBar(
        // --- PERBAIKAN TOMBOL BACK ---
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFE2E8F0)),
          onPressed:
              _openHome, // Biarkan ini, karena logic Anda pakai pushReplacement
        ),
        // --- AKHIR PERBAIKAN ---
        title: Text(
          'History Pencarian',
          style: TextStyle(color: Color(0xFFE2E8F0)),
        ),
        backgroundColor: Color(0xFF1A202C),
        iconTheme: IconThemeData(color: Color(0xFFE2E8F0)),
        elevation: 0,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete_sweep,
                color: Color(0xFF66B3FF),
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
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada history',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFA0AEC0),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cari negara untuk menambah history',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFA0AEC0).withOpacity(0.7),
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

                return Dismissible(
                  key: Key(item.key.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteHistoryItem(item, index);
                  },
                  background: Container(
                    color: Colors.red.shade800,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'HAPUS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.delete_forever, color: Colors.white),
                      ],
                    ),
                  ),
                  child: Column(
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
                            color: Color(0xFFE2E8F0),
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
                              ),
                            ),
                            Text(
                              'Region: ${item.region}',
                              style: TextStyle(
                                color: Color(0xFFA0AEC0),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _formatDate(item.viewedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(
                                  0xFFA0AEC0,
                                ).withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                      Divider(
                        color: Color(0xFF2D3748),
                        height: 16,
                        indent: 16,
                        endIndent: 16,
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF2D3748),
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Color(0xFFA0AEC0),
        selectedItemColor: Color(0xFF66B3FF),
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
