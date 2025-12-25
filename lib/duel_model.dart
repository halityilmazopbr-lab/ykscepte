import 'package:cloud_firestore/cloud_firestore.dart';

/// ⚔️ Düello Veri Modeli
class DuelModel {
  final String id;           // Düello ID (Firebase Doc ID)
  final String code;         // 6 haneli oda kodu (Örn: 123456)
  final String kurucuId;     // Meydan okuyan kullanıcı ID
  final String? rakipId;     // Meydan okunan (Katılan) kullanıcı ID
  final List<dynamic> kartlar; // Deste içeriği (JSON listesi)
  
  // Kurucu (Challenge başlatan) verileri
  final int kurucuSkor;
  final int kurucuSure;      // Saniye cinsinden
  final String kurucuAd;
  
  // Rakip (Meydan okumayı kabul eden) verileri
  final int rakipSkor;
  final int rakipSure;
  final String? rakipAd;

  final String durum;        // 'bekliyor', 'aktif', 'tamamlandi'
  final DateTime createdAt;

  DuelModel({
    required this.id,
    required this.code,
    required this.kurucuId,
    this.rakipId,
    required this.kartlar,
    required this.kurucuSkor,
    required this.kurucuSure,
    required this.kurucuAd,
    this.rakipSkor = 0,
    this.rakipSure = 0,
    this.rakipAd,
    this.durum = 'bekliyor',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'kurucuId': kurucuId,
      'rakipId': rakipId,
      'kartlar': kartlar,
      'kurucuSkor': kurucuSkor,
      'kurucuSure': kurucuSure,
      'kurucuAd': kurucuAd,
      'rakipSkor': rakipSkor,
      'rakipSure': rakipSure,
      'rakipAd': rakipAd,
      'durum': durum,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory DuelModel.fromMap(Map<String, dynamic> map, String docId) {
    return DuelModel(
      id: docId,
      code: map['code'] ?? '',
      kurucuId: map['kurucuId'] ?? '',
      rakipId: map['rakipId'],
      kartlar: map['kartlar'] ?? [],
      kurucuSkor: map['kurucuSkor'] ?? 0,
      kurucuSure: map['kurucuSure'] ?? 0,
      kurucuAd: map['kurucuAd'] ?? 'Gizli Kahraman',
      rakipSkor: map['rakipSkor'] ?? 0,
      rakipSure: map['rakipSure'] ?? 0,
      rakipAd: map['rakipAd'],
      durum: map['durum'] ?? 'bekliyor',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
