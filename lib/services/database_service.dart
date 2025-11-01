// lib/services/database_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/history_item.dart';

class DatabaseService {
  static const String _userBoxName = 'users';
  static const String _historyBoxName = 'history';
  static const String _currentUserKey = 'current_user';
  static const String _profileBoxName = 'profile';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(HistoryItemAdapter());

    // Open boxes
    await Hive.openBox<User>(_userBoxName);
    await Hive.openBox<HistoryItem>(_historyBoxName);
    await Hive.openBox<String>(_currentUserKey);
    await Hive.openBox(_profileBoxName);
  }

  // User Box
  static Box<User> get _userBox => Hive.box<User>(_userBoxName);

  // History Box
  static Box<HistoryItem> get _historyBox =>
      Hive.box<HistoryItem>(_historyBoxName);

  // Current User Box
  static Box<String> get _currentUserBox => Hive.box<String>(_currentUserKey);

  // Profile Box (BARU: Untuk menyimpan data yang dapat diedit di Profile Page)
  static Box get _profileBox => Hive.box(_profileBoxName);

  // Get user by username
  static User? getUser(String username) {
    // Catatan: Pastikan konstruktor User di orElse() juga sudah diupdate untuk email/noHp
    return _userBox.values
            .firstWhere(
              (user) => user.username == username,
              orElse: () => User(
                username: '',
                passwordHash: '',
                // Asumsi field baru (email/noHp) sudah ada di model User
                email: '',
                noHp: '',
                createdAt: DateTime.now(),
                lastLogin: DateTime.now(),
              ),
            )
            .username
            .isNotEmpty
        ? _userBox.values.firstWhere((user) => user.username == username)
        : null;
  }

  // Add new user
  static Future<void> addUser(User user) async {
    await _userBox.add(user);
  }

  // Update user
  static Future<void> updateUser(User user) async {
    await user.save();
  }

  // Check if username exists
  static bool usernameExists(String username) {
    return _userBox.values.any((user) => user.username == username);
  }

  // Get current logged in user
  static String? getCurrentUsername() {
    return _currentUserBox.get('username');
  }

  // Set current logged in user
  static Future<void> setCurrentUser(String username) async {
    await _currentUserBox.put('username', username);
  }

  // Clear current user (logout)
  static Future<void> clearCurrentUser() async {
    await _currentUserBox.delete('username');
  }

  // Add history item
  static Future<void> addHistory(HistoryItem item) async {
    await _historyBox.add(item);
  }

  // Get history for user
  static List<HistoryItem> getHistoryForUser(String username) {
    return _historyBox.values
        .where((item) => item.username == username)
        .toList()
      ..sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
  }

  // Clear history for user
  static Future<void> clearHistoryForUser(String username) async {
    final itemsToDelete = _historyBox.values
        .where((item) => item.username == username)
        .toList();

    for (var item in itemsToDelete) {
      await item.delete();
    }
  }

  // Get all users (for debugging)
  static List<User> getAllUsers() {
    return _userBox.values.toList();
  }

  // 🟢 BARU: Metode untuk menyimpan/mengupdate data profil yang dapat diedit
  static Future<void> updateProfileData(
    String username,
    Map<String, dynamic> data,
  ) async {
    // Menyimpan data profil (email, noHp, dll.) ke profile box.
    // Catatan: Karena box ini tidak menggunakan kunci username, data ini akan menimpa data user sebelumnya.
    // Ini mengasumsikan hanya ada satu user yang mengakses profil pada satu waktu.
    await _profileBox.putAll(data);
  }
}
