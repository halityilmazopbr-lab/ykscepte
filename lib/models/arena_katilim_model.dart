import 'package:cloud_firestore/cloud_firestore.dart';

/// Arena Katılım Model
/// 
/// Bir öğrencinin challenge'a katılım kaydı.
/// Leaderboard ve live ticker için kullanılır.
class ArenaKatilimModel {
  final String userId;
  final String kullaniciAdi;
  final int puan; // Hız + Doğruluk combo
  final int sure; // Saniye cinsinden
  final bool dogruMu;
  final Timestamp katilimZamani;
  final String? avatarUrl;
  final String? sehir; // "İstanbul'dan Pelin..." için

  ArenaKatilimModel({
    required this.userId,
    required this.kullaniciAdi,
    required this.puan,
    required this.sure,
    required this.dogruMu,
    required this.katilimZamani,
    this.avatarUrl,
    this.sehir,
  });

  /// Sıralama için karşılaştırma
  /// Önce puan (yüksekten düşüğe), sonra süre (düşükten yükseğe)
  int compareTo(ArenaKatilimModel other) {
    if (puan != other.puan) {
      return other.puan.compareTo(puan); // Yüksek puan önce
    }
    return sure.compareTo(other.sure); // Düşük süre önce
  }

  // ================== FIREBASE SERIALIZATION ==================

  factory ArenaKatilimModel.fromMap(Map<String, dynamic> map) {
    return ArenaKatilimModel(
      userId: map['userId'] ?? '',
      kullaniciAdi: map['kullaniciAdi'] ?? 'Anonim',
      puan: map['puan'] ?? 0,
      sure: map['sure'] ?? 0,
      dogruMu: map['dogruMu'] ?? false,
      katilimZamani: map['katilimZamani'] as Timestamp? ?? Timestamp.now(),
      avatarUrl: map['avatarUrl'],
      sehir: map['sehir'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'kullaniciAdi': kullaniciAdi,
      'puan': puan,
      'sure': sure,
      'dogruMu': dogruMu,
      'katilimZamani': katilimZamani,
      'avatarUrl': avatarUrl,
      'sehir': sehir,
    };
  }

  @override
  String toString() {
    return 'ArenaKatilimModel(kullanici: $kullaniciAdi, puan: $puan, sure: ${sure}s)';
  }
}
