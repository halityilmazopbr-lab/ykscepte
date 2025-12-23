import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'models.dart';
import 'cache_service.dart';

// 🔹 GEMINI API KEY
const String _geminiKey = "AIzaSyBI6JuUxYPZ24valrMHrRvRx4Jge-tVvJg";

// 🔹 OPTİMİZE EDİLMİŞ PROMPTLAR
class _Prompts {
  // Kısa ve etkili sistem talimatları
  static const String soruCozum = "YKS sorusu. Türkçe çöz. Kısa ve net maddeler halinde.";
  static const String sohbet = "YKS rehber öğretmenisin. Kısa, net cevaplar ver. Gereksiz giriş yapma.";
  static const String program = "YKS program oluştur. SADECE JSON döndür, başka metin yazma.";
}

// 🔹 API AYARLARI
class _ApiConfig {
  static const int maxOutputTokens = 500;  // Cevap token sınırı
  static const double temperature = 0.7;   // Yaratıcılık seviyesi
}

class GravityAI {
  
  // ═══════════════════════════════════════════════════════════════
  // 🟢 1. METİN ÜRETME (Ücretsiz - Pollinations.ai + Cache)
  // ═══════════════════════════════════════════════════════════════
  static Future<String> generateText(String prompt) async {
    // 1. Önce cache'e bak
    final cachedResponse = CacheService.get(prompt);
    if (cachedResponse != null) {
      return cachedResponse; // 💰 Maliyet: 0 TL
    }

    // 2. Cache'de yoksa API'ye sor
    try {
      String encodedPrompt = Uri.encodeComponent(prompt);
      final url = Uri.parse('https://text.pollinations.ai/$encodedPrompt');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = response.body;
        
        // 3. Cevabı cache'e kaydet
        await CacheService.set(prompt, result);
        
        return result;
      } else {
        return "Bağlantı Hatası: ${response.statusCode}";
      }
    } catch (e) {
      return "Hata oluştu: $e";
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🟠 2. GÖRSEL SORU ÇÖZÜMÜ (Akıllı Hibrit Sistem)
  // ═══════════════════════════════════════════════════════════════
  /// [soruTipi]: "sozel", "sayisal" veya "auto"
  /// Sözel sorular OCR ile çözülür (ücretsiz), sayısal Gemini ile
  static Future<String> soruCoz(XFile image, {String soruTipi = "auto"}) async {
    
    // Sözel soru ise önce OCR dene (ücretsiz yol)
    if (soruTipi == "sozel") {
      final ocrResult = await _ocrThenText(image);
      if (!ocrResult.contains("okunamadı")) {
        return ocrResult; // 💰 Maliyet: 0 TL
      }
    }

    // Sayısal veya OCR başarısız → Gemini Vision
    try {
      String geminiResponse = await _geminiVisionCall(image);
      if (!geminiResponse.contains("429") && !geminiResponse.contains("Hata:")) {
        return geminiResponse;
      }
    } catch (e) {
      debugPrint("Gemini Hatası: $e");
    }

    // Yedek plan: OCR + Metin
    return await _ocrThenText(image);
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔵 3. GEMİNİ VİZYON (Optimize Edilmiş)
  // ═══════════════════════════════════════════════════════════════
  static Future<String> _geminiVisionCall(XFile image) async {
    if (_geminiKey.isEmpty) return "API Key Yok";
    
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
                {"text": _Prompts.soruCozum}, // ✅ Optimize prompt
                {
                  "inline_data": {
                    "mime_type": "image/jpeg",
                    "data": base64Image
                  }
                }
              ]
            }
          ],
          // ✅ Token sınırlaması
          "generationConfig": {
            "maxOutputTokens": _ApiConfig.maxOutputTokens,
            "temperature": _ApiConfig.temperature
          }
        }));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['candidates'][0]['content']['parts'][0]['text'];
    }
    return "Hata: ${response.statusCode} - ${response.body}";
  }

  // ═══════════════════════════════════════════════════════════════
  // 🟣 4. OCR + METİN (Ücretsiz Yol)
  // ═══════════════════════════════════════════════════════════════
  static Future<String> _ocrThenText(XFile image) async {
    if (kIsWeb) {
      return "OCR tarayıcıda çalışmaz. Mobil uygulamayı kullanın.";
    }

    try {
      // 1. Resimdeki yazıyı oku (OCR - Ücretsiz, Offline)
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      String sorununMetni = recognizedText.text;
      textRecognizer.close();

      if (sorununMetni.length < 10) {
        return "Resimden yeterli yazı okunamadı. Fotoğrafı daha net çekin.";
      }

      // 2. Cache kontrolü
      final cacheKey = "ocr:$sorununMetni";
      final cachedResponse = CacheService.get(cacheKey);
      if (cachedResponse != null) {
        return cachedResponse; // 💰 Maliyet: 0 TL
      }

      // 3. Pollinations'a sor (ücretsiz)
      String prompt = "${_Prompts.soruCozum}\n\nSoru: $sorununMetni";
      final result = await generateText(prompt);
      
      // 4. Cache'e kaydet
      await CacheService.set(cacheKey, result);
      
      return result;

    } catch (e) {
      return "OCR hatası: $e";
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🟡 5. AI PROGRAM OLUŞTURMA (Optimize)
  // ═══════════════════════════════════════════════════════════════
  static Future<List<Gorev>> programOlustur(String sinif, String alan, String stil, int gunlukSaat, String zayifDers) async {
    // Cache key
    final cacheKey = "program:$sinif-$alan-$gunlukSaat-$zayifDers";
    
    // Cache kontrolü
    final cachedResponse = CacheService.get(cacheKey);
    if (cachedResponse != null) {
      try {
        List<dynamic> data = jsonDecode(cachedResponse);
        return data.map((e) => Gorev.fromJson(e)).toList();
      } catch (e) {
        // Cache bozuksa devam et
      }
    }

    // Optimize prompt
    String prompt = "${_Prompts.program} "
        "$sinif. sınıf $alan, günde $gunlukSaat saat, zayıf: $zayifDers. "
        "Format: [{\"hafta\":1,\"gun\":\"Pazartesi\",\"saat\":\"09:00\",\"ders\":\"Matematik\",\"konu\":\"Türev\",\"aciklama\":\"Video\"}]";

    try {
      String jsonStr = await generateText(prompt);
      jsonStr = jsonStr.replaceAll("```json", "").replaceAll("```", "").trim();
      
      // Cache'e kaydet
      await CacheService.set(cacheKey, jsonStr);
      
      List<dynamic> data = jsonDecode(jsonStr);
      return data.map((e) => Gorev.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Program Oluşturma Hatası: $e");
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔴 6. AI SOHBET (Cache Destekli)
  // ═══════════════════════════════════════════════════════════════
  static Future<String> sohbetEt(String mesaj) async {
    final prompt = "${_Prompts.sohbet}\n\nÖğrenci: $mesaj";
    return await generateText(prompt);
  }
}
