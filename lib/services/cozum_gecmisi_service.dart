import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Çözüm Geçmişi Yönetim Servisi
/// 
/// Öğrencinin çözdüğü soru ID'lerini yerel hafızada (Hive) tutar.
/// Firebase ile senkronize eder (uygulama silme durumu için).
/// 
/// Amaç: "Exclusion Problem"i çözmek - 500+ soruyu NOT IN ile 
/// sorgulayamayız, bu yüzden client-side filtreleme yapıyoruz.
class CozumGecmisiService {
  static const String boxName = 'cozulen_sorular_box';
  static const String firestoreCollection = 'cozulen_sorular';

  /// App başlangıcında Hive'ı initialize et
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(boxName);
    debugPrint("✅ CozumGecmisiService: Hive initialized");
  }

  /// Hive box'ına erişim
  Box<String> get _box => Hive.box<String>(boxName);

  /// ============================================================
  /// 1. SORU ÇÖZÜLDÜ OLARAK İŞARETLE
  /// ============================================================
  /// Hem yerel hafızaya (Hive) hem de Firebase'e kaydeder.
  Future<void> soruCozulduOlarakIsaretle(
    String soruId, {
    String? ogrenciId,
    bool? dogruMu,
  }) async {
    try {
      // 1. Yerel hafızaya kaydet (Hive)
      if (!_box.values.contains(soruId)) {
        await _box.add(soruId);
        debugPrint("📝 Soru yerel geçmişe eklendi: $soruId");
      }

      // 2. Firebase'e kaydet (senkronizasyon için)
      if (ogrenciId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(ogrenciId)
            .collection(firestoreCollection)
            .doc(soruId)
            .set({
          'cozulmeTarihi': FieldValue.serverTimestamp(),
          'dogruMu': dogruMu,
        }, SetOptions(merge: true));
        
        debugPrint("☁️ Soru Firebase'e senkronize edildi: $soruId");
      }
    } catch (e) {
      debugPrint("❌ Soru işaretleme hatası: $e");
    }
  }

  /// ============================================================
  /// 2. DAHA ÖNCE ÇÖZÜLDÜ MÜ KONTROLÜ
  /// ============================================================
  /// Yerel hafızada (Hive) bu ID var mı diye bakar.
  /// Çok hızlı (<1ms), sunucuya gitmez.
  bool dahaOnceCozulduMu(String soruId) {
    return _box.values.contains(soruId);
  }

  /// ============================================================
  /// 3. TÜM ÇÖZÜLEN ID'LERI GETİR
  /// ============================================================
  List<String> getCozulenIdListesi() {
    return _box.values.toList();
  }

  /// Çözülen soru sayısı
  int get cozulenSoruSayisi => _box.length;

  /// ============================================================
  /// 4. FİREBASE SENKRONİZASYONU
  /// ============================================================
  /// Uygulama ilk açıldığında veya kullanıcı giriş yaptığında çağrılır.
  /// Firebase'deki geçmişi yerel Hive'a indirip senkronize eder.
  /// 
  /// Use Case: Öğrenci uygulamayı silip tekrar yüklerse, 
  /// geçmişini kaybetmemesi için.
  Future<void> gecmisiSenkronizeEt(String ogrenciId) async {
    try {
      debugPrint("🔄 Geçmiş senkronizasyonu başlatılıyor...");

      // Eğer yerel hafıza zaten doluysa, sync'e gerek yok
      // (Kullanıcı uygulamayı silmemiş demektir)
      if (_box.isNotEmpty) {
        debugPrint("✅ Yerel geçmiş mevcut (${_box.length} soru), sync atlandı.");
        return;
      }

      // Firebase'den çözülen soruları çek
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(ogrenciId)
          .collection(firestoreCollection)
          .get();

      // Hive'a ekle
      for (var doc in snapshot.docs) {
        if (!_box.values.contains(doc.id)) {
          await _box.add(doc.id);
        }
      }

      debugPrint("✅ Geçmiş senkronize edildi: ${_box.length} soru indirildi.");
    } catch (e) {
      debugPrint("❌ Geçmiş senkronizasyon hatası: $e");
    }
  }

  /// ============================================================
  /// 5. YARDIMCI FONKSİYONLAR
  /// ============================================================
  
  /// Tüm yerel geçmişi temizle (test/debug için)
  Future<void> gecmisiTemizle() async {
    await _box.clear();
    debugPrint("🗑️ Tüm geçmiş temizlendi");
  }

  /// İstatistikler
  Map<String, dynamic> getIstatistikler() {
    return {
      'toplamCozulen': _box.length,
      'sonCozulen': _box.isNotEmpty ? _box.values.last : null,
    };
  }
}
