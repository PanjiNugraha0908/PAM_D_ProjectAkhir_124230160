import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/history_item.dart';

// Layanan yang membungkus operasi Hive Database
class DatabaseService {
  static const String _userBoxName = 'users';
  static const String _historyBoxName = 'history';
  static const String _currentUserKey = 'current_user';
  static const String _profileBoxName = 'profile';

  // Inisialisasi Hive dan mendaftarkan TypeAdapter
  static Future<void> init() async {
    await Hive.initFlutter();

    // Mendaftarkan adapter untuk model kustom
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(HistoryItemAdapter());

    // Membuka box yang diperlukan
    await Hive.openBox<User>(_userBoxName);
    await Hive.openBox<HistoryItem>(_historyBoxName);
    await Hive.openBox<String>(_currentUserKey);
    await Hive.openBox(
      _profileBoxName,
    ); // Box untuk data profil yang dapat diedit
  }

  // Getter untuk Box User
  static Box<User> get _userBox => Hive.box<User>(_userBoxName);

  // Getter untuk Box History
  static Box<HistoryItem> get _historyBox =>
      Hive.box<HistoryItem>(_historyBoxName);

  // Getter untuk Box Current User
  static Box<String> get _currentUserBox => Hive.box<String>(_currentUserKey);

  // Mendapatkan objek User berdasarkan username
  static User? getUser(String username) {
    // Mencari user berdasarkan username
    return _userBox.values
            .firstWhere(
              (user) => user.username == username,
              // Menggunakan orElse untuk mencegah error jika user tidak ditemukan
              orElse: () => User(
                username: '',
                passwordHash: '',
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

  // Menambahkan user baru
  static Future<void> addUser(User user) async {
    await _userBox.add(user);
  }

  // Memperbarui data user
  static Future<void> updateUser(User user) async {
    await user.save();
  }

  // Memeriksa apakah username sudah ada
  static bool usernameExists(String username) {
    return _userBox.values.any((user) => user.username == username);
  }

  // Mendapatkan username dari user yang sedang login
  static String? getCurrentUsername() {
    return _currentUserBox.get('username');
  }

  // Menyimpan status user yang sedang login
  static Future<void> setCurrentUser(String username) async {
    await _currentUserBox.put('username', username);
  }

  // Menghapus status user yang sedang login (Logout)
  static Future<void> clearCurrentUser() async {
    await _currentUserBox.delete('username');
  }

  // Menambahkan item ke riwayat pencarian
  static Future<void> addHistory(HistoryItem item) async {
    await _historyBox.add(item);
  }

  // Mendapatkan riwayat pencarian untuk user tertentu, diurutkan berdasarkan waktu
  static List<HistoryItem> getHistoryForUser(String username) {
    return _historyBox.values
        .where((item) => item.username == username)
        .toList()
      ..sort(
        (a, b) => b.viewedAt.compareTo(a.viewedAt),
      ); // Urutan Terbaru ke Terlama
  }

  // Menghapus semua riwayat untuk user tertentu
  static Future<void> clearHistoryForUser(String username) async {
    final itemsToDelete = _historyBox.values
        .where((item) => item.username == username)
        .toList();

    for (var item in itemsToDelete) {
      await item.delete();
    }
  }

  // Mendapatkan semua user (untuk debugging)
  static List<User> getAllUsers() {
    return _userBox.values.toList();
  }
}
