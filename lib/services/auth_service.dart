import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // REGISTER - Hanya username, email, password
  static Future<Map<String, dynamic>> register(
    String username,
    String password, {
    required String email,
  }) async {
    if (username.isEmpty || password.isEmpty || email.isEmpty) {
      return {
        'success': false,
        'message': 'Username, Email, dan Password harus diisi',
      };
    }

    if (username.length < 3) {
      return {'success': false, 'message': 'Username minimal 3 karakter'};
    }

    if (password.length < 6) {
      return {'success': false, 'message': 'Password minimal 6 karakter'};
    }

    if (DatabaseService.usernameExists(username)) {
      return {'success': false, 'message': 'Username sudah digunakan'};
    }

    if (DatabaseService.emailExists(email)) {
      return {'success': false, 'message': 'Email sudah terdaftar'};
    }

    // Buat user dengan fullName dan noHp kosong (diisi saat edit profil)
    User newUser = User(
      username: username,
      passwordHash: hashPassword(password),
      email: email,
      noHp: '', // Kosong, diisi saat edit profil
      fullName: '', // Kosong, diisi saat edit profil
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
      profilePicturePath: null,
      saranKesan: '',
    );

    await DatabaseService.addUser(newUser);

    return {'success': true, 'message': 'Registrasi berhasil'};
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    if (username.isEmpty || password.isEmpty) {
      return {
        'success': false,
        'message': 'Username dan password tidak boleh kosong',
      };
    }

    User? user = DatabaseService.getUser(username);
    if (user == null) {
      return {'success': false, 'message': 'Username tidak ditemukan'};
    }

    String hashedPassword = hashPassword(password);
    if (user.passwordHash != hashedPassword) {
      return {'success': false, 'message': 'Password salah'};
    }

    // Update user melalui DatabaseService (bukan user.save())
    User updatedUser = User(
      username: user.username,
      passwordHash: user.passwordHash,
      email: user.email,
      noHp: user.noHp,
      fullName: user.fullName,
      createdAt: user.createdAt,
      lastLogin: DateTime.now(), // Update lastLogin
      profilePicturePath: user.profilePicturePath,
      saranKesan: user.saranKesan,
    );

    await DatabaseService.updateUser(updatedUser);
    await DatabaseService.setCurrentUser(username);

    return {'success': true, 'message': 'Login berhasil', 'username': username};
  }

  static Future<void> logout() async {
    await DatabaseService.clearCurrentUser();
  }

  static bool isLoggedIn() {
    return DatabaseService.getCurrentUsername() != null;
  }

  static String? getCurrentUsername() {
    return DatabaseService.getCurrentUsername();
  }
}
