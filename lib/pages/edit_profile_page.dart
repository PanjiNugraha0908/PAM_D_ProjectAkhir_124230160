import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late Box _profileBox;

  // Controllers untuk setiap field
  late TextEditingController _namaController;
  late TextEditingController _noHpController;
  late TextEditingController _prodiController;
  late TextEditingController _emailController;
  late TextEditingController _fotoUrlController;

  @override
  void initState() {
    super.initState();
    _profileBox = Hive.box('profile');
    
    // Isi controller dengan data yang sudah tersimpan di Hive (jika ada)
    _namaController = TextEditingController(text: _profileBox.get('nama', defaultValue: ''));
    _noHpController = TextEditingController(text: _profileBox.get('noHp', defaultValue: ''));
    _prodiController = TextEditingController(text: _profileBox.get('prodi', defaultValue: ''));
    _emailController = TextEditingController(text: _profileBox.get('email', defaultValue: ''));
    _fotoUrlController = TextEditingController(text: _profileBox.get('fotoUrl', defaultValue: ''));
  }

  // Fungsi untuk menyimpan data
  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _profileBox.put('nama', _namaController.text);
      _profileBox.put('noHp', _noHpController.text);
      _profileBox.put('prodi', _prodiController.text);
      _profileBox.put('email', _emailController.text);
      _profileBox.put('fotoUrl', _fotoUrlController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Kembali ke halaman profil
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile,
            tooltip: 'Simpan',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _buildTextField(
              controller: _namaController,
              label: 'Nama Lengkap',
              icon: Icons.person,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _noHpController,
              label: 'No. HP',
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
            SizedBox(height: 16),
            _buildTextField(
              controller: _fotoUrlController,
              label: 'URL Foto Profil',
              hint: 'https://...',
              icon: Icons.image,
              keyboardType: TextInputType.url,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          // Khusus URL Foto boleh kosong
          if (label == 'URL Foto Profil') return null;
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    // Selalu dispose controller
    _namaController.dispose();
    _noHpController.dispose();
    _prodiController.dispose();
    _emailController.dispose();
    _fotoUrlController.dispose();
    super.dispose();
  }
}