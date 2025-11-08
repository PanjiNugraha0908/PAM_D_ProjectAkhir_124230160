import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import 'database_service.dart';

/// Kelas helper statis untuk menangani semua logika otentikasi.
class AuthService {
  /// Melakukan hash pada string [password] menggunakan algoritma SHA-256.
  static String hashPassword(String password) {
    var bytes = utf8.encode(password); // Ubah string ke bytes (UTF-8)
    var digest = sha256.convert(bytes); // Lakukan hash
    return digest.toString();
  }

  /// Mendaftarkan pengguna baru ke database lokal (Hive).
  static Future<Map<String, dynamic>> register(
    String username,
    String password, {
    // Parameter wajib untuk data profil awal
    required String email,
    required String noHp,
  }) async {
    // --- 1. Validasi Input ---
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
    if (DatabaseService.usernameExists(username)) {
      return {'success': false, 'message': 'Username sudah digunakan'};
    }

    // --- PERUBAHAN (Goal 1): Menambahkan cek email unik ---
    if (DatabaseService.emailExists(email)) {
      return {'success': false, 'message': 'Email sudah terdaftar'};
    }
    // --- AKHIR PERUBAHAN ---

    // --- 2. Buat Objek User Baru (untuk Otentikasi) ---

    // --- PERBAIKAN: createdAt dan lastLogin dikembalikan ---
    // Ini untuk memperbaiki error "parameter is required"
    User newUser = User(
      username: username,
      passwordHash: hashPassword(password),
      email: email,
      noHp: noHp,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    // --- AKHIR PERBAIKAN ---

    await DatabaseService.addUser(newUser);

    // --- 3. Buat Entri Profil Terpisah (untuk Data yang Dapat Diedit) ---
    final profileBox = Hive.box('profile');
    var newUserProfile = {
      'email': email,
      'noHp': noHp,
      'nama': '', // Dikosongkan, diisi nanti via Edit Profile
      'prodi': '', // Dikosongkan
      // --- PERUBAHAN (Goal 2): 'saranKesan' dihapus dari sini ---
      // 'saranKesan': '',
      'fotoPath': null, // Dikosongkan
    };
    await profileBox.put(username, newUserProfile);

    return {'success': true, 'message': 'Registrasi berhasil'};
  }

  /// Memvalidasi kredensial pengguna dan melakukan login.
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    // --- 1. Validasi Input ---
    if (username.isEmpty || password.isEmpty) {
      return {
        'success': false,
        'message': 'Username dan password tidak boleh kosong',
      };
    }

    // --- 2. Ambil dan Validasi User ---
    User? user = DatabaseService.getUser(username);
    if (user == null) {
      return {'success': false, 'message': 'Username tidak ditemukan'};
    }

    // --- 3. Validasi Password ---
    String hashedPassword = hashPassword(password);
    if (user.passwordHash != hashedPassword) {
      return {'success': false, 'message': 'Password salah'};
    }

    // --- 4. Proses Pasca-Login ---
    user.lastLogin = DateTime.now();
    await DatabaseService.updateUser(user);
    await DatabaseService.setCurrentUser(username);

    // [Fallback/Migrasi] Memastikan entri data profil ada.
    final profileBox = Hive.box('profile');
    if (profileBox.get(username) == null) {
      var userProfileData = {
        'email': user.email,
        'noHp': user.noHp,
        'nama': '',
        'prodi': '',
        // 'saranKesan': '', // Dihapus juga di fallback
        'fotoPath': null,
      };
      await profileBox.put(username, userProfileData);
    }

    return {'success': true, 'message': 'Login berhasil', 'username': username};
  }

  /// Melakukan logout pada pengguna yang sedang aktif.
  static Future<void> logout() async {
    await DatabaseService.clearCurrentUser();
  }

  /// Memeriksa apakah ada pengguna yang sedang login.
  static bool isLoggedIn() {
    return DatabaseService.getCurrentUsername() != null;
  }

  /// Mendapatkan [String] username dari pengguna yang sedang login.
  static String? getCurrentUsername() {
    return DatabaseService.getCurrentUsername();
  }
}
