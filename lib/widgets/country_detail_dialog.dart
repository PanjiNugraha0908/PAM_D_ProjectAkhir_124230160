import 'package:flutter/material.dart';
import 'dart:async';
import '../models/country.dart';
import '../services/currency_service.dart';
import '../services/timezone_service.dart';

class CountryDetailDialog extends StatefulWidget {
  final Country country;

  CountryDetailDialog({required this.country});

  @override
  _CountryDetailDialogState createState() => _CountryDetailDialogState();
}

class _CountryDetailDialogState extends State<CountryDetailDialog> {
  // Currency Converter
  String? selectedFromCurrency;
  String? selectedToCurrency;
  final _amountController = TextEditingController(text: '1');
  double convertedAmount = 0.0;
  double exchangeRate = 0.0;
  bool isLoadingConversion = false;
  String conversionError = '';

  List<DropdownMenuItem<String>> _buildTimezoneItems() {
    return TimezoneService.getAvailableTimezones().map((timezone) {
      return DropdownMenuItem<String>(
        value: timezone,
        child: Text(
          '${timezone} (${TimezoneService.getTimezoneName(timezone)})',
        ),
      );
    }).toList();
  }

  String _getCurrencySymbol(String? code) {
    if (code == null) return '';
    try {
      if (widget.country.currencies.containsKey(code)) {
        final v = widget.country.currencies[code];
        if (v is Map && v['symbol'] != null && v['symbol'].toString().isNotEmpty) {
          return v['symbol'].toString();
        }
      }
    } catch (e) {
      // ignore and fallback
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
    };

    return fallbacks[code] ?? code;
  }

  // Real-time timezone
  Timer? _timer;
  String? selectedTimezone;
  String countryTime = '';
  String convertedTime = '';

  @override
  void initState() {
    super.initState();

    // Set default currency jika ada
    if (widget.country.currencies.isNotEmpty) {
      selectedFromCurrency = widget.country.currencies.keys.first;
      selectedToCurrency = 'USD';
    }

    // Set default timezone
    selectedTimezone = 'WIB';

    // Mulai timer untuk update waktu real-time
    _updateTimes();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTimes());
  }

  void _updateTimes() {
    if (widget.country.timezones.isEmpty) return;

    setState(() {
      // Update waktu negara
      countryTime = TimezoneService.getCurrentTimeForCountry(
        widget.country.timezones[0],
      );

      // Update waktu konversi jika ada timezone yang dipilih
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

  List<String> _getAvailableCurrencies() {
    return [
      'USD',
      'EUR',
      'GBP',
      'JPY',
      'IDR',
      'AUD',
      'CAD',
      'SGD',
      'MYR',
      'THB',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 700, maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.country.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
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
                              color: Colors.blue.shade700,
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

                          Divider(height: 32, thickness: 2),

                          // Konversi Mata Uang
                          Text(
                            '💱 Konversi Mata Uang',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          SizedBox(height: 12),

                          if (widget.country.currencies.isNotEmpty) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Dari:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      DropdownButtonFormField<String>(
                                        value: selectedFromCurrency,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        items: widget.country.currencies.keys
                                            .map((currency) {
                                              return DropdownMenuItem(
                                                value: currency,
                                                child: Text(currency),
                                              );
                                            })
                                            .toList(),
                                        onChanged: (value) {
                                          setState(
                                            () => selectedFromCurrency = value,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ke:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      DropdownButtonFormField<String>(
                                        value: selectedToCurrency,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        items: _getAvailableCurrencies().map((
                                          currency,
                                        ) {
                                          return DropdownMenuItem(
                                            value: currency,
                                            child: Text(currency),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(
                                            () => selectedToCurrency = value,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Jumlah',
                                border: OutlineInputBorder(),
                                prefix: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  child: Text(
                                    _getCurrencySymbol(selectedFromCurrency),
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoadingConversion
                                    ? null
                                    : _convertCurrency,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: Colors.green,
                                ),
                                child: isLoadingConversion
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Konversi',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),

                            if (conversionError.isNotEmpty) ...[
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade700,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        conversionError,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                        ),
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
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${_getCurrencySymbol(selectedFromCurrency)}${_amountController.text} = ',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          '${_getCurrencySymbol(selectedToCurrency)}${convertedAmount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Rate: 1 $selectedFromCurrency = ${exchangeRate.toStringAsFixed(4)} $selectedToCurrency',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
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
                              style: TextStyle(color: Colors.grey),
                            ),

                          Divider(height: 32, thickness: 2),

                          // Waktu Real-time
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🕐 Waktu Real-time',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              SizedBox(height: 16),
                              if (widget.country.timezones.isNotEmpty) ...[
                                // Waktu negara saat ini
                                _buildTimeCard(
                                  widget.country.timezones[0],
                                  'Waktu ${widget.country.name}',
                                  countryTime,
                                  Colors.blue,
                                ),
                                SizedBox(height: 16),

                                // Dropdown untuk memilih timezone
                                DropdownButtonFormField<String>(
                                  value: selectedTimezone,
                                  decoration: InputDecoration(
                                    labelText: 'Pilih Zona Waktu',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  items: _buildTimezoneItems(),
                                  onChanged: (value) {
                                    setState(() => selectedTimezone = value);
                                    _updateTimes();
                                  },
                                ),

                                if (selectedTimezone != null &&
                                    convertedTime.isNotEmpty) ...[
                                  SizedBox(height: 16),
                                  _buildTimeCard(
                                    selectedTimezone!,
                                    TimezoneService.getTimezoneName(
                                      selectedTimezone!,
                                    ),
                                    convertedTime,
                                    Colors.orange,
                                  ),
                                ],
                              ] else
                                Text(
                                  'Tidak ada informasi timezone untuk negara ini',
                                  style: TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),

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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? 'N/A' : value)),
        ],
      ),
    );
  }

  Widget _buildTimeCard(String code, String name, String time, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              code,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amountController.dispose();
    super.dispose();
  }
}
