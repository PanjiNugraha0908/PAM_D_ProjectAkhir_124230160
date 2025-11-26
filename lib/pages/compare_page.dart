import 'package:flutter/material.dart';
import '../models/country.dart';
import '../controllers/compare_controller.dart';
import 'package:fl_chart/fl_chart.dart';

class ComparePage extends StatefulWidget {
  ComparePage({Key? key}) : super(key: key);

  @override
  _ComparePageState createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> with CompareController {
  // Warna Dasar
  final Color bgColor = Color(0xFF1A202C);
  final Color surfaceColor = Color(0xFF2D3748);
  final Color textColor = Color(0xFFE2E8F0);
  final Color hintColor = Color(0xFFA0AEC0);
  // Warna Ikon Seragam (Abu-abu Terang / Putih Tulang)
  final Color iconColor = Color(0xFFE2E8F0);

  bool _showChart = false;

  final double labelColumnWidth = 120.0;
  final double countryColumnWidth = 160.0;
  final double fixedRowHeight = 65.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        // Judul dihapus dari AppBar agar tidak sempit/kepotong
        title: null,
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor), // Warna back button
        actions: [
          // 1. Ikon HISTORY (Seragam)
          IconButton(
            icon: Icon(Icons.history, color: iconColor),
            onPressed: _showHistoryModal,
            tooltip: 'Riwayat Pencarian',
          ),

          // 2. Ikon CHART (Seragam)
          if (validCountries.length >= 2)
            IconButton(
              icon: Icon(
                _showChart ? Icons.table_chart : Icons.bar_chart,
                color: iconColor,
              ),
              onPressed: () {
                setState(() {
                  _showChart = !_showChart;
                });
              },
              tooltip: _showChart ? 'Tampilkan Tabel' : 'Tampilkan Grafik',
            ),

          // 3. Ikon CLEAR (Seragam)
          IconButton(
            icon: Icon(Icons.clear_all, color: iconColor),
            onPressed: clearSelection,
            tooltip: 'Bersihkan Pilihan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // JUDUL HALAMAN DI SINI (Pindah dari AppBar)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, left: 4.0),
              child: Text(
                'Perbandingan Negara',
                style: TextStyle(
                  fontSize: 28, // Ukuran besar
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),

            _buildCountrySelectors(),

            SizedBox(height: 24),
            validCountries.isEmpty
                ? _buildEmptyState()
                : _showChart
                    ? _buildComparisonChart()
                    : _buildComparisonTable(),
          ],
        ),
      ),
    );
  }

  // --- Modal Bottom Sheet History ---
  void _showHistoryModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Pencarian',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: hintColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(color: hintColor.withOpacity(0.3)),
              recentHistory.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'Belum ada riwayat',
                          style: TextStyle(color: hintColor),
                        ),
                      ),
                    )
                  : Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: recentHistory.length,
                        itemBuilder: (context, index) {
                          final item = recentHistory[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(item.flagUrl),
                              backgroundColor: Colors.transparent,
                            ),
                            title: Text(
                              item.countryName,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Terakhir dilihat: ${_formatDate(item.viewedAt)}',
                              style: TextStyle(color: hintColor, fontSize: 12),
                            ),
                            onTap: () {
                              selectFromHistory(item.countryName);
                              Navigator.pop(context);
                            },
                            trailing: Icon(Icons.add_circle_outline,
                                color: iconColor),
                          );
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.compare_arrows_rounded, size: 60, color: hintColor),
            SizedBox(height: 16),
            Text(
              'Mulai Mencari Negara',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ketik nama negara di kolom atas atau pilih dari icon History.',
              style: TextStyle(fontSize: 14, color: hintColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySelectors() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cari Negara',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF66B3FF), // Judul Section Biru
            ),
          ),
          SizedBox(height: 16),
          // Warna Kolom Input tetap Biru Langit (Seragam)
          _buildCountrySearchField(0, 'Negara 1', Color(0xFF66B3FF)),
          SizedBox(height: 12),
          _buildCountrySearchField(1, 'Negara 2', Color(0xFF66B3FF)),
          SizedBox(height: 12),
          _buildCountrySearchField(2, 'Negara 3 (Opsional)', Color(0xFF66B3FF)),
        ],
      ),
    );
  }

  Widget _buildCountrySearchField(int index, String label, Color fieldColor) {
    return TextFormField(
      controller: searchControllers[index],
      style: TextStyle(color: textColor),
      textInputAction: TextInputAction.search,
      onFieldSubmitted: (value) => searchCountry(index),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: hintColor),
        hintText: 'Ketik nama negara...',
        hintStyle: TextStyle(color: hintColor.withOpacity(0.5)),
        filled: true,
        fillColor: bgColor.withOpacity(0.5),
        errorText: errors[index],
        suffixIcon: isLoading[index]
            ? Transform.scale(
                scale: 0.5,
                child: CircularProgressIndicator(color: fieldColor),
              )
            : IconButton(
                icon: Icon(Icons.search, color: hintColor),
                onPressed: () => searchCountry(index),
              ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: hintColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: fieldColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 0,
        horizontalMargin: 0,
        dataRowMinHeight: fixedRowHeight,
        dataRowMaxHeight: fixedRowHeight,
        headingRowHeight: fixedRowHeight,
        headingRowColor: MaterialStateProperty.all(surfaceColor),
        border: TableBorder.all(
          color: hintColor.withOpacity(0.3),
          width: 1,
          borderRadius: BorderRadius.circular(8),
        ),
        columns: [
          DataColumn(
            label: Container(
              width: labelColumnWidth,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                'Data',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF66B3FF),
                  fontSize: 16,
                ),
              ),
            ),
          ),
          ...validCountries.map((country) {
            return DataColumn(
              label: Container(
                width: countryColumnWidth,
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(country.flagUrl,
                          width: 32, height: 22, fit: BoxFit.cover),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        country.name,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
        rows: [
          _buildDataRow(
              'Ibu Kota', (c) => c.capital.isEmpty ? 'N/A' : c.capital),
          _buildDataRow('Region', (c) => c.region),
          _buildDataRow('Sub-Region', (c) => c.subregion),
          _buildDataRow('Populasi', (c) => formatNumber(c.population)),
          _buildDataRow('Luas (km²)', (c) => formatNumber(c.area)),
          _buildDataRow('Bahasa', (c) => getJoinedString(c.languages)),
          _buildDataRow(
              'Mata Uang', (c) => getJoinedString(c.currencies.keys.toList())),
          _buildDataRow(
            'GDP per Kapita',
            (c) => c.gdpPerCapita != null
                ? '\$${formatNumber(c.gdpPerCapita!.round())}'
                : 'N/A',
          ),
          _buildDataRow(
            'Skor Kebahagiaan',
            (c) => c.happinessScore != null
                ? '${c.happinessScore!.toStringAsFixed(2)}/10'
                : 'N/A',
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String label, String Function(Country) getValue) {
    return DataRow(
      color: MaterialStateProperty.all(bgColor.withOpacity(0.5)),
      cells: [
        DataCell(
          Container(
            width: labelColumnWidth,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                color: hintColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        ...validCountries.map((country) => DataCell(
              Container(
                width: countryColumnWidth,
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  getValue(country),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildComparisonChart() {
    if (validCountries.length < 2) {
      return Center(
        child: Text(
          'Minimal 2 negara untuk membuat grafik',
          style: TextStyle(color: hintColor),
        ),
      );
    }

    return Column(
      children: [
        _buildBarChart(
          title: 'Perbandingan Populasi',
          getData: (c) => c.population.toDouble(),
          yAxisFormatter: (value) => value >= 1000000
              ? '${(value / 1000000).toStringAsFixed(0)}M'
              : '${(value / 1000).toStringAsFixed(0)}K',
        ),
        SizedBox(height: 24),
        _buildBarChart(
          title: 'Perbandingan Luas (km²)',
          getData: (c) => c.area,
          yAxisFormatter: (value) => value >= 1000000
              ? '${(value / 1000000).toStringAsFixed(1)}M'
              : '${(value / 1000).toStringAsFixed(0)}K',
        ),
        SizedBox(height: 24),
        _buildBarChart(
          title: 'Perbandingan GDP per Kapita (USD)',
          getData: (c) => c.gdpPerCapita ?? 0,
          yAxisFormatter: (value) => value >= 1000
              ? '${(value / 1000).toStringAsFixed(0)}K'
              : '${value.toStringAsFixed(0)}',
        ),
        SizedBox(height: 24),
        _buildBarChart(
          title: 'Perbandingan Skor Kebahagiaan',
          getData: (c) => c.happinessScore ?? 0,
          yAxisFormatter: (value) => value.toStringAsFixed(1),
        ),
      ],
    );
  }

  Widget _buildBarChart({
    required String title,
    required double Function(Country) getData,
    required String Function(double) yAxisFormatter,
  }) {
    // Warna standar Chart (Biru, Oranye, Hijau)
    final List<Color> barColors = [
      Color(0xFF4299E1),
      Color(0xFFED8936),
      Color(0xFF48BB78),
    ];

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < validCountries.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: getData(validCountries[i]),
              color: barColors[i % barColors.length],
              width: 40,
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    double calculatedMaxY =
        validCountries.map((c) => getData(c)).reduce((a, b) => a > b ? a : b);
    double effectiveMaxY = calculatedMaxY == 0 ? 1.0 : calculatedMaxY;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF66B3FF),
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: effectiveMaxY * 1.1,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${validCountries[groupIndex].name}\n',
                        TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: formatNumber(rod.toY),
                            style: TextStyle(
                              color: rod.color,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < validCountries.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              validCountries[index].name.length > 10
                                  ? '${validCountries[index].name.substring(0, 10)}...'
                                  : validCountries[index].name,
                              style: TextStyle(
                                color: hintColor,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          yAxisFormatter(value),
                          style: TextStyle(
                            color: hintColor,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: effectiveMaxY / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: hintColor.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
