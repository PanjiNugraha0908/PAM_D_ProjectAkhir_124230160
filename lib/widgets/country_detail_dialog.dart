// lib/widgets/country_detail_dialog.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../models/country.dart';
import '../services/currency_service.dart';
import '../services/timezone_service.dart';
import '../pages/country_map_page.dart'; // Import untuk Peta

class CountryDetailDialog extends StatefulWidget {
  final Country country;

  CountryDetailDialog({required this.country});

  @override
  _CountryDetailDialogState createState() => _CountryDetailDialogState();
}

class _CountryDetailDialogState extends State<CountryDetailDialog> {
  // Palet Warna (Sudah Gelap)
  final Color primaryColor = Color(0xFF010A1E);
  final Color secondaryColor = Color(0xFF103070);
  final Color tertiaryColor = Color(0xFF2A364B);
  final Color cardColor = Color(0xFF21252F);
  final Color textColor = Color(0xFFD9D9D9);
  final Color hintColor = Color(0xFF898989);

  // Currency Converter
  String? selectedFromCurrency;
  String? selectedToCurrency;
  final _amountController = TextEditingController(text: '1');
  double convertedAmount = 0.0;
  double exchangeRate = 0.0;
  bool isLoadingConversion = false;
  String conversionError = '';

  // Real-time timezone
  Timer? _timer; // <-- Dideklarasikan
  String? selectedTimezone;
  String countryTime = '';
  String convertedTime = '';

  List<DropdownMenuItem<String>> _buildTimezoneItems() {
    return TimezoneService.getAvailableTimezones().map((timezone) {
      return DropdownMenuItem<String>(
        value: timezone,
        child: Text(
          '${TimezoneService.getTimezoneName(timezone)}',
          style: TextStyle(color: textColor),
        ),
      );
    }).toList();
  }

  String _getCurrencySymbol(String? code) {
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
      // ignore and fallback
    }
    // Fallback jika simbol tidak ada di data API
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

  // Fungsi untuk menavigasi ke halaman peta
  void _openCountryMap() {
    // Cek apakah koordinat valid sebelum navigasi
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

  @override
  void initState() {
    super.initState();
    if (widget.country.currencies.isNotEmpty) {
      selectedFromCurrency = widget.country.currencies.keys.first;
      selectedToCurrency = 'IDR'; // Default ke IDR
    }
    selectedTimezone = 'WIB';
    _updateTimes();
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (_) => _updateTimes(),
    ); // <-- Diinisialisasi
  }

