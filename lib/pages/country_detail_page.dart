import 'package:flutter/material.dart';
import 'dart:async';
import '../models/country.dart';
import '../services/currency_service.dart';
import '../services/timezone_service.dart';
import 'country_map_page.dart'; // Import untuk Peta

/// Halaman yang menampilkan informasi detail lengkap dari sebuah [Country].
///
/// Mencakup informasi umum, konverter mata uang, dan perbandingan
/// zona waktu real-time, disajikan dalam tata letak Scrollable.
class CountryDetailPage extends StatefulWidget {
  final Country country;

  CountryDetailPage({required this.country});

  @override
  _CountryDetailPageState createState() => _CountryDetailPageState();
}

class _CountryDetailPageState extends State<CountryDetailPage> {
  // --- Palet Warna Halaman ---
  final Color backgroundColor = Color(0xFF1A202C);
  final Color surfaceColor = Color(0xFF2D3748);
  final Color accentColor = Color(0xFF66B3FF);
  final Color primaryButtonColor = Color(0xFF4299E1);
  final Color textColor = Color(0xFFE2E8F0);
  final Color hintColor = Color(0xFFA0AEC0);

  // --- State Konverter Mata Uang ---
  String? selectedFromCurrency;
  String? selectedToCurrency;
  final _amountController = TextEditingController(text: '1');
  double convertedAmount = 0.0;
  double exchangeRate = 0.0;
  bool isLoadingConversion = false;
  String conversionError = '';

  // --- State Zona Waktu Real-time ---
  Timer? _timer;
  String? selectedTimezone;
  String countryTime = ''; // Waktu di negara yang dilihat
  String convertedTime = ''; // Waktu di zona waktu yang dipilih pengguna

