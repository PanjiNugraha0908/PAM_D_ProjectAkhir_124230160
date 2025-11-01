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

  // Palet Warna BARU (Datar dan Kontras)
  final Color backgroundColor = Color.fromARGB(100, 33, 37, 47);
  final Color surfaceColor = Color(0xFF21252F);
  final Color accentColor = Color.fromARGB(255, 38, 88, 188);
  final Color primaryButtonColor = Color.fromARGB(255, 38, 88, 188);
  final Color textColor = Color(0xFFD9D9D9);
  final Color hintColor = Color(0xFF898989);

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
                  // Field Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: hintColor.withOpacity(0.5)),
                      prefixIcon: Icon(
                        Icons.lock,
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
