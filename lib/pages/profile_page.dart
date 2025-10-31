import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil Pembuat')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 32),
            // Foto profil
            CircleAvatar(
              radius: 80,
              // Ganti dengan foto Anda
              backgroundImage: NetworkImage('URL_FOTO_ANDA'),
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 80, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            // Nama
            Text(
              'Nama Anda',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // NIM
            Text(
              'NIM: 123456789',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 32),
            // Informasi tambahan
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(
                    'Program Studi',
                    'Program Studi Anda',
                    Icons.school,
                  ),
                  _buildInfoSection(
                    'Fakultas',
                    'Fakultas Anda',
                    Icons.business,
                  ),
                  _buildInfoSection(
                    'Universitas',
                    'Universitas Anda',
                    Icons.account_balance,
                  ),
                  SizedBox(height: 24),
                  _buildInfoSection('Email', 'email@example.com', Icons.email),
                  _buildInfoSection(
                    'GitHub',
                    'github.com/username',
                    Icons.code,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
