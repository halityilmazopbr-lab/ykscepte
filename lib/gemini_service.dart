import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
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

  // 🔥 DEMİR YUMRUK SORU ÜRETİM PROMPTu - Halüsinasyonu Sıfırla
  static String soruUretimPrompt({
    required String ders,
    required String konu,
    required String zorluk,
  }) => '''
SEN: ÖSYM formatına hakim, 20 yıllık tecrübeye sahip uzman bir YKS öğretmenisin.
ÖNEMLİ: Hata yapma lüksün YOK. %100 doğru, müfredata uygun sorular üreteceksin.

--- GÖREVİN ---
Ders: $ders
Konu: $konu  
Zorluk: $zorluk

--- DEMİR KURALLAR (KESİNLİKLE UY) ---
1. ASLA sohbet cümlesi kurma ("Tabii, işte sorunuz" gibi). 
2. ASLA Markdown formatı (```json) kullanma.
3. ASLA yanlış bilgi verme. Emin değilsen soru ÜRETME.
4. ASLA çeldiricisiz veya mantıksız şık yazma.
5. Matematiksel ifadeler için LaTeX kullan: \\( x^2 \\)
6. 5 şık olsun: A, B, C, D, E
7. Doğru cevap net ve tartışmasız olsun.
8. SADECE aşağıdaki JSON formatını döndür, başka HİÇBİR ŞEY yazma.

--- DOĞRU ÇIKTI ÖRNEĞİ (BUNU AYNEN TAKİP ET) ---
{
  "soru": "Aşağıdakilerden hangisi prokaryot hücrelerin özelliklerinden biridir?",
  "secenekler": {
    "A": "Çekirdek zarı bulundurma",
    "B": "Halkasal DNA taşıma",
    "C": "Mitokondri ile ATP üretme",
    "D": "Çok hücreli olma",
    "E": "Mitoz bölünme geçirme"
  },
  "dogru_sik": "B",
  "cozum": "Prokaryotlarda zarla çevrili organel yoktur ve DNA halkasaldır. A şıkkı yanlış çünkü çekirdek zarı yoktur."
}

--- ŞİMDİ SEN ÜRET ---
Yukarıdaki formata KELİME KELİME sadık kalarak '$konu' hakkında $zorluk seviye soruyu üret:
''';
  
  // 🔥 YKS AKILLI KOÇ: MASTER PROMPT (Ultimate Design)
  static String masterCoachPrompt({
    required Ogrenci ogrenci,
    required List<KonuTamamlama> bitenKonular,
    required int kalanGun,
    required String strateji,
  }) {
    String inventory = bitenKonular.map((t) => "${t.ders}: ${t.konu} (${t.tarih.toIso8601String()})").join(", ");
    
    return '''
### ROL VE KİMLİK ###
Sen, YKS (TYT/AYT) sınav sistemine hakim, stratejik planlama yapan üst düzey bir eğitim koçusun. Görevin, öğrencinin akademik geçmişini ve kalan süresini analiz ederek, ona en yüksek net artışını sağlayacak haftalık "Yol Haritası"nı JSON formatında çizmektir.

### ANALİZ VERİLERİ (GİRİŞ) ###
- Öğrenci: ${ogrenci.ad}
- Alan: ${ogrenci.alan}
- Kalan Gün: $kalanGun
- Günlük Çalışma Kapasitesi: ${ogrenci.dailyHours} Saat
- Zayıf Dersler: ${ogrenci.weakSubjects.join(", ")}
- STRATEJİ: $strateji
- BİTEN KONULAR (ENVANTER): [$inventory]

### ÇALIŞMA PRENSİPLERİ (Düşünce Zinciri) ###
1. **ENVANTER KONTROLÜ (Kritik):**
   - "biten_konular" listesindeki konuları ASLA "Konu Çalışması" olarak planlama. Bu vakit kaybıdır.
   - Bunun yerine, bu konuları unutmamak için aralara "30 dk Soru Çözümü/Tekrar" blokları (Sarmal Tekrar) serpiştir.
   - Zamanı, öğrencinin "bilmediği" ve sınavda çok çıkan konulara ayır.

2. **BİLİŞSEL YÜK DENGESİ:**
   - Aynı güne iki ağır "Sayısal" dersi (Örn: AYT Matematik + AYT Fizik) yan yana koyma. Araya sözel veya biyoloji gibi daha hafif dersler koy.
   - Zayıf olduğu dersleri (Örn: Fizik) tek blokta uzun süre vermek yerine, haftaya yayarak 40'ar dakikalık parçalar halinde ver (Pomodoro).

3. **ÖN KOŞUL ZİNCİRİ:**
   - Bir dersin temeli atılmadan ileri konusunu yazma. (Örn: "Hareket" bitmeden "Enerji" yazma).

4. **SABAH RUTİNİ:**
   - Her sabah (Pazar hariç) mutlaka "20 Paragraf + 20 Problem" ile başla.

### ÇIKTI FORMATI (Strict JSON) ###
Sadece aşağıdaki JSON yapısını döndür. Yorum yapma.

{
  "strateji_notu": "Kalan süren az olduğu için Limit konusuna ağırlık verdim. Bitirdiğin 'Üslü Sayılar' için Salı gününe tekrar koydum.",
  "haftalik_plan": [
    {
      "gun": "Pazartesi",
      "bloklar": [
        {
          "ders": "AYT Matematik",
          "konu": "Logaritma",
          "tip": "Konu Çalışması", 
          "sure_dk": 50,
          "oncelik": "Yüksek"
        },
        {
          "ders": "TYT Türkçe",
          "konu": "Paragraf",
          "tip": "Rutin",
          "sure_dk": 30,
          "oncelik": "Orta"
        }
      ]
    }
  ]
}
''';
  }

  // Legacy: Program oluşturma promptu
  static String programPrompt({
    required String alan,
    required String sinif,
    required String hedef,
    required int gunlukSaat,
    required String zayifDers,
    required bool okulVar,
  }) => '''
Sen bir YKS rehber öğretmenisin. Öğrenci için haftalık çalışma programı oluştur.

ÖĞRENCİ BİLGİLERİ:
- Sınıf: $sinif
- Alan: $alan
- Hedef: $hedef
- Günlük Çalışma Saati: $gunlukSaat saat
- Zayıf Ders: $zayifDers
- Okul Devam Ediyor mu: ${okulVar ? "Evet" : "Hayır"}

KURALLAR:
1. 7 günlük program oluştur (Pazartesi-Pazar).
2. Her gün için ders blokları belirle.
3. Zayıf olan derse daha fazla zaman ayır.
4. Pazar günü haftalık tekrar günü olsun.
5. Her saat bloğu 45-60 dk olsun.
6. Mola sürelerini dahil etme.

JSON FORMATI:
{
  "program": [
    {
      "gun": "Pazartesi",
      "bloklar": [
        {"saat_araligi": "09:00 - 10:00", "ders": "Matematik", "konu": "Fonksiyonlar", "tur": "Konu Çalışması"},
        {"saat_araligi": "10:00 - 11:00", "ders": "Türkçe", "konu": "Paragraf", "tur": "Soru Çözümü"}
      ]
    }
  ]
}

SADECE JSON DÖNDÜR, başka açıklama yapma.
''';
}

