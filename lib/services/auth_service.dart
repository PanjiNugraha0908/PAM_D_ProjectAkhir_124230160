// lib/services/auth_service.dart

import 'package:crypto/crypto.dart';
import 'dart:convert';
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
    // 🟢 BARU: Tambahkan named parameter email dan noHp
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
      email: email, // 🟢 BARU: Masukkan Email
      noHp: noHp, // 🟢 BARU: Masukkan No HP
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    await DatabaseService.addUser(newUser);

    // 🟢 BARU: Simpan data yang dapat diedit ke profile box
    await DatabaseService.updateProfileData(username, {
      'email': email,
      'noHp': noHp,
    });

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

    // 🟢 BARU: Sinkronkan data profil ke profile box saat login
    // Asumsi properti email dan noHp sudah ada di User model
    await DatabaseService.updateProfileData(username, {
      'email': user.email,
      'noHp': user.noHp,
    });

    return {'success': true, 'message': 'Login berhasil', 'username': username};
  }

  // Logout
  static Future<void> logout() async {
    await DatabaseService.clearCurrentUser();
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
