import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'edit_profile_page.dart';
import 'dart:io';
// Tambahkan import untuk navigasi BottomNavBar dan kembali ke Home
import 'location_page.dart';
import 'history_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  // Palet Warna (Sudah Gelap)
  final Color primaryColor = Color(0xFF010A1E);
  final Color secondaryColor = Color(0xFF103070);
  final Color tertiaryColor = Color(0xFF2A364B);
  final Color cardColor = Color(0xFF21252F);
  final Color textColor = Color(0xFFD9D9D9);
  final Color hintColor = Color(0xFF898989);

  // Tambahkan navigasi helper untuk kembali ke Home
  void _openHome(BuildContext context) {
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

  void _openHistory(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  void _openLocation(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LocationPage()),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0: // Profil (Stay on page)
        break;
      case 1: // Lokasi
        _openLocation(context);
        break;
      case 2: // History
        _openHistory(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // === BottomNavigationBar ===
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cardColor,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: hintColor,
        selectedItemColor: hintColor, // Agar semua icon seragam/tidak berwarna
        currentIndex: 0, // Index untuk 'Profil'
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.my_location),
            label: 'Lokasi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),

      // === Akhir BottomNavigationBar ===
      backgroundColor: primaryColor,
      appBar: AppBar(
        // Tambahkan tombol kembali dan fungsi _openHome
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => _openHome(context),
        ),
        title: Text('Profil Pembuat', style: TextStyle(color: textColor)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: textColor),
            tooltip: 'Edit Profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('profile').listenable(),
        builder: (context, Box box, _) {
          String nama = box.get('nama', defaultValue: 'Nama Belum Diatur');
          String noHp = box.get('noHp', defaultValue: 'No. HP Belum Diatur');
          String prodi = box.get('prodi', defaultValue: 'Prodi Belum Diatur');
          String email = box.get('email', defaultValue: 'Email Belum Diatur');
          String? fotoPath = box.get('fotoPath');
          // 👇 BARU: Ambil Saran & Kesan
          String saranKesan = box.get('saranKesan', defaultValue: '');

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, secondaryColor, tertiaryColor],
              ),
            ),
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: tertiaryColor,
                    backgroundImage: (fotoPath != null && fotoPath.isNotEmpty)
                        ? FileImage(File(fotoPath))
                        : null,
                    child: (fotoPath == null || fotoPath.isEmpty)
                        ? Icon(
                            Icons.person,
                            size: 80,
                            color: textColor.withOpacity(0.8),
                          )
                        : null,
                  ),
                  SizedBox(height: 24),

                  Text(
                    nama,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),

                  Text(noHp, style: TextStyle(fontSize: 16, color: hintColor)),
                  SizedBox(height: 32),

                  Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: Column(
                        children: [
                          _buildInfoTile(
                            'Program Studi',
                            prodi.isEmpty ? 'Belum Diatur' : prodi,
                            Icons.school,
                          ),
                          Divider(color: tertiaryColor.withOpacity(0.5)),
                          _buildInfoTile(
                            'Email',
                            email.isEmpty ? 'Belum Diatur' : email,
                            Icons.email,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 32), // Jarak antara info dan saran/kesan
                  // 👇 BARU: Bagian Saran & Kesan
                  _buildSaranKesanSection(context, saranKesan),

                  SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: secondaryColor, size: 28),
      title: Text(label, style: TextStyle(fontSize: 14, color: hintColor)),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  // 👇 BARU: Widget untuk menampilkan Saran & Kesan
  Widget _buildSaranKesanSection(BuildContext context, String saranKesan) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saran & Kesan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, size: 18, color: hintColor),
                  onPressed: () {
                    // Navigasi ke EditProfilePage, yang kini juga bisa mengedit saranKesan
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(),
                      ),
                    );
                  },
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.zero,
                  tooltip: 'Edit Saran & Kesan',
                ),
              ],
            ),
            Divider(
              color: tertiaryColor.withOpacity(0.5),
              height: 16,
              thickness: 1,
            ),
            Text(
              saranKesan.isNotEmpty
                  ? saranKesan
                  : 'Belum ada saran atau kesan yang ditambahkan. Ketuk ikon edit di atas untuk menulis.',
              style: TextStyle(
                fontSize: 14,
                color: saranKesan.isNotEmpty ? textColor : hintColor,
                fontStyle: saranKesan.isNotEmpty
                    ? FontStyle.normal
                    : FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
