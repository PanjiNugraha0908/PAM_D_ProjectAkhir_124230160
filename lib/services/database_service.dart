import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/history_item.dart';

/// Kelas helper statis yang membungkus semua operasi database [Hive].
///
/// Kelas ini mengelola semua Box Hive dan menyediakan method
/// untuk operasi CRUD (Create, Read, Update, Delete) pada data
/// [User], [HistoryItem], dan data profil.
class DatabaseService {
  // --- Nama-nama Box Hive ---
  static const String _userBoxName = 'users';
  static const String _historyBoxName = 'history';
  static const String _currentUserKey = 'current_user';
  static const String _profileBoxName = 'profile';

  /// Menginisialisasi Hive dan mendaftarkan semua [TypeAdapter].
  ///
  /// Fungsi ini harus dipanggil di `main.dart` sebelum aplikasi dijalankan
  /// untuk memastikan semua Box terbuka dan siap digunakan.
  static Future<void> init() async {
    await Hive.initFlutter();

    // Mendaftarkan adapter untuk model kustom
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(HistoryItemAdapter());

    // Membuka semua box yang diperlukan
    await Hive.openBox<User>(_userBoxName);
    await Hive.openBox<HistoryItem>(_historyBoxName);
    await Hive.openBox<String>(_currentUserKey);
    await Hive.openBox(_profileBoxName); // Box generik untuk data profil Map
  }

  // --- Getter Privat untuk Box ---
  static Box<User> get _userBox => Hive.box<User>(_userBoxName);
  static Box<HistoryItem> get _historyBox =>
      Hive.box<HistoryItem>(_historyBoxName);
  static Box<String> get _currentUserBox => Hive.box<String>(_currentUserKey);

  // --- Operasi User ---

  /// Mendapatkan objek [User] berdasarkan [username].
  ///
  /// Mengembalikan [User] jika ditemukan, atau `null` jika tidak.
  static User? getUser(String username) {
    // Menggunakan try-catch dengan firstWhere lebih aman dan bersih
    // daripada pola orElse yang kompleks.
    try {
      return _userBox.values.firstWhere((user) => user.username == username);
    } catch (e) {
      // firstWhere melempar error jika tidak ada elemen yang cocok
      return null;
    }
  }

  /// Menambahkan [User] baru ke database.
  static Future<void> addUser(User user) async {
    await _userBox.add(user);
  }

  /// Memperbarui data [User] yang ada di database.
  ///
  /// Perubahan harus dilakukan pada objek [User] sebelum memanggil ini.
  static Future<void> updateUser(User user) async {
    await user.save();
  }

  /// Memeriksa apakah [username] sudah terdaftar di database.
  static bool usernameExists(String username) {
    return _userBox.values.any((user) => user.username == username);
  }

  // --- Operasi Sesi (Current User) ---

  /// Mendapatkan [String] username dari pengguna yang sedang login.
  ///
  /// Mengembalikan `null` jika tidak ada pengguna yang login.
  static String? getCurrentUsername() {
    return _currentUserBox.get('username');
  }

  /// Menyimpan [username] sebagai pengguna yang sedang login.
  static Future<void> setCurrentUser(String username) async {
    await _currentUserBox.put('username', username);
  }

  /// Menghapus status pengguna yang sedang login (untuk Logout).
  static Future<void> clearCurrentUser() async {
    await _currentUserBox.delete('username');
  }

  // --- Operasi History ---

  /// Menambahkan satu [HistoryItem] ke database.
  static Future<void> addHistory(HistoryItem item) async {
    await _historyBox.add(item);
  }

  /// Mendapatkan [List<HistoryItem>] untuk [username] tertentu.
  ///
  /// Daftar yang dikembalikan diurutkan dari yang terbaru ke terlama.
  static List<HistoryItem> getHistoryForUser(String username) {
    return _historyBox.values
        .where((item) => item.username == username)
        .toList()
      // Mengurutkan dengan b (baru) dibanding a (lama)
      ..sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
  }

  /// Menghapus semua [HistoryItem] yang terkait dengan [username].
  static Future<void> clearHistoryForUser(String username) async {
    final itemsToDelete = _historyBox.values
        .where((item) => item.username == username)
        .toList();

    // Menghapus satu per satu
    for (var item in itemsToDelete) {
      await item.delete();
    }
  }

  // --- Utilitas (Debugging) ---

  /// Mendapatkan [List<User>] dari semua pengguna yang terdaftar.
  /// (Hanya untuk keperluan debugging).
  static List<User> getAllUsers() {
    return _userBox.values.toList();
  }
}
