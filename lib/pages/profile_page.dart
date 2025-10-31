import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'edit_profile_page.dart';
import 'dart:io';

class ProfilePage extends StatelessWidget {
  // Palet Warna (Sudah Gelap)
  final Color primaryColor = Color(0xFF010A1E); 
  final Color secondaryColor = Color(0xFF103070); 
  final Color tertiaryColor = Color(0xFF2A364B); 
  final Color cardColor = Color(0xFF21252F);
  final Color textColor = Color(0xFFD9D9D9);
  final Color hintColor = Color(0xFF898989);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
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
                        ? Icon(Icons.person, size: 80, color: textColor.withOpacity(0.8)) 
                        : null,
                  ),
                  SizedBox(height: 24),
                  
                  Text(
                    nama,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  
                  Text(
                    noHp,
                    style: TextStyle(fontSize: 16, color: hintColor),
                  ),
                  SizedBox(height: 32),
                  
                  Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
      title: Text(
        label,
        style: TextStyle(fontSize: 14, color: hintColor),
      ),
      subtitle: Text(
        value,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}