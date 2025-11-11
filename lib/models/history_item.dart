// lib/models/history_item.dart
import 'package:hive/hive.dart';

part 'history_item.g.dart';

/// Model data untuk item riwayat (History), diadaptasi untuk [Hive].
///
/// Kelas ini merepresentasikan satu entri riwayat pencarian negara
/// oleh seorang pengguna. [typeId: 1] digunakan oleh Hive untuk
/// mengidentifikasi model ini.
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

  // --- TAMBAHAN BARU ---
  @HiveField(6)
  bool isFavorite;

  HistoryItem({
    required this.username,
    required this.countryName,
    required this.flagUrl,
    required this.capital,
    required this.region,
    required this.viewedAt,
    this.isFavorite = false, // Default value
  });
}
