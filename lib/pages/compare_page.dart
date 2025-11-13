// lib/pages/compare_page.dart
import 'package:flutter/material.dart';
import '../models/country.dart';
import '../controllers/compare_controller.dart';
import 'package:intl/intl.dart'; // <-- Pastikan 'intl' ada di pubspec.yaml

class ComparePage extends StatefulWidget {
  ComparePage({Key? key}) : super(key: key);

  @override
  _ComparePageState createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> with CompareController {
  final Color bgColor = Color(0xFF1A202C);
  final Color surfaceColor = Color(0xFF2D3748);
  final Color textColor = Color(0xFFE2E8F0);
  final Color hintColor = Color(0xFFA0AEC0);
  final Color accentColor = Color(0xFF66B3FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Perbandingan Negara', style: TextStyle(color: textColor)),
        backgroundColor: surfaceColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all, color: hintColor),
            onPressed: clearSelection,
            tooltip: 'Bersihkan Pilihan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCountrySelectors(),
            SizedBox(height: 24),
            validCountries.isEmpty
                ? _buildEmptyState()
                : _buildComparisonTable(),
          ],
        ),
      ),
    );
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
              'Gunakan kolom di atas untuk mencari negara yang ingin Anda bandingkan.',
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
              color: accentColor,
            ),
          ),
          SizedBox(height: 16),
          _buildCountrySearchField(0, 'Negara 1'),
          SizedBox(height: 12),
          _buildCountrySearchField(1, 'Negara 2'),
          SizedBox(height: 12),
          _buildCountrySearchField(2, 'Negara 3 (Opsional)'),
        ],
      ),
    );
  }

  Widget _buildCountrySearchField(int index, String label) {
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
                child: CircularProgressIndicator(color: accentColor),
              )
            : IconButton(
                icon: Icon(Icons.search, color: hintColor),
                onPressed: () => searchCountry(index),
              ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: hintColor.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor, width: 2),
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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 32,
        ),
        child: DataTable(
          columnSpacing: 16.0,
          dataRowMinHeight: 48.0,
          dataRowMaxHeight: 64.0,
          headingRowColor: MaterialStateProperty.all(surfaceColor),
          border: TableBorder.all(
            color: hintColor.withOpacity(0.3),
            width: 1,
            borderRadius: BorderRadius.circular(8),
          ),
          columns: [
            DataColumn(
              label: Text(
                'Data',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  fontSize: 16,
                ),
              ),
            ),
            ...validCountries.map((country) => DataColumn(
                  label: Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(country.flagUrl,
                            width: 30, height: 20, fit: BoxFit.cover),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            country.name,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
          rows: [
            _buildDataRow(
                'Ibu Kota', (c) => c.capital.isEmpty ? 'N/A' : c.capital),
            _buildDataRow('Region', (c) => c.region),
            _buildDataRow('Sub-Region', (c) => c.subregion),
            _buildDataRow('Populasi', (c) => formatNumber(c.population)),
            _buildDataRow('Luas (km²)', (c) => formatNumber(c.area)),
            _buildDataRow('Bahasa', (c) => getJoinedString(c.languages)),
            _buildDataRow('Mata Uang',
                (c) => getJoinedString(c.currencies.keys.toList())),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String label, String Function(Country) getValue) {
    return DataRow(
      color: MaterialStateProperty.all(bgColor.withOpacity(0.5)),
      cells: [
        DataCell(Text(
          label,
          style: TextStyle(
            color: hintColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        )),
        ...validCountries.map((country) => DataCell(
              Text(
                getValue(country),
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                ),
              ),
            )),
      ],
    );
  }
}
