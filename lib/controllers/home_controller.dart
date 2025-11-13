import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/country.dart';
import '../models/history_item.dart';
import '../pages/country_detail_page.dart';
import '../pages/compare_page.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart';
import '../pages/history_page.dart';
import '../pages/location_page.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';
import '../services/notification_service.dart';
import '../pages/home_page.dart';

mixin HomeController on State<HomePage> {
  final searchController = TextEditingController();
  List<Country> allCountries = [];
  List<Country> filteredCountries = [];
  bool isLoading = false;

  void onInit() {
    loadAllCountries();
    searchController.addListener(filterCountries);
  }

  void onDispose() {
    searchController.removeListener(filterCountries);
    searchController.dispose();
  }

  Future<void> loadAllCountries() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      print('🌍 Mengambil data semua negara dari API...');
      final response = await http.get(
        Uri.parse('https://restcountries.com/v3.1/all'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'ExploreUnity/1.0 (Flutter App)',
          'Accept-Encoding': 'gzip, deflate, br',
        },
      ).timeout(
        Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Koneksi timeout. Periksa internet Anda.');
        },
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Country> countries = [];

        for (var json in data) {
          try {
            countries.add(Country.fromJson(json));
          } catch (e) {
            print(
              '⚠️ Error parsing negara: ${json['name']?['common'] ?? 'Unknown'} - $e',
            );
          }
        }
        countries.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );

        if (mounted) {
          setState(() {
            allCountries = countries;
            filteredCountries = countries;
            isLoading = false;
          });
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error memuat negara: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> searchCountriesByName(String query) async {
    if (query.trim().isEmpty) return;
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('https://restcountries.com/v3.1/name/$query'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'ExploreUnity/1.0 (Flutter App)',
        },
      ).timeout(Duration(seconds: 10));

      if (mounted) {
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          final List<Country> countries =
              data.map((json) => Country.fromJson(json)).toList();
          setState(() {
            filteredCountries = countries;
            isLoading = false;
          });
        } else if (response.statusCode == 404) {
          setState(() {
            filteredCountries = [];
            isLoading = false;
          });
        } else {
          throw Exception('Pencarian gagal: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Error pencarian: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void filterCountries() {
    if (mounted) {
      setState(() {
        final query = searchController.text.trim().toLowerCase();

        if (query.isEmpty) {
          filteredCountries = allCountries;
        } else {
          filteredCountries = allCountries
              .where(
                (country) =>
                    country.name.toLowerCase().startsWith(query) ||
                    country.capital.toLowerCase().startsWith(query) ||
                    country.region.toLowerCase().startsWith(query),
              )
              .toList();
        }
      });
    }
  }

  void filterByAlphabet(String letter) {
    if (mounted) {
      setState(() {
        searchController.clear();
        filteredCountries = allCountries
            .where((country) => country.name.toUpperCase().startsWith(letter))
            .toList();
      });
    }
  }

  void resetFilter() {
    if (mounted) {
      setState(() {
        searchController.clear();
        filteredCountries = allCountries;
      });
    }
  }

  void showCountryDetail(Country country) async {
    String username = widget.username;

    List<HistoryItem> historySebelum = DatabaseService.getHistoryForUser(
      username,
    );
    var negaraUnikSebelum =
        historySebelum.map((item) => item.countryName).toSet();
    final int totalUnikSebelum = negaraUnikSebelum.length;

    await DatabaseService.addHistory(
      HistoryItem(
        username: username,
        countryName: country.name,
        flagUrl: country.flagUrl,
        capital: country.capital,
        region: country.region,
        viewedAt: DateTime.now(),
      ),
    );

    List<HistoryItem> historySesudah = DatabaseService.getHistoryForUser(
      username,
    );
    var negaraUnikSesudah =
        historySesudah.map((item) => item.countryName).toSet();
    final int totalUnikSesudah = negaraUnikSesudah.length;

    if (totalUnikSesudah > 0 && totalUnikSesudah % 3 == 0) {
      if (totalUnikSebelum % 3 != 0) {
        NotificationService.showNotification(
          id: totalUnikSesudah,
          title: 'Wawasan Bertambah! 🌍',
          body: 'Selamat, kamu sudah melihat $totalUnikSesudah negara baru!',
        );
      }
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CountryDetailPage(country: country),
        ),
      );
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  void openHistory() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  void openLocation() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LocationPage()),
    );
  }

  void openProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  void openComparePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ComparePage()),
    );
  }

  void onItemTapped(int index) {
    switch (index) {
      case 0:
        openProfile();
        break;
      case 1:
        openLocation();
        break;
      case 2:
        openHistory();
        break;
    }
  }
}
