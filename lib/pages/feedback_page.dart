import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'edit_feedback_Page.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  // Palet Warna (DIPERBARUI)
  final Color primaryColor = Color(0xFF010A1E); // LEBIH GELAP
  final Color secondaryColor = Color(0xFF103070); // LEBIH GELAP
  final Color tertiaryColor = Color(0xFF2A364B); // LEBIH GELAP
  final Color cardColor = Color(0xFF21252F);
  final Color textColor = Color(0xFFD9D9D9);
  final Color hintColor = Color(0xFF898989);

  String? _currentUsername;
  Box? _feedbackBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUsername = AuthService.getCurrentUsername();
    _loadFeedbackBox();
  }

  // Fungsi yang lebih aman untuk memuat Hive Box
  Future<void> _loadFeedbackBox() async {
    // Pastikan box sudah terbuka atau buka jika belum
    if (!Hive.isBoxOpen('feedback')) {
      await Hive.openBox('feedback');
    }
    _feedbackBox = Hive.box('feedback');
    setState(() {
      _isLoading = false;
    });
  }

  // Navigasi ke EditFeedbackPage (untuk menambah/mengedit)
  void _navigateToAddFeedback() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFeedbackPage(
          username: _currentUsername!, // Pasti ada karena sudah login
          feedbackKey: null,
          initialFeedback: '',
        ),
      ),
    );
  }

  void _navigateToEditFeedback(int key, String currentFeedback) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFeedbackPage(
          username: _currentUsername!,
          feedbackKey: key,
          initialFeedback: currentFeedback,
        ),
      ),
    );
  }

  void _deleteFeedback(int key) {
    _feedbackBox?.delete(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback', style: TextStyle(color: textColor)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add_comment, color: textColor),
            onPressed: _currentUsername != null ? _navigateToAddFeedback : null,
            tooltip: 'Tambah Feedback',
          ),
        ],
      ),
      body: Container(
        // Background Gradient (DIPERBARUI)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, secondaryColor, tertiaryColor],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: secondaryColor))
            : _currentUsername == null
                ? Center(
                    child: Text(
                      'Silakan login untuk melihat feedback Anda.',
                      style: TextStyle(color: hintColor),
                    ),
                  )
                : ValueListenableBuilder(
                    valueListenable: _feedbackBox!.listenable(),
                    builder: (context, Box box, _) {
                      // Ambil feedback hanya milik user yang sedang login
                      List<MapEntry> userFeedback = box.toMap().entries.where((entry) {
                        return entry.value['username'] == _currentUsername;
                      }).toList();

                      // Urutkan berdasarkan waktu
                      userFeedback.sort((a, b) {
                        // Asumsikan value['timestamp'] adalah DateTime
                        DateTime timeA = a.value['timestamp'] ?? DateTime(2000);
                        DateTime timeB = b.value['timestamp'] ?? DateTime(2000);
                        return timeB.compareTo(timeA); // Terbaru di atas
                      });

                      if (userFeedback.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: userFeedback.length,
                        itemBuilder: (context, index) {
                          final entry = userFeedback[index];
                          final key = entry.key as int;
                          final data = entry.value;
                          final feedbackText = data['feedback'] ?? 'Tidak ada teks';
                          final timestamp = data['timestamp'] ?? DateTime.now();
                          
                          // Styling tiap item feedback
                          return _buildFeedbackCard(
                            key, 
                            feedbackText, 
                            timestamp
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }

  // --- Widget Pembangun ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feedback_outlined, size: 64, color: hintColor),
          SizedBox(height: 16),
          Text(
            'Belum ada feedback dari Anda',
            style: TextStyle(fontSize: 18, color: hintColor),
          ),
          SizedBox(height: 8),
          Text(
            'Tekan ikon (+) di atas untuk menambahkan',
            style: TextStyle(fontSize: 14, color: hintColor.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(int key, String feedbackText, DateTime timestamp) {
    return Card(
      color: cardColor,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: tertiaryColor.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Konten Feedback
            Text(
              feedbackText,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 12),
            Divider(color: tertiaryColor.withOpacity(0.5), height: 1),
            SizedBox(height: 12),

            // Footer (Waktu dan Tombol Aksi)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: hintColor,
                  ),
                ),
                Row(
                  children: [
                    // Tombol Edit
                    GestureDetector(
                      onTap: () => _navigateToEditFeedback(key, feedbackText),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.edit, size: 18, color: secondaryColor),
                      ),
                    ),
                    // Tombol Hapus
                    GestureDetector(
                      onTap: () async {
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: cardColor,
                            title: Text('Hapus Feedback', style: TextStyle(color: textColor)),
                            content: Text('Anda yakin ingin menghapus feedback ini?', style: TextStyle(color: hintColor)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: TextStyle(color: hintColor))),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus', style: TextStyle(color: Colors.redAccent))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          _deleteFeedback(key);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.delete, size: 18, color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi Helper yang sudah diperbaiki menggunakan DateFormat
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} menit yang lalu';
      }
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }
}