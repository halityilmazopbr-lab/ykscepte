import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'duel_model.dart';

/// ⚔️ Düello Servisi - Sosyal Mücadele Altyapısı
class DuelService {
  static final DuelService _instance = DuelService._internal();
  factory DuelService() => _instance;
  DuelService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 1. DÜELLO OLUŞTUR (Kurucu tarafı)
  /// [userId] - Meydan okuyan
  /// [ad] - Meydan okuyan adı
  /// [kartListesi] - Oynanacak deste (LeitnerCard'lardan dönüştürülmüş Map)
  Future<String> createDuel({
    required String userId,
    required String ad,
    required List<Map<String, dynamic>> kartListesi,
    required int skor,
    required int sureSaniye,
  }) async {
    try {
      // 6 haneli rastgele kod üret
      String roomCode = (100000 + Random().nextInt(900000)).toString();
      
      DocumentReference ref = _db.collection('duels').doc();
      
      final duelData = {
        'id': ref.id,
        'code': roomCode,
        'kurucuId': userId,
        'kurucuAd': ad,
        'kurucuSkor': skor,
        'kurucuSure': sureSaniye,
        'rakipId': null,
        'rakipAd': null,
        'rakipSkor': 0,
        'rakipSure': 0,
        'kartlar': kartListesi,
        'durum': 'bekliyor',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await ref.set(duelData);
      return roomCode;
      
    } catch (e) {
      debugPrint("Düello oluşturma hatası: $e");
      throw Exception("Düello odası oluşturulamadı.");
    }
  }

  /// 2. DÜELLOYA KATIL (Rakip tarafı)
  /// [roomCode] - 6 haneli giriş kodu
  /// [userId] - Katılan kullanıcı
  Future<DuelModel> joinDuel(String roomCode, String userId) async {
    try {
      // Kodu ve bekleyen durumu ara
      QuerySnapshot snapshot = await _db
          .collection('duels')
          .where('code', isEqualTo: roomCode)
          .where('durum', isEqualTo: 'bekliyor')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception("Oda bulunamadı veya düello zaten başlamış/bitmiş.");
      }

      DocumentSnapshot doc = snapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data['kurucuId'] == userId) {
        throw Exception("Kendi meydan okumana kendin katılamazsın :)");
      }

      // Rakip olarak odayı güncelle
      await _db.collection('duels').doc(doc.id).update({
        'rakipId': userId,
        'durum': 'aktif',
      });

      return DuelModel.fromMap(data, doc.id);
      
    } catch (e) {
      debugPrint("Düelloya katılma hatası: $e");
      rethrow;
    }
  }

  /// 3. SKOR GÖNDER (Rakip testi bitirince)
  Future<void> submitRakipScore({
    required String duelId,
    required String rakipAd,
    required int skor,
    required int sureSaniye,
  }) async {
    try {
      await _db.collection('duels').doc(duelId).update({
        'rakipAd': rakipAd,
        'rakipSkor': skor,
        'rakipSure': sureSaniye,
        'durum': 'tamamlandi',
      });
    } catch (e) {
      debugPrint("Skor gönderme hatası: $e");
      throw Exception("Skor kaydedilemedi.");
    }
  }

  /// 4. DÜELLO DURUMUNU İZLE (Stream)
  Stream<DuelModel?> streamDuel(String duelId) {
    return _db.collection('duels').doc(duelId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DuelModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  /// 5. KOD İLE DÜELLO BUL (Detay görmek için)
  Future<DuelModel?> findByCode(String code) async {
    final snap = await _db.collection('duels').where('code', isEqualTo: code).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return DuelModel.fromMap(snap.docs.first.data() as Map<String, dynamic>, snap.docs.first.id);
  }
}
