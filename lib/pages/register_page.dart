import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// Hapus import User karena tidak lagi dibuat di sini
// import '../models/user.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // Ini akan jadi 'fullName'
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController(); // Field baru dari modelmu

  // Tambahkan state loading
  bool _isLoading = false;

  void _register() async {
    // <-- Tambahkan async
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _isLoading = true; // Mulai loading
      });

      // Ambil password mentah
      String rawPassword = _passwordController.text;

      try {
        // Panggil service dengan parameter yang benar
        final result = await AuthService.register(
          _usernameController.text,
          rawPassword,
          email: _emailController.text,
          noHp: _noHpController.text,
          fullName: _nameController.text, // Kirim sebagai named parameter
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false; // Selesai loading
        });

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registrasi berhasil! Silakan login.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          // Tampilkan pesan error dari service
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registrasi gagal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false; // Selesai loading jika ada error
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
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
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
                Text(
                  'Daftar untuk mulai menjelajah',
                  style: TextStyle(fontSize: 16, color: Color(0xFFA0AEC0)),
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _nameController, // 'fullName'
                  style: TextStyle(color: Color(0xFFE2E8F0)),
                  decoration: _buildInputDecoration(
                    label: 'Nama Lengkap',
                    icon: Icons.badge_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Color(0xFFE2E8F0)),
                  decoration: _buildInputDecoration(
                    label: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _noHpController, // Field baru
                  style: TextStyle(color: Color(0xFFE2E8F0)),
                  decoration: _buildInputDecoration(
                    label: 'Nomor HP',
                    icon: Icons.phone_outlined,
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor HP tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
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
                    if (value.length < 3) {
                      // <-- Ubah ke 3 agar konsisten
                      return 'Username minimal 3 karakter';
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
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
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
                        : _register, // Tambahkan cek loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4299E1),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Tambahkan indikator loading
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
                            'Daftar',
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
                      'Sudah punya akun?',
                      style: TextStyle(color: Color(0xFFA0AEC0)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Login di sini',
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
    );
  }
}
