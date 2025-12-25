/// Soru Paylaşım Servisi
/// Viral Growth Loop için soruları paylaşma ve challenge sistemi
/// 
/// Özellikler:
/// - Firestore'a soru kaydetme
/// - Paylaşım linki oluşturma  
/// - Challenge mesajı oluşturma
/// - Gelen paylaşımları listeleme

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'paylasilan_soru_model.dart';
import 'deep_link_service.dart';

class SoruPaylasimService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'paylasilanSorular';

  /// Soruyu Firestore'a kaydet ve paylaşım linkini oluştur
  static Future<String?> soruyuPaylas({
    required HataDefteriSoru soru,
    required String gonderenId,
    required String gonderenAd,
  }) async {
    try {
      // Benzersiz paylaşım ID oluştur
      final docRef = _firestore.collection(_collection).doc();
      final paylasilanSoruId = docRef.id;
      
      // PaylasilanSoru modeli oluştur
      final paylasilanSoru = PaylasilanSoru(
        id: paylasilanSoruId,
        soruId: soru.id,
        gonderenId: gonderenId,
        gonderenAd: gonderenAd,
        ders: soru.ders,
        konu: soru.konu,
        imageBase64: soru.imageBase64,
        gonderilmeTarihi: DateTime.now(),
        durum: 'bekliyor',
      );

      // Firestore'a kaydet
      await docRef.set(paylasilanSoru.toJson());
      
      debugPrint('✅ Soru paylaşıldı: $paylasilanSoruId');
      
      return paylasilanSoruId;
    } catch (e) {
      debugPrint('❌ Soru paylaşım hatası: $e');
      return null;
    }
  }

  /// Paylaşım dialogunu aç (WhatsApp, Instagram, vb.)
  static Future<void> paylasimDialoguAc({
    required String soruId,
    required String gonderenAd,
    required String ders,
    required String konu,
  }) async {
    final link = createShareLink(soruId);
    final mesaj = createChallengeMessage(
      gonderenAd: gonderenAd,
      ders: ders,
      konu: konu,
      link: link,
    );

    await Share.share(
      mesaj,
      subject: '🔥 YKS Cepte - Meydan Okuma!',
    );
  }

  /// Tek adımda paylaş (kaydet + dialog aç)
  static Future<bool> hizliPaylas({
    required HataDefteriSoru soru,
    required String gonderenId,
    required String gonderenAd,
  }) async {
    final soruId = await soruyuPaylas(
      soru: soru,
      gonderenId: gonderenId,
      gonderenAd: gonderenAd,
    );

    if (soruId != null) {
      await paylasimDialoguAc(
        soruId: soruId,
        gonderenAd: gonderenAd,
        ders: soru.ders,
        konu: soru.konu,
      );
      return true;
    }
    return false;
  }

  /// Tüm gelen paylaşımları getir (challenge'lar)
  static Future<List<PaylasilanSoru>> tumPaylasimlariGetir() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('durum', isEqualTo: 'bekliyor')
          .orderBy('gonderilmeTarihi', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => PaylasilanSoru.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('❌ Paylaşımlar getirme hatası: $e');
      return [];
    }
  }

  /// Belirli bir soruyu ID ile getir
  static Future<PaylasilanSoru?> soruGetir(String soruId) async {
    try {
      final docSnapshot = await _firestore
          .collection(_collection)
          .doc(soruId)
          .get();

      if (docSnapshot.exists) {
        return PaylasilanSoru.fromJson(
          docSnapshot.data()!,
          docSnapshot.id,
        );
      }
      return null;
    } catch (e) {
      debugPrint('❌ Soru getirme hatası: $e');
      return null;
    }
  }

  /// Challenge'ı kabul et
  static Future<bool> challengeKabulEt({
    required String paylasilanSoruId,
    required String aliciId,
  }) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(paylasilanSoruId)
          .update({
            'aliciId': aliciId,
            'durum': 'kabul_edildi',
          });
      
      debugPrint('✅ Challenge kabul edildi: $paylasilanSoruId');
      return true;
    } catch (e) {
      debugPrint('❌ Challenge kabul hatası: $e');
      return false;
    }
  }

  /// Challenge'ı reddet
  static Future<bool> challengeReddet(String paylasilanSoruId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(paylasilanSoruId)
          .update({
            'durum': 'reddedildi',
          });
      
      debugPrint('✅ Challenge reddedildi: $paylasilanSoruId');
      return true;
    } catch (e) {
      debugPrint('❌ Challenge reddetme hatası: $e');
      return false;
    }
  }

  /// Challenge'ı çözdü olarak işaretle
  static Future<bool> challengeCozuldu(String paylasilanSoruId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(paylasilanSoruId)
          .update({
            'durum': 'cozuldu',
          });
      
      debugPrint('✅ Challenge çözüldü: $paylasilanSoruId');
      return true;
    } catch (e) {
      debugPrint('❌ Challenge çözüldü işaretleme hatası: $e');
      return false;
    }
  }

  /// Stream: Gelen challenge'ları dinle (real-time)
  static Stream<List<PaylasilanSoru>> paylasimlariDinle() {
    return _firestore
        .collection(_collection)
        .where('durum', isEqualTo: 'bekliyor')
        .orderBy('gonderilmeTarihi', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaylasilanSoru.fromJson(doc.data(), doc.id))
            .toList());
  }
}
