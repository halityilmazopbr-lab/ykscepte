/// Kurumsal Modül - Veri Servisi
/// 
/// Firestore ile iletişim kurar:
/// - Denemeleri getir
/// - Kitapları getir
/// - Sonuç kaydet

import 'package:cloud_firestore/cloud_firestore.dart';
import 'kurum_models.dart';

class KurumService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Koleksiyon referansları
  static CollectionReference get _denemelerRef => _db.collection('kurum_denemeleri');
  static CollectionReference get _kitaplarRef => _db.collection('kurum_kitaplari');
  static CollectionReference get _sonuclarRef => _db.collection('deneme_sonuclari');

  /// Kuruma ait aktif denemeleri getir
  static Future<List<KurumDenemesi>> getDenemeleri(String kurumId) async {
    try {
      final snapshot = await _denemelerRef
          .where('kurum_id', isEqualTo: kurumId)
          .where('aktif_mi', isEqualTo: true)
          .orderBy('yayin_tarihi', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => KurumDenemesi.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Denemeler getirilemedi: $e');
      return [];
    }
  }

  /// Tüm aktif denemeleri getir (demo için)
  static Future<List<KurumDenemesi>> getTumDenemeler() async {
    try {
      final snapshot = await _denemelerRef
          .where('aktif_mi', isEqualTo: true)
          .orderBy('yayin_tarihi', descending: true)
          .get();
      
      if (snapshot.docs.isEmpty) {
        // Firebase boş veya bağlantı yok, demo veriler dön
        return _demoDenemeleri();
      }
      
      return snapshot.docs
          .map((doc) => KurumDenemesi.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Denemeler getirilemedi (demo kullanılıyor): $e');
      // Firebase hatası, demo veriler dön
      return _demoDenemeleri();
    }
  }

  /// Demo denemeler (Firebase olmadan test için)
  static List<KurumDenemesi> _demoDenemeleri() {
    return [
      KurumDenemesi(
        id: 'demo1',
        kurumId: 'kurum1',
        dersAdi: 'TYT Türkçe Deneme-1',
        kategori: 'TYT',
        soruSayisi: 40,
        sureDk: 50,
        pdfUrl: '', // Demo için boş, SinavEkrani handle edecek
        cevapAnahtari: 'ABCDABCDABCDABCDABCDABCDABCDABCDABCDABCD',
        yayinTarihi: DateTime.now().subtract(const Duration(days: 1)),
        aktifMi: true,
      ),
      KurumDenemesi(
        id: 'demo2',
        kurumId: 'kurum1',
        dersAdi: 'TYT Matematik Deneme-1',
        kategori: 'TYT',
        soruSayisi: 50,
        sureDk: 75,
        pdfUrl: '',
        cevapAnahtari: 'ABCDEABCDEABCDEABCDEABCDEABCDEABCDEABCDEABCDEABCDE',
        yayinTarihi: DateTime.now().subtract(const Duration(days: 2)),
        aktifMi: true,
      ),
      KurumDenemesi(
        id: 'demo3',
        kurumId: 'kurum1',
        dersAdi: 'AYT Matematik Deneme-1',
        kategori: 'AYT',
        soruSayisi: 50,
        sureDk: 80,
        pdfUrl: '',
        cevapAnahtari: 'ABCDEABCDEABCDEABCDEABCDEABCDEABCDEABCDEABCDEABCDE',
        yayinTarihi: DateTime.now().subtract(const Duration(days: 3)),
        aktifMi: true,
      ),
    ];
  }

  /// Tek bir deneme getir (ID ile)
  static Future<KurumDenemesi?> getDeneme(String denemeId) async {
    try {
      final doc = await _denemelerRef.doc(denemeId).get();
      if (doc.exists) {
        return KurumDenemesi.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Deneme getirilemedi: $e');
      return null;
    }
  }

  /// Kuruma ait kitapları getir
  static Future<List<KurumKitabi>> getKitaplar(String kurumId) async {
    try {
      final snapshot = await _kitaplarRef
          .where('kurum_id', isEqualTo: kurumId)
          .get();
      
      return snapshot.docs
          .map((doc) => KurumKitabi.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Kitaplar getirilemedi: $e');
      return [];
    }
  }

  /// Tüm kitapları getir (demo için)
  static Future<List<KurumKitabi>> getTumKitaplar() async {
    try {
      final snapshot = await _kitaplarRef.get();
      
      return snapshot.docs
          .map((doc) => KurumKitabi.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Kitaplar getirilemedi: $e');
      return [];
    }
  }

  /// Sınav sonucunu kaydet
  static Future<bool> sonucKaydet(KurumsalDenemeSonucu sonuc) async {
    try {
      await _sonuclarRef.add(sonuc.toFirestore());
      return true;
    } catch (e) {
      print('Sonuç kaydedilemedi: $e');
      return false;
    }
  }

  /// Öğrencinin bir sınava daha önce girip girmediğini kontrol et
  static Future<KurumsalDenemeSonucu?> getOgrenciSonucu(String ogrenciId, String denemeId) async {
    try {
      final snapshot = await _sonuclarRef
          .where('ogrenci_id', isEqualTo: ogrenciId)
          .where('deneme_id', isEqualTo: denemeId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return KurumsalDenemeSonucu.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Sonuç bulunamadı: $e');
      return null;
    }
  }

  /// Öğrencinin tüm sınav sonuçlarını getir
  static Future<List<KurumsalDenemeSonucu>> getOgrenciSonuclari(String ogrenciId) async {
    try {
      final snapshot = await _sonuclarRef
          .where('ogrenci_id', isEqualTo: ogrenciId)
          .orderBy('tarih', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => KurumsalDenemeSonucu.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Sonuçlar getirilemedi: $e');
      return [];
    }
  }
}

/// Puanlama Algoritması
class PuanlamaServisi {
  /// Sınavı değerlendir ve sonuç döndür
  static KurumsalDenemeSonucu sinaviDegerlendir({
    required String ogrenciId,
    required String denemeId,
    required String cevapAnahtari,
    required List<String> ogrenciCevaplari,
  }) {
    int dogru = 0;
    int yanlis = 0;
    int bos = 0;

    for (int i = 0; i < cevapAnahtari.length; i++) {
      String dogruCevap = cevapAnahtari[i];
      String ogrenciCevap = i < ogrenciCevaplari.length ? ogrenciCevaplari[i] : '';

      if (ogrenciCevap.isEmpty) {
        bos++;
      } else if (ogrenciCevap == dogruCevap) {
        dogru++;
      } else {
        yanlis++;
      }
    }

    // Net hesaplama: Doğru - (Yanlış / 4)
    double net = dogru - (yanlis / 4);

    return KurumsalDenemeSonucu(
      ogrenciId: ogrenciId,
      denemeId: denemeId,
      ogrenciCevaplari: ogrenciCevaplari.join(''),
      dogru: dogru,
      yanlis: yanlis,
      bos: bos,
      net: net,
      tarih: DateTime.now(),
    );
  }
}