  void _updateTimes() {
    if (widget.country.timezones.isEmpty) return;
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

  Future<void> _convertCurrency() async {
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
      double.tryParse(_amountController.text) ?? 1.0,
    );

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

  String _getCurrencyString() {
    if (widget.country.currencies.isEmpty) return 'N/A';
    return widget.country.currencies.entries
        .map((e) => '${e.value['name']} (${e.value['symbol'] ?? ''})')
        .join(', ');
  }

  // Daftar mata uang konversi yang dibatasi: IDR, USD, EUR
  List<String> _getAvailableCurrencies() {
    return ['IDR', 'USD', 'EUR'];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.95,
          maxWidth: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.country.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  // Tombol untuk Buka Peta
                  IconButton(
                    icon: Icon(Icons.map, color: secondaryColor, size: 28),
                    onPressed: _openCountryMap,
                    tooltip: 'Lihat Negara di Peta',
                  ),
                  // Tombol Close
                  IconButton(
                    icon: Icon(Icons.close, color: hintColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(color: tertiaryColor, height: 1),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.network(
                      widget.country.flagUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Informasi Umum
                          Text(
                            'Informasi Umum',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildDetailRow(
                            'Nama Resmi',
                            widget.country.officialName,
                          ),
                          _buildDetailRow('Ibu Kota', widget.country.capital),
                          _buildDetailRow('Region', widget.country.region),
                          _buildDetailRow(
                            'Sub-region',
                            widget.country.subregion,
                          ),
                          _buildDetailRow(
                            'Populasi',
                            widget.country.population
                                .toString()
                                .replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (Match m) => '${m[1]}.',
                                ),
                          ),
                          _buildDetailRow(
                            'Luas',
                            '${widget.country.area.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} km²',
                          ),
                          _buildDetailRow(
                            'Bahasa',
                            widget.country.languages.join(', '),
                          ),
                          _buildDetailRow('Mata Uang', _getCurrencyString()),

                          Divider(
                            height: 32,
                            thickness: 1,
                            color: tertiaryColor,
                          ),

                          // Konversi Mata Uang
                          _buildCurrencyConverter(),

                          Divider(
                            height: 32,
                            thickness: 1,
                            color: tertiaryColor,
                          ),

                          // Waktu Real-time
                          _buildTimezone(),

                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (semua metode helper Anda)

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    TextEditingController? controller,
    String? label,
    IconData? icon,
    String? prefixText,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(color: textColor),
      keyboardType: readOnly ? TextInputType.none : TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: hintColor),
        prefixIcon: icon != null
            ? Icon(icon, color: hintColor, size: 20)
            : null,
        prefixText: prefixText,
        prefixStyle: TextStyle(color: textColor, fontSize: 16),
        filled: true,
        fillColor: tertiaryColor.withOpacity(0.3),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: tertiaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildCustomDropdown({
    String? value,
    String? label,
    List<DropdownMenuItem<String>>? items,
    void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: cardColor,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: hintColor),
        filled: true,
        fillColor: tertiaryColor.withOpacity(0.3),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: tertiaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildCurrencyConverter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💱 Konversi Mata Uang',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
        SizedBox(height: 16),
        if (widget.country.currencies.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCustomDropdown(
                  label: 'Dari',
                  value: selectedFromCurrency,
                  items: widget.country.currencies.keys.map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency, style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedFromCurrency = value);
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildCustomDropdown(
                  label: 'Ke',
                  value: selectedToCurrency,
                  items: _getAvailableCurrencies().map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency, style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedToCurrency = value);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          _buildCustomTextField(
            controller: _amountController,
            label: 'Jumlah',
            icon: Icons.monetization_on, // Placeholder icon
          ),

          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoadingConversion ? null : _convertCurrency,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                backgroundColor: secondaryColor,
                disabledBackgroundColor: tertiaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoadingConversion
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: textColor,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Konversi',
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
            ),
          ),
          if (conversionError.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade900.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade700),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade200,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      conversionError,
                      style: TextStyle(color: Colors.red.shade200),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (convertedAmount > 0) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tertiaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_getCurrencySymbol(selectedFromCurrency)}${_amountController.text} = ',
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                      Text(
                        '${_getCurrencySymbol(selectedToCurrency)}${convertedAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rate: 1 $selectedFromCurrency = ${exchangeRate.toStringAsFixed(4)} $selectedToCurrency',
                    style: TextStyle(
                      fontSize: 12,
                      color: hintColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ] else
          Text(
            'Tidak ada informasi mata uang',
            style: TextStyle(color: hintColor),
          ),
      ],
    );
  }

  Widget _buildTimezone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🕐 Waktu Real-time',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
        SizedBox(height: 16),
        if (widget.country.timezones.isNotEmpty) ...[
          // Waktu negara saat ini
          _buildTimeCard(
            widget.country.timezones[0],
            'Waktu ${widget.country.name}',
            countryTime,
            secondaryColor,
          ),
          SizedBox(height: 16),
          // Dropdown untuk memilih timezone
          _buildCustomDropdown(
            label: 'Pilih Zona Waktu Konversi',
            value: selectedTimezone,
            items: _buildTimezoneItems(),
            onChanged: (value) {
              setState(() => selectedTimezone = value);
              _updateTimes();
            },
          ),
          if (selectedTimezone != null && convertedTime.isNotEmpty) ...[
            SizedBox(height: 12),
            _buildTimeCard(
              selectedTimezone!,
              TimezoneService.getTimezoneName(selectedTimezone!),
              convertedTime,
              tertiaryColor,
            ),
          ],
        ] else
          Text(
            'Tidak ada informasi timezone untuk negara ini',
            style: TextStyle(color: hintColor),
          ),
      ],
    );
  }

  Widget _buildTimeCard(String code, String name, String time, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Tampilkan NAMA PANJANG
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    color: hintColor,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          // Hapus semua elemen yang menampilkan singkatan (WIB, WITA, dll)
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // **<-- INI ADALAH PERBAIKAN LINT**
    _amountController.dispose();
    super.dispose();
  }
}
