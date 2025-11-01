import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../services/auth_service.dart';

/// Halaman (Page) Stateful untuk mengedit data profil pengguna.
///
/// Halaman ini mengambil data profil yang ada dari Hive berdasarkan
/// username yang sedang login (didapat dari [AuthService]),
/// menampilkannya dalam form, dan menyimpannya kembali ke Hive.
class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // --- Kunci dan State ---
  final _formKey = GlobalKey<FormState>();
  late Box _profileBox;
  String? _username; // Username pengguna yang sedang login
  String? _imagePath; // Path lokal ke gambar profil yang dipilih

  // --- Controller untuk Form ---
  late TextEditingController _namaController;
  late TextEditingController _noHpController;
  late TextEditingController _prodiController;
  late TextEditingController _emailController;
  late TextEditingController _saranKesanController;

  // --- Palet Warna Halaman ---
  // Catatan: Sebaiknya palet warna ini dipindahkan ke file theme/constants terpisah
  // agar konsisten dan mudah dikelola di seluruh aplikasi.
  final Color backgroundColor = Color(0xFF1A202C);
  final Color surfaceColor = Color(0xFF2D3748);
  final Color accentColor = Color(0xFF66B3FF);
  final Color primaryButtonColor = Color(0xFF4299E1);
  final Color textColor = Color(0xFFE2E8F0);
  final Color hintColor = Color(0xFFA0AEC0);

  @override
  void initState() {
    super.initState();
    _profileBox = Hive.box('profile');

    // 1. Dapatkan username yang sedang login
    _username = AuthService.getCurrentUsername();

    // 2. Ambil data profil spesifik untuk user tersebut dari Hive
    // Jika tidak ada, gunakan Map kosong sebagai default
    var userProfileData = _profileBox.get(_username) ?? <String, dynamic>{};

    // 3. Inisialisasi controller dengan data yang ada
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

  /// Membuka galeri gambar, menyalin gambar terpilih ke direktori aplikasi,
  /// dan memperbarui state [_imagePath].
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      // Dapatkan direktori dokumen aplikasi
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(pickedFile.path);
      final String newPath = path.join(appDir.path, fileName);

      // Salin file gambar ke path baru di dalam direktori aplikasi
      // Ini memastikan gambar tetap ada meskipun gambar asli di galeri dihapus
      final File newImage = await File(pickedFile.path).copy(newPath);

      setState(() {
        _imagePath = newImage.path;
      });
    }
  }

  /// Memvalidasi form dan menyimpan semua data profil ke Hive
  /// di bawah [key] username yang sedang login.
  void _saveProfile() {
    // Pastikan form valid dan kita memiliki username
    if (_formKey.currentState!.validate() && _username != null) {
      // Ambil data yang mungkin sudah ada, atau buat Map baru
      var userProfileData = _profileBox.get(_username) ?? <String, dynamic>{};

      // Update Map dengan data baru dari controllers
      userProfileData['nama'] = _namaController.text;
      userProfileData['noHp'] = _noHpController.text;
      userProfileData['prodi'] = _prodiController.text;
      userProfileData['email'] = _emailController.text;
      userProfileData['fotoPath'] = _imagePath;
      userProfileData['saranKesan'] = _saranKesanController.text;

      // Simpan kembali Map yang sudah diupdate ke Hive
      _profileBox.put(_username, userProfileData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke halaman sebelumnya (misal: halaman profil)
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Agar keyboard tidak menutupi UI
      backgroundColor: backgroundColor,
      // --- 1. AppBar ---
      appBar: AppBar(
        title: Text('Edit Profil', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: accentColor),
            onPressed: _saveProfile,
            tooltip: 'Simpan',
          ),
        ],
      ),
      // --- 2. Body ---
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: backgroundColor,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: [
                // --- 2A. Pemilih Gambar (Avatar) ---
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: surfaceColor,
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

                // --- 2B. Judul Bagian: Data Diri ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Data Diri',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryButtonColor,
                    ),
                  ),
                ),
                Divider(color: hintColor.withOpacity(0.5), height: 24),

                // --- 2C. Form Fields: Data Diri ---
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

                // --- 2D. Judul Bagian: Saran & Kesan ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Saran & Kesan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryButtonColor,
                    ),
                  ),
                ),
                Divider(color: hintColor.withOpacity(0.5), height: 24),

                // --- 2E. Form Field: Saran & Kesan ---
                _buildTextField(
                  controller: _saranKesanController,
                  label: 'Tulis saran atau kesan Anda...',
                  icon: Icons.comment,
                  maxLines: 5,
                  minLines: 3,
                  mustBeFilled: false, // Boleh kosong, jadi validasi dimatikan
                ),
                SizedBox(height: 32),

                // --- 2F. Tombol Simpan (Utama) ---
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryButtonColor,
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
                SizedBox(height: 100), // Ruang ekstra di bawah
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget helper (pabrik) untuk membuat [TextFormField] yang seragam
  /// dengan styling yang sudah ditentukan.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int? maxLines = 1,
    int? minLines = 1,
    bool mustBeFilled = false, // Menentukan apakah validator wajib diisi aktif
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
        prefixIcon: Icon(icon, color: accentColor),
        filled: true,
        fillColor: surfaceColor.withOpacity(0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: hintColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryButtonColor, width: 2),
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
        return null; // Valid
      },
    );
  }

  @override
  void dispose() {
    // Selalu dispose controller untuk mencegah kebocoran memori
    _namaController.dispose();
    _noHpController.dispose();
    _prodiController.dispose();
    _emailController.dispose();
    _saranKesanController.dispose();
    super.dispose();
  }
}
