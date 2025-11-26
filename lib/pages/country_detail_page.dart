import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/country.dart';
import '../controllers/country_detail_controller.dart';
import '../services/timezone_service.dart';
import '../services/weather_service.dart';

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
    // Menginisialisasi controller dengan negara yang sedang dibuka
    // Pastikan controller Anda memanggil DatabaseService.isFavorite(widget.country.name)
    onInit();
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  String _formatLargeNumber(double number) {
    if (number >= 1e12) return '${(number / 1e12).toStringAsFixed(2)} Triliun';
    if (number >= 1e9) return '${(number / 1e9).toStringAsFixed(2)} Miliar';
    if (number >= 1e6) return '${(number / 1e6).toStringAsFixed(2)} Juta';
    return _formatNumber(number);
  }

  String _getHDICategory(double hdi) {
    if (hdi >= 0.8) return 'Sangat Tinggi';
    if (hdi >= 0.7) return 'Tinggi';
    if (hdi >= 0.55) return 'Menengah';
    return 'Rendah';
  }

  String _formatNumber(double number) {
    return NumberFormat('#,##0.00', 'id_ID').format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A202C),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: Color(0xFF2D3748),
            iconTheme: IconThemeData(color: Color(0xFFE2E8F0)),
            actions: [
              IconButton(
                // Menggunakan getter isFavorite dari controller
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.redAccent[200] : Color(0xFFE2E8F0),
                ),
                onPressed: toggleFavorite,
                tooltip:
                    isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.country.name,
                style: TextStyle(
                    color: Color(0xFFE2E8F0), fontWeight: FontWeight.bold),
              ),
              background: Image.network(
                widget.country.flagUrl,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeatherSection(),
                  SizedBox(height: 24),
                  _buildSectionCard(
                    title: 'Informasi Umum',
                    icon: Icons.info_outline,
                    children: [
                      _buildDetailRow(
                          'Nama Resmi', widget.country.officialName),
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
                          'Bahasa', widget.country.languages.join(', ')),
                      _buildDetailRow('Mata Uang', getCurrencyString()),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.map, color: Color(0xFFE2E8F0)),
                          label: Text('Lihat di Peta',
                              style: TextStyle(color: Color(0xFFE2E8F0))),
                          onPressed: openCountryMap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4299E1),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildSectionCard(
                    title: 'Konversi Mata Uang',
                    icon: Icons.currency_exchange,
                    children: [_buildCurrencyConverter()],
                  ),
                  SizedBox(height: 24),
                  _buildSectionCard(
                    title: 'Waktu Real-time',
                    icon: Icons.watch_later_outlined,
                    children: [_buildTimezone()],
                  ),
                  SizedBox(height: 24),
                  _buildSectionCard(
                    title: 'Metrik Ekonomi & Pembangunan',
                    icon: Icons.trending_up,
                    children: [
                      if (isLoadingMetrics)
                        Center(
                            child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                  color: Color(0xFF4299E1), strokeWidth: 2),
                              SizedBox(height: 12),
                              Text('Memuat data dari World Bank...',
                                  style: TextStyle(
                                      color: Color(0xFFA0AEC0), fontSize: 12)),
                            ],
                          ),
                        ))
                      else if (enrichedCountry != null) ...[
                        if (enrichedCountry!.gdpTotal != null)
                          _buildDetailRow('GDP Total',
                              '\$${_formatLargeNumber(enrichedCountry!.gdpTotal!)}'),
                        if (enrichedCountry!.gdpPerCapita != null)
                          _buildDetailRow('GDP per Kapita',
                              '\$${_formatNumber(enrichedCountry!.gdpPerCapita!)}'),
                        if (enrichedCountry!.incomeLevel != null)
                          _buildDetailRow('Level Pendapatan',
                              enrichedCountry!.incomeLevel!),
                        if (enrichedCountry!.hdi != null)
                          _buildDetailRow(
                            'Indeks Pembangunan Manusia (IPM)',
                            '${(enrichedCountry!.hdi! * 100).toStringAsFixed(1)}% (${_getHDICategory(enrichedCountry!.hdi!)})',
                          ),
                        if (enrichedCountry!.happinessScore != null)
                          _buildDetailRow(
                            'Skor Kebahagiaan',
                            '${enrichedCountry!.happinessScore!.toStringAsFixed(2)}/10 (Peringkat #${enrichedCountry!.happinessRank})',
                          ),
                        if (enrichedCountry!.gdpTotal == null &&
                            enrichedCountry!.gdpPerCapita == null &&
                            enrichedCountry!.hdi == null &&
                            enrichedCountry!.happinessScore == null)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('Data tidak tersedia untuk negara ini',
                                style: TextStyle(
                                    color: Color(0xFFA0AEC0),
                                    fontStyle: FontStyle.italic)),
                          ),
                        SizedBox(height: 12),
                        Text(
                            'Sumber: World Bank API & World Happiness Report 2023',
                            style: TextStyle(
                                color: Color(0xFFA0AEC0),
                                fontSize: 11,
                                fontStyle: FontStyle.italic)),
                      ] else
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Gagal memuat data metrik',
                              style: TextStyle(
                                  color: Colors.red.shade300,
                                  fontStyle: FontStyle.italic)),
                        ),
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

  // --- BAGIAN INI YANG DIPERBAIKI (DESAIN CUACA) ---
  Widget _buildWeatherSection() {
    return _buildSectionCard(
      title: 'Cuaca di ${widget.country.capital}',
      icon: Icons.wb_sunny,
      children: [
        if (isLoadingWeather)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  CircularProgressIndicator(
                      color: Color(0xFF4299E1), strokeWidth: 2),
                  SizedBox(height: 12),
                  Text('Memuat data cuaca...',
                      style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 12)),
                ],
              ),
            ),
          )
        else if (weatherError.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(Icons.error_outline,
                    color: Colors.orange.shade300, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(weatherError,
                      style: TextStyle(
                          color: Color(0xFFA0AEC0),
                          fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          )
        else if (weatherData != null)
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4299E1), Color(0xFF66B3FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  // Tambahkan shadow halus
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Ubah ke Center
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${weatherData!['temperature'].toStringAsFixed(1)}°C',
                              style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              weatherData!['description']
                                  .toString()
                                  .toUpperCase(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.9)),
                            ),
                          ],
                        ),
                        // PERBAIKAN: Container bulat dengan background transparan untuk icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(0.2), // Glassmorphism
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Image.network(
                            WeatherService.getWeatherIconUrl(
                                weatherData!['icon']),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  WeatherService.getWeatherEmoji(
                                      weatherData!['description']),
                                  style: TextStyle(fontSize: 40),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Divider(color: Colors.white.withOpacity(0.3)),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeatherInfo(Icons.thermostat, 'Terasa',
                            '${weatherData!['feelsLike'].toStringAsFixed(1)}°C'),
                        _buildWeatherInfo(Icons.water_drop, 'Kelembapan',
                            '${weatherData!['humidity']}%'),
                        _buildWeatherInfo(Icons.air, 'Angin',
                            '${weatherData!['windSpeed']} m/s'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '🌡️ Min: ${weatherData!['tempMin'].toStringAsFixed(1)}°C',
                      style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 12)),
                  Text(
                      '🌡️ Max: ${weatherData!['tempMax'].toStringAsFixed(1)}°C',
                      style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 12)),
                  Text('☁️ ${weatherData!['cloudiness']}%',
                      style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 12)),
                ],
              ),
              SizedBox(height: 8),
              Text('Sumber: OpenWeatherMap',
                  style: TextStyle(
                      color: Color(0xFFA0AEC0),
                      fontSize: 10,
                      fontStyle: FontStyle.italic)),
            ],
          ),
      ],
    );
  }

  Widget _buildWeatherInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 4),
        Text(label,
            style:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
        Text(value,
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Icon(icon, color: Color(0xFF66B3FF), size: 22),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF66B3FF)),
                ),
              ),
            ],
          ),
          Divider(
              height: 24,
              thickness: 1,
              color: Color(0xFFA0AEC0).withOpacity(0.3)),
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
            child: Text('$label:',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFFA0AEC0))),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 15),
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
      style: TextStyle(color: Color(0xFFE2E8F0)),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFFA0AEC0)),
        prefixIcon: icon != null
            ? Icon(icon, color: Color(0xFF66B3FF), size: 20)
            : null,
        filled: true,
        fillColor: Color(0xFF1A202C).withOpacity(0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFFA0AEC0).withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF4299E1), width: 2),
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
      dropdownColor: Color(0xFF2D3748),
      style: TextStyle(color: Color(0xFFE2E8F0)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFFA0AEC0)),
        filled: true,
        fillColor: Color(0xFF1A202C).withOpacity(0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFFA0AEC0).withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF4299E1), width: 2),
        ),
      ),
    );
  }

  Widget _buildCurrencyConverter() {
    if (widget.country.currencies.isEmpty) {
      return Text(
        'Tidak ada informasi mata uang yang tersedia.',
        style: TextStyle(color: Color(0xFFA0AEC0), fontStyle: FontStyle.italic),
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
                    child: Text(currency,
                        style: TextStyle(color: Color(0xFFE2E8F0))),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => selectedFromCurrency = value),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildCustomDropdown(
                label: 'Ke',
                value: selectedToCurrency,
                items: getAvailableCurrencies().map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency,
                        style: TextStyle(color: Color(0xFFE2E8F0))),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => selectedToCurrency = value),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        _buildCustomTextField(
            controller: amountController,
            label: 'Jumlah',
            icon: Icons.monetization_on),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoadingConversion ? null : convertCurrency,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Color(0xFF4299E1),
              disabledBackgroundColor: Color(0xFF2D3748).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: isLoadingConversion
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Color(0xFFE2E8F0), strokeWidth: 2),
                  )
                : Text('Konversi',
                    style: TextStyle(fontSize: 16, color: Color(0xFFE2E8F0))),
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
                    child: Text(conversionError,
                        style: TextStyle(color: Colors.red.shade200))),
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
              color: Color(0xFF1A202C).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatInputAmount(
                      amountController.text, selectedFromCurrency),
                  style: TextStyle(fontSize: 18, color: Color(0xFFA0AEC0)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Icon(Icons.arrow_downward,
                      color: Color(0xFF66B3FF), size: 20),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatCurrency(convertedAmount, selectedToCurrency),
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4299E1)),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Rate: 1 $selectedFromCurrency = ${exchangeRate.toStringAsFixed(4)} $selectedToCurrency',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFA0AEC0),
                      fontStyle: FontStyle.italic),
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
        style: TextStyle(color: Color(0xFFA0AEC0), fontStyle: FontStyle.italic),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeCard(widget.country.timezones[0],
            'Waktu ${widget.country.name}', countryTime, Color(0xFF4299E1)),
        SizedBox(height: 16),
        _buildCustomDropdown(
          label: 'Bandingkan dengan...',
          value: selectedTimezone,
          items: buildTimezoneItems(),
          onChanged: (value) {
            setState(() => selectedTimezone = value);
            updateTimes();
          },
        ),
        if (selectedTimezone != null && convertedTime.isNotEmpty) ...[
          SizedBox(height: 12),
          _buildTimeCard(
              selectedTimezone!,
              TimezoneService.getTimezoneName(selectedTimezone!),
              convertedTime,
              Color(0xFF66B3FF)),
        ],
      ],
    );
  }

  Widget _buildTimeCard(String code, String name, String time, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1A202C).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFA0AEC0),
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 4),
                Text(time,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE2E8F0),
                        fontFamily: 'monospace')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
