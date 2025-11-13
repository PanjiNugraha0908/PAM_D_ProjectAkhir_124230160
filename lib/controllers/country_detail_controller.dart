// lib/controllers/country_detail_controller.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

// --- INI ADALAH IMPORT YANG HILANG ---
import '../services/currency_service.dart';
import '../services/timezone_service.dart';
import '../pages/country_map_page.dart';
import '../pages/country_detail_page.dart';
// --- AKHIR IMPORT ---

// --- TAMBAHAN IMPORT UNTUK FITUR FAVORIT ---
import '../models/history_item.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
// --- AKHIR TAMBAHAN ---

// TAMBAHKAN di bagian import:
import '../services/enhanced_country_service.dart'; // <--- TAMBAHAN
import '../models/country.dart'; // Pastikan model Country sudah diimpor jika diperlukan

/// Controller (Logic) untuk [CountryDetailPage].
mixin CountryDetailController on State<CountryDetailPage> {
  // --- State Konverter Mata Uang ---
  String? selectedFromCurrency;
  String? selectedToCurrency;
  final amountController = TextEditingController(text: '1');
  double convertedAmount = 0.0;
  double exchangeRate = 0.0;
  bool isLoadingConversion = false;
  String conversionError = '';

  // --- State Zona Waktu Real-time ---
  Timer? timer;
  String? selectedTimezone;
  String countryTime = '';
  String convertedTime = '';

  // --- TAMBAHAN STATE FAVORIT ---
  bool isFavorite = false;
  HistoryItem? historyEntry; // Untuk menyimpan referensi ke item di database
  // --- AKHIR TAMBAHAN ---

  // TAMBAHKAN state baru di dalam mixin:
  bool isLoadingMetrics = false; // <--- TAMBAHAN
  Country? enrichedCountry; // <--- TAMBAHAN

  // --- Lifecycle Methods ---
  void onInit() {
    if (widget.country.currencies.isNotEmpty) {
      selectedFromCurrency = widget.country.currencies.keys.first;
      selectedToCurrency = 'IDR';
    }
    selectedTimezone = 'WIB';
    updateTimes();
    timer = Timer.periodic(Duration(seconds: 1), (_) => updateTimes());
    _loadFavoriteStatus();
    loadEnhancedMetrics(); // <--- TAMBAHKAN INI
  }

  void onDispose() {
    timer?.cancel();
    amountController.dispose();
  }

  // TAMBAHKAN fungsi baru di dalam mixin:
  Future<void> loadEnhancedMetrics() async {
    // <--- TAMBAHAN FUNGSI
    if (mounted) {
      setState(() {
        isLoadingMetrics = true;
      });
    }
    try {
      final enhanced = await EnhancedCountryService.enrichCountryData(
        widget.country,
      );

      if (mounted) {
        setState(() {
          enrichedCountry = enhanced;
          isLoadingMetrics = false;
        });
      }
    } catch (e) {
      print('Error loading enhanced metrics: $e');
      if (mounted) {
        setState(() {
          isLoadingMetrics = false;
        });
      }
    }
  }

  // --- FUNGSI BARU UNTUK FAVORIT ---
  Future<void> _loadFavoriteStatus() async {
    String? username = AuthService.getCurrentUsername();
    if (username == null) return;

    // Saat halaman detail dibuka, home_controller SUDAH menambahkan
    // item history. Kita hanya perlu menemukannya.
    final history = DatabaseService.getHistoryForUser(username);
    try {
      historyEntry = history.firstWhere(
        (h) => h.countryName == widget.country.name,
      );
      if (mounted) {
        setState(() {
          isFavorite = historyEntry!.isFavorite;
        });
      }
    } catch (e) {
      // Seharusnya tidak terjadi, tapi sebagai pengaman
      print('Error: History item tidak ditemukan untuk ${widget.country.name}');
      historyEntry = null;
      if (mounted) setState(() => isFavorite = false);
    }
  }

  // --- FUNGSI BARU UNTUK FAVORIT ---
  Future<void> toggleFavorite() async {
    if (historyEntry == null) {
      // Jika history-nya tidak ada (kasus aneh), panggil _loadFavoriteStatus lagi
      await _loadFavoriteStatus();
      if (historyEntry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan favorit, coba lagi.')),
        );
        return;
      }
    }

    if (mounted) {
      setState(() {
        isFavorite = !isFavorite;
      });
    }

    // Update nilai di database
    historyEntry!.isFavorite = isFavorite;
    await historyEntry!.save(); // HiveObject bisa langsung di-save

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? '${widget.country.name} ditambahkan ke favorit'
              : '${widget.country.name} dihapus dari favorit',
        ),
        backgroundColor: Color(0xFF4299E1),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // --- Logika Halaman ---
  void updateTimes() {
    if (widget.country.timezones.isEmpty) return;
    if (!mounted) return;

    setState(() {
      countryTime = TimezoneService.getCurrentTimeForCountry(
        widget.country.timezones[0],
      );
      if (selectedTimezone != null) {
        convertedTime = TimezoneService.getTimeForSelectedTimezone(
          widget.country.timezones[0],
          selectedTimezone!,
        );
      }
    });
  }

  Future<void> convertCurrency() async {
    if (selectedFromCurrency == null || selectedToCurrency == null) {
      setState(() {
        conversionError = 'Pilih mata uang terlebih dahulu';
      });
      return;
    }
    setState(() {
      isLoadingConversion = true;
      conversionError = '';
      convertedAmount = 0.0;
    });

    Map<String, dynamic> result = await CurrencyService.convertCurrency(
      selectedFromCurrency!,
      selectedToCurrency!,
      double.tryParse(amountController.text) ?? 1.0,
    );

    if (!mounted) return;

    setState(() {
      isLoadingConversion = false;
      if (result['success']) {
        convertedAmount = result['result'];
        exchangeRate = result['rate'];
      } else {
        conversionError = result['error'] ?? 'Gagal konversi';
      }
    });
  }

  void openCountryMap() {
    if (widget.country.latitude == 0.0 && widget.country.longitude == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Koordinat lokasi untuk ${widget.country.name} tidak tersedia.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CountryMapPage(country: widget.country),
      ),
    );
  }

  // --- Helper Getters (Formatter) ---
  // ... (Sisa fungsi helper tidak berubah) ...
  String formatCurrency(double amount, String? currencyCode) {
    final formatter = NumberFormat("#,##0.00", "id_ID");
    String symbol = getCurrencySymbol(currencyCode);
    String formattedAmount = formatter.format(amount);

    if (currencyCode == 'IDR') {
      return '$symbol$formattedAmount';
    }
    return '$symbol $formattedAmount';
  }

  String formatInputAmount(String amountStr, String? currencyCode) {
    final double amount = double.tryParse(amountStr) ?? 0.0;
    final formatter = NumberFormat("#,##0", "id_ID");
    String symbol = getCurrencySymbol(currencyCode);

    if (currencyCode == 'IDR') {
      return '$symbol${formatter.format(amount)}';
    }
    return '$symbol ${formatter.format(amount)}';
  }

  List<DropdownMenuItem<String>> buildTimezoneItems() {
    return TimezoneService.getAvailableTimezones().map((timezone) {
      return DropdownMenuItem<String>(
        value: timezone,
        child: Text(
          '${TimezoneService.getTimezoneName(timezone)}',
          style: TextStyle(color: Color(0xFFE2E8F0)), // textColor
        ),
      );
    }).toList();
  }

  String getCurrencySymbol(String? code) {
    if (code == null) return '';
    try {
      if (widget.country.currencies.containsKey(code)) {
        final v = widget.country.currencies[code];
        if (v is Map &&
            v['symbol'] != null &&
            v['symbol'].toString().isNotEmpty) {
          return v['symbol'].toString();
        }
      }
    } catch (e) {
      // Abaikan
    }
    const fallbacks = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'IDR': 'Rp',
      'AUD': 'A\$',
      'CAD': 'C\$',
      'SGD': 'S\$',
      'MYR': 'RM',
      'THB': '฿',
      'CNY': '¥',
      'KRW': '₩',
      'INR': '₹',
    };
    return fallbacks[code] ?? code;
  }

  String getCurrencyString() {
    if (widget.country.currencies.isEmpty) return 'N/A';
    return widget.country.currencies.entries
        .map((e) => '${e.value['name']} (${e.value['symbol'] ?? ''})')
        .join(', ');
  }

  List<String> getAvailableCurrencies() {
    return ['IDR', 'USD', 'EUR'];
  }
}
