import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Halaman (Page) Stateful untuk pendaftaran pengguna baru.
///
/// Menyediakan form untuk username, email, no. hp, dan password.
/// Data ini kemudian dikirim ke [AuthService] untuk diproses.
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // --- Controller dan State ---
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
  void dispose() {
    // Selalu dispose controller untuk mencegah kebocoran memori
    _usernameController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Menangani proses pendaftaran.
  ///
  /// Memvalidasi kesamaan password, memanggil [AuthService.register],
  /// dan kembali ke [LoginPage] jika berhasil atau menampilkan [SnackBar] error.
  Future<void> _register() async {
    // 1. Validasi kesamaan password
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

    // 2. Panggil AuthService dengan data lengkap
    final result = await AuthService.register(
      _usernameController.text,
      _passwordController.text,
      email: _emailController.text,
      noHp: _noHpController.text,
    );

    // Pastikan widget masih mounted sebelum setState pasca-await
    if (!mounted) return;

    setState(() => _isLoading = false);

    // 3. Tangani hasil pendaftaran
    if (result['success']) {
      // Sukses: Tampilkan notifikasi dan kembali ke halaman Login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      // Gagal: Tampilkan notifikasi error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            color: surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. Logo dan Judul Aplikasi ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/Logoprojek.png',
                        height: 40,
                        width: 40,
                        color: accentColor,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'ExploreUnity',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // --- 2. Judul Halaman ---
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

                  // --- 3. Form Pendaftaran ---
                  _buildTextField(
                    controller: _usernameController,
                    hintText: 'Username',
                    label: 'Masukkan Username',
                    icon: Icons.person,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    label: 'Masukkan Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _noHpController,
                    hintText: 'Nomor HP',
                    label: 'Masukkan Nomor HP',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    label: 'Masukkan Password',
                    icon: Icons.lock,
                    isObscure: !_isPasswordVisible,
                    toggleVisibility: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    isVisible: _isPasswordVisible,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Konfirmasi Password',
                    label: 'Konfirmasi Password',
                    icon: Icons.lock_reset,
                    isObscure: !_isConfirmPasswordVisible,
                    toggleVisibility: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    isVisible: _isConfirmPasswordVisible,
                    onSubmitted: (_) => _register(),
                  ),
                  SizedBox(height: 16),

                  // --- 4. Link ke Halaman Login ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: TextStyle(color: hintColor),
                      ),
                      TextButton(
                        onPressed: () {
                          // Kembali ke halaman Login
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Login di sini!',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // --- 5. Tombol Register ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: primaryButtonColor,
                        disabledBackgroundColor: surfaceColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              // Indikator loading
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

  /// [Helper Widget] Membangun [TextField] yang seragam untuk form.
  ///
  /// Termasuk label, ikon, tipe keyboard, dan logika
  /// untuk toggle visibilitas password.
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isObscure = false,
    void Function(String)? onSubmitted,
    void Function()? toggleVisibility, // Fungsi untuk toggle
    bool isVisible = false, // Status visibilitas saat ini
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
            prefixIcon: Icon(icon, color: accentColor),
            // Tampilkan ikon mata hanya jika 'toggleVisibility' disediakan
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
            fillColor: surfaceColor.withOpacity(0.5),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hintColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryButtonColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
