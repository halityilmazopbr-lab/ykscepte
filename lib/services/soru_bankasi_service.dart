import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/soru_model.dart';
import 'cozum_gecmisi_service.dart'; // YENİ: Hybrid filtering için

/// Yaşayan Soru Bankası - Ana Yönetim Servisi
/// 
/// Bu servis "Önce havuza bak, yoksa üret" mantığıyla çalışır.
/// Her soru üretimi maliyetlidir, ama havuzdan getirmek ücretsizdir.
/// 
/// YENİ: Hybrid Filtering ile aynı soruyu tekrar göstermez.
class SoruBankasiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'havuz_sorulari';
  final CozumGecmisiService _gecmisService = CozumGecmisiService(); // YENİ
  
  // Gemini API instance (API key'i environment'tan alacağız)
  late final GenerativeModel _geminiModel;

  SoruBankasiService() {
    // API key'i environment variable veya config'den al
    const apiKey = String.fromEnvironment('GEMINI_API_KEY', 
        defaultValue: 'AIzaSyDLG8RbIiPnkHOOi_P5R02SN_Mhvu3L2RY'); // Fallback
    
    _geminiModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7, // Yaratıcılık için biraz yüksek
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
  }

  /// ============================================================
  /// 1. HYBRID SORU GETİRME (Exclusion Problem Çözümü)
  /// ============================================================
  /// Mantık: "Batch Getir → Yerel Eleye → Temiz Soruyu Göster"
  /// 
  /// Adımlar:
  /// 1. Firebase'den 20 soru çek (batch)
  /// 2. Her birini yerel geçmişle karşılaştır (Hive)
  /// 3. Çözülmemiş olanı döndür
  /// 4. Bulamazsa tekrar dene (max 3 attempt)
  /// 5. Hala bulamazsa AI'ya ürettir
  /// 
  /// Maliyet: ~1 Firestore read (batch) + ~0ms yerel filtreleme
  Future<SoruModel> soruGetir({
    required String ders,
    required String konu,
    String? ogrenciId, // Geçmiş kaydı için
  }) async {
    try {
      debugPrint("📚 Soru talebi: $ders > $konu");
      
      int denemeSayisi = 0;
      const maxDeneme = 3;
      
      // DÖNGÜ: Temiz soru bulana kadar dene
      while (denemeSayisi < maxDeneme) {
        debugPrint("🔄 Deneme ${denemeSayisi + 1}/$maxDeneme");
        
        // ADIM 1: Firebase'den BATCH soru çek
        var querySnapshot = await _db
            .collection(collectionPath)
            .where('ders', isEqualTo: ders)
            .where('konu', isEqualTo: konu)
            .where('onayliMi', isEqualTo: true)
            .where('rapor', isLessThan: 5)
            .limit(20) // Batch size: 20 soru
            .get();

        if (querySnapshot.docs.isEmpty) {
          debugPrint("⚠️ Havuz boş, AI devreye giriyor...");
          return await _yeniSoruUretVeKaydet(ders, konu);
        }

        // ADIM 2: Client-Side Filtreleme
        debugPrint("🔍 ${querySnapshot.docs.length} soru getirildi, filtreleniyor...");
        
        for (var doc in querySnapshot.docs) {
          String soruId = doc.id;
          
          // Yerel geçmişte var mı kontrol et (Hive - <1ms)
          if (!_gecmisService.dahaOnceCozulduMu(soruId)) {
            // ✅ TEMİZ SORU BULUNDU!
            debugPrint("✅ Temiz soru bulundu: $soruId");
            
            var soru = SoruModel.fromMap(doc.data(), soruId);
            _goruntulenmeArtir(soruId);
            
            return soru;
          }
        }

        // ADIM 3: Batch'deki tüm sorular çözülmüş, tekrar dene
        debugPrint("⏭️ Batch'deki ${querySnapshot.docs.length} soru zaten çözülmüş, tekrar deneniyor...");
        denemeSayisi++;
        
        // Not: Gerçek implementasyonda random offset veya
        // farklı sayfa çekmek için strategy eklenebilir
      }

      // ADIM 4: Havuz tükendi, AI'ya ürettir
      debugPrint("🤖 $maxDeneme denemede temiz soru bulunamadı. Havuz tükendi, AI üretiyor...");
      return await _yeniSoruUretVeKaydet(ders, konu);
      
    } catch (e) {
      debugPrint("❌ Hata: $e");
      throw Exception("Soru getirilemedi: $e");
    }
  }

  /// ============================================================
  /// 2. AI İLE SORU ÜRETME VE KAYDETME (Private Helper)
  /// ============================================================
  Future<SoruModel> _yeniSoruUretVeKaydet(String ders, String konu) async {
    try {
      debugPrint("🤖 Gemini AI'dan soru üretiliyor...");
      
      // ÖSYM Profesyonel Prompt Engineering
      final prompt = '''
### ROL VE KİMLİK ###
Sen, ÖSYM (Öğrenci Seçme ve Yerleştirme Merkezi) soru hazırlama komitesinde 25 yıl görev yapmış, TYT ve AYT müfredatının en ince detaylarına hakim, "Baş Soru Hazırlayıcı"sın. Görevin, milyonlarca öğrencinin kaderini belirleyecek ciddiyette, akademik olarak kusursuz, pedagojik olarak ölçücü ve teknik olarak hatasız sorular üretmektir.

### ÇALIŞMA ALGORİTMASI (Bunu Adım Adım Uygula) ###
Bir soru üretmeden önce arka planda şu 4 adımı tamamla:
1. **Müfredat Kontrolü:** İstenen konu MEB güncel müfredatında var mı? (Örn: Matris/Determinant kalktı, sorma.)
2. **Kurgu:** TYT ise "yeni nesil" hikayeli, AYT ise "kazanım odaklı" akademik kurgu yap.
3. **İç Çözüm (Zorunlu):** Soruyu tasarladıktan sonra, bir öğrenci gibi çöz. Cevabın şıklarda kesin ve tek olduğundan emin ol. İşlem hatası olup olmadığını kontrol et.
4. **JSON Kodlama:** Soruyu sadece ve sadece saf JSON formatına dök.

### KATI KURALLAR (ASLA İHLAL ETME) ###
1. **ÇIKTI FORMATI:** Sadece JSON döndür. Başka hiçbir metin, "İşte sorunuz", "```json" etiketi veya markdown kullanma. Doğrudan { ile başla } ile bitir.
2. **MATEMATİK DİLİ (LaTeX):**
   * Tüm formüller, değişkenler (\$x, y\$) ve sayılar LaTeX formatında yazılmalıdır.
   * JSON içinde escape karakteri kullan: \\ yerine \\\\ kullanmalısın. (Örn: \$\\\\frac{1}{2}\$ şeklinde)
3. **ŞIKLAR:**
   * Şıklar (A, B, C, D, E) sayısal veya mantıksal bir sırayla (küçükten büyüğe) dizilmelidir.
   * Çeldiriciler (yanlış şıklar) rastgele sayılar olmamalı, öğrencinin yapabileceği muhtemel işlem hatalarının sonuçları olmalıdır.
4. **DİL:** İstanbul Türkçesi, akademik, net ve imla kurallarına %100 uygun.

### SORU İSTEĞİ ###
Ders: $ders
Konu: $konu
Zorluk: Orta (2)

### JSON ŞEMASI (Bu şablona sadık kal) ###
{
  "soru_metni": "Sorunun kökü ve hikayesi. LaTeX: \$\\\\sqrt{x^2+4}\$",
  "gorsel_gereksinimi": false,
  "siklar": ["A içeriği", "B içeriği", "C içeriği", "D içeriği", "E içeriği"],
  "dogru_cevap": "Doğru şıkkın içeriği (şıklar listesinden birisi)",
  "dogru_sik_index": 0,
  "cozum_detayli": "Adım adım, pedagojik çözüm metni. LaTeX kullan.",
  "zorluk_derecesi": 2,
  "konu_etiketleri": ["$ders", "$konu", "Alt Başlık"],
  "kazanim_kodu": "Tahmini MEB kazanımı (Örn: 12.1.2.1)"
}

### ÖRNEK (Few-Shot Prompting) ###
Girdi: Ders: Matematik, Konu: Türev
Çıktı:
{
  "soru_metni": "Gerçel sayılar kümesi üzerinde tanımlı f fonksiyonu \$f(x) = x^3 - 3x^2 + k\$ biçimindedir. f fonksiyonunun yerel minimum değeri 1 olduğuna göre, k kaçtır?",
  "gorsel_gereksinimi": false,
  "siklar": ["1", "3", "5", "7", "9"],
  "dogru_cevap": "5",
  "dogru_sik_index": 2,
  "cozum_detayli": "Türev alıp sıfıra eşitleyelim. \$f'(x) = 3x^2 - 6x = 0\$ ise \$3x(x-2)=0\$. Kökler \$x=0\$ ve \$x=2\$. İşaret tablosu yapıldığında x=2 noktasında yerel minimum olduğu görülür. \$f(2)=1\$ verilmiş. \$2^3 - 3(2^2) + k = 1\$ ise \$8 - 12 + k = 1\$ buradan \$-4 + k = 1\$ ve \$k=5\$ bulunur.",
  "zorluk_derecesi": 2,
  "konu_etiketleri": ["Matematik", "Türev", "Ekstremum Noktalar"],
  "kazanim_kodu": "12.4.1.3"
}

ŞİMDİ, YUKARIDAKI KURALLARA TAM OLARAK UYGUN ŞEKİLDE BİR SORU OLUŞTUR VE SADECE JSON DÖNDÜR:
''';

      final content = [Content.text(prompt)];
      final response = await _geminiModel.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        throw Exception("AI boş yanıt döndü");
      }

      debugPrint("🤖 AI Yanıtı alındı: ${response.text!.substring(0, 100)}...");

      // JSON parse et
      Map<String, dynamic> soruData;
      try {
        // Bazen AI ```json ... ``` formatında dönebilir, temizleyelim
        String cleanedResponse = response.text!
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        
        soruData = jsonDecode(cleanedResponse);
      } catch (e) {
        debugPrint("❌ JSON parse hatası: $e");
        throw Exception("AI yanıtı JSON formatında değil");
      }

      // Validation - Yeni şemaya göre
      if (!soruData.containsKey('soru_metni') || 
          !soruData.containsKey('siklar') || 
          !soruData.containsKey('dogru_cevap')) {
        throw Exception("AI eksik veri döndü");
      }

      if ((soruData['siklar'] as List).length != 5) {
        throw Exception("Şık sayısı 5 olmalı");
      }

      // SoruModel oluştur - ÖSYM standart alanlarıyla
      var yeniSoru = SoruModel(
        soruMetni: soruData['soru_metni'],
        siklar: List<String>.from(soruData['siklar']),
        dogruCevap: soruData['dogru_cevap'],
        cozumAciklamasi: soruData['cozum_detayli'],
        ders: ders,
        konu: konu,
        zorlukDerecesi: soruData['zorluk_derecesi'],
        konuEtiketleri: soruData['konu_etiketleri'] != null
            ? List<String>.from(soruData['konu_etiketleri'])
            : null,
        kazanimKodu: soruData['kazanim_kodu'],
        gorselGereksinimi: soruData['gorsel_gereksinimi'],
        olusturulmaTarihi: DateTime.now(),
        onayliMi: true, // İlk versiyonda direkt onaylı
        kaynak: "AI",
      );

      // Firestore'a kaydet
      debugPrint("💾 Soru veritabanına kaydediliyor...");
      DocumentReference docRef = await _db
          .collection(collectionPath)
          .add(yeniSoru.toMap());
      
      yeniSoru.id = docRef.id;
      
      debugPrint("✅ Yeni soru oluşturuldu ve kaydedildi (ID: ${docRef.id})");
      
      return yeniSoru;
    } catch (e) {
      debugPrint("❌ AI soru üretme hatası: $e");
      throw Exception("Soru üretilemedi: $e");
    }
  }

  /// ============================================================
  /// 3. İSTATİSTİK YÖNETİMİ
  /// ============================================================
  
  /// Görüntülenme sayacını artır (fire-and-forget)
  void _goruntulenmeArtir(String soruId) {
    _db.collection(collectionPath).doc(soruId).update({
      'goruntulenme': FieldValue.increment(1),
    }).catchError((e) => debugPrint("Görüntülenme güncellenemedi: $e"));
  }

  /// Kullanıcı cevap verdiğinde çağrılır
  /// YENİ: Çözülen soruyu geçmişe kaydeder (Hive + Firebase)
  Future<void> sonucKaydet(
    String soruId, 
    bool dogruMu,
    {String? ogrenciId} // YENİ: Geçmiş kaydı için
  ) async {
    if (soruId.isEmpty) return;

    try {
      // 1. Soru istatistiklerini güncelle (mevcut)
      await _db.collection(collectionPath).doc(soruId).update({
        'goruntulenme': FieldValue.increment(1),
        if (dogruMu) 'dogruSayisi': FieldValue.increment(1)
        else 'yanlisSayisi': FieldValue.increment(1),
      });
      
      debugPrint("📊 İstatistik güncellendi: $soruId (Doğru: $dogruMu)");
      
      // 2. YENİ: Çözülen soruyu geçmişe kaydet
      if (ogrenciId != null) {
        await _gecmisService.soruCozulduOlarakIsaretle(
          soruId,
          ogrenciId: ogrenciId,
          dogruMu: dogruMu,
        );
        debugPrint("📝 Soru geçmişe kaydedildi");
      }
    } catch (e) {
      debugPrint("❌ İstatistik güncellenemedi: $e");
    }
  }

  /// ============================================================
  /// 4. GERİ BİLDİRİM YÖNETİMİ (Quality Control)
  /// ============================================================
  
  /// Kullanıcı soruyu beğendiğinde
  Future<void> soruBegen(String soruId, bool begendiMi) async {
    if (soruId.isEmpty) return;

    try {
      await _db.collection(collectionPath).doc(soruId).update({
        if (begendiMi) 'begeni': FieldValue.increment(1)
        else 'begenmeme': FieldValue.increment(1),
      });
      
      debugPrint("👍 Beğeni kaydedildi: $soruId");
    } catch (e) {
      debugPrint("❌ Beğeni kaydedilemedi: $e");
    }
  }

  /// Kullanıcı soruyu raporladığında (Karantina mekanizması)
  Future<void> soruRaporla(String soruId, String sebep) async {
    if (soruId.isEmpty) return;

    try {
      // Rapor sayısını artır
      await _db.collection(collectionPath).doc(soruId).update({
        'rapor': FieldValue.increment(1),
      });

      // Sorunun güncel halini al ve karantina kontrolü yap
      var doc = await _db.collection(collectionPath).doc(soruId).get();
      if (doc.exists) {
        var soru = SoruModel.fromMap(doc.data()!, doc.id);
        
        // Karantina koşulu: 5+ rapor VEYA %10+ rapor oranı
        if (soru.karantinada) {
          debugPrint("🚨 Soru karantinaya alındı: $soruId");
          await _db.collection(collectionPath).doc(soruId).update({
            'onayliMi': false,
          });
        }
      }
      
      debugPrint("🚩 Rapor kaydedildi: $soruId (Sebep: $sebep)");
    } catch (e) {
      debugPrint("❌ Rapor kaydedilemedi: $e");
    }
  }

  /// ============================================================
  /// 5. ADMIN / ANALİZ FONKSİYONLARI
  /// ============================================================
  
  /// Toplam soru sayısı
  Future<int> toplamSoruSayisi() async {
    var snapshot = await _db.collection(collectionPath).count().get();
    return snapshot.count ?? 0;
  }

  /// Ders/Konu bazlı istatistikler
  Future<Map<String, int>> dersIstatistikleri() async {
    var snapshot = await _db.collection(collectionPath).get();
    Map<String, int> istatistik = {};
    
    for (var doc in snapshot.docs) {
      String ders = doc.data()['ders'] ?? 'Bilinmeyen';
      istatistik[ders] = (istatistik[ders] ?? 0) + 1;
    }
    
    return istatistik;
  }
}
