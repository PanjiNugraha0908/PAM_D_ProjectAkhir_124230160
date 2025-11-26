import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/history_item.dart';
import '../models/favorite_item.dart'; // TAMBAHAN BARU

class DatabaseService {
  static const String _userBoxName = 'users';
  static const String _historyBoxName = 'history';
  static const String _currentUserKey = 'current_user';
  static const String _profileBoxName = 'profile';
  static const String _appStateBoxName = 'app_state';
  static const String _favoriteBoxName = 'favorites'; // TAMBAHAN BARU

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(HistoryItemAdapter());
    Hive.registerAdapter(FavoriteItemAdapter()); // TAMBAHAN BARU

    await Hive.openBox<User>(_userBoxName);
    await Hive.openBox<HistoryItem>(_historyBoxName);
    await Hive.openBox<String>(_currentUserKey);
    await Hive.openBox(_profileBoxName);
    await Hive.openBox(_appStateBoxName);
    await Hive.openBox<FavoriteItem>(_favoriteBoxName); // TAMBAHAN BARU
  }

  static Box<User> get _userBox => Hive.box<User>(_userBoxName);
  static Box<HistoryItem> get _historyBox =>
      Hive.box<HistoryItem>(_historyBoxName);
  static Box<String> get _currentUserBox => Hive.box<String>(_currentUserKey);
  static Box<FavoriteItem> get _favoriteBox => // TAMBAHAN BARU
      Hive.box<FavoriteItem>(_favoriteBoxName);

  // ==================== USER METHODS ====================
  static Future<void> updateUser(User user) async {
    final userBox = _userBox;
    int? userIndex;

    for (int i = 0; i < userBox.length; i++) {
      if (userBox.getAt(i)?.username == user.username) {
        userIndex = i;
        break;
      }
    }

    if (userIndex != null) {
      await userBox.putAt(userIndex, user);
    } else {
      await userBox.add(user);
    }
  }

  static User? getUser(String username) {
    try {
      return _userBox.values.firstWhere((user) => user.username == username);
    } catch (e) {
      return null;
    }
  }

  static Future<void> addUser(User user) async {
    await _userBox.add(user);
  }

  static bool usernameExists(String username) {
    return _userBox.values.any((user) => user.username == username);
  }

  static bool emailExists(String email) {
    return _userBox.values.any(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
    );
  }

  static String? getCurrentUsername() {
    return _currentUserBox.get('username');
  }

  static Future<void> setCurrentUser(String username) async {
    await _currentUserBox.put('username', username);
  }

  static Future<void> clearCurrentUser() async {
    await _currentUserBox.delete('username');
  }

  static List<User> getAllUsers() {
    return _userBox.values.toList();
  }

  // ==================== HISTORY METHODS ====================
  static Future<void> addHistory(HistoryItem item) async {
    await _historyBox.add(item);
  }

  static List<HistoryItem> getHistoryForUser(String username) {
    return _historyBox.values
        .where((item) => item.username == username)
        .toList()
      ..sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
  }

  static Future<void> clearHistoryForUser(String username) async {
    final itemsToDelete =
        _historyBox.values.where((item) => item.username == username).toList();

    for (var item in itemsToDelete) {
      await item.delete();
    }
  }

  // ==================== FAVORITE METHODS (BARU) ====================

  /// Menambahkan negara ke favorit
  static Future<void> addFavorite(FavoriteItem item) async {
    await _favoriteBox.add(item);
  }

  /// Mendapatkan semua favorit untuk user tertentu
  static List<FavoriteItem> getFavoritesForUser(String username) {
    return _favoriteBox.values
        .where((item) => item.username == username)
        .toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  /// Mengecek apakah negara sudah difavoritkan
  static bool isFavorite(String username, String countryName) {
    return _favoriteBox.values.any(
      (item) => item.username == username && item.countryName == countryName,
    );
  }

  /// Menghapus negara dari favorit
  static Future<bool> removeFavorite(
      String username, String countryName) async {
    try {
      final favorite = _favoriteBox.values.firstWhere(
        (item) => item.username == username && item.countryName == countryName,
      );
      await favorite.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Toggle favorit (tambah jika belum ada, hapus jika sudah ada)
  static Future<bool> toggleFavorite({
    required String username,
    required String countryName,
    required String flagUrl,
    required String capital,
    required String region,
  }) async {
    final isAlreadyFavorite = isFavorite(username, countryName);

    if (isAlreadyFavorite) {
      // Hapus dari favorit
      await removeFavorite(username, countryName);
      return false; // Mengembalikan false = tidak favorit lagi
    } else {
      // Tambah ke favorit
      final favorite = FavoriteItem(
        username: username,
        countryName: countryName,
        flagUrl: flagUrl,
        capital: capital,
        region: region,
        addedAt: DateTime.now(),
      );
      await addFavorite(favorite);
      return true; // Mengembalikan true = sekarang favorit
    }
  }

  /// Menghapus semua favorit untuk user tertentu
  static Future<void> clearFavoritesForUser(String username) async {
    final itemsToDelete =
        _favoriteBox.values.where((item) => item.username == username).toList();

    for (var item in itemsToDelete) {
      await item.delete();
    }
  }
}
