import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'register_page.dart';

/// Halaman (Page) Stateful untuk otentikasi pengguna (Login).
///
/// Halaman ini menyediakan field untuk username dan password,
/// memvalidasinya melalui [AuthService], dan mengarahkan
/// pengguna ke [HomePage] jika berhasil.
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- Controller dan State ---
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // State untuk toggle visibilitas password

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
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Menangani proses login.
  ///
  /// Mengambil teks dari controller, memanggil [AuthService.login],
  /// dan menavigasi ke [HomePage] atau menampilkan [SnackBar] error.
  Future<void> _login() async {
    setState(() => _isLoading = true);

    final result = await AuthService.login(
      _usernameController.text,
      _passwordController.text,
    );

    // Pastikan widget masih mounted sebelum setState pasca-await
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success']) {
      // Navigasi ke HomePage dan hapus stack sebelumnya
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(username: result['username']),
        ),
      );
    } else {
      // Tampilkan SnackBar error
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
          // Menggunakan Card untuk Tampilan Form yang terangkat
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
                  Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 32),

                  // --- 2. Form Field: Username ---
                  Text(
                    'Masukkan Username',
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Username',
                      hintStyle: TextStyle(color: hintColor.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.person, color: accentColor),
                      filled: true,
                      fillColor: surfaceColor.withOpacity(0.5),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: hintColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: primaryButtonColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // --- 3. Form Field: Password ---
                  Text(
                    'Masukkan Password',
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: hintColor.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.lock, color: accentColor),
                      suffixIcon: IconButton(
                        // Toggle visibilitas password
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: hintColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: surfaceColor.withOpacity(0.5),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: hintColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: primaryButtonColor,
                          width: 2,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                  SizedBox(height: 16),

                  // --- 4. Link ke Halaman Register ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: TextStyle(color: hintColor),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Daftar di sini!',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // --- 5. Tombol Login ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
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
                              'Masuk',
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
}
