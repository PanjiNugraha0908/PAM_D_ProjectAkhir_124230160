import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import 'database_service.dart';

/// Kelas helper statis untuk menangani semua logika otentikasi.
///
/// Tanggung jawab kelas ini meliputi:
/// - Mendaftarkan pengguna baru.
/// - Memvalidasi login pengguna.
/// - Mengelola sesi pengguna (login/logout).
/// - Menyediakan utilitas hashing password.
class AuthService {
  /// Melakukan hash pada string [password] menggunakan algoritma SHA-256.
  ///
  /// Mengembalikan [String] representasi heksadesimal dari hash.
  static String hashPassword(String password) {
    var bytes = utf8.encode(password); // Ubah string ke bytes (UTF-8)
    var digest = sha256.convert(bytes); // Lakukan hash
    return digest.toString();
  }

  /// Mendaftarkan pengguna baru ke database lokal (Hive).
  ///
  /// Selain membuat entri [User] untuk otentikasi, fungsi ini juga
  /// membuat entri profil kosong yang terpisah di box 'profile'
  /// yang di-key berdasarkan [username].
  ///
  /// Mengembalikan [Map<String, dynamic>] yang berisi:
  /// - `success` (bool): Status registrasi.
  /// - `message` (String): Pesan hasil (sukses atau error).
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

    // --- 2. Buat Objek User Baru (untuk Otentikasi) ---
    User newUser = User(
      username: username,
      passwordHash: hashPassword(password),
      email: email, // Menyimpan Email dari registrasi
      noHp: noHp, // Menyimpan No HP dari registrasi
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    await DatabaseService.addUser(newUser);

    // --- 3. Buat Entri Profil Terpisah (untuk Data yang Dapat Diedit) ---
    final profileBox = Hive.box('profile');
    var newUserProfile = {
      'email': email,
      'noHp': noHp,
      'nama': '', // Dikosongkan, diisi nanti via Edit Profile
      'prodi': '', // Dikosongkan
      'saranKesan': '', // Dikosongkan
      'fotoPath': null, // Dikosongkan
    };
    // Menyimpan data profil di bawah key username
    await profileBox.put(username, newUserProfile);

    return {'success': true, 'message': 'Registrasi berhasil'};
  }

  /// Memvalidasi kredensial pengguna dan melakukan login.
  ///
  /// Jika berhasil:
  /// 1. Memperbarui [lastLogin] pengguna.
  /// 2. Menetapkan pengguna sebagai 'current user' di [DatabaseService].
  /// 3. Memastikan entri profil untuk pengguna ini ada (untuk migrasi data lama).
  ///
  /// Mengembalikan [Map<String, dynamic>] yang berisi:
  /// - `success` (bool): Status login.
  /// - `message` (String): Pesan hasil (sukses atau error).
  /// - `username` (String, opsional): Username jika login berhasil.
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
    // Memperbarui waktu login terakhir
    user.lastLogin = DateTime.now();
    await DatabaseService.updateUser(user);

    // Menetapkan user sebagai user yang sedang login
    await DatabaseService.setCurrentUser(username);

    // [Fallback/Migrasi] Memastikan entri data profil ada.
    // Ini untuk menangani pengguna lama yang mungkin dibuat sebelum
    // sistem 'profileBox' terpisah diimplementasikan.
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

  /// Melakukan logout pada pengguna yang sedang aktif.
  ///
  /// Ini menghapus status 'current user' dari [DatabaseService].
  static Future<void> logout() async {
    await DatabaseService.clearCurrentUser();
  }

  /// Memeriksa apakah ada pengguna yang sedang login.
  ///
  /// Mengembalikan `true` jika ada 'current user', `false` jika tidak.
  static bool isLoggedIn() {
    return DatabaseService.getCurrentUsername() != null;
  }

  /// Mendapatkan [String] username dari pengguna yang sedang login.
  ///
  /// Mengembalikan `null` jika tidak ada pengguna yang login.
  static String? getCurrentUsername() {
    return DatabaseService.getCurrentUsername();
  }
}
