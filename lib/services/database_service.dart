import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/history_item.dart';

/// Kelas helper statis yang membungkus semua operasi database [Hive].
class DatabaseService {
  // --- Nama-nama Box Hive ---
  static const String _userBoxName = 'users';
  static const String _historyBoxName = 'history';
  static const String _currentUserKey = 'current_user';
  static const String _profileBoxName = 'profile';

  // --- TAMBAHAN BARU ---
  // Box baru untuk menyimpan state aplikasi, seperti waktu terakhir aktif
  static const String _appStateBoxName = 'app_state';
  // --- AKHIR TAMBAHAN ---

  /// Menginisialisasi Hive dan mendaftarkan semua [TypeAdapter].
  static Future<void> init() async {
    await Hive.initFlutter();

    // Mendaftarkan adapter untuk model kustom
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(HistoryItemAdapter());

    // Membuka semua box yang diperlukan
    await Hive.openBox<User>(_userBoxName);
    await Hive.openBox<HistoryItem>(_historyBoxName);
    await Hive.openBox<String>(_currentUserKey);
    await Hive.openBox(_profileBoxName);

    // --- TAMBAHAN BARU ---
    // Membuka box baru untuk state aplikasi
    await Hive.openBox(_appStateBoxName);
    // --- AKHIR TAMBAHAN ---
  }

  // --- Getter Privat untuk Box ---
  static Box<User> get _userBox => Hive.box<User>(_userBoxName);
  static Box<HistoryItem> get _historyBox =>
      Hive.box<HistoryItem>(_historyBoxName);
  static Box<String> get _currentUserBox => Hive.box<String>(_currentUserKey);

  // --- Operasi User ---
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

  static Future<void> updateUser(User user) async {
    await user.save();
  }

  static bool usernameExists(String username) {
    return _userBox.values.any((user) => user.username == username);
  }

  static bool emailExists(String email) {
    return _userBox.values
        .any((user) => user.email.toLowerCase() == email.toLowerCase());
  }

  // --- Operasi Sesi (Current User) ---
  static String? getCurrentUsername() {
    return _currentUserBox.get('username');
  }

  static Future<void> setCurrentUser(String username) async {
    await _currentUserBox.put('username', username);
  }

  static Future<void> clearCurrentUser() async {
    await _currentUserBox.delete('username');
  }

  // --- Operasi History ---
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

  // --- Utilitas (Debugging) ---
  static List<User> getAllUsers() {
    return _userBox.values.toList();
  }
}