import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class EditFeedbackPage extends StatefulWidget {
  final String username;
  final int? feedbackKey; 
  final String initialFeedback;

  EditFeedbackPage({
    required this.username,
    required this.feedbackKey,
    required this.initialFeedback,
  });

  @override
  _EditFeedbackPageState createState() => _EditFeedbackPageState();
}

class _EditFeedbackPageState extends State<EditFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _feedbackController;
  late Box _feedbackBox;

  // Palet Warna (DIPERBARUI)
  final Color primaryColor = Color(0xFF010A1E); // LEBIH GELAP
  final Color secondaryColor = Color(0xFF103070); // LEBIH GELAP
  final Color tertiaryColor = Color(0xFF2A364B); // LEBIH GELAP
  final Color cardColor = Color(0xFF21252F);
  final Color textColor = Color(0xFFD9D9D9);
  final Color hintColor = Color(0xFF898989);

  bool get isEditing => widget.feedbackKey != null;

  @override
  void initState() {
    super.initState();
    _feedbackBox = Hive.box('feedback');
    _feedbackController = TextEditingController(text: widget.initialFeedback);
  }

  void _saveFeedback() {
    if (_formKey.currentState!.validate()) {
      final feedbackData = {
        'username': widget.username,
        'feedback': _feedbackController.text,
        'timestamp': DateTime.now(), 
      };

      if (isEditing) {
        _feedbackBox.put(widget.feedbackKey, feedbackData);
      } else {
        _feedbackBox.add(feedbackData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Feedback berhasil diubah!' : 'Feedback berhasil dikirim!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Feedback' : 'Kirim Feedback Baru',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.send, color: textColor),
            onPressed: _saveFeedback,
            tooltip: 'Simpan',
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
        child: Form(
          key: _formKey,
          // Menggunakan SingleChildScrollView untuk mencegah overflow
          child: SingleChildScrollView( 
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Halo ${widget.username}, kami menghargai masukan Anda.',
                  style: TextStyle(fontSize: 16, color: hintColor),
                ),
                SizedBox(height: 24),
                
                TextFormField(
                  controller: _feedbackController,
                  maxLines: 10,
                  minLines: 5,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Tulis feedback atau saran Anda di sini...',
                    labelStyle: TextStyle(color: hintColor),
                    filled: true,
                    fillColor: tertiaryColor.withOpacity(0.3),
                    
                    // Ikon kontras (abu-abu)
                    prefixIcon: Icon(Icons.comment, color: hintColor), 
                    
                    // Garis pinggir kontras (abu-abu)
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: hintColor), 
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: secondaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Feedback tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: _saveFeedback,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Simpan Perubahan' : 'Kirim Feedback',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 20), // Padding aman saat keyboard hilang
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}