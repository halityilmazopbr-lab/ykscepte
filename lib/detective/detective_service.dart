/// 🕵️ NET-X Dedektifi - Ana Servis
/// Cevap eşleştirme, analiz ve rapor oluşturma

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'detective_models.dart';

/// 🧠 Dedektif Ana Servisi
class DetectiveService {
  static final DetectiveService _instance = DetectiveService._internal();
  factory DetectiveService() => _instance;
  DetectiveService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════
  // 🔍 CEVAP KARŞILAŞTIRMA
  // ═══════════════════════════════════════════════════════════════

  /// Doğru cevaplarla öğrenci cevaplarını karşılaştır
  /// Returns: Sadece yanlış ve boş soruların listesi
  List<SorguKaydi> karsilastir({
    required Map<int, String> dogruCevaplar,
    required Map<int, String?> ogrenciCevaplari,
  }) {
    final hataliFiltrelenmis = <SorguKaydi>[];
    final tumKayitlar = <SorguKaydi>[];

    dogruCevaplar.forEach((soruNo, dogruCevap) {
      final ogrenciCevabi = ogrenciCevaplari[soruNo];
      
      final kayit = SorguKaydi(
        soruNo: soruNo,
        dogruCevap: dogruCevap,
        ogrenciCevabi: ogrenciCevabi,
      );

      tumKayitlar.add(kayit);

      // Sadece yanlış ve boşları ekle
      if (kayit.yanlisMi || kayit.bosmu) {
        hataliFiltrelenmis.add(kayit);
      }
    });

    // Soru numarasına göre sırala
    hataliFiltrelenmis.sort((a, b) => a.soruNo.compareTo(b.soruNo));
    
    return hataliFiltrelenmis;
  }

  /// Tüm detaylı sonucu al (doğrular dahil)
  Map<String, dynamic> getDetayliSonuc({
    required Map<int, String> dogruCevaplar,
    required Map<int, String?> ogrenciCevaplari,
  }) {
    int dogru = 0;
    int yanlis = 0;
    int bos = 0;

    dogruCevaplar.forEach((soruNo, dogruCevap) {
      final ogrenciCevabi = ogrenciCevaplari[soruNo];
      
      if (ogrenciCevabi == null) {
        bos++;
      } else if (ogrenciCevabi == dogruCevap) {
        dogru++;
      } else {
        yanlis++;
      }
    });

    // Net hesaplama: Doğru - (Yanlış / 4)
    final net = dogru - (yanlis / 4);

    return {
      'dogru': dogru,
      'yanlis': yanlis,
      'bos': bos,
      'toplam': dogruCevaplar.length,
      'net': net,
    };
  }

  // ═══════════════════════════════════════════════════════════════
  // 📊 POTANSİYEL NET HESAPLAMA
  // ═══════════════════════════════════════════════════════════════

  /// Etiketlenmiş hatalara göre potansiyel net hesapla
  double hesaplaPotansiyelNet(List<SorguKaydi> sorguKayitlari, double mevcutNet) {
    // Dikkat hataları = potansiyel doğrular
    final dikkatHatalari = sorguKayitlari
        .where((k) => k.hataTuru == HataTuru.dikkatHatasi)
        .length;

    // Tereddüt = %50 şansla doğru olabilirdi
    final teredutler = sorguKayitlari
        .where((k) => k.hataTuru == HataTuru.teredut)
        .length;

    // Potansiyel ek net:
    // - Dikkat hataları tam doğru sayılır
    // - Tereddütler %50 sayılır
    final potansiyelEk = dikkatHatalari + (teredutler * 0.5);

    return mevcutNet + potansiyelEk;
  }

  // ═══════════════════════════════════════════════════════════════
  // 📋 RAPOR OLUŞTURMA
  // ═══════════════════════════════════════════════════════════════

