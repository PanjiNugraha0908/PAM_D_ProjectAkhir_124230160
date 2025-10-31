import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  // ============================================================
  // ISI SARAN DAN KESAN ANDA DI BAWAH INI
  // ============================================================

  // SARAN (Bisa berupa list atau paragraf panjang)
  final List<String> saranList = [
    "Tulis saran pertama Anda di sini", // ← ISI SARAN 1
    "Tulis saran kedua Anda di sini", // ← ISI SARAN 2
    "Tulis saran ketiga Anda di sini", // ← ISI SARAN 3
    // Tambahkan lebih banyak saran jika diperlukan
  ];

  // KESAN (Bisa berupa list atau paragraf panjang)
  final List<String> kesanList = [
    "Tulis kesan pertama Anda di sini", // ← ISI KESAN 1
    "Tulis kesan kedua Anda di sini", // ← ISI KESAN 2
    "Tulis kesan ketiga Anda di sini", // ← ISI KESAN 3
    // Tambahkan lebih banyak kesan jika diperlukan
  ];

  // ============================================================
  // ATAU JIKA INGIN FORMAT PARAGRAF PANJANG:
  // ============================================================

  final String saranParagraf = """
Tulis saran Anda dalam bentuk paragraf panjang di sini.
Anda bisa menulis beberapa baris.
Dan akan ditampilkan seperti ini.

Paragraf kedua juga bisa ditambahkan.
  """; // ← ISI SARAN PARAGRAF

  final String kesanParagraf = """
Tulis kesan Anda dalam bentuk paragraf panjang di sini.
Anda bisa menulis beberapa baris.
Dan akan ditampilkan seperti ini.

Paragraf kedua juga bisa ditambahkan.
  """; // ← ISI KESAN PARAGRAF

  // ============================================================
  // PILIH FORMAT: true = List, false = Paragraf
  // ============================================================
  final bool useListFormat = true; // ← UBAH KE false JIKA INGIN FORMAT PARAGRAF

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saran & Kesan'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade600, Colors.purple.shade600],
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.feedback, size: 60, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Saran & Kesan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pengalaman dalam mengembangkan aplikasi ini',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SARAN
                  _buildSectionCard(
                    icon: Icons.lightbulb,
                    title: 'Saran',
                    color: Colors.orange,
                    content: useListFormat
                        ? _buildListContent(saranList)
                        : _buildParagraphContent(saranParagraf),
                  ),

                  SizedBox(height: 16),

                  // KESAN
                  _buildSectionCard(
                    icon: Icons.emoji_emotions,
                    title: 'Kesan',
                    color: Colors.green,
                    content: useListFormat
                        ? _buildListContent(kesanList)
                        : _buildParagraphContent(kesanParagraf),
                  ),

                  SizedBox(height: 24),

                  // Catatan Footer
                  Card(
                    elevation: 1,
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Terima kasih telah menggunakan Country Explorer!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Color color,
    required Widget content,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: (color as MaterialColor).shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(16), child: content),
        ],
      ),
    );
  }

  Widget _buildListContent(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        int index = entry.key;
        String item = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildParagraphContent(String text) {
    return Text(
      text.trim(),
      style: TextStyle(fontSize: 15, height: 1.7, color: Colors.grey.shade800),
    );
  }
}
