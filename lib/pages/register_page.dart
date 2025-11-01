import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// Halaman untuk Pendaftaran Pengguna Baru
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController =
      TextEditingController(); // Controller untuk input Email
  final _noHpController =
      TextEditingController(); // Controller untuk input No HP
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  // State untuk mengontrol visibilitas password
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Definisi Palet Warna
  final Color backgroundColor = Color(
    0xFF1A202C,
  ); // Latar Belakang Utama Aplikasi
  final Color surfaceColor = Color(
    0xFF2D3748,
  ); // Warna Permukaan (Card, Input Field)
  final Color accentColor = Color(
    0xFF66B3FF,
  ); // Aksen Utama (Logo, Judul, Ikon Penting)
  final Color primaryButtonColor = Color(0xFF4299E1); // Warna Tombol Utama
  final Color textColor = Color(0xFFE2E8F0); // Warna Teks Standar
  final Color hintColor = Color(0xFFA0AEC0); // Warna Teks Petunjuk

  // Fungsi asinkron untuk proses pendaftaran
  Future<void> _register() async {
    // Validasi kesamaan password
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password dan Konfirmasi Password tidak cocok'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Memanggil AuthService.register dengan data lengkap (termasuk email & noHp)
    final result = await AuthService.register(
      _usernameController.text,
      _passwordController.text,
      email: _emailController.text,
      noHp: _noHpController.text,
    );

    setState(() => _isLoading = false);

    // Menangani hasil pendaftaran
    if (result['success']) {
      // Menampilkan SnackBar sukses dan kembali ke Login Page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      // Kembali ke halaman Login
      Navigator.pop(context);
    } else {
      // Menampilkan pesan error jika pendaftaran gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor, // Menggunakan warna latar belakang datar
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            color: surfaceColor, // Warna background card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Logo dan Judul Aplikasi ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/Logoprojek.png',
                        height: 40,
                        width: 40,
                        color: accentColor, // Icon warna aksen
                      ),
                      SizedBox(width: 12),
                      Text(
                        'ExploreUnity',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: accentColor, // Judul warna aksen
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Judul Halaman
                  Text(
                    'Register',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Field Username
                  _buildTextField(
                    controller: _usernameController,
                    hintText: 'Username',
                    label: 'Masukkan Username',
                    icon: Icons.person,
                  ),
                  SizedBox(height: 16),

                  // Field Email
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    label: 'Masukkan Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),

                  // Field No HP
                  _buildTextField(
                    controller: _noHpController,
                    hintText: 'Nomor HP',
                    label: 'Masukkan Nomor HP',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16),

                  // Field Password
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    label: 'Masukkan Password',
                    icon: Icons.lock,
                    isObscure: !_isPasswordVisible, // Menggunakan state
                    toggleVisibility: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    isVisible: _isPasswordVisible,
                  ),
                  SizedBox(height: 16),

                  // Field Konfirmasi Password
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Konfirmasi Password',
                    label: 'Konfirmasi Password',
                    icon: Icons.lock_reset,
                    isObscure: !_isConfirmPasswordVisible, // Menggunakan state
                    toggleVisibility: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    isVisible: _isConfirmPasswordVisible,
                    onSubmitted: (_) => _register(),
                  ),
                  SizedBox(height: 16),

                  // Link Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: TextStyle(color: hintColor),
                      ),
                      TextButton(
                        onPressed: () {
                          // Cukup pop untuk kembali ke halaman Login
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Login di sini!',
                          style: TextStyle(
                            color: accentColor, // Warna teks aksen
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Tombol Register
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor:
                            primaryButtonColor, // Warna tombol utama
                        disabledBackgroundColor: surfaceColor.withOpacity(
                          0.5,
                        ), // Warna saat dinonaktifkan
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: textColor,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget untuk membuat TextField (dengan fitur toggle password)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isObscure = false,
    void Function(String)? onSubmitted,
    void Function()? toggleVisibility,
    bool isVisible = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textColor, fontSize: 14)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: keyboardType,
          style: TextStyle(color: textColor),
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: hintColor.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: accentColor), // Ikon warna aksen
            suffixIcon: toggleVisibility != null
                ? IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility : Icons.visibility_off,
                      color: hintColor,
                    ),
                    onPressed: toggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: surfaceColor.withOpacity(0.5), // Warna isian field
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hintColor), // Batas warna hint
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              // Batas fokus warna tombol
              borderSide: BorderSide(color: primaryButtonColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose(); // Dispose Controller Email
    _noHpController.dispose(); // Dispose Controller No HP
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
