import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/history_item.dart';

class DatabaseService {
  static const String _userBoxName = 'users';
  static const String _historyBoxName = 'history';
  static const String _currentUserKey = 'current_user';

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
  }

  // User Box
  static Box<User> get _userBox => Hive.box<User>(_userBoxName);

  // History Box
  static Box<HistoryItem> get _historyBox =>
      Hive.box<HistoryItem>(_historyBoxName);

  // Current User Box
  static Box<String> get _currentUserBox => Hive.box<String>(_currentUserKey);

  // Get user by username
  static User? getUser(String username) {
    return _userBox.values
            .firstWhere(
              (user) => user.username == username,
              orElse: () => User(
                username: '',
                passwordHash: '',
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
}
