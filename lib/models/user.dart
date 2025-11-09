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

  @HiveField(4)
  String email;

  @HiveField(5)
  String noHp;

  @HiveField(6)
  String fullName;

  @HiveField(7)
  String? profilePicturePath;

  // TAMBAHAN BARU: Saran dan Kesan
  @HiveField(8)
  String saranKesan;

  User({
    required this.username,
    required this.passwordHash,
    required this.createdAt,
    required this.lastLogin,
    required this.email,
    required this.noHp,
    required this.fullName,
    this.profilePicturePath,
    this.saranKesan = '', // Default kosong
  });
}
