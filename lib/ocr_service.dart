import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// 📸 OCR Servisi - Fotoğraftan Metin Çıkarma (On-Device, Bedava!)
///
/// Google ML Kit kullanarak fotoğraftaki yazıları okur.
/// Bu işlem tamamen telefonda gerçekleşir, internet gerektirmez ve ücretsizdir.
///
/// Kullanım:
/// ```dart
/// final ocrService = OcrService();
/// final metin = await ocrService.extractTextFromCamera();
/// print(metin); // "Tanzimat Fermanı 1839 yılında..."
/// ```

class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();
  
  final ImagePicker _picker = ImagePicker();
  
  // Latin alfabesi için text recognizer (Türkçe dahil)
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  /// 📷 Kameradan fotoğraf çekip metin çıkar
  Future<String?> extractTextFromCamera() async {
    return await _extractText(ImageSource.camera);
  }
  
  /// 🖼️ Galeriden fotoğraf seçip metin çıkar
  Future<String?> extractTextFromGallery() async {
    return await _extractText(ImageSource.gallery);
  }
  
  /// Ana OCR işlemi
  Future<String?> _extractText(ImageSource source) async {
    try {
      // 1. Fotoğrafı al
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85, // Boyutu küçült, hızı artır
        maxWidth: 1920,   // Full HD yeterli
      );
      
      if (image == null) return null; // Kullanıcı vazgeçti
      
      // 2. ML Kit ile işle
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // 3. Metni temizle ve döndür
      String extractedText = recognizedText.text;
      
      if (extractedText.isEmpty) {
        throw Exception("Fotoğrafta okunabilir yazı bulunamadı.");
      }
      
      // Satır sonlarını temizle (cümleler bölünmesin)
      // Çoklu boşlukları tekile indir
      extractedText = extractedText
          .replaceAll('\n', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      
      return extractedText;
      
    } catch (e) {
      if (e.toString().contains("bulunamadı")) {
        rethrow;
      }
      throw Exception("Yazı okunamadı. Işık yetersiz veya yazı bulanık olabilir.");
    }
  }
  
  /// XFile'dan direkt metin çıkar (harici kullanım için)
  Future<String?> extractTextFromFile(XFile file) async {
    try {
      final inputImage = InputImage.fromFilePath(file.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      String extractedText = recognizedText.text
          .replaceAll('\n', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      
      return extractedText.isEmpty ? null : extractedText;
    } catch (e) {
      return null;
    }
  }
  
  /// Güven skoru hesapla (okunan metnin kalitesi)
  /// 0.0 - 1.0 arası
  double calculateConfidence(RecognizedText result) {
    if (result.blocks.isEmpty) return 0.0;
    
    double totalConfidence = 0;
    int count = 0;
    
    for (var block in result.blocks) {
      for (var line in block.lines) {
        if (line.confidence != null) {
          totalConfidence += line.confidence!;
          count++;
        }
      }
    }
    
    return count > 0 ? totalConfidence / count : 0.5;
  }
  
  /// Dispose (sayfa kapanınca çağrılmalı)
  void dispose() {
    _textRecognizer.close();
  }
}
