import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// import 'login_page.dart'; // DIHAPUS

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // Palet Warna BARU (Corporate Blue Dark Theme)
  final Color backgroundColor = Color.fromARGB(100, 33, 37, 47);
  final Color surfaceColor = Color(0xFF21252F);
  final Color accentColor = Color.fromARGB(255, 38, 88, 188);
  final Color primaryButtonColor = Color.fromARGB(255, 38, 88, 188);
  final Color textColor = Color(0xFFD9D9D9);
  final Color hintColor = Color(0xFF898989);

  Future<void> _register() async {
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

    final result = await AuthService.register(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      // Tampilkan SnackBar sukses dan kembali ke Login Page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
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
                        color: textColor, // Icon warna aksen
                      ),
                      SizedBox(width: 12),
                      Text(
                        'ExploreUnity',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
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

                  // Label Username
                  Text(
                    'Masukkan Username',
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  // Field Username
                  _buildTextField(
                    controller: _usernameController,
                    hintText: 'Username',
                    icon: Icons.person,
                  ),
                  SizedBox(height: 16),

                  // Label Password
                  Text(
                    'Masukkan Password',
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  // Field Password
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    icon: Icons.lock,
                    isObscure: true,
                  ),
                  SizedBox(height: 16),

                  // Label Konfirmasi Password
                  Text(
                    'Konfirmasi Password',
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  // Field Konfirmasi Password
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Konfirmasi Password',
                    icon: Icons.lock_reset,
                    isObscure: true,
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

  // Helper widget untuk membuat TextField (dengan style gelap)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isObscure = false,
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: TextStyle(color: textColor),
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: accentColor), // Ikon warna aksen
        filled: true,
        fillColor: surfaceColor.withOpacity(0.5), // Warna isian field
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: hintColor), // Batas warna hint
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: primaryButtonColor,
            width: 2,
          ), // Batas fokus warna tombol
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
