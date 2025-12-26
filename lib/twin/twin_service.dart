import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'twin_models.dart';
import 'twin_personas.dart';
import '../diamond/diamond_service.dart';

/// 🧬 Twin Service - Sınav İkizi Sistemi Ana Servisi
/// Eşleştirme, takip, düello ve reaksiyon işlemlerini yönetir
class TwinService {
  static final TwinService _instance = TwinService._internal();
  factory TwinService() => _instance;
  TwinService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ====== PROFİL YÖNETİMİ ======

  /// Kullanıcının twin profilini al veya oluştur
  Future<TwinProfile> getOrCreateProfile(String odgrenciId, {
    required String alan,
    required String hedefBolum,
  }) async {
    try {
      final doc = await _db.collection('twinProfiles').doc(odgrenciId).get();
      
      if (doc.exists) {
        return TwinProfile.fromJson(doc.data()!);
      }
      
      // Yeni profil oluştur
      final yeniProfil = TwinProfile(
        odgrenciId: odgrenciId,
        alan: alan,
        hedefBolum: hedefBolum,
        sonGuncelleme: DateTime.now(),
      );
      
      await _db.collection('twinProfiles').doc(odgrenciId).set(yeniProfil.toJson());
      return yeniProfil;
    } catch (e) {
      debugPrint('TwinService.getOrCreateProfile hatası: $e');
      rethrow;
    }
  }

  /// Profil istatistiklerini güncelle
  Future<void> guncelleProfilStats({
    required String odgrenciId,
    int? yeniSoruSayisi,
    int? yeniOdakDakika,
    double? yeniNet,
  }) async {
    try {
      final updates = <String, dynamic>{
        'sonGuncelleme': DateTime.now().toIso8601String(),
      };
      
      if (yeniSoruSayisi != null) {
        updates['haftalikSoruSayisi'] = FieldValue.increment(yeniSoruSayisi);
      }
      if (yeniOdakDakika != null) {
        updates['haftalikOdakSuresi'] = FieldValue.increment(yeniOdakDakika);
      }
      if (yeniNet != null) {
        updates['ortalamaNet'] = yeniNet;
      }
      
      await _db.collection('twinProfiles').doc(odgrenciId).update(updates);
    } catch (e) {
      debugPrint('Profil güncelleme hatası: $e');
    }
  }

  // ====== EŞLEŞTİRME ALGORİTMASI ======

  /// Twin Score hesapla (0-1000 arası)
  int hesaplaTwinScore(TwinProfile profil) {
    // Temel puan: 500
    int puan = 500;
    
    // Net ortalaması: her 10 net = 30 puan (max 300)
    puan += ((profil.ortalamaNet / 10) * 30).clamp(0, 300).toInt();
    
    // Çalışma süresi: her 60 dakika = 25 puan (max 200)
    puan += ((profil.gunlukCalismaDakika / 60) * 25).clamp(0, 200).toInt();
    
    return puan.clamp(0, 1000);
  }

  /// En uygun ikizi bul ve eşleştir
  Future<ExamTwin?> bulVeEslestirIkiz(String odgrenciId) async {
    try {
      // 1. Önce kendi profilimi al
      final benimProfilDoc = await _db.collection('twinProfiles').doc(odgrenciId).get();
      if (!benimProfilDoc.exists) {
        debugPrint('Profil bulunamadı: $odgrenciId');
        return null;
      }
      
      final benimProfil = TwinProfile.fromJson(benimProfilDoc.data()!);
      final benimScore = hesaplaTwinScore(benimProfil);
      
      // 2. Uygun adayları bul (aynı alan + aynı hedef)
      final adaylarSnapshot = await _db.collection('twinProfiles')
          .where('alan', isEqualTo: benimProfil.alan)
          .where('hedefBolum', isEqualTo: benimProfil.hedefBolum)
          .get();
      
      if (adaylarSnapshot.docs.isEmpty) {
        debugPrint('Uygun aday bulunamadı');
        return null;
      }
      
      // 3. Mevcut eşleşmeleri al (çift eşleşmeyi engellemek için)
      final mevcutEslesmeler = await _db.collection('examTwins')
          .where('durum', isEqualTo: 'aktif')
          .get();
      
      final eslesmisIdler = <String>{};
      for (var doc in mevcutEslesmeler.docs) {
        eslesmisIdler.add(doc.data()['odgrenciId']);
        eslesmisIdler.add(doc.data()['ikizId']);
      }
      
      // 4. En uygun ikizi bul (±50 puan farkı tercih et)
      String? enUygunId;
      int enDusukFark = 9999;
      
      for (var doc in adaylarSnapshot.docs) {
        final adayId = doc.id;
        
        // Kendimi atla
        if (adayId == odgrenciId) continue;
        
        // Zaten eşleşmiş olanları atla
        if (eslesmisIdler.contains(adayId)) continue;
        
        final adayProfil = TwinProfile.fromJson(doc.data());
        final adayScore = hesaplaTwinScore(adayProfil);
        final fark = (benimScore - adayScore).abs();
        
        // ±50 puan farkı idealdir
        if (fark < enDusukFark) {
          enDusukFark = fark;
          enUygunId = adayId;
        }
      }
      
      if (enUygunId == null) {
        debugPrint('Uygun eşleşme bulunamadı');
        return null;
      }
      
      // 5. Eşleşmeyi oluştur
      return await _olusturEslestirme(odgrenciId, enUygunId);
      
    } catch (e) {
      debugPrint('İkiz eşleştirme hatası: $e');
      return null;
    }
  }

