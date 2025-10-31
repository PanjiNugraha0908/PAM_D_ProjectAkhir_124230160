import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class EditFeedbackPage extends StatefulWidget {
  @override
  _EditFeedbackPageState createState() => _EditFeedbackPageState();
}

class _EditFeedbackPageState extends State<EditFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  late Box _feedbackBox;

  // Controllers untuk Saran dan Kesan
  late TextEditingController _saranController;
  late TextEditingController _kesanController;

  @override
  void initState() {
    super.initState();
    _feedbackBox = Hive.box('feedback');
    
    // Isi controller dengan data yang sudah tersimpan di Hive
    _saranController = TextEditingController(text: _feedbackBox.get('saran', defaultValue: ''));
    _kesanController = TextEditingController(text: _feedbackBox.get('kesan', defaultValue: ''));
  }

  // Fungsi untuk menyimpan data
  void _saveFeedback() {
    if (_formKey.currentState!.validate()) {
      _feedbackBox.put('saran', _saranController.text);
      _feedbackBox.put('kesan', _kesanController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saran & Kesan berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Kembali ke halaman feedback
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Saran & Kesan'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveFeedback,
            tooltip: 'Simpan',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Text(
              'Saran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildTextField(
              controller: _saranController,
              hint: 'Tulis saran Anda di sini...',
            ),
            SizedBox(height: 24),
            Text(
              'Kesan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildTextField(
              controller: _kesanController,
              hint: 'Tulis kesan Anda di sini...',
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveFeedback,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat TextField multi-line
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.all(16),
      ),
      // Ini membuat TextField bisa diisi banyak baris
      keyboardType: TextInputType.multiline,
      maxLines: null, // Otomatis menambah tinggi
      minLines: 5,     // Tinggi minimal 5 baris
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Tidak boleh kosong';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _saranController.dispose();
    _kesanController.dispose();
    super.dispose();
  }
}