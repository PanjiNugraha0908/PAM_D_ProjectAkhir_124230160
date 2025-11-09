import 'package:flutter/material.dart';
import 'package:mobileprojek/pages/register_page.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Tambahkan state loading

  /// Menggunakan AuthService untuk login
  void _login() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _isLoading = true; // Mulai loading
      });

      String username = _usernameController.text;
      String password = _passwordController.text;

      // --- PERBAIKAN DI SINI ---
      // AuthService.login mengembalikan Map, bukan bool
      Map<String, dynamic> result = await AuthService.login(username, password);
      // --- AKHIR PERBAIKAN ---

      if (!mounted) return; // Cek jika widget masih ada

      setState(() {
        _isLoading = false; // Selesai loading
      });

      // --- PERBAIKAN DI SINI ---
      if (result['success']) {
        // --- AKHIR PERBAIKAN ---
        // Navigasi ke Halaman Utama
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(username: username)),
        );
      } else {
        // Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // --- PERBAIKAN DI SINI ---
            content: Text(result['message'] ?? 'Username atau password salah'),
            // --- AKHIR PERBAIKAN ---
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A202C),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/Logoprojek.png',
                  height: 100,
                  width: 100,
                  color: Color(0xFFE2E8F0),
                ),
                SizedBox(height: 16),
                Text(
                  'ExploreUnity',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
                Text(
                  'Masuk untuk melanjutkan',
                  style: TextStyle(fontSize: 16, color: Color(0xFFA0AEC0)),
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  style: TextStyle(color: Color(0xFFE2E8F0)),
                  decoration: _buildInputDecoration(
                    label: 'Username',
                    icon: Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: Color(0xFFE2E8F0)),
                  decoration: _buildInputDecoration(
                    label: 'Password',
                    icon: Icons.lock_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _login, // Nonaktifkan saat loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4299E1),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun?',
                      style: TextStyle(color: Color(0xFFA0AEC0)),
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
                      child: Text(
                        'Daftar di sini',
                        style: TextStyle(
                          color: Color(0xFF66B3FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color(0xFFA0AEC0)),
      prefixIcon: Icon(icon, color: Color(0xFFA0AEC0)),
      filled: true,
      fillColor: Color(0xFF2D3748),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF66B3FF)),
      ),
    );
  }
}
