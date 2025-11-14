import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import '../services/currency_service.dart';
import '../services/timezone_service.dart';
import '../pages/country_map_page.dart';
import '../pages/country_detail_page.dart';
import '../models/history_item.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/enhanced_country_service.dart';
import '../models/country.dart';
import '../services/weather_service.dart';

mixin CountryDetailController on State<CountryDetailPage> {
  String? selectedFromCurrency;
  String? selectedToCurrency;
  final amountController = TextEditingController(text: '1');
  double convertedAmount = 0.0;
  double exchangeRate = 0.0;
  bool isLoadingConversion = false;
  String conversionError = '';

  Timer? timer;
  String? selectedTimezone;
  String countryTime = '';
  String convertedTime = '';

  bool isFavorite = false;
  HistoryItem? historyEntry;

  bool isLoadingMetrics = false;
  Country? enrichedCountry;

  bool isLoadingWeather = false;
  Map<String, dynamic>? weatherData;
  String weatherError = '';

  void onInit() {
    if (widget.country.currencies.isNotEmpty) {
      selectedFromCurrency = widget.country.currencies.keys.first;
      selectedToCurrency = 'IDR';
    }
    selectedTimezone = 'WIB';
    updateTimes();
    timer = Timer.periodic(Duration(seconds: 1), (_) => updateTimes());
    _loadFavoriteStatus();
    loadEnhancedMetrics();
    loadWeatherData();
  }

  void onDispose() {
    timer?.cancel();
    amountController.dispose();
  }

  Future<void> loadWeatherData() async {
    if (mounted) {
      setState(() {
        isLoadingWeather = true;
        weatherError = '';
      });
    }

    try {
      final result =
          await WeatherService.getCurrentWeather(widget.country.capital);

      if (mounted) {
        setState(() {
          if (result['success']) {
            weatherData = result;
            weatherError = '';
          } else {
            weatherData = null;
            weatherError = result['error'] ?? 'Gagal memuat cuaca';
          }
          isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          weatherData = null;
          weatherError = 'Terjadi kesalahan';
          isLoadingWeather = false;
        });
      }
    }
  }

  Future<void> loadEnhancedMetrics() async {
    if (mounted) setState(() => isLoadingMetrics = true);
    try {
      final enhanced =
          await EnhancedCountryService.enrichCountryData(widget.country);
      if (mounted)
        setState(() {
          enrichedCountry = enhanced;
          isLoadingMetrics = false;
        });
    } catch (e) {
      if (mounted) setState(() => isLoadingMetrics = false);
    }
  }

  Future<void> _loadFavoriteStatus() async {
    String? username = AuthService.getCurrentUsername();
    if (username == null) return;

    final history = DatabaseService.getHistoryForUser(username);
    try {
      historyEntry =
          history.firstWhere((h) => h.countryName == widget.country.name);
      if (mounted) setState(() => isFavorite = historyEntry!.isFavorite);
    } catch (e) {
      historyEntry = null;
      if (mounted) setState(() => isFavorite = false);
    }
  }

  Future<void> toggleFavorite() async {
    if (historyEntry == null) {
      await _loadFavoriteStatus();
      if (historyEntry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan favorit, coba lagi.')),
        );
        return;
      }
    }

    if (mounted) setState(() => isFavorite = !isFavorite);
    historyEntry!.isFavorite = isFavorite;
    await historyEntry!.save();

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

  void updateTimes() {
    if (widget.country.timezones.isEmpty || !mounted) return;
    setState(() {
      countryTime =
          TimezoneService.getCurrentTimeForCountry(widget.country.timezones[0]);
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
      setState(() => conversionError = 'Pilih mata uang terlebih dahulu');
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
              'Koordinat lokasi untuk ${widget.country.name} tidak tersedia.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CountryMapPage(country: widget.country)),
    );
  }

  String formatCurrency(double amount, String? currencyCode) {
    final formatter = NumberFormat("#,##0.00", "id_ID");
    String symbol = getCurrencySymbol(currencyCode);
    String formattedAmount = formatter.format(amount);
    if (currencyCode == 'IDR') return '$symbol$formattedAmount';
    return '$symbol $formattedAmount';
  }

  String formatInputAmount(String amountStr, String? currencyCode) {
    final double amount = double.tryParse(amountStr) ?? 0.0;
    final formatter = NumberFormat("#,##0", "id_ID");
    String symbol = getCurrencySymbol(currencyCode);
    if (currencyCode == 'IDR') return '$symbol${formatter.format(amount)}';
    return '$symbol ${formatter.format(amount)}';
  }

  List<DropdownMenuItem<String>> buildTimezoneItems() {
    return TimezoneService.getAvailableTimezones().map((timezone) {
      return DropdownMenuItem<String>(
        value: timezone,
        child: Text(
          '${TimezoneService.getTimezoneName(timezone)}',
          style: TextStyle(color: Color(0xFFE2E8F0)),
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
    } catch (e) {}
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

  List<String> getAvailableCurrencies() => ['IDR', 'USD', 'EUR'];
}
