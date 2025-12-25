import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 💎 Elmas Token Ekonomisi Servisi
/// Mining (kazanma), Spending (harcama), Security (güvenlik) yönetimi
class DiamondService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // ═══════════════════════════════════════════════════════════════
  // 📊 SABİTLER (ECONOMY BALANCING)
  // ═══════════════════════════════════════════════════════════════
  
  // Kazanma değerleri (Mining)
  static const int GUNLUK_GIRIS = 5;
  static const int REKLAM_IZLE = 15;
  static const int ODEV_TAMAMLA = 10;
  static const int DUELLO_KAZAN = 5;
  static const int HATA_DEFTERI_EKLE = 1;
  static const int DENEME_BITIR = 25;
  
  // Limitler
  static const int GUNLUK_REKLAM_LIMITI = 1;
  static const int GUNLUK_DUELLO_ODUL_LIMITI = 3;
  
  // Harcama fiyatları (Shop)
  static const int FIYAT_24_SAAT_PRO = 250;
  static const int FIYAT_10_AI_SORU = 40;
  static const int FIYAT_AI_FLASHCARD = 60;
  static const int FIYAT_PROFIL_CERCEVE = 500;
  
  // ═══════════════════════════════════════════════════════════════
  // 💰 BAKİYE İŞLEMLERİ
  // ═══════════════════════════════════════════════════════════════
  
  /// Mevcut bakiyeyi getir
  static Future<int> getBalance(String odenciId) async {
    try {
      final doc = await _db.collection('users').doc(odenciId).get();
      if (doc.exists) {
        final data = doc.data();
        return (data?['wallet']?['balance'] ?? 0) as int;
      }
      return 0;
    } catch (e) {
      debugPrint('❌ Bakiye getirme hatası: $e');
      // Fallback: SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('diamond_balance_$odenciId') ?? 0;
    }
  }
  
  /// Bakiyeyi güncelle (internal)
  static Future<void> _updateBalance(String ogrenciId, int newBalance, String reason, int change) async {
    try {
      await _db.collection('users').doc(ogrenciId).set({
        'wallet': {
          'balance': newBalance,
          'lastUpdated': FieldValue.serverTimestamp(),
          'history': FieldValue.arrayUnion([{
            'reason': reason,
            'change': change,
            'newBalance': newBalance,
            'timestamp': DateTime.now().toIso8601String(),
          }]),
        }
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Bakiye güncelleme hatası: $e');
    }
    
    // Local backup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('diamond_balance_$ogrenciId', newBalance);
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ⛏️ KAZANMA (MINING)
  // ═══════════════════════════════════════════════════════════════
  
  /// Elmas kazan (generic)
  static Future<bool> earnDiamonds({
    required String ogrenciId,
    required int amount,
    required String reason,
  }) async {
    try {
      final currentBalance = await getBalance(ogrenciId);
      final newBalance = currentBalance + amount;
      
      await _updateBalance(ogrenciId, newBalance, reason, amount);
      
      debugPrint('💎 +$amount Elmas kazanıldı: $reason (Yeni bakiye: $newBalance)');
      return true;
    } catch (e) {
      debugPrint('❌ Elmas kazanma hatası: $e');
      return false;
    }
  }
  
  /// Günlük giriş ödülü
  static Future<bool> claimDailyLogin(String ogrenciId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastClaim = prefs.getString('last_daily_claim_$ogrenciId');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    
    if (lastClaim == today) {
      debugPrint('⚠️ Günlük giriş zaten alınmış');
      return false;
    }
    
    final success = await earnDiamonds(
      ogrenciId: ogrenciId,
      amount: GUNLUK_GIRIS,
      reason: 'Günlük Giriş Ödülü',
    );
    
    if (success) {
      await prefs.setString('last_daily_claim_$ogrenciId', today);
    }
    
    return success;
  }
  
  /// Reklam izleme ödülü (günlük 1 kez)
  static Future<bool> claimAdReward(String ogrenciId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastAd = prefs.getString('last_ad_watch_$ogrenciId');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    
    if (lastAd == today) {
      debugPrint('⚠️ Günlük reklam limiti doldu');
      return false;
    }
    
    final success = await earnDiamonds(
      ogrenciId: ogrenciId,
      amount: REKLAM_IZLE,
      reason: 'Reklam İzleme Ödülü',
    );
    
    if (success) {
      await prefs.setString('last_ad_watch_$ogrenciId', today);
    }
    
    return success;
  }
  
  /// Reklam izlenebilir mi?
  static Future<bool> canWatchAd(String ogrenciId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastAd = prefs.getString('last_ad_watch_$ogrenciId');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastAd != today;
  }
  
  /// Ödev tamamlama ödülü
  static Future<bool> claimHomeworkReward(String ogrenciId, String homeworkId) async {
    return earnDiamonds(
      ogrenciId: ogrenciId,
      amount: ODEV_TAMAMLA,
      reason: 'Ödev Tamamlandı: $homeworkId',
    );
  }
  
  /// Düello kazanma ödülü (günlük 3 kez)
  static Future<bool> claimDuelReward(String ogrenciId) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    
    final key = 'duel_wins_$ogrenciId\_$today';
    final todayWins = prefs.getInt(key) ?? 0;
    
    if (todayWins >= GUNLUK_DUELLO_ODUL_LIMITI) {
      debugPrint('⚠️ Günlük düello ödül limiti doldu');
      return false;
    }
    
    final success = await earnDiamonds(
      ogrenciId: ogrenciId,
      amount: DUELLO_KAZAN,
      reason: 'Düello Zaferi',
    );
    
    if (success) {
      await prefs.setInt(key, todayWins + 1);
    }
    
    return success;
  }
  
  /// Hata defterine ekleme ödülü
  static Future<bool> claimErrorLogReward(String ogrenciId) async {
    return earnDiamonds(
      ogrenciId: ogrenciId,
      amount: HATA_DEFTERI_EKLE,
      reason: 'Hata Defterine Ekleme',
    );
  }
  
  /// Deneme sınavı bitirme ödülü
  static Future<bool> claimExamCompletionReward(String ogrenciId, String examId) async {
    return earnDiamonds(
      ogrenciId: ogrenciId,
      amount: DENEME_BITIR,
      reason: 'Deneme Sınavı Tamamlandı: $examId',
    );
  }
  
  // ═══════════════════════════════════════════════════════════════
  // 🛒 HARCAMA (SPENDING)
  // ═══════════════════════════════════════════════════════════════
  
  /// Elmas harca (generic)
  static Future<bool> spendDiamonds({
    required String ogrenciId,
    required int amount,
    required String reason,
  }) async {
    try {
      final currentBalance = await getBalance(ogrenciId);
      
      if (currentBalance < amount) {
        debugPrint('❌ Yetersiz bakiye: $currentBalance < $amount');
        return false;
      }
      
      final newBalance = currentBalance - amount;
      await _updateBalance(ogrenciId, newBalance, reason, -amount);
      
      debugPrint('💎 -$amount Elmas harcandı: $reason (Yeni bakiye: $newBalance)');
      return true;
    } catch (e) {
      debugPrint('❌ Elmas harcama hatası: $e');
      return false;
    }
  }
  
  /// 24 Saatlik Pro satın al
  static Future<bool> purchase24HourPro(String ogrenciId) async {
    final success = await spendDiamonds(
      ogrenciId: ogrenciId,
      amount: FIYAT_24_SAAT_PRO,
      reason: '24 Saatlik Pro Modu',
    );
    
    if (success) {
      // Pro bitiş tarihini ayarla
      final expiration = DateTime.now().add(const Duration(hours: 24));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pro_expiration_$ogrenciId', expiration.toIso8601String());
      
      // Firestore'a da kaydet
      try {
        await _db.collection('users').doc(ogrenciId).set({
          'proExpiration': Timestamp.fromDate(expiration),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('❌ Pro expiration kaydetme hatası: $e');
      }
    }
    
    return success;
  }
  
  /// Pro durumunu kontrol et
  static Future<bool> isPro(String ogrenciId) async {
    final prefs = await SharedPreferences.getInstance();
    final expirationStr = prefs.getString('pro_expiration_$ogrenciId');
    
    if (expirationStr == null) return false;
    
    final expiration = DateTime.tryParse(expirationStr);
    if (expiration == null) return false;
    
    return DateTime.now().isBefore(expiration);
  }
  
  /// Pro bitiş zamanını getir
  static Future<DateTime?> getProExpiration(String ogrenciId) async {
    final prefs = await SharedPreferences.getInstance();
    final expirationStr = prefs.getString('pro_expiration_$ogrenciId');
    
    if (expirationStr == null) return null;
    return DateTime.tryParse(expirationStr);
  }
  
  /// +10 AI Soru Hakkı satın al
  static Future<bool> purchaseAICredits(String ogrenciId) async {
    final success = await spendDiamonds(
      ogrenciId: ogrenciId,
      amount: FIYAT_10_AI_SORU,
      reason: '+10 AI Soru Hakkı',
    );
    
    if (success) {
      // Mevcut soru hakkına 10 ekle
      final prefs = await SharedPreferences.getInstance();
      final key = 'ai_credits_$ogrenciId';
      final current = prefs.getInt(key) ?? 0;
      await prefs.setInt(key, current + 10);
    }
    
    return success;
  }
  
  /// AI Flashcard Destesi satın al
  static Future<bool> purchaseFlashcardDeck(String ogrenciId) async {
    return spendDiamonds(
      ogrenciId: ogrenciId,
      amount: FIYAT_AI_FLASHCARD,
      reason: 'AI Flashcard Destesi',
    );
  }
  
  /// Profil Çerçevesi satın al
  static Future<bool> purchaseProfileFrame(String ogrenciId, String frameId) async {
    final success = await spendDiamonds(
      ogrenciId: ogrenciId,
      amount: FIYAT_PROFIL_CERCEVE,
      reason: 'Profil Çerçevesi: $frameId',
    );
    
    if (success) {
      // Satın alınan çerçeveyi kaydet
      try {
        await _db.collection('users').doc(ogrenciId).set({
          'ownedFrames': FieldValue.arrayUnion([frameId]),
          'activeFrame': frameId,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('❌ Çerçeve kaydetme hatası: $e');
      }
    }
    
    return success;
  }
  
  // ═══════════════════════════════════════════════════════════════
  // 🛡️ GÜVENLİK (SECURITY)
  // ═══════════════════════════════════════════════════════════════
  
  /// Elmas geri çek (ödev reddi durumu)
  static Future<bool> clawbackDiamonds({
    required String ogrenciId,
    required int amount,
    required String reason,
  }) async {
    try {
      final currentBalance = await getBalance(ogrenciId);
      final newBalance = currentBalance - amount; // Negatif olabilir (borç)
      
      await _updateBalance(ogrenciId, newBalance, 'CEZA: $reason', -amount);
      
      debugPrint('⚠️ -$amount Elmas geri çekildi: $reason (Yeni bakiye: $newBalance)');
      return true;
    } catch (e) {
      debugPrint('❌ Elmas geri çekme hatası: $e');
      return false;
    }
  }
  
  /// Ödev reddi cezası
  static Future<bool> penalizeHomeworkRejection(String ogrenciId, String homeworkId) async {
    return clawbackDiamonds(
      ogrenciId: ogrenciId,
      amount: ODEV_TAMAMLA,
      reason: 'Ödev Reddi: $homeworkId',
    );
  }
  
  // ═══════════════════════════════════════════════════════════════
  // 📜 GEÇMİŞ (HISTORY)
  // ═══════════════════════════════════════════════════════════════
  
  /// İşlem geçmişini getir
  static Future<List<Map<String, dynamic>>> getHistory(String ogrenciId) async {
    try {
      final doc = await _db.collection('users').doc(ogrenciId).get();
      if (doc.exists) {
        final data = doc.data();
        final history = data?['wallet']?['history'] as List<dynamic>?;
        if (history != null) {
          return history.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('❌ Geçmiş getirme hatası: $e');
      return [];
    }
  }
}
