import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobileprojek/pages/edit_profile_page.dart';
import 'package:mobileprojek/pages/login_page.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String? _username = AuthService.getCurrentUsername();
  late final Box _profileBox;

  // Palet Warna
  final Color primaryColor = const Color(0xFF1A237E); // Biru Gelap
  final Color accentColor = const Color(0xFFFFAB00); // Kuning/Emas
  final Color cardColor = Colors.white;
  final Color shadowColor = Colors.blueGrey[200]!;

  @override
  void initState() {
    super.initState();
    // Pastikan box 'profile' sudah dibuka di main.dart
    _profileBox = Hive.box('profile');
  }

  // Fungsi untuk logout
  void _logout() async {
    await AuthService.logout();
    // Navigasi ke halaman Login dan hapus semua halaman sebelumnya
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  // Fungsi untuk navigasi ke Edit Profile
  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    ).then((_) {
      // Refresh halaman (setState) setelah kembali dari edit
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ValueListenableBuilder(
        valueListenable: _profileBox.listenable(keys: [_username]),
        builder: (context, Box box, _) {
          if (_username == null) {
            // Pengaman jika username null
            return Center(
                child: Text("Error: Pengguna tidak ditemukan. Silakan login ulang."));
          }
          // Ambil data profil dari Hive
          var userProfileData =
              box.get(_username) ?? <String, dynamic>{};

          // Data fallback jika null
          String nama = userProfileData['nama'] ?? 'Nama Belum Diatur';
          String prodi = userProfileData['prodi'] ?? 'Prodi Belum Diatur';
          String email = userProfileData['email'] ?? 'Email';
          String noHp = userProfileData['noHp'] ?? 'No HP';
          String? fotoPath = userProfileData['fotoPath'];

          return CustomScrollView(
            slivers: [
              // --- AppBar Kustom ---
              _buildSliverAppBar(context, nama, prodi, fotoPath),

              // --- Konten Body (Info Card) ---
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(
                        'Informasi Kontak',
                        Icons.contact_mail,
                        [
                          _buildInfoRow(Icons.email, email),
                          _buildInfoRow(Icons.phone, noHp),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // --- PERUBAHAN 9 (Goal 2) ---
                      // Mengubah Saran & Kesan menjadi statis
                      _buildInfoCard(
                        'Saran & Kesan',
                        Icons.lightbulb_outline,
                        [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Text(
                              // Ini adalah teks statis yang kamu minta
                              'Aplikasi ini sangat membantu untuk melihat informasi mata uang dan zona waktu. Tampilannya juga menarik!',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                                height: 1.4,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // --- AKHIR PERUBAHAN 9 ---

                      const SizedBox(height: 20),

                      // --- Tombol Logout ---
                      _buildLogoutButton(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget untuk AppBar
  SliverAppBar _buildSliverAppBar(
      BuildContext context, String nama, String prodi, String? fotoPath) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      backgroundColor: primaryColor,
      iconTheme: IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.white),
          onPressed: _navigateToEditProfile,
          tooltip: 'Edit Profil',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          _username!, // Username yang sedang login
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(blurRadius: 2.0, color: Colors.black.withOpacity(0.5))
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, Color(0xFF303F9F)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Foto Profil
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: (fotoPath != null
                            ? FileImage(File(fotoPath))
                            : null) as ImageProvider?,
                        child: fotoPath == null
                            ? Icon(Icons.person,
                                size: 60, color: Colors.grey[400])
                            : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      nama,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      prodi,
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    SizedBox(height: 40), // Ruang untuk title
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk Card Info
  Widget _buildInfoCard(String title, IconData titleIcon, List<Widget> children) {
    return Card(
      elevation: 5,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Card
            Row(
              children: [
                Icon(titleIcon, color: primaryColor, size: 22),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            Divider(height: 20, thickness: 1, color: Colors.grey[200]),
            // Konten Card
            ...children,
          ],
        ),
      ),
    );
  }

  // Widget untuk baris info (Icon + Teks)
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 16),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk tombol logout
  Widget _buildLogoutButton() {
    return Center(
      child: ElevatedButton.icon(
        icon: Icon(Icons.logout, color: Colors.red[700]),
        label: Text(
          'Logout',
          style: TextStyle(color: Colors.red[700], fontSize: 16),
        ),
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.red[100]!),
          ),
        ),
      ),
    );
  }
}