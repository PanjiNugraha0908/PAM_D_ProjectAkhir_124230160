import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password tidak cocok!'),
          backgroundColor: Color(0xFF041C4A),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Color(0xFF214894),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Color(0xFF041C4A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF041C4A), // Warna utama
              Color(0xFF214894), // Warna sekunder
              Color(0xFF394461), // Warna tersier
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              color: Color(0xFF21252F), // Background card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon dengan background circle
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF214894).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.public,
                        size: 64,
                        color: Color(0xFFD9D9D9),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Daftar',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD9D9D9),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Buat akun baru untuk melanjutkan',
                      style: TextStyle(color: Color(0xFF898989), fontSize: 14),
                    ),
                    SizedBox(height: 32),

                    // Username Field
                    TextField(
                      controller: _usernameController,
                      style: TextStyle(color: Color(0xFFD9D9D9)),
                      decoration: InputDecoration(
                        labelText: 'Masukkan Username',
                        labelStyle: TextStyle(color: Color(0xFF898989)),
                        hintText: 'Username',
                        hintStyle: TextStyle(
                          color: Color(0xFF898989).withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Color(0xFF214894),
                        ),
                        filled: true,
                        fillColor: Color(0xFF394461).withOpacity(0.3),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF394461)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFF214894),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: Color(0xFFD9D9D9)),
                      decoration: InputDecoration(
                        labelText: 'Masukkan Password',
                        labelStyle: TextStyle(color: Color(0xFF898989)),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Color(0xFF898989).withOpacity(0.5),
                        ),
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF214894)),
                        filled: true,
                        fillColor: Color(0xFF394461).withOpacity(0.3),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF394461)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFF214894),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Confirm Password Field
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: TextStyle(color: Color(0xFFD9D9D9)),
                      decoration: InputDecoration(
                        labelText: 'Masukkan Kembali Password',
                        labelStyle: TextStyle(color: Color(0xFF898989)),
                        hintText: 'Konfirmasi Password',
                        hintStyle: TextStyle(
                          color: Color(0xFF898989).withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Color(0xFF214894),
                        ),
                        filled: true,
                        fillColor: Color(0xFF394461).withOpacity(0.3),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF394461)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFF214894),
                            width: 2,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _register(),
                    ),
                    SizedBox(height: 24),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Color(0xFF214894),
                          disabledBackgroundColor: Color(0xFF394461),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Color(0xFFD9D9D9),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFD9D9D9),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Link to Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: TextStyle(color: Color(0xFF898989)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Login di sini',
                            style: TextStyle(
                              color: Color(0xFF214894),
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
