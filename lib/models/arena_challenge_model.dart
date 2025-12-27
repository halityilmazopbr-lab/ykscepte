import 'package:cloud_firestore/cloud_firestore.dart';

/// Arena Challenge Model
/// 
/// Global meydan okuma sistemi için challenge verisi.
/// 3 tür: Günlük, Boss Raid, Turnuva
class ArenaChallengeModel {
  String? id;
  final String tur; // "Gunluk", "Boss", "Turnuva"
  final String baslik;
  final String aciklama;
  final Timestamp baslangicZamani;
  final Timestamp bitisZamani;
  final bool aktif;
  
  // Soru referansı (cevap sunucuda tutulacak - anti-cheat)
  final String soruId;
  
  // Realtime İstatistikler
  int katilimciSayisi;
  int cozenSayisi;
  
  // Boss Raid için (opsiyonel)
  final int? toplamCan;
  int? kalanCan;
  
  // Ödüller
  final int xpOdul;
  final String? rozetId;

  ArenaChallengeModel({
    this.id,
    required this.tur,
    required this.baslik,
    required this.aciklama,
    required this.baslangicZamani,
    required this.bitisZamani,
    required this.aktif,
    required this.soruId,
    this.katilimciSayisi = 0,
    this.cozenSayisi = 0,
    this.toplamCan,
    this.kalanCan,
    required this.xpOdul,
    this.rozetId,
  });

  /// Challenge türü enum
  static const String turGunluk = "Gunluk";
  static const String turBoss = "Boss";
  static const String turTurnuva = "Turnuva";

  /// Challenge aktif mi?
  bool get suAnAktifMi {
    final now = Timestamp.now();
    return aktif && 
           now.compareTo(baslangicZamani) >= 0 && 
           now.compareTo(bitisZamani) <= 0;
  }

  /// Kalan süre (saniye)
  int get kalanSureSaniye {
    final now = DateTime.now();
    final bitis = bitisZamani.toDate();
    return bitis.difference(now).inSeconds.clamp(0, double.infinity.toInt());
  }

  /// Başarı oranı
  double get basariOrani {
    if (katilimciSayisi == 0) return 0;
    return (cozenSayisi / katilimciSayisi) * 100;
  }

  /// Boss Raid için HP yüzdesi
  double get bossHpYuzdesi {
    if (toplamCan == null || kalanCan == null) return 0;
    return (kalanCan! / toplamCan!) * 100;
  }

  // ================== FIREBASE SERIALIZATION ==================

  factory ArenaChallengeModel.fromMap(Map<String, dynamic> map, String id) {
    return ArenaChallengeModel(
      id: id,
      tur: map['tur'] ?? turGunluk,
      baslik: map['baslik'] ?? '',
      aciklama: map['aciklama'] ?? '',
      baslangicZamani: map['baslangicZamani'] as Timestamp,
      bitisZamani: map['bitisZamani'] as Timestamp,
      aktif: map['aktif'] ?? false,
      soruId: map['soruId'] ?? '',
      katilimciSayisi: map['katilimciSayisi'] ?? 0,
      cozenSayisi: map['cozenSayisi'] ?? 0,
      toplamCan: map['toplamCan'],
      kalanCan: map['kalanCan'],
      xpOdul: map['xpOdul'] ?? 0,
      rozetId: map['rozetId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tur': tur,
      'baslik': baslik,
      'aciklama': aciklama,
      'baslangicZamani': baslangicZamani,
      'bitisZamani': bitisZamani,
      'aktif': aktif,
      'soruId': soruId,
      'katilimciSayisi': katilimciSayisi,
      'cozenSayisi': cozenSayisi,
      'toplamCan': toplamCan,
      'kalanCan': kalanCan,
      'xpOdul': xpOdul,
      'rozetId': rozetId,
    };
  }

  @override
  String toString() {
    return 'ArenaChallengeModel(id: $id, tur: $tur, baslik: $baslik, katilimci: $katilimciSayisi)';
  }
}
