// lib/pages/country_detail_page.dart
import 'package:flutter/material.dart';
// import 'dart:async'; // <-- HAPUS BARIS INI (Tidak terpakai di file ini)
// import 'package:intl/intl.dart'; // <-- HAPUS BARIS INI (Tidak terpakai di file ini)
import '../models/country.dart';
import '../controllers/country_detail_controller.dart'; // Import controller
import '../services/timezone_service.dart'; // Import timezone service

/// Halaman yang menampilkan informasi detail lengkap dari sebuah [Country] (Tampilan/View).
///
/// File ini hanya berisi metode `build` dan helper `_build...` untuk UI.
/// Semua logika, state, dan pemformatan data di-handle oleh
/// [CountryDetailController] yang di-mixin ke `_CountryDetailPageState`.
class CountryDetailPage extends StatefulWidget {
  final Country country;

  CountryDetailPage({required this.country});

  @override
  _CountryDetailPageState createState() => _CountryDetailPageState();
}

class _CountryDetailPageState extends State<CountryDetailPage>
    with CountryDetailController {
  @override
  void initState() {
    super.initState();
    onInit(); // Panggil onInit dari controller
  }

  @override
  void dispose() {
    onDispose(); // Panggil onDispose dari controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A202C), // backgroundColor
      body: CustomScrollView(
        slivers: [
          // --- 1. AppBar yang bisa mengecil (Bendera & Judul) ---
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: Color(0xFF2D3748), // surfaceColor
            iconTheme: IconThemeData(color: Color(0xFFE2E8F0)), // textColor
            // --- TAMBAHAN BARU: Tombol Favorit ---
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.redAccent[200] : Color(0xFFE2E8F0),
                ),
                onPressed: toggleFavorite, // Panggil fungsi controller
                tooltip: 'Tambah ke Favorit',
              ),
            ],
            // --- AKHIR TAMBAHAN ---
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.country.name,
                style: TextStyle(
                  color: Color(0xFFE2E8F0), // textColor
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Image.network(
                widget.country.flagUrl,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),

          // --- 2. Konten Halaman ---
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 2A. Informasi Umum ---
                  _buildSectionCard(
                    title: 'Informasi Umum',
                    icon: Icons.info_outline,
                    children: [
                      // ... (Widget _buildDetailRow tidak berubah) ...
                      _buildDetailRow(
                        'Nama Resmi',
                        widget.country.officialName,
                      ),
                      _buildDetailRow('Ibu Kota', widget.country.capital),
                      _buildDetailRow('Region', widget.country.region),
                      _buildDetailRow('Sub-region', widget.country.subregion),
                      _buildDetailRow(
                        'Populasi',
                        widget.country.population.toString().replaceAllMapped(
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
                      _buildDetailRow(
                        'Mata Uang',
                        getCurrencyString(),
                      ), // Panggil controller
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.map,
                            color: Color(0xFFE2E8F0),
                          ), // textColor
                          label: Text(
                            'Lihat di Peta',
                            style: TextStyle(
                              color: Color(0xFFE2E8F0),
                            ), // textColor
                          ),
                          onPressed: openCountryMap, // Panggil controller
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(
                              0xFF4299E1,
                            ), // primaryButtonColor
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // --- 2B. Konverter Mata Uang ---
                  _buildSectionCard(
                    title: 'Konversi Mata Uang',
                    icon: Icons.currency_exchange,
                    children: [
                      _buildCurrencyConverter(), // Panggil helper UI
                    ],
                  ),
                  SizedBox(height: 24),

                  // --- 2C. Waktu Real-time ---
                  _buildSectionCard(
                    title: 'Waktu Real-time',
                    icon: Icons.watch_later_outlined,
                    children: [
                      _buildTimezone(), // Panggil helper UI
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets (Bagian dari "Style" / Tampilan) ---
  // ... (Semua helper widget _build... TIDAK BERUBAH) ...

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF2D3748), // surfaceColor
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFF66B3FF), size: 22), // accentColor
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF66B3FF), // accentColor
                ),
              ),
            ],
          ),
          Divider(
            height: 24,
            thickness: 1,
            color: Color(0xFFA0AEC0).withOpacity(0.3), // hintColor
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFFA0AEC0), // hintColor
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 15,
              ), // textColor
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
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Color(0xFFE2E8F0)), // textColor
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFFA0AEC0)), // hintColor
        prefixIcon: icon != null
            ? Icon(icon, color: Color(0xFF66B3FF), size: 20) // accentColor
            : null,
        filled: true,
        fillColor: Color(0xFF1A202C).withOpacity(0.5), // backgroundColor
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Color(0xFFA0AEC0).withOpacity(0.7),
          ), // hintColor
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Color(0xFF4299E1),
            width: 2,
          ), // primaryButtonColor
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
      dropdownColor: Color(0xFF2D3748), // surfaceColor
      style: TextStyle(color: Color(0xFFE2E8F0)), // textColor
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFFA0AEC0)), // hintColor
        filled: true,
        fillColor: Color(0xFF1A202C).withOpacity(0.5), // backgroundColor
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Color(0xFFA0AEC0).withOpacity(0.7),
          ), // hintColor
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Color(0xFF4299E1),
            width: 2,
          ), // primaryButtonColor
        ),
      ),
    );
  }

  Widget _buildCurrencyConverter() {
    if (widget.country.currencies.isEmpty) {
      return Text(
        'Tidak ada informasi mata uang yang tersedia.',
        style: TextStyle(
          color: Color(0xFFA0AEC0),
          fontStyle: FontStyle.italic,
        ), // hintColor
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    child: Text(
                      currency,
                      style: TextStyle(color: Color(0xFFE2E8F0)),
                    ), // textColor
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
                items: getAvailableCurrencies().map((currency) {
                  // Panggil controller
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(
                      currency,
                      style: TextStyle(color: Color(0xFFE2E8F0)),
                    ), // textColor
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
          controller: amountController,
          label: 'Jumlah',
          icon: Icons.monetization_on,
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoadingConversion
                ? null
                : convertCurrency, // Panggil controller
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Color(0xFF4299E1), // primaryButtonColor
              disabledBackgroundColor: Color(
                0xFF2D3748,
              ).withOpacity(0.5), // surfaceColor
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoadingConversion
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFFE2E8F0), // textColor
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Konversi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFE2E8F0),
                    ), // textColor
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
                Icon(Icons.error_outline, color: Colors.red.shade200, size: 20),
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
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF1A202C).withOpacity(0.5), // backgroundColor
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatInputAmount(
                    amountController.text,
                    selectedFromCurrency,
                  ), // Panggil controller
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFA0AEC0), // hintColor
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Icon(
                    Icons.arrow_downward,
                    color: Color(0xFF66B3FF), // accentColor
                    size: 20,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatCurrency(
                      convertedAmount,
                      selectedToCurrency,
                    ), // Panggil controller
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4299E1), // primaryButtonColor
                    ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Rate: 1 $selectedFromCurrency = ${exchangeRate.toStringAsFixed(4)} $selectedToCurrency',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFA0AEC0), // hintColor
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimezone() {
    if (widget.country.timezones.isEmpty) {
      return Text(
        'Tidak ada informasi timezone untuk negara ini.',
        style: TextStyle(
          color: Color(0xFFA0AEC0),
          fontStyle: FontStyle.italic,
        ), // hintColor
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeCard(
          widget.country.timezones[0],
          'Waktu ${widget.country.name}',
          countryTime,
          Color(0xFF4299E1), // primaryButtonColor
        ),
        SizedBox(height: 16),
        _buildCustomDropdown(
          label: 'Bandingkan dengan...',
          value: selectedTimezone,
          items: buildTimezoneItems(), // Panggil controller
          onChanged: (value) {
            setState(() => selectedTimezone = value);
            updateTimes(); // Panggil controller
          },
        ),
        if (selectedTimezone != null && convertedTime.isNotEmpty) ...[
          SizedBox(height: 12),
          _buildTimeCard(
            selectedTimezone!,
            TimezoneService.getTimezoneName(selectedTimezone!),
            convertedTime,
            Color(0xFF66B3FF), // accentColor
          ),
        ],
      ],
    );
  }

  Widget _buildTimeCard(String code, String name, String time, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1A202C).withOpacity(0.5), // backgroundColor
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFA0AEC0), // hintColor
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE2E8F0), // textColor
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
