import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'edit_profile_page.dart'; // Import halaman edit
import 'dart:io'; // Import untuk File

class ProfilePage extends StatelessWidget {
  // Palet Warna
  final Color primaryColor = Color(0xFF041C4A);
  final Color secondaryColor = Color(0xFF214894);
  final Color tertiaryColor = Color(0xFF394461);
  final Color cardColor = Color(0xFF21252F);
  final Color textColor = Color(0xFFD9D9D9);
  final Color hintColor = Color(0xFF898989);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Untuk gradient
      appBar: AppBar(
        title: Text('Profil Pembuat', style: TextStyle(color: textColor)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        actions: [
          // Tombol Edit
          IconButton(
            icon: Icon(Icons.edit, color: textColor),
            tooltip: 'Edit Profil',
            onPressed: () {
              // Pindah ke halaman Edit Profil
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
              // TIDAK PERLU .then() atau reassemble
              // ValueListenableBuilder akan otomatis update
            },
          ),
        ],
      ),
      // Gunakan ValueListenableBuilder agar halaman otomatis update
      body: ValueListenableBuilder(
        valueListenable: Hive.box('profile').listenable(),
        builder: (context, Box box, _) {
          // Ambil data dari Hive.
          String nama = box.get('nama', defaultValue: 'Nama Belum Diatur');
          String noHp = box.get('noHp', defaultValue: 'No. HP Belum Diatur');
          String prodi = box.get('prodi', defaultValue: 'Prodi Belum Diatur');
          String email = box.get('email', defaultValue: 'Email Belum Diatur');
          // Ganti 'fotoUrl' menjadi 'fotoPath'
          String? fotoPath = box.get('fotoPath'); 

          return Container(
            // Background Gradient
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, secondaryColor, tertiaryColor],
              ),
            ),
            width: double.infinity,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center horizontal
                children: [
                  SizedBox(height: 32),
                  // Foto profil
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: tertiaryColor,
                    // Tampilkan foto dari PATH jika ada
                    backgroundImage: (fotoPath != null && fotoPath.isNotEmpty)
                        ? FileImage(File(fotoPath))
                        : null,
                    child: (fotoPath == null || fotoPath.isEmpty)
                        ? Icon(Icons.person, size: 80, color: hintColor)
                        : null,
                  ),
                  SizedBox(height: 24),
                  
                  // Nama (di-center dan bisa wrap)
                  Text(
                    nama,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                    textAlign: TextAlign.center, // <-- PERBAIKAN TATA LETAK
                  ),
                  SizedBox(height: 8),
                  
                  // No. HP
                  Text(
                    noHp,
                    style: TextStyle(fontSize: 16, color: hintColor),
                  ),
                  SizedBox(height: 32),
                  
                  // Informasi tambahan (menggunakan layout baru)
                  _buildInfoTile(
                    'Program Studi',
                    prodi.isEmpty ? 'Belum Diatur' : prodi,
                    Icons.school,
                  ),
                  _buildInfoTile(
                    'Email',
                    email.isEmpty ? 'Belum Diatur' : email,
                    Icons.email,
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget helper baru sesuai screenshot
  Widget _buildInfoTile(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: secondaryColor, size: 28),
      title: Text(
        label,
        style: TextStyle(fontSize: 14, color: hintColor),
      ),
      subtitle: Text(
        value,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
      ),
      contentPadding: EdgeInsets.zero, // Hapus padding default ListTile
    );
  }
}