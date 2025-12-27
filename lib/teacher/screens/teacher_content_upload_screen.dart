import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../models.dart';
import '../models/teacher_models.dart';
import '../teacher_service.dart';

class TeacherContentUploadScreen extends StatefulWidget {
  final Ogretmen ogretmen;
  final ClassModel? preSelectedClass;

  const TeacherContentUploadScreen({
    super.key,
    required this.ogretmen,
    this.preSelectedClass,
  });

  @override
  State<TeacherContentUploadScreen> createState() => _TeacherContentUploadScreenState();
}

class _TeacherContentUploadScreenState extends State<TeacherContentUploadScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  ContentType _selectedType = ContentType.pdf;
  ContentCategory _selectedCategory = ContentCategory.quiz;
  String? _selectedClassId;
  PlatformFile? _pickedFile;
  XFile? _pickedImage;
  bool _isLoading = false;

  late List<ClassModel> _myClasses;

  @override
  void initState() {
    super.initState();
    _myClasses = TeacherService.getTeacherClasses(widget.ogretmen.id);
    if (widget.preSelectedClass != null) {
      _selectedClassId = widget.preSelectedClass!.id;
    } else if (_myClasses.isNotEmpty) {
      _selectedClassId = _myClasses.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('İçerik Yükle', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hedef Sınıf
            _buildSectionTitle("1. Hedef Sınıf", Icons.people),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade700),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedClassId,
                  dropdownColor: const Color(0xFF21262D),
                  style: const TextStyle(color: Colors.white),
                  hint: const Text("Sınıf Seçiniz", style: TextStyle(color: Colors.grey)),
                  items: _myClasses.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedClassId = val),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. İçerik Tipi ve Kategori
            _buildSectionTitle("2. İçerik Detayları", Icons.category),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildRadioOption(
                    "PDF Doküman",
                    ContentType.pdf,
                    Icons.picture_as_pdf,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRadioOption(
                    "Soru Fotoğrafı",
                    ContentType.image,
                    Icons.image,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
             DropdownButtonFormField<ContentCategory>(
              value: _selectedCategory,
              dropdownColor: const Color(0xFF21262D),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF21262D),
                labelText: "Kategori",
                labelStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ContentCategory.values.map((cat) {
                 String label;
                 switch (cat) {
                   case ContentCategory.quiz: label = "Quiz / Tarama"; break;
                   case ContentCategory.trial: label = "Deneme Sınavı"; break;
                   case ContentCategory.summary: label = "Konu Özeti"; break;
                   case ContentCategory.question: label = "Soru Çözümü"; break;
                   default: label = "Diğer";
                 }
                 return DropdownMenuItem(value: cat, child: Text(label));
               }).toList(),
              onChanged: (val) {
                if(val != null) setState(() => _selectedCategory = val);
              },
            ),

            const SizedBox(height: 24),

            // 3. Dosya Seçimi
            _buildSectionTitle("3. Dosya Yükle", Icons.upload_file),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF21262D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (_pickedFile != null || _pickedImage != null)
                        ? Colors.green
                        : Colors.grey.shade700,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_pickedFile != null) ...[
                      const Icon(Icons.check_circle, color: Colors.green, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        _pickedFile!.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB",
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ] else if (_pickedImage != null) ...[
                      const Icon(Icons.check_circle, color: Colors.green, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        "Fotoğraf Seçildi",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ] else ...[
                      Icon(
                        _selectedType == ContentType.pdf ? Icons.picture_as_pdf : Icons.add_a_photo,
                        color: Colors.grey.shade500,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedType == ContentType.pdf
                            ? "PDF Seçmek İçin Dokunun"
                            : "Fotoğraf Çekmek/Seçmek İçin Dokunun",
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // 4. Başlık ve Açıklama
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Başlık (Örn: Türev Tarama Testi)",
                filled: true,
                fillColor: Color(0xFF21262D),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Açıklama (Opsiyonel)",
                filled: true,
                fillColor: Color(0xFF21262D),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),

            const SizedBox(height: 32),

            // Yükle Butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _uploadContent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                  : const Icon(Icons.cloud_upload),
                label: Text(_isLoading ? "YÜKLENİYOR..." : "PAYLAŞ"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 20),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRadioOption(String label, ContentType value, IconData icon, Color color) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
          _pickedFile = null;
          _pickedImage = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(50) : const Color(0xFF21262D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey.shade800),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    if (_selectedType == ContentType.pdf) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        setState(() => _pickedFile = result.files.first);
      }
    } else {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _pickedImage = image);
      }
    }
  }

  Future<void> _uploadContent() async {
    if (_selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen bir sınıf seçin.")));
      return;
    }
    if (_pickedFile == null && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen bir dosya seçin.")));
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen bir başlık girin.")));
      return;
    }

    setState(() => _isLoading = true);

    // Simüle edilmiş dosya URL'i
    String fakeUrl = "https://firebasestorage.googleapis.com/.../demo.pdf";
    if (_selectedType == ContentType.image) {
      fakeUrl = "https://firebasestorage.googleapis.com/.../demo_image.jpg";
    }

    final content = TeacherContentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      type: _selectedType,
      category: _selectedCategory,
      fileUrl: fakeUrl,
      teacherId: widget.ogretmen.id,
      teacherName: widget.ogretmen.ad,
      classId: _selectedClassId,
      createdAt: DateTime.now(),
    );

    // Servis çağır
    await TeacherService.uploadContent(content);

    // Çıkış ve bildirim (3 saniye gecikme ekle demo loading hissi için)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("İçerik başarıyla paylaşıldı! ✅"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }
}
