// lib/controllers/compare_controller.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
import '../models/country.dart';
import '../models/history_item.dart'; // Import HistoryItem
import '../pages/compare_page.dart';
import '../services/country_service.dart';
import '../services/enhanced_country_service.dart';

/// Controller (Logic) untuk [ComparePage].
mixin CompareController on State<ComparePage> {
  final List<TextEditingController> searchControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  final List<Country?> selectedCountries = [null, null, null];
  final List<bool> isLoading = [false, false, false];
  final List<String?> errors = [null, null, null];

  // TAMBAHAN: Variabel untuk menyimpan riwayat
  List<HistoryItem> recentHistory = [];

  @override
  void initState() {
    super.initState();
    loadHistory(); // Load riwayat saat halaman dibuka
  }

  @override
  void dispose() {
    for (var controller in searchControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // TAMBAHAN: Fungsi mengambil riwayat dari Hive
  void loadHistory() {
    try {
      // Pastikan box 'history' sudah dibuka di main.dart, jika belum kita buka aman
      if (Hive.isBoxOpen('history')) {
        final box = Hive.box<HistoryItem>('history');
        // Ambil 10 item terakhir, balik urutannya (terbaru di awal)
        setState(() {
          recentHistory = box.values.toList().reversed.take(10).toList();
        });
      }
    } catch (e) {
      print("Error loading history: $e");
    }
  }

  // TAMBAHAN: Fungsi memilih dari riwayat
  void selectFromHistory(String countryName) {
    // Cari kolom input pertama yang masih kosong
    int targetIndex = -1;
    for (int i = 0; i < 3; i++) {
      if (searchControllers[i].text.isEmpty) {
        targetIndex = i;
        break;
      }
    }

    // Jika ada kolom kosong, isi dan cari
    if (targetIndex != -1) {
      searchControllers[targetIndex].text = countryName;
      searchCountry(targetIndex);
    } else {
      // Jika semua penuh, beritahu pengguna (opsional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Semua kolom perbandingan sudah terisi'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> searchCountry(int index) async {
    final String query = searchControllers[index].text.trim();
    if (query.isEmpty) {
      setState(() {
        selectedCountries[index] = null;
        errors[index] = null;
      });
      return;
    }

    setState(() {
      isLoading[index] = true;
      errors[index] = null;
      selectedCountries[index] = null;
    });

    try {
      final country = await CountryService.searchCountryByName(query);

      // Enrich dengan metrik
      final enrichedCountry =
          await EnhancedCountryService.enrichCountryData(country);

      setState(() {
        selectedCountries[index] = enrichedCountry;
        isLoading[index] = false;
      });
    } catch (e) {
      setState(() {
        errors[index] = 'Tidak ditemukan';
        isLoading[index] = false;
      });
    }
  }

  void clearSelection() {
    for (int i = 0; i < 3; i++) {
      searchControllers[i].clear();
      selectedCountries[i] = null;
      errors[i] = null;
      isLoading[i] = false;
    }
    setState(() {});
  }

  List<Country> get validCountries =>
      selectedCountries.whereType<Country>().toList();

  String formatNumber(num number) {
    if (number == 0) return 'N/A';
    return NumberFormat.decimalPattern('id_ID').format(number);
  }

  String getJoinedString(List<String> list) {
    if (list.isEmpty) return 'N/A';
    return list.join(', ');
  }
}
