// lib/services/auth_service.dart

import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart'; // 🟢 BARU: Import Hive
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  // Hash password menggunakan SHA256
  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register user baru
  static Future<Map<String, dynamic>> register(
    String username,
    String password, {
    // 泙 BARU: Tambahkan named parameter email dan noHp
    required String email,
    required String noHp,
  }) async {
    // Validasi
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

    // Check if username exists
    if (DatabaseService.usernameExists(username)) {
      return {'success': false, 'message': 'Username sudah digunakan'};
    }

    // Create new user
    User newUser = User(
      username: username,
      passwordHash: hashPassword(password),
      email: email, // 泙 BARU: Masukkan Email
      noHp: noHp, // 泙 BARU: Masukkan No HP
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
      // 🟢 CATATAN: Pastikan model User Anda (user.dart) memiliki field email dan noHp
      // Dan jalankan build_runner
    );

    await DatabaseService.addUser(newUser);

    // 🟢 PERBAIKAN DATA: Buat data profil KOSONG untuk user baru
    // Data ini akan diisi di EditProfilePage
    final profileBox = Hive.box('profile');
    var newUserProfile = {
      'email': email, // Ambil dari registrasi
      'noHp': noHp, // Ambil dari registrasi
      'nama': '', // Kosongkan
      'prodi': '', // Kosongkan
      'saranKesan': '', // Kosongkan
      'fotoPath': null, // Kosongkan
    };
    await profileBox.put(
      username,
      newUserProfile,
    ); // Simpan data di bawah key username

    return {'success': true, 'message': 'Registrasi berhasil'};
  }

  // Login user
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    // Validasi
    if (username.isEmpty || password.isEmpty) {
      return {
        'success': false,
        'message': 'Username dan password tidak boleh kosong',
      };
    }

    // Get user
    User? user = DatabaseService.getUser(username);

    if (user == null) {
      return {'success': false, 'message': 'Username tidak ditemukan'};
    }

    // Check password
    String hashedPassword = hashPassword(password);
    if (user.passwordHash != hashedPassword) {
      return {'success': false, 'message': 'Password salah'};
    }

    // Update last login
    user.lastLogin = DateTime.now();
    await DatabaseService.updateUser(user);

    // Set current user
    await DatabaseService.setCurrentUser(username);

    // 🟢 PERBAIKAN DATA: Saat login, cek apakah data profil sudah ada
    // Jika user lama (dibuat sebelum perbaikan ini), buatkan data profil baru
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

  // Logout
  static Future<void> logout() async {
    await DatabaseService.clearCurrentUser();
    // Tidak perlu clear profile box, karena data disimpan per user
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return DatabaseService.getCurrentUsername() != null;
  }

  // Get current username
  static String? getCurrentUsername() {
    return DatabaseService.getCurrentUsername();
  }
}
