import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late Box _profileBox;

  // Palet Warna (Sudah Gelap)
  final Color primaryColor = Color(0xFF010A1E); 
  final Color secondaryColor = Color(0xFF103070); 
  final Color tertiaryColor = Color(0xFF2A364B); 
  final Color cardColor = Color(0xFF21252F);
  final Color textColor = Color(0xFFD9D9D9);
  final Color hintColor = Color(0xFF898989);

  late TextEditingController _namaController;
  late TextEditingController _noHpController;
  late TextEditingController _prodiController;
  late TextEditingController _emailController;
  
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _profileBox = Hive.box('profile');
    
    _namaController = TextEditingController(text: _profileBox.get('nama', defaultValue: ''));
    _noHpController = TextEditingController(text: _profileBox.get('noHp', defaultValue: ''));
    _prodiController = TextEditingController(text: _profileBox.get('prodi', defaultValue: ''));
    _emailController = TextEditingController(text: _profileBox.get('email', defaultValue: ''));
    _imagePath = _profileBox.get('fotoPath'); 
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

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
    if (_formKey.currentState!.validate()) {
      _profileBox.put('nama', _namaController.text);
      _profileBox.put('noHp', _noHpController.text);
      _profileBox.put('prodi', _prodiController.text);
      _profileBox.put('email', _emailController.text);
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
    // Ambil tinggi keyboard (0 jika keyboard tidak muncul)
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
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
          // Menggunakan SingleChildScrollView untuk mencegah overflow
          child: SingleChildScrollView( 
            // Padding bawah dinamis
            padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0 + (bottomPadding > 0 ? bottomPadding : 0)),
            child: Column(
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
                
                // --- Text Fields ---
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
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: secondaryColor,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                    )
                  ),
                  child: Text('Simpan Perubahan', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                ),
                // Padding di sini dihilangkan/disesuaikan dengan padding di SingleChildScrollView
              ],
            ),
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
    bool mustBeFilled = false,
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
        
        prefixIcon: Icon(icon, color: hintColor), 
        
        filled: true,
        fillColor: tertiaryColor.withOpacity(0.3),
        
        // Garis pinggir kontras (abu-abu)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: hintColor), 
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