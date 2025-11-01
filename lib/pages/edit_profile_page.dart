// lib/pages/edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../services/auth_service.dart'; // 🟢 BARU: Import AuthService

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late Box _profileBox;
  String? _username; // 🟢 BARU: Untuk menyimpan username

  // Palet Warna BARU (Datar dan Kontras)
  final Color backgroundColor = Color(
    0xFF1A202C,
  ); // Latar Belakang Utama Aplikasi (Biru Sangat Gelap)
  final Color surfaceColor = Color(
    0xFF2D3748,
  ); // Warna Permukaan (Card, Input Field, Bottom Navigation)
  final Color accentColor = Color(
    0xFF66B3FF,
  ); // Aksen Utama (Logo, Judul, Ikon Penting, Selected Item)
  final Color primaryButtonColor = Color(0xFF4299E1); // Warna Tombol Utama
  final Color textColor = Color(0xFFE2E8F0); // Warna Teks Standar
  final Color hintColor = Color(
    0xFFA0AEC0,
  ); // Warna Teks Petunjuk (Hint text, ikon minor)

  late TextEditingController _namaController;
  late TextEditingController _noHpController;
  late TextEditingController _prodiController;
  late TextEditingController _emailController;
  late TextEditingController _saranKesanController;

  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _profileBox = Hive.box('profile');

    // 🟢 PERBAIKAN DATA: Baca data dari key username
    _username = AuthService.getCurrentUsername();
    var userProfileData = _profileBox.get(_username) ?? <String, dynamic>{};

    _namaController = TextEditingController(
      text: userProfileData['nama'] ?? '',
    );
    _noHpController = TextEditingController(
      text: userProfileData['noHp'] ?? '',
    );
    _prodiController = TextEditingController(
      text: userProfileData['prodi'] ?? '',
    );
    _emailController = TextEditingController(
      text: userProfileData['email'] ?? '',
    );
    _saranKesanController = TextEditingController(
      text: userProfileData['saranKesan'] ?? '',
    );

    _imagePath = userProfileData['fotoPath'];
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(pickedFile.path);
      final String newPath = path.join(appDir.path, fileName);

      final File newImage = await File(pickedFile.path).copy(newPath);

      setState(() {
        _imagePath = newImage.path;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate() && _username != null) {
      // 🟢 PERBAIKAN DATA: Simpan data sebagai Map di bawah key username
      var userProfileData = _profileBox.get(_username) ?? <String, dynamic>{};

      userProfileData['nama'] = _namaController.text;
      userProfileData['noHp'] = _noHpController.text;
      userProfileData['prodi'] = _prodiController.text;
      userProfileData['email'] = _emailController.text;
      userProfileData['fotoPath'] = _imagePath;
      userProfileData['saranKesan'] = _saranKesanController.text;

      _profileBox.put(_username, userProfileData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil berhasil disimpan!'),
          backgroundColor: Colors
              .green, // Anda bisa ganti ini ke primaryButtonColor jika mau
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor, // Latar belakang datar
      appBar: AppBar(
        title: Text('Edit Profil', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor, // Latar belakang datar
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: accentColor), // Ikon warna aksen
            onPressed: _saveProfile,
            tooltip: 'Simpan',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity, // PERBAIKAN: Tambahkan height full
        color: backgroundColor, // Latar belakang datar
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: surfaceColor, // Warna permukaan
                          backgroundImage:
                              (_imagePath != null && _imagePath!.isNotEmpty)
                              ? FileImage(File(_imagePath!))
                              : null,
                          child: (_imagePath == null || _imagePath!.isEmpty)
                              ? Icon(
                                  Icons.person_add_alt_1,
                                  size: 80,
                                  color: textColor,
                                )
                              : null,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Ketuk gambar untuk mengubah',
                          style: TextStyle(color: hintColor),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // Judul Bagian Profil
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Data Diri',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryButtonColor,
                    ), // Warna tombol
                  ),
                ),
                Divider(
                  color: hintColor.withOpacity(0.5),
                  height: 24,
                ), // Divider warna hint

                _buildTextField(
                  controller: _namaController,
                  label: 'Nama Lengkap',
                  icon: Icons.person,
                  mustBeFilled: true,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _noHpController,
                  label: 'No. HP',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  mustBeFilled: true,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _prodiController,
                  label: 'Program Studi',
                  icon: Icons.school,
                  mustBeFilled: true,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  mustBeFilled: true,
                ),
                SizedBox(height: 32),

                // Judul Bagian Saran & Kesan
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Saran & Kesan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryButtonColor,
                    ), // Warna tombol
                  ),
                ),
                Divider(
                  color: hintColor.withOpacity(0.5),
                  height: 24,
                ), // Divider warna hint
                // 燥 BARU: Field Saran & Kesan
                _buildTextField(
                  controller: _saranKesanController,
                  label: 'Tulis saran atau kesan Anda...',
                  icon: Icons.comment,
                  maxLines: 5,
                  minLines: 3,
                  mustBeFilled: false,
                ),

                SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryButtonColor, // Warna tombol
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 100), // PERBAIKAN: Tambah ruang ekstra
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int? maxLines = 1,
    int? minLines = 1,
    bool mustBeFilled = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor),
      maxLines: maxLines,
      minLines: minLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: hintColor),
        hintText: hint,
        hintStyle: TextStyle(color: hintColor.withOpacity(0.5)),

        prefixIcon: Icon(icon, color: accentColor), // Ikon warna aksen

        filled: true,
        fillColor: surfaceColor.withOpacity(0.5), // Warna isian field

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: hintColor),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: primaryButtonColor,
            width: 2,
          ), // Fokus warna tombol
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
      validator: (value) {
        if (mustBeFilled && (value == null || value.isEmpty)) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _prodiController.dispose();
    _emailController.dispose();
    _saranKesanController.dispose(); // 燥 BARU: Dispose
    super.dispose();
  }
}