  @override
  void initState() {
    super.initState();
    // Inisialisasi default konverter mata uang
    if (widget.country.currencies.isNotEmpty) {
      selectedFromCurrency = widget.country.currencies.keys.first;
      selectedToCurrency = 'IDR'; // Default konversi ke IDR
    }
    // Inisialisasi default zona waktu
    selectedTimezone = 'WIB';
    _updateTimes();
    // Timer untuk memperbarui jam setiap detik
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTimes());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Pastikan timer dibatalkan
    _amountController.dispose();
    super.dispose();
  }

  /// Memperbarui state [countryTime] dan [convertedTime]
  /// berdasarkan [TimezoneService].
  void _updateTimes() {
    if (widget.country.timezones.isEmpty) return;
    // Cek 'mounted' untuk mencegah setState dipanggil setelah dispose()
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

  /// Memanggil [CurrencyService] untuk mengkonversi mata uang
  /// dan memperbarui state UI.
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

    // Cek 'mounted' sebelum setState pasca-await
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

  /// Navigasi ke [CountryMapPage] untuk menampilkan lokasi negara.
  ///
  /// Melakukan pengecekan koordinat (0,0) sebagai data tidak valid
  /// sebelum bernavigasi.
  void _openCountryMap() {
    // Cek apakah koordinat valid (bukan 0.0, 0.0)
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

  /// Mengambil daftar zona waktu yang tersedia dari [TimezoneService]
  /// dan mengubahnya menjadi [DropdownMenuItem].
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

  /// Mendapatkan simbol mata uang.
  ///
  /// Mencoba mengambil dari data [country.currencies] terlebih dahulu,
  /// jika gagal, menggunakan daftar [fallbacks] hardcoded.
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
      // Abaikan error parsing dan lanjut ke fallback
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
    return fallbacks[code] ?? code; // Default ke kode jika tidak ada fallback
  }

  /// Mengambil dan memformat string mata uang dari data negara.
  ///
  /// Contoh: "US Dollar ($), Euro (€)"
  String _getCurrencyString() {
    if (widget.country.currencies.isEmpty) return 'N/A';
    return widget.country.currencies.entries
        .map((e) => '${e.value['name']} (${e.value['symbol'] ?? ''})')
        .join(', ');
  }

  /// Mengembalikan daftar mata uang (hardcoded) yang didukung untuk konversi.
  List<String> _getAvailableCurrencies() {
    return ['IDR', 'USD', 'EUR'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // --- 1. AppBar yang bisa mengecil (Bendera & Judul) ---
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: surfaceColor,
            iconTheme: IconThemeData(color: textColor),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.country.name,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Image.network(
                widget.country.flagUrl,
                fit: BoxFit.cover,
                // Efek gelap agar teks 'title' lebih mudah dibaca
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
                        // Format angka dengan pemisah titik
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
                      SizedBox(height: 16),
                      // Tombol Lihat Peta
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.map, color: textColor),
                          label: Text(
                            'Lihat di Peta',
                            style: TextStyle(color: textColor),
                          ),
                          onPressed: _openCountryMap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryButtonColor,
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
                      _buildCurrencyConverter(),
                    ],
                  ),
                  SizedBox(height: 24),

                  // --- 2C. Waktu Real-time ---
                  _buildSectionCard(
                    title: 'Waktu Real-time',
                    icon: Icons.watch_later_outlined,
                    children: [
                      _buildTimezone(),
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

  // --- Helper Widgets ---

  /// [Helper Widget] Membangun 'Card' kustom untuk setiap bagian.
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 22),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          Divider(
            height: 24,
            thickness: 1,
            color: hintColor.withOpacity(0.3),
          ),
          ...children,
        ],
      ),
    );
  }

  /// [Helper Widget] Membangun baris info (Label: Value).
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Lebar tetap untuk label
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: hintColor,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value, // Fallback jika value kosong
              style: TextStyle(color: textColor, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  /// [Helper Widget] Membangun [TextFormField] kustom.
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
            ? Icon(icon, color: accentColor, size: 20)
            : null,
        prefixText: prefixText,
        prefixStyle: TextStyle(color: textColor, fontSize: 16),
        filled: true,
        fillColor: backgroundColor.withOpacity(0.5), // Warna lebih gelap
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: hintColor.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryButtonColor, width: 2),
        ),
      ),
    );
  }

  /// [Helper Widget] Membangun [DropdownButtonFormField] kustom.
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
      dropdownColor: surfaceColor,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: hintColor),
        filled: true,
        fillColor: backgroundColor.withOpacity(0.5), // Warna lebih gelap
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: hintColor.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryButtonColor, width: 2),
        ),
      ),
    );
  }

  /// [Helper Widget] Membangun UI untuk bagian Konverter Mata Uang.
  Widget _buildCurrencyConverter() {
    // Cek jika negara punya data mata uang
    if (widget.country.currencies.isEmpty) {
      return Text(
        'Tidak ada informasi mata uang yang tersedia.',
        style: TextStyle(color: hintColor, fontStyle: FontStyle.italic),
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
          icon: Icons.monetization_on,
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoadingConversion ? null : _convertCurrency,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              backgroundColor: primaryButtonColor,
              disabledBackgroundColor: surfaceColor.withOpacity(0.5),
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
        // Tampilan Error (jika ada)
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
        // Tampilan Hasil (jika sukses)
        if (convertedAmount > 0) ...[
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.5),
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryButtonColor,
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
      ],
    );
  }

  /// [Helper Widget] Membangun UI untuk bagian Zona Waktu.
  Widget _buildTimezone() {
    // Cek jika negara punya data timezone
    if (widget.country.timezones.isEmpty) {
      return Text(
        'Tidak ada informasi timezone untuk negara ini.',
        style: TextStyle(color: hintColor, fontStyle: FontStyle.italic),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kartu Waktu Negara (Tujuan)
        _buildTimeCard(
          widget.country.timezones[0],
          'Waktu ${widget.country.name}',
          countryTime,
          primaryButtonColor, // Border warna primer
        ),
        SizedBox(height: 16),
        // Dropdown Pilihan Zona Waktu
        _buildCustomDropdown(
          label: 'Bandingkan dengan...',
          value: selectedTimezone,
          items: _buildTimezoneItems(),
          onChanged: (value) {
            setState(() => selectedTimezone = value);
            _updateTimes();
          },
        ),
        // Kartu Waktu Pilihan (Terkonversi)
        if (selectedTimezone != null && convertedTime.isNotEmpty) ...[
          SizedBox(height: 12),
          _buildTimeCard(
            selectedTimezone!,
            TimezoneService.getTimezoneName(selectedTimezone!),
            convertedTime,
            accentColor, // Border warna aksen
          ),
        ],
      ],
    );
  }

  /// [Helper Widget] Membangun kartu untuk menampilkan waktu.
  Widget _buildTimeCard(String code, String name, String time, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color, // Menggunakan warna border yang di-pass
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name, // Menampilkan nama panjang (misal: "Waktu Indonesia Barat")
                  style: TextStyle(
                    fontSize: 16,
                    color: hintColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  time, // Waktu (HH:mm:ss)
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily:
                        'monospace', // Font monospace agar angka tidak 'loncat-loncat'
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