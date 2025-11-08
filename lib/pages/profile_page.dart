import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobileprojek/pages/edit_profile_page.dart';
import 'package:mobileprojek/pages/login_page.dart';
import '../services/auth_service.dart';
import 'home_page.dart'; // <-- PERLU IMPORT INI UNTUK NAVIGASI KEMBALI

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String? _username = AuthService.getCurrentUsername();
  late final Box _profileBox;

  // --- PERUBAHAN 1: Palet Warna (Disesuaikan dengan Dark Mode) ---
  final Color backgroundColor = Color(0xFF1A202C);
  final Color surfaceColor = Color(0xFF2D3748);
  final Color accentColor = Color(0xFF66B3FF);
  // final Color primaryButtonColor = Color(0xFF4299E1); // Tidak terpakai di sini
  final Color textColor = Color(0xFFE2E8F0);
  final Color hintColor = Color(0xFFA0AEC0);
  // --- AKHIR PERUBAHAN 1 ---

  @override
  void initState() {
    super.initState();
    _profileBox = Hive.box('profile');
  }

  // --- PERUBAHAN 2: Fungsi untuk Tombol "Kembali" ---
  /// Navigasi kembali ke [HomePage].
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
  // --- AKHIR PERUBAHAN 2 ---

  // Fungsi untuk navigasi ke Edit Profile
  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // <-- PERUBAHAN WARNA
      body: ValueListenableBuilder(
        valueListenable: _profileBox.listenable(keys: [_username]),
        builder: (context, Box box, _) {
          if (_username == null) {
            return Center(child: Text("Error: Pengguna tidak ditemukan."));
          }
          var userProfileData = box.get(_username) ?? <String, dynamic>{};

          String nama = userProfileData['nama'] ?? 'Nama Belum Diatur';
          String prodi = userProfileData['prodi'] ?? 'Prodi Belum Diatur';
          String email = userProfileData['email'] ?? 'Email';
          String noHp = userProfileData['noHp'] ?? 'No HP';
          String? fotoPath = userProfileData['fotoPath'];

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, nama, prodi, fotoPath),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard('Informasi Kontak', Icons.contact_mail, [
                        _buildInfoRow(Icons.email, email),
                        _buildInfoRow(Icons.phone, noHp),
                      ]),
                      const SizedBox(height: 20),
                      _buildInfoCard('Saran & Kesan', Icons.lightbulb_outline, [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: Text(
                            'Aplikasi ini sangat membantu untuk melihat informasi mata uang dan zona waktu. Tampilannya juga menarik!',
                            style: TextStyle(
                              fontSize: 15,
                              color: hintColor, // <-- PERUBAHAN WARNA
                              height: 1.4,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ]),

                      // --- PERUBAHAN 4: Tombol Logout Dihapus ---
                      // const SizedBox(height: 20),
                      // _buildLogoutButton(),
                      // --- AKHIR PERUBAHAN 4 ---
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

  SliverAppBar _buildSliverAppBar(
    BuildContext context,
    String nama,
    String prodi,
    String? fotoPath,
  ) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      backgroundColor: backgroundColor, // <-- PERUBAHAN WARNA
      iconTheme: IconThemeData(color: textColor), // <-- PERUBAHAN WARNA
      // --- PERUBAHAN 3: Tombol "Kembali" Ditambahkan ---
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: textColor),
        onPressed: _openHome,
        tooltip: 'Kembali ke Home',
      ),

      // --- AKHIR PERUBAHAN 3 ---
      actions: [
        IconButton(
          icon: Icon(Icons.edit, color: textColor), // <-- PERUBAHAN WARNA
          onPressed: _navigateToEditProfile,
          tooltip: 'Edit Profil',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          _username!,
          style: TextStyle(
            color: textColor, // <-- PERUBAHAN WARNA
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          color: backgroundColor, // <-- PERUBAHAN WARNA (Gradient Dihapus)
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: surfaceColor.withOpacity(
                        0.5,
                      ), // <-- PERUBAHAN WARNA
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: surfaceColor, // <-- PERUBAHAN WARNA
                        backgroundImage:
                            (fotoPath != null
                                    ? FileImage(File(fotoPath))
                                    : null)
                                as ImageProvider?,
                        child: fotoPath == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: hintColor,
                              ) // <-- PERUBAHAN WARNA
                            : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      nama,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ), // <-- PERUBAHAN WARNA
                    ),
                    SizedBox(height: 4),
                    Text(
                      prodi,
                      style: TextStyle(
                        fontSize: 16,
                        color: hintColor,
                      ), // <-- PERUBAHAN WARNA
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    IconData titleIcon,
    List<Widget> children,
  ) {
    return Card(
      elevation: 0, // <-- PERUBAHAN (Flat)
      shadowColor: Colors.transparent, // <-- PERUBAHAN
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: surfaceColor, // <-- PERUBAHAN WARNA
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  titleIcon,
                  color: accentColor,
                  size: 22,
                ), // <-- PERUBAHAN WARNA
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor, // <-- PERUBAHAN WARNA
                  ),
                ),
              ],
            ),
            Divider(
              height: 20,
              thickness: 1,
              color: hintColor.withOpacity(0.2),
            ), // <-- PERUBAHAN WARNA
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, color: hintColor, size: 20), // <-- PERUBAHAN WARNA
          SizedBox(width: 16),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: textColor.withOpacity(0.9),
              ), // <-- PERUBAHAN WARNA
            ),
          ),
        ],
      ),
    );
  }

  // --- PERUBAHAN 5: Seluruh Fungsi Logout Dihapus ---
  // Widget _buildLogoutButton() { ... }
  // --- AKHIR PERUBAHAN 5 ---
}
