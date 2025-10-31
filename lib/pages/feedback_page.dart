import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
import 'edit_feedback_page.dart'; // Import halaman edit

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Gunakan ValueListenableBuilder untuk auto-update
    return ValueListenableBuilder(
      valueListenable: Hive.box('feedback').listenable(),
      builder: (context, Box box, _) {
        // Ambil data dari Hive, beri nilai default jika kosong
        final String saranParagraf = box.get('saran',
            defaultValue: 'Saran belum diatur. Tekan tombol edit (✏️) di kanan atas untuk menambahkan.');
        final String kesanParagraf = box.get('kesan',
            defaultValue: 'Kesan belum diatur. Tekan tombol edit (✏️) di kanan atas untuk menambahkan.');

        return Scaffold(
          appBar: AppBar(
            title: Text('Saran & Kesan'),
            elevation: 0,
            actions: [
              // Tombol Edit
              IconButton(
                icon: Icon(Icons.edit),
                tooltip: 'Edit Saran & Kesan',
                onPressed: () {
                  // Pindah ke halaman Edit Feedback
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditFeedbackPage()),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header (Ini tetap sama)
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
                      // SARAN (Kita hanya pakai format paragraf)
                      _buildSectionCard(
                        icon: Icons.lightbulb,
                        title: 'Saran',
                        color: Colors.orange,
                        content: _buildParagraphContent(saranParagraf),
                      ),

                      SizedBox(height: 16),

                      // KESAN (Kita hanya pakai format paragraf)
                      _buildSectionCard(
                        icon: Icons.emoji_emotions,
                        title: 'Kesan',
                        color: Colors.green,
                        content: _buildParagraphContent(kesanParagraf),
                      ),

                      SizedBox(height: 24),

                      // Catatan Footer (Ini tetap sama)
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
      },
    );
  }

  // Helper widget (Ini tetap sama)
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

  // Helper widget (Ini tetap sama)
  Widget _buildParagraphContent(String text) {
    return Text(
      text.trim(),
      style: TextStyle(fontSize: 15, height: 1.7, color: Colors.grey.shade800),
    );
  }
}