import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/history_item.dart';

class DatabaseService {
  static const String _userBoxName = 'users';
  static const String _historyBoxName = 'history';
  static const String _currentUserKey = 'current_user';
  static const String _profileBoxName = 'profile';
  static const String _appStateBoxName = 'app_state';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(HistoryItemAdapter());

    await Hive.openBox<User>(_userBoxName);
    await Hive.openBox<HistoryItem>(_historyBoxName);
    await Hive.openBox<String>(_currentUserKey);
    await Hive.openBox(_profileBoxName);
    await Hive.openBox(_appStateBoxName);
  }

  static Box<User> get _userBox => Hive.box<User>(_userBoxName);
  static Box<HistoryItem> get _historyBox =>
      Hive.box<HistoryItem>(_historyBoxName);
  static Box<String> get _currentUserBox => Hive.box<String>(_currentUserKey);

  // --- PERBAIKAN: Update User dengan cara yang benar ---
  static Future<void> updateUser(User user) async {
    // Cari index user di box berdasarkan username
    final userBox = _userBox;
    int? userIndex;

    for (int i = 0; i < userBox.length; i++) {
      if (userBox.getAt(i)?.username == user.username) {
        userIndex = i;
        break;
      }
    }

    // Jika ditemukan, update di index tersebut
    if (userIndex != null) {
      await userBox.putAt(userIndex, user);
    } else {
      // Jika tidak ditemukan, tambahkan sebagai user baru
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
    final itemsToDelete = _historyBox.values
        .where((item) => item.username == username)
        .toList();

    for (var item in itemsToDelete) {
      await item.delete();
    }
  }

  static List<User> getAllUsers() {
    return _userBox.values.toList();
  }
}
