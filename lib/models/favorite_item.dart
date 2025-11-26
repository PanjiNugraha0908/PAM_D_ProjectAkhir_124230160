import 'package:hive/hive.dart';

part 'favorite_item.g.dart';

/// Model data untuk item favorit negara (terpisah dari history)
@HiveType(typeId: 2) // typeId berbeda dari User (0) dan HistoryItem (1)
class FavoriteItem extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String countryName;

  @HiveField(2)
  String flagUrl;

  @HiveField(3)
  String capital;

  @HiveField(4)
  String region;

  @HiveField(5)
  DateTime addedAt; // Kapan ditambahkan ke favorit

  FavoriteItem({
    required this.username,
    required this.countryName,
    required this.flagUrl,
    required this.capital,
    required this.region,
    required this.addedAt,
  });
}