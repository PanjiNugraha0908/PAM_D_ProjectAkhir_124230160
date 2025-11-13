// lib/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'dart:convert'; // <-- PERBAIKAN TYPO DI SINI
import 'package:http/http.dart' as http;
import '../models/country.dart';
import '../models/history_item.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

// --- KEMBALIKAN MENJADI CLASS (BUKAN MIXIN) ---
class HomeController {
  final searchController = TextEditingController();

  // Ini HANYA akan berisi hasil pencarian API
  List<Country> filteredCountries = [];

  bool isLoading = false;
  String errorMessage = '';

  // State untuk Riwayat & Favorit
  List<HistoryItem> userHistory = [];
  Set<String> favoriteCountryNames = {};

  // Callback untuk update UI dan navigasi
  late Function(Country) onCountryTap;
  late Function() setStateCallback;

  // Variabel untuk menyimpan username
  late String _username;

  void onInit(Function() onStateChanged, Function(Country) onNavToDetail) {
    setStateCallback = onStateChanged;
    onCountryTap = onNavToDetail;
    // Kita tidak perlu listener karena search dipicu oleh onSubmitted
  }

  void onDispose() {
    searchController.dispose();
  }

  void setState(VoidCallback fn) {
    fn();
    setStateCallback();
  }

  // --- FUNGSI ASLI ANDA UNTUK MENYIMPAN USERNAME ---
  void initHistoryAndFavorites(String username) {
    _username = username; // Simpan username
    String? currentUsername = AuthService.getCurrentUsername();
    if (currentUsername == null) return;

    userHistory = DatabaseService.getHistoryForUser(currentUsername);
    favoriteCountryNames = userHistory
        .where((h) => h.isFavorite)
        .map((h) => h.countryName)
        .toSet();
  }

  void refreshHistoryAndFavorites() {
    initHistoryAndFavorites(_username);
    setState(() {}); // Update UI
  }

  // --- INI FUNGSI PENTING ANDA: MENCARI VIA API ---
  Future<void> searchCountries() async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      filteredCountries = []; // Kosongkan hasil sebelumnya
    });

    try {
      // Panggil API berdasarkan nama
      final data = await http.get(
        Uri.parse('https://restcountries.com/v3.1/name/$query'),
      );

      if (data.statusCode == 200) {
        final List<dynamic> jsonData =
            json.decode(data.body); // Error json diperbaiki
        setState(() {
          // 'filteredCountries' sekarang berisi hasil pencarian
          filteredCountries = jsonData.map((e) => Country.fromJson(e)).toList();
          isLoading = false;
        });
      } else if (data.statusCode == 404) {
        // Tidak ditemukan
        setState(() {
          filteredCountries = []; // Kosongkan list
          isLoading = false;
          // Kita akan tampilkan _buildEmptyState di UI
        });
      } else {
        // Error server
        setState(() {
          isLoading = false;
          errorMessage = 'Gagal terhubung ke server (Error ${data.statusCode})';
        });
      }
    } catch (e) {
      // Error koneksi/lainnya
      setState(() {
        isLoading = false;
        errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  void clearSearch() {
    searchController.clear();
    setState(() {
      // Kosongkan hasil pencarian agar list statis tampil lagi
      filteredCountries = [];
      errorMessage = '';
    });
  }
}
