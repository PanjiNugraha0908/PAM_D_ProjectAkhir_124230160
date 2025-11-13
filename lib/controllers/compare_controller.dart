// lib/controllers/compare_controller.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <-- Pastikan 'intl' ada di pubspec.yaml
import '../models/country.dart';
import '../pages/compare_page.dart';
import '../services/country_service.dart'; // Service baru kita
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

  @override
  void dispose() {
    for (var controller in searchControllers) {
      controller.dispose();
    }
    super.dispose();
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

      // TAMBAHAN BARU: Enrich dengan metrik
      final enrichedCountry =
          await EnhancedCountryService.enrichCountryData(country);

      setState(() {
        selectedCountries[index] = enrichedCountry; // Gunakan enriched data
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
