import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'edit_profile_page.dart'; // Import halaman edit yang baru kita buat

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Gunakan ValueListenableBuilder agar halaman otomatis update
    // saat data di Hive berubah (setelah kita simpan di halaman edit)
    return ValueListenableBuilder(
      valueListenable: Hive.box('profile').listenable(),
      builder: (context, Box box, _) {
        // Ambil data dari Hive. Jika kosong, gunakan data default.
        String nama = box.get('nama', defaultValue: 'Nama Belum Diatur');
        String noHp = box.get('noHp', defaultValue: 'No. HP Belum Diatur');
        String prodi = box.get('prodi', defaultValue: 'Prodi Belum Diatur');
        String email = box.get('email', defaultValue: 'Email Belum Diatur');
        String fotoUrl = box.get('fotoUrl', defaultValue: '');

        return Scaffold(
          appBar: AppBar(
            title: Text('Profil Pembuat'),
            actions: [
              // Tombol Edit
              IconButton(
                icon: Icon(Icons.edit),
                tooltip: 'Edit Profil',
                onPressed: () {
                  // Pindah ke halaman Edit Profil
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfilePage()),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 32),
                // Foto profil
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.grey[300],
                  // Tampilkan foto dari URL jika ada, jika tidak tampilkan Icon
                  backgroundImage: fotoUrl.isNotEmpty
                      ? NetworkImage(fotoUrl)
                      : null,
                  child: fotoUrl.isEmpty
                      ? Icon(Icons.person, size: 80, color: Colors.grey[600])
                      : null,
                ),
                SizedBox(height: 24),
                // Nama
                Text(
                  nama,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                // No. HP (menggantikan NIM)
                Text(
                  noHp,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 32),
                // Informasi tambahan
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection('Program Studi', prodi, Icons.school),
                      _buildInfoSection('Email', email, Icons.email),
                      // Kita hapus Fakultas, Universitas, dan GitHub
                    ],
                  ),
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget helper (tidak berubah dari kode lama)
  Widget _buildInfoSection(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
