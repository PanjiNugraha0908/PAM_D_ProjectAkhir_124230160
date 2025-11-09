import 'package:hive/hive.dart';

part 'user.g.dart';

/// Model data untuk Pengguna (User), diadaptasi untuk [Hive].
///
/// Kelas ini merepresentasikan data otentikasi dan profil dasar
/// seorang pengguna. [typeId: 0] digunakan oleh Hive untuk
/// mengidentifikasi model ini.
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String passwordHash; // Password yang sudah di-hash (misal: SHA-256)

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime lastLogin;

  // Field untuk data profil dasar yang diambil saat registrasi
  @HiveField(4)
  String email;

  @HiveField(5)
  String noHp;

  // --- TAMBAHAN BARU ---
  @HiveField(6)
  String fullName;

  @HiveField(7)
  String? profilePicturePath;
  // --- AKHIR TAMBAHAN ---

  User({
    required this.username,
    required this.passwordHash,
    required this.createdAt,
    required this.lastLogin,
    required this.email,
    required this.noHp,
    // --- TAMBAHAN BARU ---
    required this.fullName,
    this.profilePicturePath,
    // --- AKHIR TAMBAHAN ---
  });
}
