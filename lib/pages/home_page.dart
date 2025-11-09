// ============================================================================
// FILE: lib/pages/home_page.dart (FIXED OVERFLOW - Background Ikut Scroll)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk Clipboard
import '../controllers/home_controller.dart';

/// Halaman utama aplikasi dengan daftar nama negara yang bisa di-copy
class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with HomeController {
  // Daftar nama negara (A-Z) - Total 195 negara
  final List<String> _allCountryNames = [
    // A
    'Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola',
    'Antigua and Barbuda', 'Argentina', 'Armenia', 'Australia', 'Austria',
    'Azerbaijan',
    // B
    'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados', 'Belarus',
    'Belgium', 'Belize', 'Benin', 'Bhutan', 'Bolivia',
    'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei', 'Bulgaria',
    'Burkina Faso', 'Burundi',
    // C
    'Cabo Verde', 'Cambodia', 'Cameroon', 'Canada', 'Central African Republic',
    'Chad', 'Chile', 'China', 'Colombia', 'Comoros',
    'Congo', 'Costa Rica', 'Croatia', 'Cuba', 'Cyprus',
    'Czechia',
    // D
    'Denmark', 'Djibouti', 'Dominica', 'Dominican Republic',
    // E
    'Ecuador', 'Egypt', 'El Salvador', 'Equatorial Guinea', 'Eritrea',
    'Estonia', 'Eswatini', 'Ethiopia',
    // F
    'Fiji', 'Finland', 'France',
    // G
    'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana',
    'Greece', 'Grenada', 'Guatemala', 'Guinea', 'Guinea-Bissau',
    'Guyana',
    // H
    'Haiti', 'Honduras', 'Hungary',
    // I
    'Iceland', 'India', 'Indonesia', 'Iran', 'Iraq',
    'Ireland', 'Israel', 'Italy',
    // J
    'Jamaica', 'Japan', 'Jordan',
    // K
    'Kazakhstan', 'Kenya', 'Kiribati', 'Kosovo', 'Kuwait',
    'Kyrgyzstan',
    // L
    'Laos', 'Latvia', 'Lebanon', 'Lesotho', 'Liberia',
    'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg',
    // M
    'Madagascar', 'Malawi', 'Malaysia', 'Maldives', 'Mali',
    'Malta', 'Marshall Islands', 'Mauritania', 'Mauritius', 'Mexico',
    'Micronesia', 'Moldova', 'Monaco', 'Mongolia', 'Montenegro',
    'Morocco', 'Mozambique', 'Myanmar',
    // N
    'Namibia', 'Nauru', 'Nepal', 'Netherlands', 'New Zealand',
    'Nicaragua', 'Niger', 'Nigeria', 'North Korea', 'North Macedonia',
    'Norway',
    // O
    'Oman',
    // P
    'Pakistan', 'Palau', 'Palestine', 'Panama', 'Papua New Guinea',
    'Paraguay', 'Peru', 'Philippines', 'Poland', 'Portugal',
    // Q
    'Qatar',
    // R
    'Romania', 'Russia', 'Rwanda',
    // S
    'Saint Kitts and Nevis', 'Saint Lucia', 'Saint Vincent and the Grenadines',
    'Samoa', 'San Marino', 'Sao Tome and Principe', 'Saudi Arabia', 'Senegal',
    'Serbia', 'Seychelles', 'Sierra Leone', 'Singapore', 'Slovakia',
    'Slovenia', 'Solomon Islands', 'Somalia', 'South Africa', 'South Korea',
    'South Sudan', 'Spain', 'Sri Lanka', 'Sudan', 'Suriname',
    'Sweden', 'Switzerland', 'Syria',
    // T
    'Tajikistan', 'Tanzania', 'Thailand', 'Timor-Leste', 'Togo',
    'Tonga', 'Trinidad and Tobago', 'Tunisia', 'Turkey', 'Turkmenistan',
    'Tuvalu',
    // U
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Uruguay', 'Uzbekistan',
    // V
    'Vanuatu', 'Vatican City', 'Venezuela', 'Vietnam',
    // Y
    'Yemen',
    // Z
    'Zambia', 'Zimbabwe',
  ];

