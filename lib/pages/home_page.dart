import 'package:flutter/material.dart';
import '../controllers/home_controller.dart'; // Import controller

/// Halaman utama aplikasi (Tampilan/View).
///
/// File ini sekarang hanya bertanggung jawab untuk me-render UI (metode `build`).
/// Semua logika, state, dan fungsi-fungsi di-handle oleh [HomeController]
/// yang di-mixin ke dalam `_HomePageState`.
class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with HomeController {
  // --- Lifecycle Methods ---
  // Kita panggil fungsi onInit dan onDispose dari Controller
  @override
  void initState() {
    super.initState();
    onInit(); // Panggil onInit dari mixin
  }

  @override
  void dispose() {
    onDispose(); // Panggil onDispose dari mixin
    super.dispose();
  }

  // --- Build Method (Tampilan/Style) ---
  // File ini sekarang hanya berisi kode untuk tampilan.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFF1A202C), // backgroundColor
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF2D3748), // surfaceColor
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Color(0xFFA0AEC0), // hintColor
        selectedItemColor: Color(0xFFA0AEC0), // hintColor
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: onItemTapped, // Panggil fungsi dari controller
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
            // --- 1. Header ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: Color(0xFFA0AEC0),
                    ), // hintColor
                    onPressed: openSettings, // Panggil fungsi dari controller
                    tooltip: 'Pengaturan',
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/Logoprojek.png',
                        height: 24,
                        width: 24,
                        color: Color(0xFFE2E8F0), // textColor
                      ),
                      SizedBox(width: 8),
                      Text(
                        'ExploreUnity',
                        style: TextStyle(
                          color: Color(0xFFE2E8F0), // textColor
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.logout,
                      color: Color(0xFFA0AEC0),
                    ), // hintColor
                    onPressed: logout, // Panggil fungsi dari controller
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),

            // --- 2. Search Bar ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: searchController, // Gunakan controller
                style: TextStyle(color: Color(0xFFE2E8F0)), // textColor
                decoration: InputDecoration(
                  hintText: 'Cari negara...',
                  hintStyle: TextStyle(
                    color: Color(0xFFA0AEC0).withOpacity(0.7),
                  ), // hintColor
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF66B3FF),
                  ), // accentColor
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Color(0xFFA0AEC0),
                          ), // hintColor
                          onPressed:
                              resetFilter, // Panggil fungsi dari controller
                        )
                      : null,
                  filled: true,
                  fillColor: Color(0xFF2D3748), // surfaceColor
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Color(0xFF4299E1), // primaryButtonColor
                      width: 2,
                    ),
                  ),
                ),
                onSubmitted:
                    (allCountries.isEmpty && searchController.text.isNotEmpty)
                    ? (value) => searchCountriesByName(value)
                    : null,
              ),
            ),
            SizedBox(height: 8),

            // --- 3. Filter Abjad ---
            if (!isLoading && allCountries.isNotEmpty)
              Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: 26,
                  itemBuilder: (context, index) {
                    final letter = String.fromCharCode(65 + index);
                    final hasCountries = allCountries.any(
                      (c) => c.name.toUpperCase().startsWith(letter),
                    );

                    return Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(
                          letter,
                          style: TextStyle(
                            color: hasCountries
                                ? Color(0xFFE2E8F0) // textColor
                                : Color(
                                    0xFFA0AEC0,
                                  ).withOpacity(0.3), // hintColor
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onSelected: hasCountries
                            ? (_) =>
                                  filterByAlphabet(letter) // Panggil controller
                            : null,
                        backgroundColor: Color(
                          0xFF2D3748,
                        ).withOpacity(0.5), // surfaceColor
                        selectedColor: Color(0xFF4299E1), // primaryButtonColor
                        disabledColor: Color(
                          0xFF2D3748,
                        ).withOpacity(0.1), // surfaceColor
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 8),

            // --- 4. Info Jumlah Hasil ---
            if (!isLoading && filteredCountries.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      allCountries.isNotEmpty
                          ? 'Menampilkan ${filteredCountries.length} dari ${allCountries.length} negara'
                          : '${filteredCountries.length} hasil',
                      style: TextStyle(
                        color: Color(0xFFA0AEC0),
                        fontSize: 12,
                      ), // hintColor
                    ),
                    if (filteredCountries.length != allCountries.length &&
                        allCountries.isNotEmpty)
                      TextButton(
                        onPressed: resetFilter, // Panggil controller
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size(0, 30),
                        ),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: Color(0xFF66B3FF),
                            fontSize: 12,
                          ), // accentColor
                        ),
                      ),
                  ],
                ),
              ),

            // --- 5. Daftar Negara (atau Loading / Empty State) ---
            if (isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF4299E1), // primaryButtonColor
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 24),
                      Text(
                        allCountries.isEmpty
                            ? 'Memuat data negara...'
                            : 'Mencari...',
                        style: TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 16,
                        ), // textColor
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Mohon tunggu sebentar',
                        style: TextStyle(
                          color: Color(0xFFA0AEC0),
                          fontSize: 12,
                        ), // hintColor
                      ),
                    ],
                  ),
                ),
              )
            else if (filteredCountries.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2D3748), // surfaceColor
                          ),
                          child: Image.asset(
                            'assets/Logoprojek.png',
                            height: 80,
                            width: 80,
                            color: Color(
                              0xFF66B3FF,
                            ).withOpacity(0.8), // accentColor
                          ),
                        ),
                        SizedBox(height: 32),
                        Text(
                          allCountries.isEmpty
                              ? 'Jelajahi Dunia'
                              : 'Tidak Ada Hasil',
                          style: TextStyle(
                            color: Color(0xFFE2E8F0), // textColor
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          allCountries.isEmpty
                              ? 'Cari negara yang ingin kamu ketahui'
                              : 'untuk "${searchController.text}"',
                          style: TextStyle(
                            color: Color(0xFFA0AEC0),
                            fontSize: 14,
                          ), // hintColor
                          textAlign: TextAlign.center,
                        ),
                        if (allCountries.isEmpty) ...[
                          SizedBox(height: 32),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(
                                0xFF2D3748,
                              ).withOpacity(0.5), // surfaceColor
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(
                                  0xFF66B3FF,
                                ).withOpacity(0.3), // accentColor
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xFFA0AEC0), // hintColor
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Ketik di search bar dan tekan Enter',
                                    style: TextStyle(
                                      color: Color(0xFFA0AEC0), // hintColor
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = filteredCountries[index];
                    bool showHeader = false;
                    if (allCountries.isNotEmpty && index == 0) {
                      showHeader = true;
                    } else if (allCountries.isNotEmpty && index > 0) {
                      final currentLetter = country.name[0].toUpperCase();
                      final prevLetter = filteredCountries[index - 1].name[0]
                          .toUpperCase();
                      showHeader = currentLetter != prevLetter;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader)
                          Padding(
                            padding: EdgeInsets.only(
                              top: 16,
                              bottom: 8,
                              left: 4,
                            ),
                            child: Text(
                              country.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF66B3FF), // accentColor
                              ),
                            ),
                          ),
                        // Card untuk setiap negara
                        Card(
                          color: Color(0xFF2D3748), // surfaceColor
                          margin: EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => showCountryDetail(
                              country,
                            ), // Panggil controller
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      country.flagUrl,
                                      width: 60,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 60,
                                              height: 40,
                                              color: Color(0xFF2D3748)
                                                  .withOpacity(
                                                    0.8,
                                                  ), // surfaceColor
                                              child: Icon(
                                                Icons.flag,
                                                color: Color(
                                                  0xFFA0AEC0,
                                                ), // hintColor
                                                size: 24,
                                              ),
                                            );
                                          },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              width: 60,
                                              height: 40,
                                              color: Color(0xFF2D3748)
                                                  .withOpacity(
                                                    0.8,
                                                  ), // surfaceColor
                                              child: Center(
                                                child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Color(
                                                          0xFFA0AEC0,
                                                        ), // hintColor
                                                      ),
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          country.name,
                                          style: TextStyle(
                                            color: Color(
                                              0xFFE2E8F0,
                                            ), // textColor
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '🏛️ ${country.capital}',
                                          style: TextStyle(
                                            color: Color(
                                              0xFFA0AEC0,
                                            ), // hintColor
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '🌏 ${country.region}',
                                          style: TextStyle(
                                            color: Color(
                                              0xFFA0AEC0,
                                            ), // hintColor
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Color(0xFFA0AEC0), // hintColor
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
