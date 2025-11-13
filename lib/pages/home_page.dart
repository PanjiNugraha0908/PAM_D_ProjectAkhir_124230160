// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../models/country.dart';
import '../controllers/home_controller.dart';
import 'country_detail_page.dart';
import 'profile_page.dart';
import 'location_page.dart';
import 'history_page.dart';
import 'compare_page.dart'; // Import halaman baru

class HomePage extends StatefulWidget {
  // Hapus parameter 'username'
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with HomeController {
  final _homeController = HomeControllerMixin();

  @override
  void initState() {
    super.initState();
    _homeController.onInit(
      () => setState(() {}),
      (country) => navigateToDetail(country),
    );
    _homeController.initHistoryAndFavorites();
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    ).then((_) => _homeController.refreshHistoryAndFavorites());
  }

  void navigateToLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationPage()),
    );
  }

  void navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(), // Panggil tanpa parameter
      ),
    ).then((_) => _homeController.refreshHistoryAndFavorites());
  }

  void navigateToCompare() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComparePage(), // Panggil tanpa parameter
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A202C),
      appBar: AppBar(
        title: Text(
          'ExploreUnity',
          style: TextStyle(
            color: Color(0xFFE2E8F0),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF2D3748),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.compare_arrows_rounded, color: Color(0xFFE2E8F0)),
            onPressed: navigateToCompare,
            tooltip: 'Bandingkan Negara',
          ),
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
          _buildFilterChips(), // Filter chips sekarang tidak akan berfungsi
          Expanded(
            child: _homeController.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4299E1),
                    ),
                  )
                : _homeController.errorMessage.isNotEmpty
                    ? _buildErrorState()
                    : _homeController.filteredCountries.isEmpty
                        ? _buildInitialState() // Gunakan state awal
                        : _buildCountryList(),
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
        onSubmitted: (value) =>
            _homeController.searchCountries(), // Panggil search
        decoration: InputDecoration(
          hintText: 'Cari negara...',
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

  Widget _buildFilterChips() {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Asia', 'Asia'),
          _buildFilterChip('Europe', 'Europe'),
          _buildFilterChip('Africa', 'Africa'),
          _buildFilterChip('Americas', 'Americas'),
          _buildFilterChip('Oceania', 'Oceania'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? region) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        labelStyle: TextStyle(
          color: Color(0xFFA0AEC0).withOpacity(0.5),
        ),
        selected: false,
        onSelected: (bool selected) {
          // Tidak melakukan apa-apa
        },
        backgroundColor: Color(0xFF2D3748).withOpacity(0.5),
        selectedColor: Color(0xFF2D3748),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Color(0xFFA0AEC0).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.travel_explore, size: 60, color: Color(0xFFA0AEC0)),
            SizedBox(height: 16),
            Text(
              'Mulai Menjelajah',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE2E8F0),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ketik nama negara di atas untuk memulai pencarian.',
              style: TextStyle(color: Color(0xFFA0AEC0)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
              onPressed: _homeController.searchCountries, // Coba search lagi
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4299E1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PERBAIKAN: HAPUS _buildEmptyState yang tidak terpakai ---
  // Widget _buildEmptyState() { ... }
  // ---------------------------------------------------------

  Widget _buildCountryList() {
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
