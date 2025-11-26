import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'edit_profile_page.dart';
import 'history_page.dart';
import 'location_page.dart';
import 'home_page.dart';
import '../models/history_item.dart';
import '../models/favorite_item.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;

  // ===== TAMBAHAN BARU: State untuk show/hide saran kesan =====
  bool _showSaranKesan = false;
  // =============================================================

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    String? username = AuthService.getCurrentUsername();
    if (username != null) {
      User? user = await DatabaseService.getUser(username);
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    }
  }

  Future<void> _editProfile() async {
    if (_user == null) return;

    final bool? profileWasUpdated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage(user: _user!)),
    );

    if (profileWasUpdated == true) {
      _loadUserProfile();
    }
  }

  void _openHome() {
    String? username = AuthService.getCurrentUsername();
    if (username != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(username: username)),
      );
    }
  }

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

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
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
      backgroundColor: Color(0xFF1A202C),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFE2E8F0)),
          onPressed: _openHome,
        ),
        title: Text('Profil Saya', style: TextStyle(color: Color(0xFFE2E8F0))),
        backgroundColor: Color(0xFF1A202C),
        iconTheme: IconThemeData(color: Color(0xFFE2E8F0)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Color(0xFF66B3FF)),
            onPressed: _editProfile,
            tooltip: 'Edit Profil',
          ),
        ],
      ),
      body: _user == null
          ? Center(child: CircularProgressIndicator(color: Color(0xFF4299E1)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF2D3748),
                    backgroundImage: _user!.profilePicturePath != null
                        ? FileImage(File(_user!.profilePicturePath!))
                        : null,
                    child: _user!.profilePicturePath == null
                        ? Icon(Icons.person, size: 60, color: Color(0xFFA0AEC0))
                        : null,
                  ),
                  SizedBox(height: 16),
                  Text(
                    _user!.fullName.isEmpty
                        ? '(Nama Belum Diatur)'
                        : _user!.fullName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                  Text(
                    '@${_user!.username}',
                    style: TextStyle(fontSize: 16, color: Color(0xFFA0AEC0)),
                  ),
                  SizedBox(height: 32),

                  // Informasi Profil
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF2D3748),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: _user!.email,
                        ),
                        Divider(color: Color(0xFFA0AEC0).withOpacity(0.3)),
                        _buildInfoRow(
                          icon: Icons.phone_outlined,
                          label: 'No. HP',
                          value: _user!.noHp.isEmpty ? '-' : _user!.noHp,
                        ),
                        Divider(color: Color(0xFFA0AEC0).withOpacity(0.3)),
                        _buildInfoRow(
                          icon: Icons.history,
                          label: 'Negara Dilihat',
                          value: DatabaseService.getHistoryForUser(
                            _user!.username,
                          ).map((h) => h.countryName).toSet().length.toString(),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // ===== PERUBAHAN: Saran dan Kesan dengan Toggle =====
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF2D3748),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header yang bisa diklik
                        InkWell(
                          onTap: () {
                            setState(() {
                              _showSaranKesan = !_showSaranKesan;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.comment_outlined,
                                  color: Color(0xFF66B3FF),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Saran dan Kesan',
                                    style: TextStyle(
                                      color: Color(0xFF66B3FF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _showSaranKesan
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Color(0xFFA0AEC0),
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _showSaranKesan ? 'Sembunyikan' : 'Lihat',
                                  style: TextStyle(
                                    color: Color(0xFFA0AEC0),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Konten yang muncul/hilang
                        if (_showSaranKesan) ...[
                          Divider(
                            height: 1,
                            color: Color(0xFFA0AEC0).withOpacity(0.3),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "Kesan saya untuk mata kuliah Pemrograman Aplikasi Mobile ini... jujur, tugasnya 'sangat mudah'. Mengurus state management, integrasi API, notifikasi, dan database Hive itu ternyata ringan sekali.\n\nPesan saya, terima kasih banyak kepada Pak Bagus atas bimbingan dan materi yang diberikan. Pengalaman mengerjakan project akhir ini sungguh tak terlupakan.\n\nSEGAMPANG ITU!!",
                              style: TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 14,
                                height: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // ===== AKHIR PERUBAHAN =====

                  SizedBox(height: 24),

                  // Bagian Negara Favorit
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF2D3748),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Color(0xFF66B3FF),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Negara Favorit',
                              style: TextStyle(
                                color: Color(0xFF66B3FF),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Builder(
                          builder: (context) {
                            final List<FavoriteItem> favorites =
                                DatabaseService.getFavoritesForUser(
                                    _user!.username);

                            if (favorites.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Text(
                                    'Belum ada negara favorit.\nTekan ikon hati di halaman detail negara.',
                                    style: TextStyle(
                                      color: Color(0xFFA0AEC0),
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 3 / 2.8,
                              ),
                              itemCount: favorites.length,
                              itemBuilder: (context, index) {
                                final item = favorites[index];
                                return Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: item.flagUrl.isNotEmpty
                                          ? Image.network(
                                              item.flagUrl,
                                              height: 50,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              height: 50,
                                              width: double.infinity,
                                              color: Color(0xFF1A202C),
                                              child: Icon(
                                                Icons.flag,
                                                color: Color(0xFFA0AEC0),
                                              ),
                                            ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      item.countryName,
                                      style: TextStyle(
                                        color: Color(0xFFE2E8F0),
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF2D3748),
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Color(0xFFA0AEC0),
        selectedItemColor: Color(0xFF66B3FF),
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
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF66B3FF), size: 20),
          SizedBox(width: 16),
          Text(label, style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 14)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
