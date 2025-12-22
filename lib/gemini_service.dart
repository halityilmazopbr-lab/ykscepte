import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart'; // Added for XFile
import 'package:flutter/foundation.dart'; // Added for kIsWeb
import 'models.dart';

// 🔹 2. ADIM: GEMINI VİZYON İÇİN ANAHTAR (Sadece Görsel Sorularda Kullanılır)
const String _geminiKey = "AIzaSyBI6JuUxYPZ24valrMHrRvRx4Jge-tVvJg"; // En son verdiğiniz anahtar

class GravityAI {
  // 🟢 1. PLAN: Sınırsız Sohbet & Metin (Pollinations.ai)
  static Future<String> generateText(String prompt) async {
    try {
      // Pollinations.ai API Yapısı: https://text.pollinations.ai/{prompt}
      // Boşlukları %20 ile doldurarak URL oluşturuyoruz
      String encodedPrompt = Uri.encodeComponent(prompt);
      final url = Uri.parse('https://text.pollinations.ai/$encodedPrompt');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return response.body; 
      } else {
        return "Bağlantı Hatası: ${response.statusCode}";
      }
    } catch (e) {
      return "Hata oluştu: $e";
    }
  }


  // 🟠 2. PLAN: Görsel Soru Çözümü (Hibrit Sistem - Web Uyumlu)
  static Future<String> soruCoz(XFile image) async {
    // A. ÖNCE GEMINI İLE DENEYELİM (Görüntü İşleme / Geometri için)
    try {
      String geminiResponse = await _geminiVisionCall(image);
      if (!geminiResponse.contains("429")) { // Eğer kota hatası yoksa
        return geminiResponse; // Gemini cevabını döndür
      }
    } catch (e) {
      // Gemini hatası olursa devam et...
      print("Gemini Hatası: $e");
    }

    // B. GEMINI KOTASI DOLUYSA -> YEDEK PLAN (ML Kit + Pollinations)
    return await _fallbackVisionCall(image);
  }

  // Gemini API Çağrısı (Private)
  static Future<String> _geminiVisionCall(XFile image) async {
    if (_geminiKey.isEmpty) return "API Key Yok";
    
    // Gemini 2.0 Flash Modelini Kullan
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_geminiKey');
    
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": "Bu soruyu detaylıca çöz ve anlat. Cevabı Türkçe ver."},
                {
                  "inline_data": {
                    "mime_type": "image/jpeg",
                    "data": base64Image
                  }
                }
              ]
            }
          ]
        }));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['candidates'][0]['content']['parts'][0]['text'];
    }
    // Hata durumunda kodu döndür ki yakalayabilelim
    return "Hata: ${response.statusCode} - ${response.body}";
  }

  // Yedek Plan: OCR + Metin Zekası (Private)
  static Future<String> _fallbackVisionCall(XFile image) async {
    // WEB KONTROLU: ML Kit Web'de çalışmaz.
    if (kIsWeb) {
      return "Üzgünüm, yedek sistem (OCR) şu an tarayıcıda çalışmıyor. Lütfen Gemini API kotasının dolmasını bekleyin veya mobil uygulamayı kullanın.";
    }

    try {
      // 1. Resimdeki yazıyı oku (OCR) - Çevrimdışı ve ücretsiz
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      String sorununMetni = recognizedText.text;
      textRecognizer.close(); // Temizlik

      if (sorununMetni.length < 5) {
        return "Resimden yeterli yazı okunamadı. Lütfen fotoğrafı daha net çekin.";
      }

      // 2. Okunan metni Pollinations'a sor
      String prompt = "Bu soruyu çöz: $sorununMetni";
      return await generateText(prompt); // Yukarıdaki fonksiyonu tekrar kullanıyoruz

    } catch (e) {
      return "Yedek sistem hatası: $e";
    }
  }

  // Eski kodlarınızla uyumluluk için (Program Oluşturma vs)
  // 🟠 3. PLAN: AI Program Oluşturma (Structured)
  static Future<List<Gorev>> programOlustur(String sinif, String alan, String stil, int gunlukSaat, String zayifDers) async {
    String prompt = "Bana YKS hazırlık için $sinif. sınıf, $alan öğrencisi için bir haftalık ders programı yap. "
        "Günde $gunlukSaat saat çalışacak. Zayıf olduğu ders: $zayifDers. "
        "Çıktıyı SADECE şu JSON formatında ver: "
        "[{\"hafta\":1, \"gun\":\"Pazartesi\", \"saat\":\"09:00\", \"ders\":\"Matematik\", \"konu\":\"Türev\", \"aciklama\":\"Video izle\"}] "
        "Başka hiçbir metin yazma.";

    try {
      String jsonStr = await generateText(prompt);
      // Temizlik (Bazen AI markdown ```json ... ``` ekler)
      jsonStr = jsonStr.replaceAll("```json", "").replaceAll("```", "").trim();
      
      List<dynamic> data = jsonDecode(jsonStr);
      return data.map((e) => Gorev.fromJson(e)).toList();
    } catch (e) {
      print("Program Oluşturma Hatası: $e");
      // Hata durumunda boş liste veya varsayılan bir program dönebiliriz
      return [];
    }
  }
}
