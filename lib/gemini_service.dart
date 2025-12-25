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

// 🔹 OPTİMİZE EDİLMİŞ PROMPTLAR - Pedagojik Direktifler
class _Prompts {
  // Ana soru çözüm promptu - Pedagojik ve detaylı
  static const String soruCozum = '''
Sen uzman bir YKS Matematik öğretmenisin.
KURALLAR:
1. Sadece sonucu (örn: 42) söyleme - işlemleri ADIM ADIM anlat
2. Bir öğrencinin anlayacağı pedagojik bir dille açıkla
3. Önce formülü ver, sonra işlemi yap
4. Gereksiz sohbet etme, net ve kısa ol
5. Eğer resimdeki sayıları net okuyamıyorsan TAHMİN YÜRÜTME
   → "Sayılar/şekil net görünmüyor" de ve öğrenciden tekrar çekmesini iste

FORMAT:
📌 Konu: [Konu adı]
📝 Formül: [Kullanılacak formül]
🔢 Çözüm:
  Adım 1: ...
  Adım 2: ...
✅ Cevap: [Net cevap]
''';
  
  // Sohbet modu için
  static const String sohbet = '''
YKS rehber öğretmenisin. Türkiye'deki YKS sınavına hazırlanan öğrencilere yardım ediyorsun.
- Kısa ve net cevaplar ver
- Gereksiz giriş yapma
- Motive edici ol ama abartma
- Türkçe konuş
''';
  
  // Program oluşturma için - MASTER KOÇ PROMPTU
  static String programPrompt({
    required String alan,
    required String sinif,
    required String hedef,
    required int gunlukSaat,
    required String zayifDers,
    required bool okulVar,
  }) => '''
SENİN ROLÜN:
Sen "YKS Cepte" uygulamasının yapay zeka tabanlı, 20 yıllık deneyime sahip uzman Eğitim Koçusun. Adın "Cepte Koç".
Görevin: Öğrencinin verdiği verilere dayanarak ona en verimli, gerçekçi ve kazanılabilir bir HAFTALIK DERS ÇALIŞMA PROGRAMI oluşturmaktır.

GİRDİ DEĞİŞKENLERİ:
- Alan: $alan (Sayısal, EA, Sözel, Dil)
- Sınıf: $sinif (11, 12 veya Mezun)
- Hedef: $hedef
- Günlük Müsaitlik Saati: $gunlukSaat saat
- En Zayıf Ders: $zayifDers (Buna öncelik verilecek)
- Okul Durumu: ${okulVar ? "Hafta içi okula gidiyor (08:00-16:00 boş bırak)" : "Mezun/Özel ders"}

PEDAGOJİK KURALLAR (ALGORİTMA):
1. SABAH RUTİNİ: Program her sabah (Pazar hariç) mutlaka "Paragraf (20 Soru)" ve "Problem (20 Soru)" ile başlamalıdır.
2. ZAYIF DERS KURALI: "$zayifDers" diğer derslerden en az %30 daha fazla yer kaplamalıdır.
3. SANDVİÇ TEKNİĞİ: Asla iki zor sayısal dersi (Mat-Fiz) arka arkaya koyma. Araya sözel veya mola koy.
4. POMODORO: Dersleri "45 dk Ders + 10 dk Mola" şeklinde planla.
5. SARMAL TEKRAR: Pazar gününü "Haftalık Genel Tekrar" ve "Deneme Analizi"ne ayır.
6. GERÇEKÇİLİK: Günlük $gunlukSaat saat limitini asla aşma.
7. ALAN DENGESİ:
   - Sayısal: Mat, Geo, Fiz, Kim, Biyo ağırlıklı
   - EA: Mat, Edebiyat, Tar, Coğ ağırlıklı
   - Mezun: TYT ve AYT paralel

ÇIKTI FORMATI (KESİNLİKLE UYULACAK):
SADECE parse edilebilir SAF JSON döndür. Başka hiçbir metin yazma.

{
  "koc_notu": "Öğrenciyi motive eden 1-2 cümle",
  "odak_konusu": "Bu haftanın ana teması",
  "program": [
    {
      "gun": "Pazartesi",
      "bloklar": [
        {
          "saat_araligi": "09:00 - 09:50",
          "ders": "Rutin",
          "konu": "20 Paragraf + 20 Problem",
          "tur": "Soru Çözümü"
        }
      ]
    }
  ]
}
''';
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
  // 🟡 5. AI PROGRAM OLUŞTURMA (Master Koç Sistemi)
  // ═══════════════════════════════════════════════════════════════
  /// Gelişmiş haftalık program oluşturma - Master Koç Sistemi
  /// [hedef]: "İlk 10 Bin", "Tıp Fakültesi" gibi
  /// [okulVar]: Hafta içi okula gidiyor mu?
  static Future<Map<String, dynamic>> programOlusturV2({
    required String sinif,
    required String alan,
    required String hedef,
    required int gunlukSaat,
    required String zayifDers,
    bool okulVar = true,
  }) async {
    // Cache key
    final cacheKey = "programV2:$sinif-$alan-$hedef-$gunlukSaat-$zayifDers-$okulVar";
    
    // Cache kontrolü
    final cachedResponse = CacheService.get(cacheKey);
    if (cachedResponse != null) {
      try {
        return jsonDecode(cachedResponse) as Map<String, dynamic>;
      } catch (e) {
        // Cache bozuksa devam et
      }
    }

    // Master Koç promptunu oluştur
    String prompt = _Prompts.programPrompt(
      alan: alan,
      sinif: sinif,
      hedef: hedef,
      gunlukSaat: gunlukSaat,
      zayifDers: zayifDers,
      okulVar: okulVar,
    );

    try {
      String jsonStr = await generateText(prompt);
      jsonStr = jsonStr.replaceAll("```json", "").replaceAll("```", "").trim();
      
      // JSON'u parse et
      Map<String, dynamic> result = jsonDecode(jsonStr);
      
      // Cache'e kaydet
      await CacheService.set(cacheKey, jsonEncode(result));
      
      return result;
    } catch (e) {
      debugPrint("Program Oluşturma Hatası: $e");
      return {
        "koc_notu": "Program oluşturulamadı, lütfen tekrar deneyin.",
        "odak_konusu": "",
        "program": []
      };
    }
  }

