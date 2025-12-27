import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/odul_anket_models.dart';

/// 🗳️ HAFTALIK ÖDÜL ANKETİ SERVİSİ
/// Oy verme, anket oluşturma, kazanan belirleme
class AnketService {
  static final AnketService _instance = AnketService._internal();
  factory AnketService() => _instance;
  AnketService._internal();
  
  final _db = FirebaseFirestore.instance;
  
  // Koleksiyon isimleri
  static const String _anketlerCollection = 'haftalik_anketler';
  static const String _oylarCollection = 'anket_oylari';
  static const String _urunlerCollection = 'odul_magazasi';
  
  // ============================================
  // 📊 ANKET YÖNETİMİ
  // ============================================
  
  /// Mevcut aktif anketi getir
  Future<HaftalikOdulAnketi?> aktifAnketiGetir() async {
    try {
      final now = DateTime.now();
      final snapshot = await _db.collection(_anketlerCollection)
          .where('kapandi', isEqualTo: false)
          .orderBy('baslangicTarihi', descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      final anket = HaftalikOdulAnketi.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
      
      // Aktif mi kontrol et
      if (now.isAfter(anket.baslangicTarihi) && now.isBefore(anket.bitisTarihi)) {
        return anket;
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Aktif anket getirme hatası: $e');
      return null;
    }
  }
  
  /// Bu haftanın anketini oluştur (Cuma 20:00 - Cumartesi 20:00)
  Future<HaftalikOdulAnketi?> haftaninAnketiniOlustur({
    double minFiyat = 50.0,
    double maxFiyat = 150.0,
  }) async {
    try {
      // Bu haftanın Cuma ve Cumartesi tarihlerini hesapla
      final now = DateTime.now();
      final weekday = now.weekday; // 1 = Pazartesi, 5 = Cuma, 6 = Cumartesi
      
      // En yakın Cuma'yı bul
      int daysUntilFriday = (5 - weekday) % 7;
      if (daysUntilFriday == 0 && now.hour >= 20) {
        // Bugün Cuma ve saat 20'den sonra, gelecek haftaya ayarla
        daysUntilFriday = 7;
      }
      
      final cumaGunu = DateTime(now.year, now.month, now.day + daysUntilFriday, 20, 0);
      final cumartesiGunu = cumaGunu.add(const Duration(hours: 24));
      
      // Hafta numarasını hesapla
      final haftaNo = _haftaNumarasiHesapla(cumaGunu);
      
      // Bu hafta için anket var mı kontrol et
      final existing = await _db.collection(_anketlerCollection)
          .where('haftaNumarasi', isEqualTo: haftaNo)
          .get();
      
      if (existing.docs.isNotEmpty) {
        return HaftalikOdulAnketi.fromMap(existing.docs.first.data(), existing.docs.first.id);
      }
      
      // Fiyat aralığındaki ürünleri getir
      final urunler = await fiyatAraligindakiUrunleriGetir(minFiyat, maxFiyat);
      
      if (urunler.isEmpty) {
        debugPrint('⚠️ Belirtilen fiyat aralığında ürün bulunamadı');
        return null;
      }
      
      // Anket oluştur
      final anketRef = _db.collection(_anketlerCollection).doc();
      final anket = HaftalikOdulAnketi(
        id: anketRef.id,
        baslangicTarihi: cumaGunu,
        bitisTarihi: cumartesiGunu,
        minFiyat: minFiyat,
        maxFiyat: maxFiyat,
        urunIdleri: urunler.map((u) => u.id).toList(),
        haftaNumarasi: haftaNo,
      );
      
      await anketRef.set(anket.toJson());
      debugPrint('✅ Haftalık anket oluşturuldu: Hafta $haftaNo');
      
      return anket;
    } catch (e) {
      debugPrint('❌ Anket oluşturma hatası: $e');
      return null;
    }
  }
  
  /// Hafta numarasını hesapla
  int _haftaNumarasiHesapla(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(firstDayOfYear).inDays;
    return (daysDiff / 7).ceil() + 1;
  }
  
  // ============================================
  // 🗳️ OY İŞLEMLERİ
  // ============================================
  
  /// Oy kullan (tek seferlik, değiştirilemez)
  Future<bool> oyKullan({
    required String anketId,
    required String ogrenciId,
    required String urunId,
  }) async {
    try {
      // Daha önce oy kullanmış mı kontrol et
      if (await oyKullandiMi(anketId, ogrenciId)) {
        debugPrint('⚠️ Bu öğrenci zaten oy kullanmış');
        return false;
      }
      
      // Anket aktif mi kontrol et
      final anketDoc = await _db.collection(_anketlerCollection).doc(anketId).get();
      if (!anketDoc.exists) return false;
      
      final anket = HaftalikOdulAnketi.fromMap(anketDoc.data()!, anketDoc.id);
      if (!anket.aktifMi) {
        debugPrint('⚠️ Anket aktif değil');
        return false;
      }
      
      // Transaction ile oy kaydet
      await _db.runTransaction((transaction) async {
        final anketRef = _db.collection(_anketlerCollection).doc(anketId);
        final oyRef = _db.collection(_oylarCollection).doc();
        
        // Oy kaydı oluştur
        final oyKaydi = OyKaydi(
          id: oyRef.id,
          anketId: anketId,
          ogrenciId: ogrenciId,
          secilenUrunId: urunId,
          oyTarihi: DateTime.now(),
        );
        
        // Anket oy sayısını güncelle
        transaction.update(anketRef, {
          'oylar.$urunId': FieldValue.increment(1),
          'oyKullananlar': FieldValue.arrayUnion([ogrenciId]),
        });
        
        // Oy kaydını kaydet
        transaction.set(oyRef, oyKaydi.toJson());
      });
      
      debugPrint('✅ Oy başarıyla kaydedildi');
      return true;
    } catch (e) {
      debugPrint('❌ Oy kullanma hatası: $e');
      return false;
    }
  }
  
  /// Öğrenci bu ankette oy kullandı mı?
  Future<bool> oyKullandiMi(String anketId, String ogrenciId) async {
    try {
      final snapshot = await _db.collection(_oylarCollection)
          .where('anketId', isEqualTo: anketId)
          .where('ogrenciId', isEqualTo: ogrenciId)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Öğrencinin bu anketteki oyunu getir
  Future<String?> ogrencininOyunuGetir(String anketId, String ogrenciId) async {
    try {
      final snapshot = await _db.collection(_oylarCollection)
          .where('anketId', isEqualTo: anketId)
          .where('ogrenciId', isEqualTo: ogrenciId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.data()['secilenUrunId'];
    } catch (e) {
      return null;
    }
  }
  
  // ============================================
  // 🏆 SONUÇ İŞLEMLERİ
  // ============================================
  
  /// Anket sonuçlarını getir
  Stream<HaftalikOdulAnketi?> anketSonuclariStream(String anketId) {
    return _db.collection(_anketlerCollection)
        .doc(anketId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return HaftalikOdulAnketi.fromMap(snapshot.data()!, snapshot.id);
        });
  }
  
  /// Anketi kapat ve kazananı belirle
  Future<String?> anketiKapatVeKazananiBelirle(String anketId) async {
    try {
      final anketDoc = await _db.collection(_anketlerCollection).doc(anketId).get();
      if (!anketDoc.exists) return null;
      
      final anket = HaftalikOdulAnketi.fromMap(anketDoc.data()!, anketDoc.id);
      final kazananId = anket.hesaplaKazanan();
      
      await _db.collection(_anketlerCollection).doc(anketId).update({
        'kapandi': true,
        'kazananUrunId': kazananId,
      });
      
      debugPrint('✅ Anket kapatıldı, kazanan ürün: $kazananId');
      return kazananId;
    } catch (e) {
      debugPrint('❌ Anket kapatma hatası: $e');
      return null;
    }
  }
  
  // ============================================
  // 🎁 ÜRÜN İŞLEMLERİ
  // ============================================
  
  /// Fiyat aralığındaki ürünleri getir
  Future<List<OdulMagazasiUrunu>> fiyatAraligindakiUrunleriGetir(
    double minFiyat,
    double maxFiyat,
  ) async {
    try {
      final snapshot = await _db.collection(_urunlerCollection)
          .where('aktif', isEqualTo: true)
          .where('fiyat', isGreaterThanOrEqualTo: minFiyat)
          .where('fiyat', isLessThanOrEqualTo: maxFiyat)
          .get();
      
      return snapshot.docs
          .map((doc) => OdulMagazasiUrunu.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('❌ Ürün getirme hatası: $e');
      return [];
    }
  }
  
  /// Tek ürün getir
  Future<OdulMagazasiUrunu?> urunGetir(String urunId) async {
    try {
      final doc = await _db.collection(_urunlerCollection).doc(urunId).get();
      if (!doc.exists) return null;
      return OdulMagazasiUrunu.fromMap(doc.data()!, doc.id);
    } catch (e) {
      return null;
    }
  }
  
  /// Birden fazla ürünü getir
  Future<List<OdulMagazasiUrunu>> urunleriGetir(List<String> urunIdleri) async {
    if (urunIdleri.isEmpty) return [];
    
    try {
      final List<OdulMagazasiUrunu> urunler = [];
      
      // Firestore 'in' query limiti 10
      for (var i = 0; i < urunIdleri.length; i += 10) {
        final chunk = urunIdleri.skip(i).take(10).toList();
        final snapshot = await _db.collection(_urunlerCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        
        urunler.addAll(snapshot.docs.map(
          (doc) => OdulMagazasiUrunu.fromMap(doc.data(), doc.id),
        ));
      }
      
      return urunler;
    } catch (e) {
      debugPrint('❌ Ürünler getirme hatası: $e');
      return [];
    }
  }
  
  /// Örnek ürünler ekle (geliştirme için)
  Future<void> ornekUrunlerEkle() async {
    final ornekUrunler = [
      OdulMagazasiUrunu(
        id: 'urun_1',
        ad: 'Hepsiburada 50 TL Hediye Çeki',
        aciklama: 'Hepsiburada\'da kullanılabilir',
        gorselUrl: 'https://cdn.hepsiburada.net/assets/mkhepsiburada/logo.png',
        fiyat: 50,
        kategori: 'hediye_ceki',
      ),
      OdulMagazasiUrunu(
        id: 'urun_2',
        ad: 'Trendyol 75 TL Hediye Çeki',
        aciklama: 'Trendyol\'da kullanılabilir',
        gorselUrl: 'https://cdn.trendyol.com/Trendyol_Logo.png',
        fiyat: 75,
        kategori: 'hediye_ceki',
      ),
      OdulMagazasiUrunu(
        id: 'urun_3',
        ad: 'Amazon 100 TL Hediye Çeki',
        aciklama: 'Amazon Türkiye\'de kullanılabilir',
        gorselUrl: 'https://upload.wikimedia.org/wikipedia/commons/a/a9/Amazon_logo.svg',
        fiyat: 100,
        kategori: 'hediye_ceki',
      ),
      OdulMagazasiUrunu(
        id: 'urun_4',
        ad: 'Spotify 3 Aylık Premium',
        aciklama: 'Spotify Premium üyeliği',
        gorselUrl: 'https://storage.googleapis.com/pr-newsroom-wp/1/2018/11/Spotify_Logo_RGB_Green.png',
        fiyat: 120,
        kategori: 'dijital',
      ),
      OdulMagazasiUrunu(
        id: 'urun_5',
        ad: 'Netflix 1 Aylık Abonelik',
        aciklama: 'Netflix standart üyelik',
        gorselUrl: 'https://upload.wikimedia.org/wikipedia/commons/0/08/Netflix_2015_logo.svg',
        fiyat: 150,
        kategori: 'dijital',
      ),
    ];
    
    for (var urun in ornekUrunler) {
      await _db.collection(_urunlerCollection).doc(urun.id).set(urun.toJson());
    }
    
    debugPrint('✅ ${ornekUrunler.length} örnek ürün eklendi');
  }
}
