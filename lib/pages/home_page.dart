// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/home_controller.dart';
import '../models/country.dart';
import '../services/news_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with HomeController {
  // Data benua untuk filter horizontal (TANPA "Semua")
  final List<Map<String, String>> _continentsData = [
    {'name': 'Asia', 'key': 'Asia'},
    {'name': 'Afrika', 'key': 'Africa'},
    {'name': 'Eropa', 'key': 'Europe'},
    {'name': 'Amerika Utara', 'key': 'Americas'},
    {'name': 'Amerika Selatan', 'key': 'Americas'},
    {'name': 'Oseania', 'key': 'Oceania'},
  ];

  String? _selectedContinent;

  // DATA STATIC NAMA NEGARA UNTUK COPY-PASTE
  final Map<String, List<String>> _countriesByContinent = {
    'Asia': [
      'Afghanistan',
      'Bahrain',
      'Bangladesh',
      'Bhutan',
      'Brunei',
      'Cambodia',
      'China',
      'Cyprus',
      'Georgia',
      'India',
      'Indonesia',
      'Iran',
      'Iraq',
      'Israel',
      'Japan',
      'Jordan',
      'Kazakhstan',
      'Kuwait',
      'Kyrgyzstan',
      'Laos',
      'Lebanon',
      'Malaysia',
      'Maldives',
      'Mongolia',
      'Myanmar',
      'Nepal',
      'North Korea',
      'Oman',
      'Pakistan',
      'Palestine',
      'Philippines',
      'Qatar',
      'Saudi Arabia',
      'Singapore',
      'South Korea',
      'Sri Lanka',
      'Syria',
      'Tajikistan',
      'Thailand',
      'Timor-Leste',
      'Turkey',
      'Turkmenistan',
      'United Arab Emirates',
      'Uzbekistan',
      'Vietnam',
      'Yemen',
    ],
    'Africa': [
      'Algeria',
      'Angola',
      'Benin',
      'Botswana',
      'Burkina Faso',
      'Burundi',
      'Cabo Verde',
      'Cameroon',
      'Central African Republic',
      'Chad',
      'Comoros',
      'Congo',
      'Djibouti',
      'Egypt',
      'Equatorial Guinea',
      'Eritrea',
      'Eswatini',
      'Ethiopia',
      'Gabon',
      'Gambia',
      'Ghana',
      'Guinea',
      'Guinea-Bissau',
      'Kenya',
      'Lesotho',
      'Liberia',
      'Libya',
      'Madagascar',
      'Malawi',
      'Mali',
      'Mauritania',
      'Mauritius',
      'Morocco',
      'Mozambique',
      'Namibia',
      'Niger',
      'Nigeria',
      'Rwanda',
      'Sao Tome and Principe',
      'Senegal',
      'Seychelles',
      'Sierra Leone',
      'Somalia',
      'South Africa',
      'South Sudan',
      'Sudan',
      'Tanzania',
      'Togo',
      'Tunisia',
      'Uganda',
      'Zambia',
      'Zimbabwe',
    ],
    'Europe': [
      'Albania',
      'Andorra',
      'Armenia',
      'Austria',
      'Azerbaijan',
      'Belarus',
      'Belgium',
      'Bosnia and Herzegovina',
      'Bulgaria',
      'Croatia',
      'Czechia',
      'Denmark',
      'Estonia',
      'Finland',
      'France',
      'Germany',
      'Greece',
      'Hungary',
      'Iceland',
      'Ireland',
      'Italy',
      'Kosovo',
      'Latvia',
      'Liechtenstein',
      'Lithuania',
      'Luxembourg',
      'Malta',
      'Moldova',
      'Monaco',
      'Montenegro',
      'Netherlands',
      'North Macedonia',
      'Norway',
      'Poland',
      'Portugal',
      'Romania',
      'Russia',
      'San Marino',
      'Serbia',
      'Slovakia',
      'Slovenia',
      'Spain',
      'Sweden',
      'Switzerland',
      'Ukraine',
      'United Kingdom',
      'Vatican City',
    ],
    'Americas': [
      'Antigua and Barbuda',
      'Argentina',
      'Bahamas',
      'Barbados',
      'Belize',
      'Bolivia',
      'Brazil',
      'Canada',
      'Chile',
      'Colombia',
      'Costa Rica',
      'Cuba',
      'Dominica',
      'Dominican Republic',
      'Ecuador',
      'El Salvador',
      'Grenada',
      'Guatemala',
      'Guyana',
      'Haiti',
      'Honduras',
      'Jamaica',
      'Mexico',
      'Nicaragua',
      'Panama',
      'Paraguay',
      'Peru',
      'Saint Kitts and Nevis',
      'Saint Lucia',
      'Saint Vincent and the Grenadines',
      'Suriname',
      'Trinidad and Tobago',
      'United States',
      'Uruguay',
      'Venezuela',
    ],
    'Oceania': [
      'Australia',
      'Fiji',
      'Kiribati',
      'Marshall Islands',
      'Micronesia',
      'Nauru',
      'New Zealand',
      'Palau',
      'Papua New Guinea',
      'Samoa',
      'Solomon Islands',
      'Tonga',
      'Tuvalu',
      'Vanuatu',
    ],
  };

  // State untuk berita
  List<dynamic> _newsArticles = [];
  bool _isLoadingNews = false;
  String _newsError = '';

  @override
  void initState() {
    super.initState();
    onInit();
    _loadNews();
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  // Load berita global
  Future<void> _loadNews() async {
    setState(() {
      _isLoadingNews = true;
      _newsError = '';
    });

    try {
      final result = await NewsService.getGlobalNews(pageSize: 5);

      if (mounted) {
        setState(() {
          if (result['success']) {
            _newsArticles = result['articles'];
          } else {
            _newsError = result['error'] ?? 'Failed to load news';
          }
          _isLoadingNews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _newsError = 'Connection error';
          _isLoadingNews = false;
        });
      }
    }
  }

  @override
  void resetFilter() {
    setState(() {
      searchController.clear();
      _selectedContinent = null;
      filteredCountries.clear();
      isLoading = false;
    });
  }

  // Copy nama negara dan tutup dialog
  void _copyCountryName(String name, BuildContext dialogContext) {
    Clipboard.setData(ClipboardData(text: name));
    Navigator.of(dialogContext).pop(); // Tutup dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ "$name" disalin! Paste di Search Bar ⬆️'),
        backgroundColor: Color(0xFF4299E1),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 70, left: 16, right: 16),
      ),
    );
  }

  // Tampilkan dialog daftar negara
  void _showCountryCopyDialog(String continentKey) {
    final List<String> namesList = _countriesByContinent[continentKey] ?? [];

    ValueNotifier<List<String>> filteredListNotifier = ValueNotifier(namesList);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Color(0xFF2D3748),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Copy Nama Negara',
            style: TextStyle(color: Color(0xFF66B3FF), fontSize: 18),
          ),
          content: Container(
            width: 300,
            height: 400,
            child: Column(
              children: [
                TextField(
                  onChanged: (query) {
                    if (query.isEmpty) {
                      filteredListNotifier.value = namesList;
                    } else {
                      filteredListNotifier.value = namesList
                          .where((name) =>
                              name.toLowerCase().contains(query.toLowerCase()))
                          .toList();
                    }
                  },
                  style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Filter...',
                    hintStyle:
                        TextStyle(color: Color(0xFFA0AEC0).withOpacity(0.7)),
                    prefixIcon: Icon(Icons.filter_list,
                        color: Color(0xFF66B3FF), size: 18),
                    filled: true,
                    fillColor: Color(0xFF1A202C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: ValueListenableBuilder<List<String>>(
                    valueListenable: filteredListNotifier,
                    builder: (context, filteredList, child) {
                      if (filteredList.isEmpty) {
                        return Center(
                          child: Text('Tidak ditemukan',
                              style: TextStyle(color: Color(0xFFA0AEC0))),
                        );
                      }
                      return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final countryName = filteredList[index];
                          return InkWell(
                            onTap: () =>
                                _copyCountryName(countryName, dialogContext),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              margin: EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFF1A202C),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                countryName,
                                style: TextStyle(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('TUTUP', style: TextStyle(color: Color(0xFFA0AEC0))),
            ),
          ],
        );
      },
    );
  }

  // Launch URL berita
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
              icon: Icon(Icons.my_location), label: 'Lokasi'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // === HEADER (FIXED) ===
            Padding(
              padding: EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.settings,
                        color: Color(0xFFA0AEC0), size: 22),
                    onPressed: openSettings,
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                  Row(
                    children: [
                      Image.asset('assets/Logoprojek.png',
                          height: 22, width: 22, color: Color(0xFFE2E8F0)),
                      SizedBox(width: 8),
                      Text('ExploreUnity',
                          style: TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.compare_arrows,
                            color: Color(0xFF66B3FF), size: 22),
                        onPressed: openComparePage,
                        padding: EdgeInsets.all(8),
                        constraints: BoxConstraints(),
                        tooltip: 'Bandingkan Negara',
                      ),
                      IconButton(
                        icon: Icon(Icons.logout,
                            color: Color(0xFFA0AEC0), size: 22),
                        onPressed: logout,
                        padding: EdgeInsets.all(8),
                        constraints: BoxConstraints(),
                      ),
                    ],
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
                      color: Color(0xFFA0AEC0).withOpacity(0.7), fontSize: 14),
                  prefixIcon:
                      Icon(Icons.search, color: Color(0xFF66B3FF), size: 20),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear,
                              color: Color(0xFFA0AEC0), size: 20),
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
                onSubmitted: (value) => searchCountriesByName(value),
              ),
            ),

            // === FILTER BENUA HORIZONTAL (TANPA EMOJI, TANPA "SEMUA") ===
            Container(
              height: 45,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12),
                itemCount: _continentsData.length,
                itemBuilder: (context, index) {
                  final continent = _continentsData[index];
                  final isSelected = _selectedContinent == continent['key'];

                  return GestureDetector(
                    onTap: () => _showCountryCopyDialog(continent['key']!),
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Color(0xFF2D3748),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Color(0xFF4299E1).withOpacity(0.3),
                            width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Text(
                            continent['name']!,
                            style: TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.content_copy,
                              color: Color(0xFF66B3FF), size: 14),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // === SCROLLABLE CONTENT ===
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // --- LOADING STATE ---
                  if (isLoading)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                                color: Color(0xFF4299E1), strokeWidth: 3),
                            SizedBox(height: 16),
                            Text('Mencari...',
                                style: TextStyle(
                                    color: Color(0xFFE2E8F0), fontSize: 14)),
                          ],
                        ),
                      ),
                    )
                  // --- STATE 1: ADA HASIL PENCARIAN ---
                  else if (filteredCountries.isNotEmpty &&
                      searchController.text.isNotEmpty) ...[
                    _buildResultHeader(
                        '${filteredCountries.length} hasil ditemukan'),
                    _buildCountrySliverList(),
                  ]
                  // --- STATE 2: TIDAK ADA HASIL ---
                  else if (searchController.text.isNotEmpty &&
                      filteredCountries.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              color: Color(0xFFA0AEC0), size: 60),
                          SizedBox(height: 16),
                          Text('Tidak ada hasil',
                              style: TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text(
                              'Tidak ada negara ditemukan untuk "${searchController.text}"',
                              style: TextStyle(
                                  color: Color(0xFFA0AEC0), fontSize: 13),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  // --- STATE 3: HALAMAN AWAL (BERITA + INFO) ---
                  else ...[
                    // === BERITA SECTION ===
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: Row(
                              children: [
                                Icon(Icons.newspaper,
                                    color: Color(0xFF66B3FF), size: 20),
                                SizedBox(width: 8),
                                Text('Global News',
                                    style: TextStyle(
                                        color: Color(0xFFE2E8F0),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          _buildNewsSection(),
                          SizedBox(height: 24),
                          // INFO: Cara Menggunakan
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF2D3748),
                                    Color(0xFF4A5568)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Color(0xFF4299E1).withOpacity(0.3),
                                    width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: Color(0xFF66B3FF), size: 20),
                                      SizedBox(width: 8),
                                      Text('Cara Cepat Mencari Negara',
                                          style: TextStyle(
                                              color: Color(0xFF66B3FF),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  _buildInfoStep('1',
                                      'Klik tombol benua di atas (contoh: Asia)'),
                                  _buildInfoStep(
                                      '2', 'Pilih nama negara dari daftar'),
                                  _buildInfoStep('3',
                                      'Nama otomatis disalin, paste di Search Bar ⬆️'),
                                  _buildInfoStep(
                                      '4', 'Tekan Enter untuk mencari!'),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === WIDGET HELPER ===
  Widget _buildInfoStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Color(0xFF4299E1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: Color(0xFFE2E8F0), fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    if (_isLoadingNews) {
      return Container(
        height: 180,
        child:
            Center(child: CircularProgressIndicator(color: Color(0xFF4299E1))),
      );
    }

    if (_newsError.isNotEmpty) {
      return Container(
        height: 120,
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.orange, size: 32),
              SizedBox(height: 8),
              Text('Gagal memuat berita',
                  style: TextStyle(color: Color(0xFFA0AEC0))),
              SizedBox(height: 8),
              TextButton(
                onPressed: _loadNews,
                child: Text('Coba Lagi',
                    style: TextStyle(color: Color(0xFF66B3FF))),
              ),
            ],
          ),
        ),
      );
    }

    if (_newsArticles.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _newsArticles.length,
        itemBuilder: (context, index) {
          final article = _newsArticles[index];
          return GestureDetector(
            onTap: () => _launchURL(article['url'] ?? ''),
            child: Container(
              width: 280,
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Color(0xFF2D3748),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      article['urlToImage'] ?? '',
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          color: Color(0xFF1A202C),
                          child: Icon(Icons.image_not_supported,
                              color: Color(0xFFA0AEC0)),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article['title'] ?? 'No title',
                            style: TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacer(),
                          Text(
                            NewsService.formatPublishedDate(
                                article['publishedAt']),
                            style: TextStyle(
                                color: Color(0xFFA0AEC0), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 6),
        child: Text(title,
            style: TextStyle(
                color: Color(0xFFA0AEC0),
                fontSize: 12,
                fontStyle: FontStyle.italic)),
      ),
    );
  }

  Widget _buildCountrySliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final country = filteredCountries[index];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            color: Color(0xFF2D3748),
            margin: EdgeInsets.only(bottom: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              onTap: () => showCountryDetail(country),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        country.flagUrl,
                        width: 50,
                        height: 35,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 35,
                            color: Color(0xFF2D3748).withOpacity(0.8),
                            child: Icon(Icons.flag,
                                color: Color(0xFFA0AEC0), size: 20),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            country.name,
                            style: TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 3),
                          Text(
                            '🏛️ ${country.capital}',
                            style: TextStyle(
                                color: Color(0xFFA0AEC0), fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '🌏 ${country.region}',
                            style: TextStyle(
                                color: Color(0xFFA0AEC0), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        color: Color(0xFFA0AEC0), size: 14),
                  ],
                ),
              ),
            ),
          ),
        );
      }, childCount: filteredCountries.length),
    );
  }
}
