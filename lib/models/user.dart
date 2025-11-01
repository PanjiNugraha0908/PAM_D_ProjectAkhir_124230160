import 'package:hive/hive.dart';

part 'user.g.dart';

// Model data untuk User, terhubung dengan Hive (Database Lokal)
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String passwordHash;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime lastLogin;

  // Field untuk data profil dasar
  @HiveField(4)
  String email;

  @HiveField(5)
  String noHp;

  User({
    required this.username,
    required this.passwordHash,
    required this.createdAt,
    required this.lastLogin,
    required this.email,
    required this.noHp,
  });
}