import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import '../controllers/home_controller.dart';
import '../models/country.dart'; 

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with HomeController {

  final List<Map<String, dynamic>> _continentsData = [
    {'name': 'Asia'},
    {'name': 'Afrika'},
    {'name': 'Eropa'},
    {'name': 'Amerika Utara'},
    {'name': 'Amerika Selatan'},
    {'name': 'Australia/Oseania'},
  ];

  final Map<String, List<String>> _countriesByName = {
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
    'Afrika': [
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
    'Eropa': [
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
    'Amerika Utara': [
      'Antigua and Barbuda',
      'Bahamas',
      'Barbados',
      'Belize',
      'Canada',
      'Costa Rica',
      'Cuba',
      'Dominica',
      'Dominican Republic',
      'El Salvador',
      'Grenada',
      'Guatemala',
      'Haiti',
      'Honduras',
      'Jamaica',
      'Mexico',
      'Nicaragua',
      'Panama',
      'Saint Kitts and Nevis',
      'Saint Lucia',
      'Saint Vincent and the Grenadines',
      'Trinidad and Tobago',
      'United States',
    ],
    'Amerika Selatan': [
      'Argentina',
      'Bolivia',
      'Brazil',
      'Chile',
      'Colombia',
      'Ecuador',
      'Guyana',
      'Paraguay',
      'Peru',
      'Suriname',
      'Uruguay',
      'Venezuela',
    ],
    'Australia/Oseania': [
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

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller (dari HomeController)
    onInit();
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  // --- OVERRIDE: Ubah fungsi tombol clear di search bar ---
  @override
  void resetFilter() {
    setState(() {
      searchController.clear();
      filteredCountries.clear();
      isLoading = false;
    });
  }

  // --- FUNGSI BARU: Untuk menyalin teks ---
  void _copyToClipboard(String text, BuildContext dialogContext) {
    Clipboard.setData(ClipboardData(text: text));
    Navigator.of(dialogContext).pop(); // Tutup dialog
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

  // --- FUNGSI BARU: Untuk menampilkan Pop-up Copy ---
  void _showCountryCopyDialog(String continentName) {
    final List<String> namesList = _countriesByName[continentName] ?? [];

    ValueNotifier<List<String>> filteredListNotifier = ValueNotifier(namesList);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Color(0xFF2D3748),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Copy Nama Negara ($continentName)',
            style: TextStyle(color: Color(0xFF66B3FF), fontSize: 18),
          ),
          content: Container(
            width: 300, // Lebar dialog
            height: 400, // Tinggi dialog
            child: Column(
              children: [
                TextField(
                  onChanged: (query) {
                    if (query.isEmpty) {
                      filteredListNotifier.value = namesList;
                    } else {
                      filteredListNotifier.value = namesList
                          .where(
                            (name) => name.toLowerCase().contains(
                              query.toLowerCase(),
                            ),
                          )
                          .toList();
                    }
                  },
                  style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Filter...',
                    hintStyle: TextStyle(
                      color: Color(0xFFA0AEC0).withOpacity(0.7),
                    ),
                    prefixIcon: Icon(
                      Icons.filter_list,
                      color: Color(0xFF66B3FF),
                      size: 18,
                    ),
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
                          child: Text(
                            'Tidak ditemukan',
                            style: TextStyle(color: Color(0xFFA0AEC0)),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final countryName = filteredList[index];
                          return InkWell(
                            onTap: () =>
                                _copyToClipboard(countryName, dialogContext),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFF1A202C),
      bottomNavigationBar: BottomNavigationBar(
        // ... (BottomNavBar tidak berubah) ...
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
                            color: Color(0xFFA0AEC0),
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
                onSubmitted: (value) => searchCountriesByName(value),
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
                              color: Color(0xFF4299E1),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Mencari...',
                              style: TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  // --- STATE 1: HASIL PENCARIAN (Ada hasil) ---
                  else if (filteredCountries.isNotEmpty) ...[
                    _buildResultHeader(
                      '${filteredCountries.length} hasil ditemukan',
                    ),
                    _buildCountrySliverList(), // Tampilkan list negara
                  ]
                  // --- STATE 2: TIDAK ADA HASIL (Setelah mencari) ---
                  else if (searchController.text.isNotEmpty &&
                      filteredCountries.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            color: Color(0xFFA0AEC0),
                            size: 60,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada hasil',
                            style: TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tidak ada negara ditemukan untuk "${searchController.text}"',
                            style: TextStyle(
                              color: Color(0xFFA0AEC0),
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  // --- STATE 3: HALAMAN AWAL (Kosong, tampilkan card benua) ---
                  else ...[
                    // Judul "Copy Nama Negara..." SUDAH DIHAPUS
                    // SliverToBoxAdapter( ... ) <-- BLOK INI HILANG

                    // Card Benua Geser VERTIKAL (Teks Saja)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                        ), // Beri sedikit jarak
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final continent = _continentsData[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: _buildContinentCard(
                            name: continent['name'],
                            // Hapus imagePath dan color
                            onTap: () =>
                                _showCountryCopyDialog(continent['name']),
                          ),
                        );
                      }, childCount: _continentsData.length),
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

  /// PERUBAHAN: Membuat Card Benua (Hanya Teks)
  Widget _buildContinentCard({
    required String name,
    // Hapus 'imagePath' dan 'color'
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        // Hapus 'height' agar ukurannya pas dengan konten
        decoration: BoxDecoration(
          color: Color(0xFF2D3748), // Warna kartu standar
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          // Sesuaikan padding karena tidak ada gambar
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            children: [
              // BLOK Image.asset() SUDAH DIHAPUS
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.8),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membuat Header untuk List Hasil (Search atau Browse)
  Widget _buildResultHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Color(0xFFA0AEC0),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membungkus SliverList agar tidak duplikat kode
  Widget _buildCountrySliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final country = filteredCountries[index];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Negara (tidak berubah)
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
                                child: Icon(
                                  Icons.flag,
                                  color: Color(0xFFA0AEC0),
                                  size: 20,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 50,
                                height: 35,
                                color: Color(0xFF2D3748).withOpacity(0.8),
                                child: Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFA0AEC0),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}
