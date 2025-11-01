import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart'; // Import untuk Hive
import '../models/user.dart';
import 'database_service.dart';

// Layanan untuk menangani semua logika Autentikasi (Register, Login, Hashing)
class AuthService {
  // Hash password menggunakan algoritma SHA256
  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Mendaftarkan user baru ke database lokal (Hive)
  static Future<Map<String, dynamic>> register(
    String username,
    String password, {
    // Parameter wajib untuk data profil awal
    required String email,
    required String noHp,
  }) async {
    // Validasi input dasar
    if (username.isEmpty || password.isEmpty || email.isEmpty || noHp.isEmpty) {
      return {
        'success': false,
        'message':
            'Semua field (Username, Email, No HP, Password) tidak boleh kosong',
      };
    }

    if (username.length < 3) {
      return {'success': false, 'message': 'Username minimal 3 karakter'};
    }

    if (password.length < 6) {
      return {'success': false, 'message': 'Password minimal 6 karakter'};
    }

    // Cek apakah username sudah terdaftar
    if (DatabaseService.usernameExists(username)) {
      return {'success': false, 'message': 'Username sudah digunakan'};
    }

    // Membuat objek User baru
    User newUser = User(
      username: username,
      passwordHash: hashPassword(password),
      email: email, // Menyimpan Email dari registrasi
      noHp: noHp, // Menyimpan No HP dari registrasi
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    await DatabaseService.addUser(newUser);

    // Membuat entri data profil awal (dipisahkan dari User Model untuk data yang dapat diedit)
    final profileBox = Hive.box('profile');
    var newUserProfile = {
      'email': email,
      'noHp': noHp,
      'nama': '', // Nama lengkap dikosongkan (diisi di Edit Profile)
      'prodi': '', // Prodi dikosongkan
      'saranKesan': '', // Saran Kesan dikosongkan
      'fotoPath': null, // Foto profil dikosongkan
    };
    // Menyimpan data profil di bawah key username
    await profileBox.put(username, newUserProfile);

    return {'success': true, 'message': 'Registrasi berhasil'};
  }

  // Login user
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    // Validasi input
    if (username.isEmpty || password.isEmpty) {
      return {
        'success': false,
        'message': 'Username dan password tidak boleh kosong',
      };
    }

    // Mengambil data user dari database
    User? user = DatabaseService.getUser(username);

    if (user == null) {
      return {'success': false, 'message': 'Username tidak ditemukan'};
    }

    // Membandingkan hash password
    String hashedPassword = hashPassword(password);
    if (user.passwordHash != hashedPassword) {
      return {'success': false, 'message': 'Password salah'};
    }

    // Memperbarui waktu login terakhir
    user.lastLogin = DateTime.now();
    await DatabaseService.updateUser(user);

    // Menetapkan user sebagai user yang sedang login
    await DatabaseService.setCurrentUser(username);

    // Memastikan entri data profil ada (untuk user lama yang baru di-migrate)
    final profileBox = Hive.box('profile');
    if (profileBox.get(username) == null) {
      var userProfileData = {
        'email': user.email,
        'noHp': user.noHp,
        'nama': '',
        'prodi': '',
        'saranKesan': '',
        'fotoPath': null,
      };
      await profileBox.put(username, userProfileData);
    }

    return {'success': true, 'message': 'Login berhasil', 'username': username};
  }

  // Logout: Menghapus status user yang sedang login
  static Future<void> logout() async {
    await DatabaseService.clearCurrentUser();
  }

  // Memeriksa status login
  static bool isLoggedIn() {
    return DatabaseService.getCurrentUsername() != null;
  }

  // Mendapatkan username dari user yang sedang login
  static String? getCurrentUsername() {
    return DatabaseService.getCurrentUsername();
  }
}
