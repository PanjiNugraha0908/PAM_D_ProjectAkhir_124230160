// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  // BARU: State untuk mengontrol visibilitas password
  bool _isPasswordVisible = false;

  // Palet Warna BARU (Sophisticated Dark Blue - Kontras Optimal)
  final Color backgroundColor = Color(
    0xFF1A202C,
  ); // Latar Belakang Utama Aplikasi (Biru Sangat Gelap)
  final Color surfaceColor = Color(
    0xFF2D3748,
  ); // Warna Permukaan (Card, Input Field, Bottom Navigation)
  final Color accentColor = Color(
    0xFF66B3FF,
  ); // Aksen Utama (Logo, Judul, Ikon Penting, Selected Item)
  final Color primaryButtonColor = Color(0xFF4299E1); // Warna Tombol Utama
  final Color textColor = Color(0xFFE2E8F0); // Warna Teks Standar
  final Color hintColor = Color(
    0xFFA0AEC0,
  ); // Warna Teks Petunjuk (Hint text, ikon minor)

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final result = await AuthService.login(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(username: result['username']),
        ),
      );
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
                  // Logo dan Judul Aplikasi
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
                    'Login',
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
                  TextField(
                    controller: _usernameController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Username',
                      hintStyle: TextStyle(color: hintColor.withOpacity(0.5)),
                      prefixIcon: Icon(
                        Icons.person,
                        color: accentColor,
                      ), // Ikon warna aksen
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
                        ), // Batas fokus warna tombol
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Label Password
                  Text(
                    'Masukkan Password',
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  // Field Password (dengan toggle)
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible, // Menggunakan state
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: hintColor.withOpacity(0.5)),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: accentColor,
                      ), // Ikon warna aksen
                      suffixIcon: IconButton(
                        // Tombol toggle
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
                        ), // Batas fokus warna tombol
                      ),
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                  SizedBox(height: 16),

                  // Link Daftar
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
                            color: accentColor, // Warna teks aksen
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Tombol Login
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor:
                            primaryButtonColor, // Warna tombol utama
                        disabledBackgroundColor: surfaceColor.withOpacity(0.5),
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
