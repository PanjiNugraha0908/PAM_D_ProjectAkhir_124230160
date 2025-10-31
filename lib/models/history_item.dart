import 'package:hive/hive.dart';

part 'history_item.g.dart';

@HiveType(typeId: 1)
class HistoryItem extends HiveObject {
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
  DateTime viewedAt;

  HistoryItem({
    required this.username,
    required this.countryName,
    required this.flagUrl,
    required this.capital,
    required this.region,
    required this.viewedAt,
  });
}