  /// İki öğrenci arasında eşleşme oluştur
  Future<ExamTwin> _olusturEslestirme(String odgrenci1Id, String odgrenci2Id) async {
    // Her iki taraf için persona ata
    final (kodAdi1, emoji1) = TwinPersonas.ataPersona(odgrenci2Id);
    final (kodAdi2, emoji2) = TwinPersonas.ataPersona(odgrenci1Id);
    
    final now = DateTime.now();
    final docRef = _db.collection('examTwins').doc();
    
    // Öğrenci 1'in gördüğü eşleşme
    final twin1 = ExamTwin(
      id: docRef.id,
      odgrenciId: odgrenci1Id,
      ikizId: odgrenci2Id,
      ikizKodAdi: kodAdi1,
      ikizEmoji: emoji1,
      ikizSeviye: 1,
      eslesmeTarihi: now,
    );
    
    await docRef.set(twin1.toJson());
    
    // Öğrenci 2'nin gördüğü eşleşme (ters yönlü)
    final docRef2 = _db.collection('examTwins').doc();
    final twin2 = ExamTwin(
      id: docRef2.id,
      odgrenciId: odgrenci2Id,
      ikizId: odgrenci1Id,
      ikizKodAdi: kodAdi2,
      ikizEmoji: emoji2,
      ikizSeviye: 1,
      eslesmeTarihi: now,
    );
    
    await docRef2.set(twin2.toJson());
    
    debugPrint('İkiz eşleşmesi oluşturuldu: $odgrenci1Id <-> $odgrenci2Id');
    return twin1;
  }

  // ====== AKTİF İKİZ İŞLEMLERİ ======

  /// Kullanıcının aktif ikizini getir
  Future<ExamTwin?> getAktifIkiz(String odgrenciId) async {
    try {
      final snapshot = await _db.collection('examTwins')
          .where('odgrenciId', isEqualTo: odgrenciId)
          .where('durum', isEqualTo: 'aktif')
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      return ExamTwin.fromJson(snapshot.docs.first.data(), snapshot.docs.first.id);
    } catch (e) {
      debugPrint('Aktif ikiz alma hatası: $e');
      return null;
    }
  }

