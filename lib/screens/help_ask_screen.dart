import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/help_request_model.dart';
import '../services/help_service.dart';
import '../data.dart'; // Aktif kullanıcı bilgisi için

class HelpAskScreen extends StatefulWidget {
  const HelpAskScreen({super.key});

  @override
  State<HelpAskScreen> createState() => _HelpAskScreenState();
}

class _HelpAskScreenState extends State<HelpAskScreen> {
  final _helpService = HelpService();
  final _picker = ImagePicker();
  final _descriptionController = TextEditingController();
  final _topicController = TextEditingController();
  
  File? _imageFile;
  String selectedLesson = 'Matematik';
  int offeredCoins = 15;
  bool isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<String> _uploadImage(File file) async {
    final ref = FirebaseStorage.instance.ref().child('help_questions/${const Uuid().v4()}.jpg');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  void _submit() async {
    if (_descriptionController.text.isEmpty || _topicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm alanları doldurun")));
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen sorunun fotoğrafını çekin")));
      return;
    }

    setState(() => isUploading = true);

    try {
      final userId = VeriDeposu.aktifKullaniciId ?? 'test_user';
      final personaName = _helpService.generatePersonaName(userId);
      
      // Gerçek fotoğrafı yükle
      final photoUrl = await _uploadImage(_imageFile!);
      
      final request = HelpRequestModel(
        id: const Uuid().v4(),
        senderUserId: userId,
        senderPersonaName: personaName,
        senderPersonaAvatar: 'owl_avatar', 
        photoUrl: photoUrl,
        lesson: selectedLesson,
        topic: _topicController.text,
        description: _descriptionController.text,
        coinsOffered: offeredCoins,
        timestamp: DateTime.now(),
      );

      await _helpService.soruSor(request);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sorun Meydana atıldı! 🕊️")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Soru Sor")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fotoğraf Alanı
            GestureDetector(
              onTap: () => _pickImage(ImageSource.camera), // Varsayılan kamera
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.indigo.shade200),
                  image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
                ),
                child: _imageFile == null ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 50, color: Colors.indigo),
                    SizedBox(height: 10),
                    Text("Sorunun Fotoğrafını Çek", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                  ],
                ) : null,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.image), label: const Text("Galeriden Seç")),
                const SizedBox(width: 20),
                TextButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text("Kamera")),
              ],
            ),
            const SizedBox(height: 20),

            // Ders Seçimi
            const Text("Ders Seç", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedLesson,
              isExpanded: true,
              items: ['Matematik', 'Fizik', 'Kimya', 'Biyoloji', 'Türkçe', 'Tarih', 'Coğrafya']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedLesson = val!),
            ),
            const SizedBox(height: 15),

            // Konu
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(labelText: "Konu (Örn: Türev, Paragraf)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            // Açıklama
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Açıklama (Anlamadığın yerleri belirt...)",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // Ödül Belirleme
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Ödül (Coin)", style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: offeredCoins.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  label: offeredCoins.toString(),
                  onChanged: (val) => setState(() => offeredCoins = val.toInt()),
                ),
                Text(offeredCoins.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
              ],
            ),
            const SizedBox(height: 30),

            // Gönder Butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isUploading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade700),
                child: isUploading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("MEYDANA AT", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
