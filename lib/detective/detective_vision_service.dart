/// 🕵️ NET-X Dedektifi - Vision Service (v2)
/// Google Generative AI paketi ile optik form tarama
/// 
/// Bu servis resmi google_generative_ai paketini kullanır.
/// Daha stabil ve güvenilir sonuçlar sağlar.

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detective_models.dart';

/// 🔹 Gemini API Key
const String _geminiKey = "AIzaSyBI6JuUxYPZ24valrMHrRvRx4Jge-tVvJg";

/// 📸 Optik Form Tarama Servisi (v2 - Official SDK)
class DetectiveVisionService {
  static final DetectiveVisionService _instance = DetectiveVisionService._internal();
  factory DetectiveVisionService() => _instance;
  DetectiveVisionService._internal();

  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Gemini modeli (singleton)
  late final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _geminiKey,
  );

  // ═══════════════════════════════════════════════════════════════
  // 🔢 GÜNLÜK LİMİT KONTROLÜ
  // ═══════════════════════════════════════════════════════════════

  static const int gunlukTaramaLimiti = 5;

  /// Bugün kaç tarama yapıldı?
  Future<int> getBugunTaramaSayisi(String ogrenciId) async {
    final prefs = await SharedPreferences.getInstance();
    final bugun = DateTime.now().toIso8601String().substring(0, 10);
    final key = 'detective_scans_${ogrenciId}_$bugun';
    return prefs.getInt(key) ?? 0;
  }

  /// Tarama hakkı var mı?
  Future<bool> taramaHakkiVarMi(String ogrenciId) async {
    final bugunSayisi = await getBugunTaramaSayisi(ogrenciId);
    return bugunSayisi < gunlukTaramaLimiti;
  }

  /// Kalan tarama hakkı
  Future<int> getKalanTaramaHakki(String ogrenciId) async {
    final bugunSayisi = await getBugunTaramaSayisi(ogrenciId);
    return (gunlukTaramaLimiti - bugunSayisi).clamp(0, gunlukTaramaLimiti);
  }

  /// Tarama sayısını artır
  Future<void> _artirTaramaSayisi(String ogrenciId) async {
    final prefs = await SharedPreferences.getInstance();
    final bugun = DateTime.now().toIso8601String().substring(0, 10);
    final key = 'detective_scans_${ogrenciId}_$bugun';
    final mevcut = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, mevcut + 1);
  }

  // ═══════════════════════════════════════════════════════════════
  // 📷 KAMERA İŞLEMLERİ
  // ═══════════════════════════════════════════════════════════════

  /// Kameradan fotoğraf çek
  Future<XFile?> fotografCek() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // Hız için düşük kalite yeterli
        maxWidth: 1920,
      );
    } catch (e) {
      debugPrint('📷 Fotoğraf çekme hatası: $e');
      return null;
    }
  }

  /// Galeriden fotoğraf seç
  Future<XFile?> galeridenSec() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 1920,
      );
    } catch (e) {
      debugPrint('🖼️ Galeri seçme hatası: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🤖 GEMİNİ VİSİON API (v2 - Official SDK)
  // ═══════════════════════════════════════════════════════════════

  /// Optik formu tara ve cevapları çıkar
  /// Returns: {1: 'A', 2: 'C', 3: null, ...} (null = boş)
  Future<TaramaSonucu?> taraOptikForm(XFile image, String ogrenciId) async {
    // Limit kontrolü
    if (!await taramaHakkiVarMi(ogrenciId)) {
      throw Exception('Günlük tarama limitine ulaştınız! (5/5)');
    }

    try {
      debugPrint('🔍 NETX: Görüntü Gemini\'ye gönderiliyor...');
      
      // Görseli byte olarak oku
      final Uint8List imageBytes;
      if (kIsWeb) {
        imageBytes = await image.readAsBytes();
      } else {
        imageBytes = await File(image.path).readAsBytes();
      }

      // Prompt oluştur
      final prompt = TextPart('''
Sen bir optik form okuyucusun. Bu görseldeki soruların şıklarını analiz et.

Çıktıyı SADECE saf bir JSON objesi olarak ver. Markdown (```json) kullanma.

Format örneği:
{"1": "A", "2": "C", "3": null, "4": "B", "5": "WRONG"}

Kurallar:
- İşaretli şıkkı (A, B, C, D, E) büyük harf olarak yaz.
- Boşsa null yaz (tırnak olmadan).
- Karalama/İptal/Çoklu işaretleme varsa "WRONG" yaz.
- Soru numaralarını 1'den başlayarak sırayla yaz.
- Görseldeki TÜM soruları dahil et.

SADECE JSON VER, başka hiçbir şey yazma.
''');

      // İsteği gönder
      final content = Content.multi([
        prompt,
        DataPart('image/jpeg', imageBytes),
      ]);

      final response = await _model.generateContent([content]);
      final rawText = response.text;
      
      debugPrint('🔍 NETX: Ham Cevap: $rawText');

      if (rawText == null || rawText.isEmpty) {
        throw Exception('AI yanıt vermedi');
      }

      // JSON'u parse et
      final cevaplar = _parseOptikCevaplar(rawText);
      
      if (cevaplar.isEmpty) {
        throw Exception('Fotoğraftan cevap okunamadı. Lütfen daha net bir fotoğraf çekin.');
      }

      // Limit sayacını artır
      await _artirTaramaSayisi(ogrenciId);

      debugPrint('✅ NETX: ${cevaplar.length} soru tespit edildi!');
      
      return TaramaSonucu(
        ogrenciCevaplari: cevaplar,
        guvenSkoru: 0.85,
      );

    } catch (e) {
      debugPrint('❌ Optik form tarama hatası: $e');
      rethrow;
    }
  }

  /// Cevap anahtarını tara
  Future<Map<int, String>?> taraCevapAnahtari(XFile image, String ogrenciId) async {
    // Limit kontrolü
    if (!await taramaHakkiVarMi(ogrenciId)) {
      throw Exception('Günlük tarama limitine ulaştınız! (5/5)');
    }

    try {
      debugPrint('🔍 NETX: Cevap anahtarı taranıyor...');
      
      // Görseli byte olarak oku
      final Uint8List imageBytes;
      if (kIsWeb) {
        imageBytes = await image.readAsBytes();
      } else {
        imageBytes = await File(image.path).readAsBytes();
      }

      // Prompt oluştur
      final prompt = TextPart('''
Sen bir cevap anahtarı okuyucusun. Bu görseldeki doğru cevapları analiz et.

Çıktıyı SADECE saf bir JSON objesi olarak ver. Markdown (```json) kullanma.

Format örneği:
{"1": "A", "2": "C", "3": "B", "4": "D", "5": "A"}

Kurallar:
- Her sorunun doğru cevabını (A, B, C, D, E) büyük harf olarak yaz.
- Soru numaralarını 1'den başlayarak sırayla yaz.
- TÜM soruların cevabını oku, boş bırakma.

SADECE JSON VER, başka hiçbir şey yazma.
''');

      // İsteği gönder
      final content = Content.multi([
        prompt,
        DataPart('image/jpeg', imageBytes),
      ]);

      final response = await _model.generateContent([content]);
      final rawText = response.text;
      
      debugPrint('🔍 NETX: Cevap Anahtarı Ham Veri: $rawText');

      if (rawText == null || rawText.isEmpty) {
        throw Exception('AI yanıt vermedi');
      }

      // JSON'u parse et (null'ları filtrele - cevap anahtarında boş olmaz)
      final cevaplarRaw = _parseOptikCevaplar(rawText);
      final cevaplar = <int, String>{};
      cevaplarRaw.forEach((key, value) {
        if (value != null && value != 'WRONG') {
          cevaplar[key] = value;
        }
      });

      if (cevaplar.isEmpty) {
        throw Exception('Cevap anahtarı okunamadı. Lütfen daha net bir fotoğraf çekin.');
      }

      // Limit sayacını artır
      await _artirTaramaSayisi(ogrenciId);

      debugPrint('✅ NETX: ${cevaplar.length} cevap tespit edildi!');
      
      return cevaplar;

    } catch (e) {
      debugPrint('❌ Cevap anahtarı tarama hatası: $e');
      rethrow;
    }
  }

  /// JSON cevaplarını parse et
  Map<int, String?> _parseOptikCevaplar(String text) {
    try {
      // Markdown code block'ları temizle
      String cleanText = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // JSON'u bul (ilk { ile son } arası)
      final startIndex = cleanText.indexOf('{');
      final endIndex = cleanText.lastIndexOf('}');
      
      if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
        debugPrint('⚠️ JSON bulunamadı: $cleanText');
        return {};
      }

      final jsonStr = cleanText.substring(startIndex, endIndex + 1);
      final Map<String, dynamic> parsed = jsonDecode(jsonStr);

      final result = <int, String?>{};
      parsed.forEach((key, value) {
        final soruNo = int.tryParse(key);
        if (soruNo != null) {
          if (value == null || value.toString().toLowerCase() == 'null') {
            result[soruNo] = null;
          } else if (value.toString().toUpperCase() == 'WRONG') {
            result[soruNo] = null; // WRONG = boş sayılır
          } else {
            result[soruNo] = value.toString().toUpperCase();
          }
        }
      });

      return result;

    } catch (e) {
      debugPrint('❌ JSON parse hatası: $e');
      return {};
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 💾 YAYIN KAYIT
  // ═══════════════════════════════════════════════════════════════

  /// Yayını (cevap anahtarını) Firestore'a kaydet
  Future<YayinModel> kaydetYayin({
    required String ad,
    required String kategori,
    required Map<int, String> cevapAnahtari,
    required String olusturanId,
    bool herkeseAcik = true,
  }) async {
    try {
      final docRef = _db.collection('answerKeys').doc();
      
      final yayin = YayinModel(
        id: docRef.id,
        ad: ad,
        kategori: kategori,
        cevapAnahtari: cevapAnahtari,
        soruSayisi: cevapAnahtari.length,
        olusturanId: olusturanId,
        olusturmaTarihi: DateTime.now(),
        herkeseAcik: herkeseAcik,
      );

      await docRef.set(yayin.toJson());
      debugPrint('✅ Yayın kaydedildi: ${yayin.ad} (${yayin.soruSayisi} soru)');
      
      return yayin;
    } catch (e) {
      debugPrint('❌ Yayın kaydetme hatası: $e');
      rethrow;
    }
  }

  /// Kaydedilmiş yayınları getir
  Future<List<YayinModel>> getYayinlar({String? kategori}) async {
    try {
      Query query = _db.collection('answerKeys')
          .where('herkeseAcik', isEqualTo: true)
          .orderBy('olusturmaTarihi', descending: true);

      if (kategori != null) {
        query = query.where('kategori', isEqualTo: kategori);
      }

      final snapshot = await query.limit(50).get();
      
      return snapshot.docs
          .map((doc) => YayinModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('❌ Yayın listesi hatası: $e');
      return [];
    }
  }

  /// Kullanıcının kendi yayınlarını getir
  Future<List<YayinModel>> getKullanicininYayinlari(String ogrenciId) async {
    try {
      final snapshot = await _db.collection('answerKeys')
          .where('olusturanId', isEqualTo: ogrenciId)
          .orderBy('olusturmaTarihi', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => YayinModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('❌ Kullanıcı yayınları hatası: $e');
      return [];
    }
  }
}