  List<String> _filteredCountryNames = [];
  bool _showCountryList = false;

  @override
  void initState() {
    super.initState();
    _filteredCountryNames = List.from(_allCountryNames);
    onInit();
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  void _toggleCountryList() {
    setState(() {
      _showCountryList = !_showCountryList;
    });
  }

  void _filterCountryNames(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountryNames = List.from(_allCountryNames);
      } else {
        _filteredCountryNames = _allCountryNames
            .where((name) => name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ "$text" disalin! Paste di Search Bar ⬆️'),
        backgroundColor: Color(0xFF4299E1),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 70, left: 16, right: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFF1A202C),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF2D3748),
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Color(0xFFA0AEC0),
        selectedItemColor: Color(0xFFA0AEC0),
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.my_location),
            label: 'Lokasi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // === HEADER (FIXED - Tidak Scroll) ===
            Padding(
              padding: EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: Color(0xFFA0AEC0),
                      size: 22,
                    ),
                    onPressed: openSettings,
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/Logoprojek.png',
                        height: 22,
                        width: 22,
                        color: Color(0xFFE2E8F0),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'ExploreUnity',
                        style: TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.logout,
                      color: Color(0xFFA0AEC0),
                      size: 22,
                    ),
                    onPressed: logout,
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),

            // === SEARCH BAR (FIXED) ===
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: searchController,
                style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari negara...',
                  hintStyle: TextStyle(
                    color: Color(0xFFA0AEC0).withOpacity(0.7),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF66B3FF),
                    size: 20,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Color(0xFA0AEC0),
                            size: 20,
                          ),
                          onPressed: resetFilter,
                        )
                      : null,
                  filled: true,
                  fillColor: Color(0xFF2D3748),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF4299E1), width: 2),
                  ),
                ),
                onSubmitted:
                    (allCountries.isEmpty && searchController.text.isNotEmpty)
                    ? (value) => searchCountriesByName(value)
                    : null,
              ),
            ),

            // === SCROLLABLE CONTENT ===
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Button Toggle Daftar Negara
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: ElevatedButton.icon(
                        onPressed: _toggleCountryList,
                        icon: Icon(
                          _showCountryList
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Color(0xFFE2E8F0),
                          size: 20,
                        ),
                        label: Text(
                          _showCountryList
                              ? 'Sembunyikan Daftar'
                              : 'Daftar Negara',
                          style: TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4299E1),
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Daftar Negara (Collapsible)
                  if (_showCountryList)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(16, 0, 16, 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF2D3748),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF66B3FF),
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Ketuk nama untuk copy, paste di Search Bar ⬆️',
                                    style: TextStyle(
                                      color: Color(0xFFA0AEC0),
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            TextField(
                              onChanged: _filterCountryNames,
                              style: TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Filter...',
                                hintStyle: TextStyle(
                                  color: Color(0xFFA0AEC0).withOpacity(0.7),
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  Icons.filter_list,
                                  color: Color(0xFF66B3FF),
                                  size: 18,
                                ),
                                filled: true,
                                fillColor: Color(0xFF1A202C),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 180, // Dikurangi lagi dari 200 ke 180
                              child: ListView.builder(
                                itemCount: _filteredCountryNames.length,
                                itemBuilder: (context, index) {
                                  final countryName =
                                      _filteredCountryNames[index];
                                  return InkWell(
                                    onTap: () => _copyToClipboard(countryName),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 10,
                                      ),
                                      margin: EdgeInsets.only(bottom: 4),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1A202C),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.flag,
                                            color: Color(0xFF66B3FF),
                                            size: 16,
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              countryName,
                                              style: TextStyle(
                                                color: Color(0xFFE2E8F0),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.copy,
                                            color: Color(0xFFA0AEC0),
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${_filteredCountryNames.length} negara',
                              style: TextStyle(
                                color: Color(0xFFA0AEC0),
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Filter Abjad
                  if (!isLoading && allCountries.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        height: 42,
                        margin: EdgeInsets.only(bottom: 6),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: 26,
                          itemBuilder: (context, index) {
                            final letter = String.fromCharCode(65 + index);
                            final hasCountries = allCountries.any(
                              (c) => c.name.toUpperCase().startsWith(letter),
                            );

                            return Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text(
                                  letter,
                                  style: TextStyle(
                                    color: hasCountries
                                        ? Color(0xFFE2E8F0)
                                        : Color(0xFFA0AEC0).withOpacity(0.3),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                onSelected: hasCountries
                                    ? (_) => filterByAlphabet(letter)
                                    : null,
                                backgroundColor: Color(
                                  0xFF2D3748,
                                ).withOpacity(0.5),
                                selectedColor: Color(0xFF4299E1),
                                disabledColor: Color(
                                  0xFF2D3748,
                                ).withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Info Jumlah Hasil
                  if (!isLoading && filteredCountries.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              allCountries.isNotEmpty
                                  ? '${filteredCountries.length} dari ${allCountries.length} negara'
                                  : '${filteredCountries.length} hasil',
                              style: TextStyle(
                                color: Color(0xFFA0AEC0),
                                fontSize: 11,
                              ),
                            ),
                            if (filteredCountries.length !=
                                    allCountries.length &&
                                allCountries.isNotEmpty)
                              TextButton(
                                onPressed: resetFilter,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Reset',
                                  style: TextStyle(
                                    color: Color(0xFF66B3FF),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  // === LOADING STATE ===
                  if (isLoading)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFF4299E1),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              allCountries.isEmpty ? 'Memuat...' : 'Mencari...',
                              style: TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  // === EMPTY STATE (BACKGROUND LOGO IKUT SCROLL) ===
                  else if (filteredCountries.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo dan Teks (Ikut di-scroll, tidak fixed)
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2D3748).withOpacity(0.3),
                            ),
                            child: Image.asset(
                              'assets/Logoprojek.png',
                              height: 80,
                              width: 80,
                              color: Color(0xFF66B3FF).withOpacity(0.6),
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Jelajahi Dunia',
                            style: TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              allCountries.isEmpty
                                  ? 'Gunakan daftar negara atau ketik di search'
                                  : 'Tidak ada hasil untuk "${searchController.text}"',
                              style: TextStyle(
                                color: Color(0xFFA0AEC0),
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    )
                  // === LIST NEGARA ===
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final country = filteredCountries[index];
                        bool showHeader = false;

                        if (allCountries.isNotEmpty && index == 0) {
                          showHeader = true;
                        } else if (allCountries.isNotEmpty && index > 0) {
                          final currentLetter = country.name[0].toUpperCase();
                          final prevLetter = filteredCountries[index - 1]
                              .name[0]
                              .toUpperCase();
                          showHeader = currentLetter != prevLetter;
                        }

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showHeader)
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 12,
                                    bottom: 6,
                                    left: 4,
                                  ),
                                  child: Text(
                                    country.name[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF66B3FF),
                                    ),
                                  ),
                                ),
                              Card(
                                color: Color(0xFF2D3748),
                                margin: EdgeInsets.only(bottom: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: InkWell(
                                  onTap: () => showCountryDetail(country),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Image.network(
                                            country.flagUrl,
                                            width: 50,
                                            height: 35,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 50,
                                                    height: 35,
                                                    color: Color(
                                                      0xFF2D3748,
                                                    ).withOpacity(0.8),
                                                    child: Icon(
                                                      Icons.flag,
                                                      color: Color(0xFFA0AEC0),
                                                      size: 20,
                                                    ),
                                                  );
                                                },
                                            loadingBuilder:
                                                (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Container(
                                                    width: 50,
                                                    height: 35,
                                                    color: Color(
                                                      0xFF2D3748,
                                                    ).withOpacity(0.8),
                                                    child: Center(
                                                      child: SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Color(
                                                                0xFFA0AEC0,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                country.name,
                                                style: TextStyle(
                                                  color: Color(0xFFE2E8F0),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 3),
                                              Text(
                                                '🏛️ ${country.capital}',
                                                style: TextStyle(
                                                  color: Color(0xFFA0AEC0),
                                                  fontSize: 11,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '🌏 ${country.region}',
                                                style: TextStyle(
                                                  color: Color(0xFFA0AEC0),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Color(0xFFA0AEC0),
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }, childCount: filteredCountries.length),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