  /// Eski uyumluluk için - Gorev listesi döndürür
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

    // Master Koç promptunu kullan
    String prompt = _Prompts.programPrompt(
      alan: alan,
      sinif: sinif,
      hedef: stil,
      gunlukSaat: gunlukSaat,
      zayifDers: zayifDers,
      okulVar: true,
    );

    try {
      String jsonStr = await generateText(prompt);
      jsonStr = jsonStr.replaceAll("```json", "").replaceAll("```", "").trim();
      
      // Yeni formattan eski Gorev listesine dönüştür
      Map<String, dynamic> result = jsonDecode(jsonStr);
      List<Gorev> gorevler = [];
      
      if (result['program'] != null) {
        int hafta = 1;
        for (var gunData in result['program']) {
          String gun = gunData['gun'] ?? '';
          List<dynamic> bloklar = gunData['bloklar'] ?? [];
          
          for (var blok in bloklar) {
            gorevler.add(Gorev(
              hafta: hafta,
              gun: gun,
              saat: blok['saat_araligi']?.toString().split(' - ').first ?? '09:00',
              ders: blok['ders'] ?? '',
              konu: blok['konu'] ?? '',
              aciklama: blok['tur'] ?? 'Konu Çalışması',
            ));
          }
        }
      }
      
      // Cache'e kaydet (eski format)
      await CacheService.set(cacheKey, jsonEncode(gorevler.map((g) => g.toJson()).toList()));
      
      return gorevler;
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
  
  // ═══════════════════════════════════════════════════════════════
  // 🦖 7. PARAGRAF CANAVARI - Metinden Flashcard Oluştur
  // ═══════════════════════════════════════════════════════════════
  
  /// Uzun bir metinden en kritik 5 bilgiyi çıkarıp flashcard formatında döndürür.
  /// [metin]: Ders kitabından veya notlardan kopyalanan uzun metin
  /// [kartSayisi]: Oluşturulacak kart sayısı (varsayılan 5)
  /// Returns: List<Map<String, String>> [{'soru': '...', 'cevap': '...'}]
  static Future<List<Map<String, String>>> paragrafToFlashcards(
    String metin, {
    int kartSayisi = 5,
  }) async {
    if (metin.length < 50) {
      throw Exception("Metin çok kısa. En az 50 karakter olmalı.");
    }
    
    final prompt = '''Sen uzman bir YKS öğretmenisin. Aşağıdaki metni analiz et.
Sınavda çıkma ihtimali en yüksek olan, en kritik $kartSayisi bilgiyi tespit et.
Bu bilgileri "Flashcard" (Bilgi Kartı) formatında JSON listesi olarak ver.

KURALLAR:
1. Soru çok kısa ve net olsun (maksimum 15 kelime).
2. Cevap maksimum 1-2 cümle olsun.
3. Tarih, isim, kavram gibi ezberlenecek bilgileri öncelikle.
4. Çıktı SADECE saf JSON olsun (Markdown \`\`\`json\`\`\` etiketi KULLANMA).
5. Türkçe karakterleri doğru kullan.

METİN:
$metin

İSTENEN JSON FORMATI:
[{"soru": "...", "cevap": "..."}, {"soru": "...", "cevap": "..."}]''';

    try {
      // Gemini API'yi kullan (daha iyi JSON çıktısı için)
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_geminiKey'
      );
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
          'generationConfig': {
            'temperature': 0.3, // Daha tutarlı çıktı için düşük
            'maxOutputTokens': 1000,
          }
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? rawText = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        
        if (rawText == null || rawText.isEmpty) {
          throw Exception("AI cevap vermedi");
        }
        
        // JSON temizleme (```json ... ``` formatını kaldır)
        rawText = rawText
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        
        // JSON'un başlangıç ve bitişini bul
        final jsonStart = rawText.indexOf('[');
        final jsonEnd = rawText.lastIndexOf(']') + 1;
        
        if (jsonStart < 0 || jsonEnd <= jsonStart) {
          throw Exception("JSON formatı bulunamadı");
        }
        
        final jsonStr = rawText.substring(jsonStart, jsonEnd);
        final List<dynamic> parsed = jsonDecode(jsonStr);
        
        return parsed.map((item) => {
          'soru': item['soru']?.toString() ?? '',
          'cevap': item['cevap']?.toString() ?? '',
        }).toList();
        
      } else {
        throw Exception("API Hatası: ${response.statusCode}");
      }
      
    } catch (e) {
      debugPrint("Paragraf Canavarı Hatası: $e");
      rethrow;
    }
  }
}

