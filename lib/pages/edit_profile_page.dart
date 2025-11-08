import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late Box _profileBox;
  String? _username;

  // Controller untuk Form
  late TextEditingController _namaController;
  late TextEditingController _noHpController;
  late TextEditingController _prodiController;
  late TextEditingController _emailController;
  // --- PERUBAHAN 4 (Goal 2) ---
  // Controller saranKesan dihapus
  // late TextEditingController _saranKesanController;
  // --- AKHIR PERUBAHAN 4 ---

  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  // Palet Warna (konsisten dengan ProfilePage)
  final Color primaryColor = const Color(0xFF1A237E); // Biru Gelap
  final Color accentColor = const Color(0xFFFFAB00); // Kuning/Emas
  final Color hintColor = Colors.grey[600]!;

  @override
  void initState() {
    super.initState();
    _profileBox = Hive.box('profile');
    _username = AuthService.getCurrentUsername();
    var userProfileData = _profileBox.get(_username) ?? <String, dynamic>{};

    // Inisialisasi controller
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

    // --- PERUBAHAN 5 (Goal 2) ---
    // Inisialisasi saranKesan dihapus
    // _saranKesanController = TextEditingController(
    //   text: userProfileData['saranKesan'] ?? '',
    // );
    // --- AKHIR PERUBAHAN 5 ---

    _imagePath = userProfileData['fotoPath'];
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate() && _username != null) {
      var userProfileData = _profileBox.get(_username) ?? <String, dynamic>{};

      // Update Map dengan data baru
      userProfileData['nama'] = _namaController.text;
      userProfileData['noHp'] = _noHpController.text;
      userProfileData['prodi'] = _prodiController.text;
      userProfileData['email'] = _emailController.text;
      userProfileData['fotoPath'] = _imagePath;

      // --- PERUBAHAN 6 (Goal 2) ---
      // Penyimpanan saranKesan dihapus
      // userProfileData['saranKesan'] = _saranKesanController.text;
      // --- AKHIR PERUBAHAN 6 ---

      _profileBox.put(_username, userProfileData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: Colors.green[700],
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profil',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, Color(0xFF303F9F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: [
                // --- 1. Pemilih Gambar (Avatar) ---
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: _imagePath != null
                        ? FileImage(File(_imagePath!))
                        : null,
                    child: _imagePath == null
                        ? Icon(Icons.camera_alt,
                            size: 50, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Ketuk untuk Ganti Foto',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 32),

                // --- 2. Form Fields ---
                // A. Data Diri
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Data Diri',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(color: hintColor.withOpacity(0.5), height: 24),

                // Fields: Nama, No HP, Prodi, Email
                _buildTextField(
                  controller: _namaController,
                  label: 'Nama Lengkap',
                  icon: Icons.person,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _noHpController,
                  label: 'Nomor HP',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _prodiController,
                  label: 'Program Studi',
                  icon: Icons.school,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 32),

                // --- PERUBAHAN 7 (Goal 2) ---
                // Bagian Saran & Kesan dihapus seluruhnya dari halaman edit
                // --- AKHIR PERUBAHAN 7 ---

                // --- 2F. Tombol Simpan (Utama) ---
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: EdgeInsets.symmetric(
                        horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 100), // Padding bawah
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget untuk membangun text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int minLines = 1,
    bool mustBeFilled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
      ),
      validator: (value) {
        if (mustBeFilled && (value == null || value.isEmpty)) {
          return '$label tidak boleh kosong';
        }
        if (label == 'Email' &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
          return 'Email tidak valid';
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
    // --- PERUBAHAN 8 (Goal 2) ---
    // _saranKesanController.dispose(); // Dihapus
    // --- AKHIR PERUBAHAN 8 ---
    super.dispose();
  }
}