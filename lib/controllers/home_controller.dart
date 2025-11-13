// lib/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';
import '../models/history_item.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

// --- PERBAIKAN: Ubah 'class' menjadi 'mixin' ---
mixin HomeControllerMixin {
  // ---------------------------------------------
  final searchController = TextEditingController();
  List<Country> allCountries = []; // Ini akan KOSONG saat awal
  List<Country> filteredCountries = []; // Ini yang ditampilkan
  String? selectedRegion;
  bool isLoading = false;
  String errorMessage = '';

  // State untuk Riwayat & Favorit
  List<HistoryItem> userHistory = [];
  Set<String> favoriteCountryNames = {};

  // Callback untuk update UI dan navigasi
  late Function(Country) onCountryTap;
  late Function() setStateCallback;

  void onInit(Function() onStateChanged, Function(Country) onNavToDetail) {
    setStateCallback = onStateChanged;
    onCountryTap = onNavToDetail;
    searchController.addListener(_onSearchChanged);

    // Jangan fetch all. Cukup load data user.
    initHistoryAndFavorites();
  }

  void onDispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
  }

  void setState(VoidCallback fn) {
    fn();
    setStateCallback();
  }

  // --- FUNGSI BARU UNTUK LOAD DATA USER ---
  void initHistoryAndFavorites() {
    String? username = AuthService.getCurrentUsername();
    if (username == null) return;

    userHistory = DatabaseService.getHistoryForUser(username);
    favoriteCountryNames = userHistory
        .where((h) => h.isFavorite)
        .map((h) => h.countryName)
        .toSet();
  }

  void refreshHistoryAndFavorites() {
    setState(() {
      initHistoryAndFavorites();
    });
  }

  // --- FUNGSI BARU UNTUK SEARCH API ---
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
        final List<dynamic> jsonData = json.decode(data.body);
        setState(() {
          // 'allCountries' sekarang hanya berisi hasil search
          allCountries = jsonData.map((e) => Country.fromJson(e)).toList();
          // 'filteredCountries' juga berisi hasil search
          filteredCountries = List.from(allCountries);
          isLoading = false;
        });
      } else if (data.statusCode == 404) {
        // Tidak ditemukan
        setState(() {
          allCountries = [];
          filteredCountries = [];
          isLoading = false;
          // errorMessage tidak perlu di-set, _buildEmptyState akan tampil
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

  void _onSearchChanged() {
    // Jika user menghapus teks, kita bersihkan list
    if (searchController.text.isEmpty && !isLoading) {
      setState(() {
        filteredCountries = [];
        allCountries = [];
        errorMessage = '';
      });
    }
  }

  void clearSearch() {
    searchController.clear();
    setState(() {
      filteredCountries = [];
      allCountries = [];
      errorMessage = '';
    });
  }

  // --- FUNGSI LAMA YANG TIDAK BERFUNGSI LAGI ---
  void filterByRegion(String? region) {
    // Tidak bisa filter by region karena kita tidak punya data 'all'
    // Biarkan kosong
  }
}
