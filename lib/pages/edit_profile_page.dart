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

  late TextEditingController _namaController;
  late TextEditingController _noHpController;
  late TextEditingController _prodiController;
  late TextEditingController _emailController;

  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  // --- PERUBAHAN 1: Palet Warna (Disesuaikan dengan Dark Mode) ---
  final Color backgroundColor = Color(0xFF1A202C);
  final Color surfaceColor = Color(0xFF2D3748);
  final Color accentColor = Color(0xFF66B3FF);
  final Color primaryButtonColor = Color(0xFF4299E1);
  final Color textColor = Color(0xFFE2E8F0);
  final Color hintColor = Color(0xFFA0AEC0);
  // --- AKHIR PERUBAHAN 1 ---

  @override
  void initState() {
    super.initState();
    _profileBox = Hive.box('profile');
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
    _imagePath = userProfileData['fotoPath'];
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate() && _username != null) {
      var userProfileData = _profileBox.get(_username) ?? <String, dynamic>{};

      userProfileData['nama'] = _namaController.text;
      userProfileData['noHp'] = _noHpController.text;
      userProfileData['prodi'] = _prodiController.text;
      userProfileData['email'] = _emailController.text;
      userProfileData['fotoPath'] = _imagePath;

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
      backgroundColor: backgroundColor, // <-- PERUBAHAN WARNA
      appBar: AppBar(
        title: Text(
          'Edit Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ), // <-- PERUBAHAN WARNA
        ),
        backgroundColor: backgroundColor, // <-- PERUBAHAN WARNA
        elevation: 0,
        iconTheme: IconThemeData(color: textColor), // <-- PERUBAHAN WARNA
      ),
      body: Container(
        color: backgroundColor, // <-- PERUBAHAN WARNA (Gradient Dihapus)
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: surfaceColor, // <-- PERUBAHAN WARNA
                    backgroundImage: _imagePath != null
                        ? FileImage(File(_imagePath!))
                        : null,
                    child: _imagePath == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: hintColor,
                          ) // <-- PERUBAHAN WARNA
                        : null,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Ketuk untuk Ganti Foto',
                  style: TextStyle(color: hintColor), // <-- PERUBAHAN WARNA
                ),
                SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Data Diri',
                    style: TextStyle(
                      color: textColor, // <-- PERUBAHAN WARNA
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(
                  color: hintColor.withOpacity(0.3),
                  height: 24,
                ), // <-- PERUBAHAN WARNA
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
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryButtonColor, // <-- PERUBAHAN WARNA
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor, // <-- PERUBAHAN WARNA
                    ),
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- PERUBAHAN 2: Style _buildTextField disesuaikan Dark Mode ---
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
      style: TextStyle(color: textColor), // <-- WARNA TEKS INPUT
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: hintColor), // <-- WARNA LABEL
        prefixIcon: Icon(icon, color: hintColor), // <-- WARNA IKON
        filled: true,
        fillColor: surfaceColor, // <-- WARNA BACKGROUND FIELD
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: accentColor,
            width: 2,
          ), // <-- WARNA FOKUS
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: surfaceColor), // <-- WARNA NORMAL
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
  // --- AKHIR PERUBAHAN 2 ---

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _prodiController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
