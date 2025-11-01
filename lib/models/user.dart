// lib/models/user.dart

import 'package:hive/hive.dart';

part 'user.g.dart';

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

  @HiveField(4) // 🟢 BARU: Field Email
  String email;

  @HiveField(5) // 🟢 BARU: Field No HP
  String noHp;

  User({
    required this.username,
    required this.passwordHash,
    required this.createdAt,
    required this.lastLogin,
    required this.email, // 🟢 BARU
    required this.noHp, // 🟢 BARU
  });
}
