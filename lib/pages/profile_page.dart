import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'edit_profile_page.dart';
import 'history_page.dart';
import 'location_page.dart';
import 'login_page.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    String? username = AuthService.getCurrentUsername();
    if (username != null) {
      User? user = await DatabaseService.getUser(username);
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    } else {
      _logout();
    }
  }

  Future<void> _editProfile() async {
    if (_user == null) return;

    final bool? profileWasUpdated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage(user: _user!)),
    );

    if (profileWasUpdated == true) {
      _loadUserProfile();
    }
  }

  // --- Navigasi ---
  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  void _openHome() {
    String? username = AuthService.getCurrentUsername();
    if (username != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(username: username)),
      );
    } else {
      _logout();
    }
  }

  void _openHistory() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  void _openLocation() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LocationPage()),
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        _openLocation();
        break;
      case 2:
        _openHistory();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A202C),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFE2E8F0)),
          onPressed: _openHome,
        ),
        title: Text('Profil Saya', style: TextStyle(color: Color(0xFFE2E8F0))),
        backgroundColor: Color(0xFF1A202C),
        iconTheme: IconThemeData(color: Color(0xFFE2E8F0)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Color(0xFF66B3FF)),
            onPressed: _editProfile,
            tooltip: 'Edit Profil',
          ),
        ],
      ),
      body: _user == null
          ? Center(child: CircularProgressIndicator(color: Color(0xFF4299E1)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF2D3748),
                    // --- PERBAIKAN DISINI ---
                    backgroundImage: _user!.profilePicturePath != null
                        ? FileImage(File(_user!.profilePicturePath!))
                        : null,
                    child: _user!.profilePicturePath == null
                        // --- AKHIR PERBAIKAN ---
                        ? Icon(Icons.person, size: 60, color: Color(0xFFA0AEC0))
                        : null,
                  ),
                  SizedBox(height: 16),
                  Text(
                    // --- PERBAIKAN DISINI ---
                    _user!.fullName,
                    // --- AKHIR PERBAIKAN ---
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                  Text(
                    '@${_user!.username}',
                    style: TextStyle(fontSize: 16, color: Color(0xFFA0AEC0)),
                  ),
                  SizedBox(height: 32),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF2D3748),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: _user!.email,
                        ),
                        Divider(color: Color(0xFFA0AEC0).withOpacity(0.3)),
                        // --- TAMBAHKAN INI ---
                        _buildInfoRow(
                          icon: Icons.phone_outlined,
                          label: 'No. HP',
                          value: _user!.noHp,
                        ),
                        Divider(color: Color(0xFFA0AEC0).withOpacity(0.3)),
                        // --- AKHIR TAMBAHAN ---
                        _buildInfoRow(
                          icon: Icons.history,
                          label: 'Negara Dilihat',
                          value: DatabaseService.getHistoryForUser(
                            _user!.username,
                          ).map((h) => h.countryName).toSet().length.toString(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF2D3748),
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Color(0xFFA0AEC0),
        selectedItemColor: Color(0xFF66B3FF),
        currentIndex: 0,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.my_location),
            label: 'Lokasi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF66B3FF), size: 20),
          SizedBox(width: 16),
          Text(label, style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 14)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