  /// Aktif ikizi canlı stream olarak izle
  Stream<ExamTwin?> streamAktifIkiz(String odgrenciId) {
    return _db.collection('examTwins')
        .where('odgrenciId', isEqualTo: odgrenciId)
        .where('durum', isEqualTo: 'aktif')
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return ExamTwin.fromJson(snapshot.docs.first.data(), snapshot.docs.first.id);
        });
  }

  /// İkizin aktivite durumunu güncelle
  Future<void> guncelleAktivite(String odgrenciId) async {
    try {
      // Benim ikizimi bul ve son aktivitemi güncelle
      final snapshot = await _db.collection('examTwins')
          .where('ikizId', isEqualTo: odgrenciId)
          .where('durum', isEqualTo: 'aktif')
          .get();
      
      for (var doc in snapshot.docs) {
        await doc.reference.update({
          'sonAktivite': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Aktivite güncelleme hatası: $e');
    }
  }

  // ====== GÜNLÜK DÜELLO ======

  /// Bugünkü düelloyu al veya oluştur
  Future<DailyBet?> getOrCreateGunlukDuello(String twinId) async {
    try {
      final twin = await _db.collection('examTwins').doc(twinId).get();
      if (!twin.exists) return null;
      
      final twinData = ExamTwin.fromJson(twin.data()!, twinId);
      final bugun = DateTime.now();
      final bugunStr = '${bugun.year}-${bugun.month.toString().padLeft(2, '0')}-${bugun.day.toString().padLeft(2, '0')}';
      
      // Bugünkü düelloyu ara
      final mevcutDuello = await _db.collection('dailyBets')
          .where('twinId', isEqualTo: twinId)
          .where('tarih', isGreaterThanOrEqualTo: bugunStr)
          .limit(1)
          .get();
      
      if (mevcutDuello.docs.isNotEmpty) {
        return DailyBet.fromJson(mevcutDuello.docs.first.data(), mevcutDuello.docs.first.id);
      }
      
      // Yeni düello oluştur
      final docRef = _db.collection('dailyBets').doc();
      final yeniDuello = DailyBet(
        id: docRef.id,
        twinId: twinId,
        odgrenci1Id: twinData.odgrenciId,
        odgrenci2Id: twinData.ikizId,
        tarih: bugun,
        odul: 20, // Sistem 20 elmas veriyor
      );
      
      await docRef.set(yeniDuello.toJson());
      return yeniDuello;
    } catch (e) {
      debugPrint('Günlük düello hatası: $e');
      return null;
    }
  }

  /// Soru çözümünü kaydet (düello skorunu güncelle)
  Future<void> kaydetSoruCozumu(String odgrenciId, int soruSayisi) async {
    try {
      // 1. Profilimi güncelle
      await guncelleProfilStats(odgrenciId: odgrenciId, yeniSoruSayisi: soruSayisi);
      
      // 2. Aktivitemi güncelle (ikizime bildirim gitsin)
      await guncelleAktivite(odgrenciId);
      
      // 3. Günlük düelloyu güncelle
      final aktifIkiz = await getAktifIkiz(odgrenciId);
      if (aktifIkiz == null) return;
      
      final duelloSnapshot = await _db.collection('dailyBets')
          .where('twinId', isEqualTo: aktifIkiz.id)
          .where('kazananId', isNull: true)
          .limit(1)
          .get();
      
      if (duelloSnapshot.docs.isNotEmpty) {
        final doc = duelloSnapshot.docs.first;
        final data = doc.data();
        
        // Hangi oyuncu olduğumu bul ve skoru güncelle
        if (data['odgrenci1Id'] == odgrenciId) {
          await doc.reference.update({
            'odgrenci1SoruSayisi': FieldValue.increment(soruSayisi),
          });
        } else {
          await doc.reference.update({
            'odgrenci2SoruSayisi': FieldValue.increment(soruSayisi),
          });
        }
      }
      
      // 4. İkiz eşleşmesindeki günlük skoru da güncelle
      await _db.collection('examTwins').doc(aktifIkiz.id).update({
        'benimGunlukSoru': FieldValue.increment(soruSayisi),
      });
      
    } catch (e) {
      debugPrint('Soru çözümü kaydetme hatası: $e');
    }
  }

  /// Günlük düelloyu sonlandır ve kazananı belirle
  Future<void> sonlandirGunlukDuello(String duelloId) async {
    try {
      final doc = await _db.collection('dailyBets').doc(duelloId).get();
      if (!doc.exists) return;
      
      final duello = DailyBet.fromJson(doc.data()!, duelloId);
      
      String? kazananId;
      if (duello.odgrenci1SoruSayisi > duello.odgrenci2SoruSayisi) {
        kazananId = duello.odgrenci1Id;
      } else if (duello.odgrenci2SoruSayisi > duello.odgrenci1SoruSayisi) {
        kazananId = duello.odgrenci2Id;
      }
      // Eşitlik durumunda kazanan yok
      
      await doc.reference.update({'kazananId': kazananId});
      
      // Kazanana elmas ver (20 elmas sistem havuzundan)
      if (kazananId != null) {
        await DiamondService.earnDiamonds(
          ogrenciId: kazananId,
          amount: 20,
          reason: 'Günlük İkiz Düellosu Kazanıldı! 🏆',
        );
      }
      
      // Co-op modunda her ikisi de hedefi tutturduysa bonus
      if (duello.coopModu && 
          duello.odgrenci1SoruSayisi >= duello.coopHedef &&
          duello.odgrenci2SoruSayisi >= duello.coopHedef) {
        // Her ikisine de 2x ödül (40 elmas)
        await DiamondService.earnDiamonds(
          ogrenciId: duello.odgrenci1Id,
          amount: 40,
          reason: 'İkiz İşbirliği Başarılı! 🤝',
        );
        await DiamondService.earnDiamonds(
          ogrenciId: duello.odgrenci2Id,
          amount: 40,
          reason: 'İkiz İşbirliği Başarılı! 🤝',
        );
        
        await doc.reference.update({'coopBasarili': true});
      }
      
    } catch (e) {
      debugPrint('Düello sonlandırma hatası: $e');
    }
  }

  // ====== REAKSİYONLAR ======

  /// Emoji reaksiyon gönder
  Future<void> gonderReaksiyon(String gonderenId, String alanId, String emoji) async {
    try {
      final docRef = _db.collection('twinReactions').doc();
      final reaksiyon = TwinReaction(
        id: docRef.id,
        gonderenId: gonderenId,
        alanId: alanId,
        emoji: emoji,
        tarih: DateTime.now(),
      );
      
      await docRef.set(reaksiyon.toJson());
      
      // İkiz eşleşmesine son reaksiyonu ekle
      final ikizlerSnapshot = await _db.collection('examTwins')
          .where('odgrenciId', isEqualTo: alanId)
          .where('ikizId', isEqualTo: gonderenId)
          .limit(1)
          .get();
      
      if (ikizlerSnapshot.docs.isNotEmpty) {
        await ikizlerSnapshot.docs.first.reference.update({
          'sonReaksiyonlar': FieldValue.arrayUnion([emoji]),
        });
      }
      
      debugPrint('Reaksiyon gönderildi: $emoji');
    } catch (e) {
      debugPrint('Reaksiyon gönderme hatası: $e');
    }
  }

  /// Son reaksiyonları getir
  Stream<List<TwinReaction>> streamReaksiyonlar(String odgrenciId) {
    return _db.collection('twinReactions')
        .where('alanId', isEqualTo: odgrenciId)
        .orderBy('tarih', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TwinReaction.fromJson(doc.data(), doc.id))
            .toList());
  }

  // ====== SOLLAMA MEKANİĞİ ======

  /// Üst üste galibiyet kontrolü yap
  Future<bool> kontrolSollama(String twinId) async {
    try {
      final twin = await _db.collection('examTwins').doc(twinId).get();
      if (!twin.exists) return false;
      
      final twinData = ExamTwin.fromJson(twin.data()!, twinId);
      return twinData.ustUsteGalibiyetSayisi >= 3;
    } catch (e) {
      return false;
    }
  }

  /// Lig atla - Daha güçlü ikiz bul
  Future<ExamTwin?> ligAtla(String odgrenciId) async {
    try {
      // 1. Mevcut eşleşmeyi pasifleştir
      final mevcutIkiz = await getAktifIkiz(odgrenciId);
      if (mevcutIkiz != null) {
        await _db.collection('examTwins').doc(mevcutIkiz.id).update({
          'durum': 'pasif',
        });
      }
      
      // 2. Yeni, daha güçlü bir ikiz bul
      // Bu sefer daha yüksek twinScore'lu birini tercih et
      return await bulVeEslestirIkiz(odgrenciId);
    } catch (e) {
      debugPrint('Lig atlama hatası: $e');
      return null;
    }
  }

  // ====== DEMO VERİ ======

  /// Demo ikiz oluştur (Firebase bağlantısı yoksa)
  ExamTwin getDemoIkiz(String odgrenciId) {
    final (kodAdi, emoji) = TwinPersonas.rastgelePersona();
    return ExamTwin(
      id: 'demo_twin',
      odgrenciId: odgrenciId,
      ikizId: 'demo_ikiz_id',
      ikizKodAdi: kodAdi,
      ikizEmoji: emoji,
      ikizSeviye: 8,
      eslesmeTarihi: DateTime.now().subtract(const Duration(days: 3)),
      sonAktivite: DateTime.now().subtract(const Duration(minutes: 15)),
      benimHaftalikSkor: 420,
      ikizHaftalikSkor: 385,
      benimGunlukSoru: 45,
      ikizGunlukSoru: 52,
    );
  }
}
