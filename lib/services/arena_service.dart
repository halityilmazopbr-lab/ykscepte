import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/arena_challenge_model.dart';
import '../models/arena_katilim_model.dart';

/// Arena Service
/// 
/// Global meydan okuma sistemi için core servis.
/// - Challenge yönetimi
/// - Katılım (anti-cheat ile)
/// - Leaderboard
/// - Live ticker
class ArenaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'arena_challenges';

  /// ============================================================
  /// 1. CHALLENGE YÖNETİMİ
  /// ============================================================

  /// Aktif challenge'ları getir (Stream - realtime)
  Stream<QuerySnapshot> aktifChallengeGetir() {
    return _db
        .collection(collectionPath)
        .where('aktif', isEqualTo: true)
        .where('bitisZamani', isGreaterThan: Timestamp.now())
        .snapshots();
  }

  /// Challenge detayını getir
  Future<ArenaChallengeModel?> challengeDetayGetir(String challengeId) async {
    try {
      var doc = await _db.collection(collectionPath).doc(challengeId).get();
      if (!doc.exists) return null;
      
      return ArenaChallengeModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint("❌ Challenge detay getirme hatası: $e");
      return null;
    }
  }

  /// ============================================================
  /// 2. KATILIM (Anti-Cheat Mekanizmalı)
  /// ============================================================

  /// Cevap gönder ve puan kazan
  /// 
  /// Anti-Cheat:
  /// - Transaction ile tek giriş hakkı
  /// - Server timestamp
  /// - Puan sunucuda hesaplanır
  Future<Map<String, dynamic>> cevapGonder({
    required String challengeId,
    required String userId,
    required String kullaniciAdi,
    required bool dogruMu,
    required int gecenSureSaniye,
    String? sehir,
    String? avatarUrl,
  }) async {
    try {
      DocumentReference challengeRef = _db.collection(collectionPath).doc(challengeId);
      DocumentReference katilimRef = challengeRef.collection('katilimcilar').doc(userId);

      int puan = 0;

      // TRANSACTION: Tek giriş hakkı + puan hesaplama
      await _db.runTransaction((transaction) async {
        // 1. Kullanıcı daha önce katıldı mı kontrol et
        DocumentSnapshot katilimSnapshot = await transaction.get(katilimRef);

        if (katilimSnapshot.exists) {
          throw Exception("Bu challenge'a zaten katıldınız!");
        }

        // 2. PUAN HESAPLAMA (Hız Odaklı)
        // Base: 100, her saniye -1, min 10
        if (dogruMu) {
          puan = _puanHesapla(gecenSureSaniye);
        }

        // 3. Katılım kaydı oluştur
        transaction.set(katilimRef, {
          'userId': userId,
          'kullaniciAdi': kullaniciAdi,
          'puan': puan,
          'sure': gecenSureSaniye,
          'dogruMu': dogruMu,
          'katilimZamani': FieldValue.serverTimestamp(), // ANTI-CHEAT: Server timestamp
          'sehir': sehir,
          'avatarUrl': avatarUrl,
        });

        // 4. Challenge istatistiklerini güncelle (atomic)
        transaction.update(challengeRef, {
          'katilimciSayisi': FieldValue.increment(1),
          if (dogruMu) 'cozenSayisi': FieldValue.increment(1),
        });
      });

      debugPrint("✅ Arena cevap gönderildi: $userId, Puan: $puan");

      return {
        'success': true,
        'puan': puan,
        'message': dogruMu ? 'Tebrikler! $puan puan kazandınız!' : 'Maalesef yanlış cevap.',
      };
    } catch (e) {
      debugPrint("❌ Arena cevap gönderme hatası: $e");
      
      if (e.toString().contains("zaten katıldınız")) {
        return {
          'success': false,
          'message': 'Bu challenge\'a zaten katıldınız!',
        };
      }
      
      return {
        'success': false,
        'message': 'Hata oluştu: $e',
      };
    }
  }

  /// Puan hesaplama algoritması
  /// Base: 100, her saniye -1, min 10
  int _puanHesapla(int gecenSureSaniye) {
    return (100 - gecenSureSaniye).clamp(10, 100);
  }

  /// ============================================================
  /// 3. LEADERBOARD
  /// ============================================================

  /// Lider tablosunu getir (Stream - realtime)
  /// Sıralama: puan DESC, süre ASC
  Stream<QuerySnapshot> liderTablosuGetir(String challengeId, {int limit = 10}) {
    return _db
        .collection(collectionPath)
        .doc(challengeId)
        .collection('katilimcilar')
        .orderBy('puan', descending: true) // En yüksek puan önce
        .orderBy('sure', descending: false) // Eşit puanda hızlı olan önce
        .limit(limit)
        .snapshots();
  }

  /// Kullanıcının sıralamasını getir
  Future<int?> kullaniciSiralamasi(String challengeId, String userId) async {
    try {
      // Kullanıcının kaydını al
      var userDoc = await _db
          .collection(collectionPath)
          .doc(challengeId)
          .collection('katilimcilar')
          .doc(userId)
          .get();

      if (!userDoc.exists) return null;

      var userPuan = userDoc.data()!['puan'] as int;
      var userSure = userDoc.data()!['sure'] as int;

      // Kullanıcıdan daha yüksek puanlı veya eşit puanda hızlı olanları say
      var betterQuery = await _db
          .collection(collectionPath)
          .doc(challengeId)
          .collection('katilimcilar')
          .where('puan', isGreaterThan: userPuan)
          .get();

      var equalPuanQuery = await _db
          .collection(collectionPath)
          .doc(challengeId)
          .collection('katilimcilar')
          .where('puan', isEqualTo: userPuan)
          .where('sure', isLessThan: userSure)
          .get();

      int rank = betterQuery.docs.length + equalPuanQuery.docs.length + 1;
      return rank;
    } catch (e) {
      debugPrint("❌ Sıralama getirme hatası: $e");
      return null;
    }
  }

  /// ============================================================
  /// 4. LIVE TICKER (Son Katılımlar)
  /// ============================================================

  /// Son katılımları getir (Live ticker için)
  Stream<QuerySnapshot> sonKatilimlar(String challengeId, {int limit = 5}) {
    return _db
        .collection(collectionPath)
        .doc(challengeId)
        .collection('katilimcilar')
        .orderBy('katilimZamani', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// ============================================================
  /// 5. BOSS RAID (Özel Mod)
  /// ============================================================

  /// Boss'a saldır (doğru cevap = -1 HP)
  Future<bool> bossaSaldir(String challengeId, String userId, bool dogruMu) async {
    try {
      DocumentReference challengeRef = _db.collection(collectionPath).doc(challengeId);

      await _db.runTransaction((transaction) async {
        DocumentSnapshot challengeSnapshot = await transaction.get(challengeRef);
        
        if (!challengeSnapshot.exists) {
          throw Exception("Challenge bulunamadı");
        }

        var kalanCan = (challengeSnapshot.data() as Map<String, dynamic>?)?['kalanCan'] as int? ?? 0;

        if (dogruMu && kalanCan > 0) {
          transaction.update(challengeRef, {
            'kalanCan': FieldValue.increment(-1),
          });
        }
      });

      return true;
    } catch (e) {
      debugPrint("❌ Boss saldırı hatası: $e");
      return false;
    }
  }

  /// ============================================================
  /// 6. ADMIN FONKSİYONLARI
  /// ============================================================

  /// Challenge oluştur (Manuel - Test için)
  Future<String?> challengeOlustur(ArenaChallengeModel challenge) async {
    try {
      var docRef = await _db.collection(collectionPath).add(challenge.toMap());
      debugPrint("✅ Challenge oluşturuldu: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      debugPrint("❌ Challenge oluşturma hatası: $e");
      return null;
    }
  }

  /// Challenge'ı kapat (bitir)
  Future<void> challengeKapat(String challengeId) async {
    await _db.collection(collectionPath).doc(challengeId).update({
      'aktif': false,
    });
  }
}