// 🔹 API AYARLARI
class _ApiConfig {
  static const int maxOutputTokens = 500;  // Cevap token sınırı
  static const double temperature = 0.3;   // ⚠️ DÜŞÜK - Halüsinasyonu Önle
  static const double questionTemperature = 0.2; // 🔒 Soru üretim için ekstra düşük
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
  // 🟡 5. AI AKILLI PROGRAM (Master Koç - Faz 3)
  // ═══════════════════════════════════════════════════════════════
  
  static Future<Map<String, dynamic>> akilliProgramOlustur({
    required Ogrenci ogrenci,
    required List<KonuTamamlama> bitenKonular,
  }) async {
    // 1. Kalan Gün Hesabı
    final yksTarihi = DateTime(2026, 6, 20); // Örnek tarih
    final kalanGun = yksTarihi.difference(DateTime.now()).inDays;
    
    // 2. Strateji Belirle (Faz 2)
    String strateji = kalanGun < 100 
        ? "KRİZ MODU: Sınava az kaldı. Detaylarda boğulma. Pareto Prensibi (80/20) uygula. En çok soru çıkan konulara odaklan. Konu anlatımını kıs, soru çözümünü artır." 
        : "STANDART MOD: Derinlemesine öğrenme. Temel eksik bırakmadan, sarmal yapıda ilerle.";

    // 3. Prompt İnşa Et
    final prompt = _Prompts.masterCoachPrompt(
      ogrenci: ogrenci,
      bitenKonular: bitenKonular,
      kalanGun: kalanGun,
      strateji: strateji,
    );

    try {
      debugPrint("🤖 AI Koç Analiz Yapıyor...");
      String jsonStr = await generateText(prompt);
      
      // JSON Temizleme
      jsonStr = jsonStr.replaceAll("```json", "").replaceAll("```", "").trim();
      
      final Map<String, dynamic> result = jsonDecode(jsonStr);
      
      // Cache'e kaydet
      final cacheKey = "master_coach:${ogrenci.id}";
      await CacheService.set(cacheKey, jsonStr);
      
      return result;
    } catch (e) {
      debugPrint("❌ AI Koç Hatası: $e");
      return {
        "strateji_notu": "Bağlantı hatası oluştu, ama azmin hala burada! Tekrar deneyelim.",
        "haftalik_plan": []
      };
    }
  }

