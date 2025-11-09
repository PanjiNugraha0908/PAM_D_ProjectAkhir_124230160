import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

// --- IMPORT YANG SAYA LUPAKAN ---
import '../models/country.dart';
import '../services/currency_service.dart';
import '../services/timezone_service.dart';
import '../pages/country_map_page.dart';
import '../pages/country_detail_page.dart';
// --- AKHIR IMPORT ---

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

  // --- Lifecycle Methods ---
  void onInit() {
    if (widget.country.currencies.isNotEmpty) {
      selectedFromCurrency = widget.country.currencies.keys.first;
      selectedToCurrency = 'IDR';
    }
    selectedTimezone = 'WIB';
    updateTimes();
    timer = Timer.periodic(Duration(seconds: 1), (_) => updateTimes());
  }

  void onDispose() {
    timer?.cancel();
    amountController.dispose();
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