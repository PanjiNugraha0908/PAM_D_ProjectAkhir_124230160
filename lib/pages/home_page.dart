// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import untuk Clipboard
import '../models/country.dart';
import '../controllers/home_controller.dart';
import 'country_detail_page.dart';
import 'profile_page.dart';
import 'location_page.dart';
import 'history_page.dart';
// import 'compare_page.dart'; // Kita tunda dulu compare

class HomePage extends StatefulWidget {
  final String username;
  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeController = HomeController();

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
    _homeController.onInit(
      () => setState(() {}),
      (country) => navigateToDetail(country),
    );
    _homeController.initHistoryAndFavorites(widget.username);
  }

  @override
  void dispose() {
    _homeController.onDispose();
    super.dispose();
  }

  void navigateToDetail(Country country) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CountryDetailPage(country: country),
      ),
    ).then((_) => _homeController.refreshHistoryAndFavorites());
  }

  void navigateToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    ).then((_) => _homeController.refreshHistoryAndFavorites());
  }

  void navigateToLocation() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LocationPage()),
    );
  }

  void navigateToHistory() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(),
      ),
    ).then((_) => _homeController.refreshHistoryAndFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A202C),
      appBar: AppBar(
        // --- TAMBAHKAN LOGO DI SINI ---
        title: Row(
          children: [
            Image.asset(
              'assets/Logoprojek.png', // Pastikan path ini benar
              height: 30, // Sesuaikan tinggi logo
              width: 30, // Sesuaikan lebar logo
              color: Color(0xFFE2E8F0), // Sesuaikan warna jika logo monokrom
            ),
            SizedBox(width: 8), // Sedikit jarak antara logo dan teks
            Text(
              'ExploreUnity',
              style: TextStyle(
                color: Color(0xFFE2E8F0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // --- AKHIR TAMBAH LOGO ---
        backgroundColor: Color(0xFF2D3748),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Color(0xFFE2E8F0)),
            onPressed: navigateToHistory,
            tooltip: 'Riwayat & Favorit',
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Color(0xFFE2E8F0)),
            onPressed: navigateToProfile,
            tooltip: 'Profil Pengguna',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _homeController.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4299E1),
                    ),
                  )
                : _homeController.errorMessage.isNotEmpty
                    ? _buildErrorState()
                    : _homeController.filteredCountries.isNotEmpty
                        ? _buildCountryList()
                        : _buildContinentList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToLocation,
        child: Icon(Icons.my_location, color: Color(0xFFE2E8F0)),
        backgroundColor: Color(0xFF4299E1),
        tooltip: 'Lokasi Saat Ini',
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: TextField(
        controller: _homeController.searchController,
        style: TextStyle(color: Color(0xFFE2E8F0)),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) => _homeController.searchCountries(),
        decoration: InputDecoration(
          hintText: 'Salin nama negara & cari di sini...',
          hintStyle: TextStyle(color: Color(0xFFA0AEC0)),
          prefixIcon: Icon(Icons.search, color: Color(0xFFA0AEC0)),
          filled: true,
          fillColor: Color(0xFF2D3748),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: _homeController.searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Color(0xFFA0AEC0)),
                  onPressed: _homeController.clearSearch,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildContinentList() {
    return ListView.builder(
      itemCount: _continentsData.length,
      itemBuilder: (context, index) {
        final continent = _continentsData[index]['name'];
        final countries = _countriesByName[continent] ?? [];
        return ExpansionTile(
          title: Text(
            continent,
            style: TextStyle(
                color: Color(0xFFE2E8F0),
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          iconColor: Color(0xFF66B3FF),
          collapsedIconColor: Color(0xFFA0AEC0),
          children: countries.map((countryName) {
            return ListTile(
              title: Text(
                countryName,
                style: TextStyle(color: Color(0xFFA0AEC0)),
              ),
              trailing: Icon(Icons.copy, color: Color(0xFF66B3FF), size: 18),
              onTap: () {
                Clipboard.setData(ClipboardData(text: countryName));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"$countryName" disalin ke clipboard.'),
                    backgroundColor: Color(0xFF4299E1),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 60, color: Color(0xFFA0AEC0)),
            SizedBox(height: 16),
            Text(
              'Gagal Memuat Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE2E8F0),
              ),
            ),
            SizedBox(height: 8),
            Text(
              _homeController.errorMessage,
              style: TextStyle(color: Color(0xFFA0AEC0)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh, color: Color(0xFFE2E8F0)),
              label:
                  Text('Coba Lagi', style: TextStyle(color: Color(0xFFE2E8F0))),
              onPressed: _homeController.searchCountries,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4299E1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryList() {
    if (_homeController.filteredCountries.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(12.0),
      itemCount: _homeController.filteredCountries.length,
      itemBuilder: (context, index) {
        final country = _homeController.filteredCountries[index];
        final isFav =
            _homeController.favoriteCountryNames.contains(country.name);
        return _buildCountryCard(country, isFav);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Color(0xFFA0AEC0)),
            SizedBox(height: 16),
            Text(
              'Tidak Ditemukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE2E8F0),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tidak ada negara yang cocok dengan pencarian Anda.',
              style: TextStyle(color: Color(0xFFA0AEC0)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryCard(Country country, bool isFavorite) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 6.0),
      color: Color(0xFF2D3748),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => navigateToDetail(country),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  country.flagUrl,
                  width: 60,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Container(width: 60, height: 40, color: Colors.grey[700]),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE2E8F0),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      country.capital.isEmpty ? 'N/A' : country.capital,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFA0AEC0),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isFavorite)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.redAccent[100],
                    size: 18,
                  ),
                ),
              Icon(
                Icons.chevron_right,
                color: Color(0xFFA0AEC0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
