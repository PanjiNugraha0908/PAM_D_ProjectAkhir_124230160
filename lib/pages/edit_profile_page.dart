import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart'; // Import package
import 'package:path_provider/path_provider.dart'; // Import package
import 'package:path/path.dart' as path; // Import package
import 'dart:io'; // Import untuk File

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late Box _profileBox;

  // Palet Warna
  final Color primaryColor = Color(0xFF041C4A);
  final Color secondaryColor = Color(0xFF214894);
  final Color tertiaryColor = Color(0xFF394461);
  final Color cardColor = Color(0xFF21252F);
  final Color textColor = Color(0xFFD9D9D9);
  final Color hintColor = Color(0xFF898989);

  // Controllers untuk setiap field
  late TextEditingController _namaController;
  late TextEditingController _noHpController;
  late TextEditingController _prodiController;
  late TextEditingController _emailController;
  
  // State untuk menyimpan path gambar yang dipilih
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _profileBox = Hive.box('profile');
    
    // Isi controller dengan data yang sudah tersimpan di Hive (jika ada)
    _namaController = TextEditingController(text: _profileBox.get('nama', defaultValue: ''));
    _noHpController = TextEditingController(text: _profileBox.get('noHp', defaultValue: ''));
    _prodiController = TextEditingController(text: _profileBox.get('prodi', defaultValue: ''));
    _emailController = TextEditingController(text: _profileBox.get('email', defaultValue: ''));
    // Ambil path gambar, bukan URL
    _imagePath = _profileBox.get('fotoPath'); 
  }

  // --- Fungsi untuk memilih gambar ---
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    // Ambil gambar dari galeri
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Dapatkan direktori dokumen aplikasi
      final Directory appDir = await getApplicationDocumentsDirectory();
      // Buat nama file yang unik (atau gunakan nama aslinya)
      final String fileName = path.basename(pickedFile.path);
      final String newPath = path.join(appDir.path, fileName);

      // Salin file ke direktori aplikasi
      final File newImage = await File(pickedFile.path).copy(newPath);

      // Update state untuk menampilkan gambar baru
      setState(() {
        _imagePath = newImage.path;
      });
    }
  }

  // Fungsi untuk menyimpan data
  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _profileBox.put('nama', _namaController.text);
      _profileBox.put('noHp', _noHpController.text);
      _profileBox.put('prodi', _prodiController.text);
      _profileBox.put('email', _emailController.text);
      // Simpan path gambar ke Hive
      _profileBox.put('fotoPath', _imagePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Untuk gradient
      appBar: AppBar(
        title: Text('Edit Profil', style: TextStyle(color: textColor)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: textColor),
            onPressed: _saveProfile,
            tooltip: 'Simpan',
          ),
        ],
      ),
      body: Container(
        // Background Gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, secondaryColor, tertiaryColor],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(24.0),
            children: [
              // --- Image Picker ---
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: tertiaryColor,
                        backgroundImage: (_imagePath != null && _imagePath!.isNotEmpty)
                            ? FileImage(File(_imagePath!))
                            : null,
                        child: (_imagePath == null || _imagePath!.isEmpty)
                            ? Icon(Icons.person_add_alt_1, size: 80, color: hintColor)
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
              
              // --- Text Fields ---
              _buildTextField(
                controller: _namaController,
                label: 'Nama Lengkap',
                icon: Icons.person,
                mustBeFilled: true, // Nama wajib diisi
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _noHpController,
                label: 'No. HP',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                mustBeFilled: true, // No. HP wajib diisi
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _prodiController,
                label: 'Program Studi',
                icon: Icons.school,
                mustBeFilled: true, // Prodi wajib diisi
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                mustBeFilled: true, // Email wajib diisi
              ),
              
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  )
                ),
                child: Text('Simpan Perubahan', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk membuat TextField (dengan style gelap)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    bool mustBeFilled = false, // Parameter untuk validasi
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: hintColor),
        hintText: hint,
        hintStyle: TextStyle(color: hintColor.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: secondaryColor),
        filled: true,
        fillColor: tertiaryColor.withOpacity(0.3),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: tertiaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: secondaryColor, width: 2),
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
    super.dispose();
  }
}