  /// Eski uyumluluk için (Legacy)
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
              id: const Uuid().v4(),
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
  // 🔥 8. DEMİR YUMRUK SORU ÜRETİCİ - Halüsinasyon Korumalı
  // ═══════════════════════════════════════════════════════════════
  /// Güvenli soru üretimi - 3 aşamalı güvenlik duvarı:
  /// 1. Girişte: ÖSYM uzmanı rolü ve sert kurallar
  /// 2. İşlemde: Temperature 0.2 ile yaratıcılık (halüsinasyon) kısıtlaması
  /// 3. Çıkışta: JSON format kontrolü, başarısızsa tekrar deneme
  static Future<Map<String, dynamic>?> soruUret({
    required String ders,
    required String konu,
    String zorluk = "Orta",
    int maxRetry = 3,
  }) async {
    final prompt = _Prompts.soruUretimPrompt(
      ders: ders,
      konu: konu,
      zorluk: zorluk,
    );

    // 3 deneme hakkı - başarısız olursa tekrar dene
    for (int attempt = 1; attempt <= maxRetry; attempt++) {
      try {
        debugPrint("🎯 Soru üretim denemesi: $attempt/$maxRetry");
        
        // Gemini API'yi düşük temperature ile çağır
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_geminiKey'
        );
        
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [{'parts': [{'text': prompt}]}],
            'generationConfig': {
              'temperature': _ApiConfig.questionTemperature, // 🔒 0.2 - Çok düşük
              'topK': 40,
              'topP': 0.95,
              'maxOutputTokens': 800,
            }
          }),
        );
        
        if (response.statusCode != 200) {
          debugPrint("❌ API Hatası: ${response.statusCode}");
          continue; // Tekrar dene
        }
        
        final data = jsonDecode(response.body);
        String? rawText = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        
        if (rawText == null || rawText.isEmpty) {
          debugPrint("❌ Boş cevap geldi");
          continue;
        }
        
        // JSON temizleme
        rawText = rawText
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        
        // JSON'un başlangıç ve bitişini bul
        final jsonStart = rawText.indexOf('{');
        final jsonEnd = rawText.lastIndexOf('}') + 1;
        
        if (jsonStart < 0 || jsonEnd <= jsonStart) {
          debugPrint("❌ JSON formatı bulunamadı: $rawText");
          continue;
        }
        
        final jsonStr = rawText.substring(jsonStart, jsonEnd);
        final Map<String, dynamic> parsed = jsonDecode(jsonStr);
        
        // Format doğrulama
        if (!parsed.containsKey('soru') || 
            !parsed.containsKey('secenekler') || 
            !parsed.containsKey('dogru_sik')) {
          debugPrint("❌ Eksik alan: ${parsed.keys}");
          continue;
        }
        
        // Şık sayısı kontrolü
        final secenekler = parsed['secenekler'] as Map<String, dynamic>?;
        if (secenekler == null || secenekler.length < 4) {
          debugPrint("❌ Yetersiz şık sayısı: ${secenekler?.length}");
          continue;
        }
        
        debugPrint("✅ Soru başarıyla üretildi: ${parsed['soru']}");
        return parsed;
        
      } catch (e) {
        debugPrint("❌ Deneme $attempt hatası: $e");
        continue;
      }
    }
    
    // Tüm denemeler başarısız
    debugPrint("⚠️ $maxRetry deneme de başarısız oldu");
    return null;
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