  /// Etiketlenmiş sorulardan final rapor oluştur
  DedektifRaporu olusturRapor({
    required String ogrenciId,
    required String yayinId,
    required String yayinAdi,
    required List<SorguKaydi> sorguKayitlari,
    required int toplamSoru,
    required int dogru,
    required int yanlis,
    required int bos,
    required double mevcutNet,
  }) {
    // Hata türü sayıları
    int dikkat = 0, bilgi = 0, sure = 0, teredut = 0;
    
    for (var kayit in sorguKayitlari) {
      switch (kayit.hataTuru) {
        case HataTuru.dikkatHatasi:
          dikkat++;
          break;
        case HataTuru.bilgiEksigi:
          bilgi++;
          break;
        case HataTuru.sureYetmedi:
          sure++;
          break;
        case HataTuru.teredut:
          teredut++;
          break;
        default:
          break;
      }
    }

    final potansiyelNet = hesaplaPotansiyelNet(sorguKayitlari, mevcutNet);

    return DedektifRaporu(
      id: '', // Firebase'de oluşturulacak
      ogrenciId: ogrenciId,
      yayinId: yayinId,
      yayinAdi: yayinAdi,
      tarih: DateTime.now(),
      toplamSoru: toplamSoru,
      dogru: dogru,
      yanlis: yanlis,
      bos: bos,
      mevcutNet: mevcutNet,
      potansiyelNet: potansiyelNet,
      dikkatHatasiSayisi: dikkat,
      bilgiEksigiSayisi: bilgi,
      sureYetmediSayisi: sure,
      teredutSayisi: teredut,
      sorguKayitlari: sorguKayitlari,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 💾 FİRESTORE İŞLEMLERİ
  // ═══════════════════════════════════════════════════════════════

  /// Raporu Firebase'e kaydet
  Future<String> kaydetRapor(DedektifRaporu rapor) async {
    try {
      final docRef = _db.collection('detectiveReports').doc();
      await docRef.set(rapor.toJson());
      debugPrint('✅ Dedektif raporu kaydedildi: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Rapor kaydetme hatası: $e');
      rethrow;
    }
  }

  /// Kullanıcının raporlarını getir
  Future<List<DedektifRaporu>> getRaporlar(String ogrenciId) async {
    try {
      final snapshot = await _db.collection('detectiveReports')
          .where('ogrenciId', isEqualTo: ogrenciId)
          .orderBy('tarih', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => DedektifRaporu.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('❌ Raporlar getirme hatası: $e');
      return [];
    }
  }

  /// Toplam istatistikleri getir
  Future<Map<String, dynamic>> getToplamIstatistikler(String ogrenciId) async {
    try {
      final raporlar = await getRaporlar(ogrenciId);
      
      if (raporlar.isEmpty) {
        return {
          'toplamAnaliz': 0,
          'toplamDikkatHatasi': 0,
          'toplamBilgiEksigi': 0,
          'ortalamaKaybedilenNet': 0.0,
        };
      }

      int toplamDikkat = 0;
      int toplamBilgi = 0;
      double toplamKayip = 0;

      for (var rapor in raporlar) {
        toplamDikkat += rapor.dikkatHatasiSayisi;
        toplamBilgi += rapor.bilgiEksigiSayisi;
        toplamKayip += rapor.dikkatKaybi;
      }

      return {
        'toplamAnaliz': raporlar.length,
        'toplamDikkatHatasi': toplamDikkat,
        'toplamBilgiEksigi': toplamBilgi,
        'ortalamaKaybedilenNet': toplamKayip / raporlar.length,
      };
    } catch (e) {
      debugPrint('❌ İstatistik hatası: $e');
      return {};
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 GÖREV ÖNERİLERİ (İleride genişletilecek)
  // ═══════════════════════════════════════════════════════════════

  /// Rapora göre görev önerileri oluştur
  List<GorevOnerisi> olusturGorevler(DedektifRaporu rapor) {
    final gorevler = <GorevOnerisi>[];

    // Dikkat hatası çoksa
    if (rapor.dikkatHatasiSayisi >= 3) {
      gorevler.add(GorevOnerisi(
        baslik: '⏱️ Odak Antrenmanı',
        aciklama: 'Çok fazla dikkat hatası yapıyorsun! Süre tutarak 20 soru çöz.',
        tur: 'odak_modu',
        yonlendirme: 'OdakModuEkrani',
        onem: 5,
      ));
    }

    // Bilgi eksiği çoksa
    if (rapor.bilgiEksigiSayisi >= 3) {
      gorevler.add(GorevOnerisi(
        baslik: '📚 Konu Tekrarı',
        aciklama: 'Bazı konularda eksiklerin var. Flashcard çalış!',
        tur: 'flashcard',
        yonlendirme: 'FlashcardsEkrani',
        onem: 5,
      ));
    }

    // Süre problemi varsa
    if (rapor.sureYetmediSayisi >= 3) {
      gorevler.add(GorevOnerisi(
        baslik: '⚡ Hız Antrenmanı',
        aciklama: 'Süre yönetimini geliştir. Kronometre ile pratik yap!',
        tur: 'kronometre',
        yonlendirme: 'KronometreEkrani',
        onem: 4,
      ));
    }

    return gorevler;
  }
}
