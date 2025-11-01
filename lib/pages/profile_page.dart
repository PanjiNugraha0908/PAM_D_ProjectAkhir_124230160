import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'edit_profile_page.dart';
import 'dart:io';
// Import untuk navigasi
import 'location_page.dart';
import 'history_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import '../services/auth_service.dart';

/// Halaman (Page) StatelessWidget untuk menampilkan data profil pengguna.
///
/// Halaman ini menggunakan [ValueListenableBuilder] untuk mendengarkan
/// perubahan data profil dari [Hive] secara real-time berdasarkan
/// username yang sedang login (didapat dari [AuthService]).
class ProfilePage extends StatelessWidget {
  // --- Palet Warna Halaman ---
  // Catatan: Sebaiknya palet warna ini dipindahkan ke file theme/constants terpisah
  // agar konsisten dan mudah dikelola di seluruh aplikasi.
  final Color backgroundColor = Color(0xFF1A202C);
  final Color surfaceColor = Color(0xFF2D3748);
  final Color accentColor = Color(0xFF66B3FF);
  final Color primaryButtonColor = Color(0xFF4299E1);
  final Color textColor = Color(0xFFE2E8F0);
  final Color hintColor = Color(0xFFA0AEC0);

  // --- Fungsi Navigasi ---

  /// Navigasi kembali ke [HomePage].
  /// Ini digunakan oleh tombol 'back' kustom di AppBar.
  void _openHome(BuildContext context) {
    String? username = AuthService.getCurrentUsername();
    if (username != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(username: username)),
      );
    } else {
      // Fallback ke Login Page jika sesi hilang
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  /// Navigasi ke [HistoryPage] (Tab).
  void _openHistory(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  /// Navigasi ke [LocationPage] (Tab).
  void _openLocation(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LocationPage()),
    );
  }

  /// Handler untuk [BottomNavigationBar] onTap.
  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0: // Profil (Halaman ini)
        // Tidak melakukan apa-apa
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
    // Dapatkan username yang sedang login
    final String? username = AuthService.getCurrentUsername();

    return Scaffold(
      backgroundColor: backgroundColor,
      // --- 1. AppBar ---
      appBar: AppBar(
        // Tombol 'back' kustom untuk kembali ke Home
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => _openHome(context),
        ),
        title: Text('Profil Pengguna', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        actions: [
          // Tombol Edit
          IconButton(
            icon: Icon(Icons.edit, color: accentColor),
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

      // --- 2. Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: surfaceColor,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: hintColor,
        selectedItemColor: accentColor,
        currentIndex: 0, // Menandai 'Profil' sebagai tab aktif
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

      // --- 3. Body (Menggunakan ValueListenableBuilder) ---
      // Builder ini akan otomatis update UI ketika data di Hive
      // untuk 'key' username ini berubah (misalnya setelah diedit).
      body: ValueListenableBuilder(
        valueListenable: Hive.box('profile').listenable(keys: [username ?? '']),
        builder: (context, Box box, _) {
          // Ambil data profil spesifik milik user dari Hive
          final userProfileData = box.get(username) ?? <String, dynamic>{};

          // Ekstrak data untuk ditampilkan
          String email = userProfileData['email'] ?? 'Email Belum Diatur';
          String noHp = userProfileData['noHp'] ?? 'No. HP Belum Diatur';
          String nama = userProfileData['nama'] ?? 'Nama Belum Diatur';
          String prodi = userProfileData['prodi'] ?? 'Prodi Belum Diatur';
          String? fotoPath = userProfileData['fotoPath'];
          String saranKesan = userProfileData['saranKesan'] ?? '';

          return Container(
            color: backgroundColor,
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- 3A. Foto Profil (Avatar) ---
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: surfaceColor,
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

                  // --- 3B. Nama dan Username ---
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
                  Text(
                    '@${username ?? 'User'}',
                    style: TextStyle(fontSize: 16, color: hintColor),
                  ),
                  SizedBox(height: 32),

                  // --- 3C. Kartu Informasi Data Diri ---
                  Card(
                    color: surfaceColor,
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
                            'Email',
                            email.isEmpty ? 'Belum Diatur' : email,
                            Icons.email,
                          ),
                          Divider(color: hintColor.withOpacity(0.5)),
                          _buildInfoTile(
                            'Nomor HP',
                            noHp.isEmpty ? 'Belum Diatur' : noHp,
                            Icons.phone,
                          ),
                          Divider(color: hintColor.withOpacity(0.5)),
                          _buildInfoTile(
                            'Program Studi',
                            prodi.isEmpty ? 'Belum Diatur' : prodi,
                            Icons.school,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // --- 3D. Kartu Saran & Kesan ---
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

  /// [Helper Widget] Membangun satu baris info (Ikon, Label, Value)
  /// di dalam kartu data diri.
  Widget _buildInfoTile(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: primaryButtonColor, size: 28),
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

  /// [Helper Widget] Membangun bagian kartu 'Saran & Kesan'.
  Widget _buildSaranKesanSection(BuildContext context, String saranKesan) {
    return Card(
      color: surfaceColor,
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
                    color: primaryButtonColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, size: 18, color: hintColor),
                  onPressed: () {
                    // Navigasi ke EditProfilePage
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
              color: hintColor.withOpacity(0.5),
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
