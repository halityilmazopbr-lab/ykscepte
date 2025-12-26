import 'package:flutter/material.dart';
import '../../models/counselor_models.dart';

/// Danışman Başvuru Formu
class CounselorApplicationScreen extends StatefulWidget {
  const CounselorApplicationScreen({super.key});

  @override
  _CounselorApplicationScreenState createState() => _CounselorApplicationScreenState();
}

class _CounselorApplicationScreenState extends State<CounselorApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  int _experienceYears = 0;
  final List<String> _selectedSpecializations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Danışman Başvurusu', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildTextField('Ad Soyad', _nameController, Icons.person),
              const SizedBox(height: 16),
              _buildTextField('E-posta', _emailController, Icons.email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField('Telefon', _phoneController, Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              const Text('Deneyim Yılı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Slider(
                value: _experienceYears.toDouble(),
                min: 0,
                max: 20,
                divisions: 20,
                label: '$_experienceYears yıl',
                onChanged: (value) => setState(() => _experienceYears = value.toInt()),
              ),
              Text('$_experienceYears yıl', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 20),
              const Text('Uzmanlık Alanları:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: Specializations.all.map((spec) => FilterChip(
                  label: Text(spec),
                  selected: _selectedSpecializations.contains(spec),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) _selectedSpecializations.add(spec);
                      else _selectedSpecializations.remove(spec);
                    });
                  },
                )).toList(),
              ),
              const SizedBox(height: 20),
              _buildTextField('Kısa Bio (500 karakter)', _bioController, Icons.description, maxLines: 4),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('BAŞVURU GÖNDER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF6366F1)),
              SizedBox(width: 8),
              Text('Başvuru Bilgileri', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Platform komisyonu: %20\n'
            'Aylık kazanç: 959-1.599 TL (deneyime göre)\n'
            'Başvurunuz 48 saat içinde değerlendirilecek.',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Lütfen doldurun' : null,
    );
  }

  void _submitApplication() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpecializations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir uzmanlık alanı seçin!')),
      );
      return;
    }

    // TODO: Firestore'a kaydet
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('✅ Başvuru Gönderildi!'),
        content: const Text('Başvurunuz alındı. 48 saat içinde e-posta ile bilgilendirileceksiniz.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
