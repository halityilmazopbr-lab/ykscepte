import 'package:cloud_firestore/cloud_firestore.dart';

/// 🧬 Twin Profile - Eşleştirme için DNA profili
/// Her öğrencinin haftalık performansını ve eşleştirme skorunu tutar
class TwinProfile {
  final String odgrenciId;
  final String alan;              // SAYISAL, EA, SOZEL, DIL
  final String hedefBolum;        // Tıp, Mühendislik, Hukuk vb.
  final double ortalamaNet;       // Son 4 haftalık net ortalaması
  final int gunlukCalismaDakika;  // Ortalama günlük çalışma süresi (dakika)
  final int twinScore;            // Hesaplanan eşleşme puanı (0-1000)
  
  // Haftalık performans verileri
  final int haftalikSoruSayisi;
  final int haftalikOdakSuresi;   // dakika cinsinden
  final int streak;               // Ardışık aktif gün sayısı
  
  // Son güncelleme
  final DateTime sonGuncelleme;

  TwinProfile({
    required this.odgrenciId,
    required this.alan,
    required this.hedefBolum,
    this.ortalamaNet = 0,
    this.gunlukCalismaDakika = 0,
    this.twinScore = 500,
    this.haftalikSoruSayisi = 0,
    this.haftalikOdakSuresi = 0,
    this.streak = 0,
    required this.sonGuncelleme,
  });

  Map<String, dynamic> toJson() => {
    'odgrenciId': odgrenciId,
    'alan': alan,
    'hedefBolum': hedefBolum,
    'ortalamaNet': ortalamaNet,
    'gunlukCalismaDakika': gunlukCalismaDakika,
    'twinScore': twinScore,
    'haftalikSoruSayisi': haftalikSoruSayisi,
    'haftalikOdakSuresi': haftalikOdakSuresi,
    'streak': streak,
    'sonGuncelleme': sonGuncelleme.toIso8601String(),
  };

  factory TwinProfile.fromJson(Map<String, dynamic> json) => TwinProfile(
    odgrenciId: json['odgrenciId'] ?? '',
    alan: json['alan'] ?? 'SAYISAL',
    hedefBolum: json['hedefBolum'] ?? '',
    ortalamaNet: (json['ortalamaNet'] ?? 0).toDouble(),
    gunlukCalismaDakika: json['gunlukCalismaDakika'] ?? 0,
    twinScore: json['twinScore'] ?? 500,
    haftalikSoruSayisi: json['haftalikSoruSayisi'] ?? 0,
    haftalikOdakSuresi: json['haftalikOdakSuresi'] ?? 0,
    streak: json['streak'] ?? 0,
    sonGuncelleme: json['sonGuncelleme'] != null 
        ? DateTime.parse(json['sonGuncelleme']) 
        : DateTime.now(),
  );

  /// TwinScore'u yeniden hesapla (net ve çalışma saatine göre)
  TwinProfile copyWithUpdatedScore({
    double? yeniNet,
    int? yeniCalismaDakika,
    int? yeniSoruSayisi,
  }) {
    return TwinProfile(
      odgrenciId: odgrenciId,
      alan: alan,
      hedefBolum: hedefBolum,
      ortalamaNet: yeniNet ?? ortalamaNet,
      gunlukCalismaDakika: yeniCalismaDakika ?? gunlukCalismaDakika,
      twinScore: _hesaplaTwinScore(
        yeniNet ?? ortalamaNet,
        yeniCalismaDakika ?? gunlukCalismaDakika,
      ),
      haftalikSoruSayisi: yeniSoruSayisi ?? haftalikSoruSayisi,
      haftalikOdakSuresi: haftalikOdakSuresi,
      streak: streak,
      sonGuncelleme: DateTime.now(),
    );
  }

  int _hesaplaTwinScore(double net, int dakika) {
    // Net: 0-100 arası normalize et, 300 puan ağırlık
    double netPuan = (net / 100) * 300;
    
    // Çalışma süresi: 0-480 dakika (8 saat) normalize et, 200 puan ağırlık
    double calismaPuan = (dakika.clamp(0, 480) / 480) * 200;
    
    // Temel puan: 500 (alan ve hedef uyumundan)
    return (500 + netPuan + calismaPuan).round().clamp(0, 1000);
  }
}

/// 🎭 İkiz Eşleşme Modeli
/// İki öğrenci arasındaki aktif eşleşmeyi temsil eder
class ExamTwin {
  final String id;
  final String odgrenciId;        // Bu kullanıcı
  final String ikizId;            // Eşleşen ikiz
  
  // Gizlilik (Persona)
  final String ikizKodAdi;        // "Neon Kaplan"
  final String ikizEmoji;         // "🐯"
  final int ikizSeviye;           // Seviye 1-20
  
  // Durum
  final String durum;             // 'aktif', 'beklemede', 'pasif'
  final DateTime eslesmeTarihi;
  final DateTime? sonAktivite;    // İkizin son aktivitesi
  
  // Haftalık skor
  final int benimHaftalikSkor;
  final int ikizHaftalikSkor;
  
  // Günlük soru sayısı (canlı takip)
  final int benimGunlukSoru;
  final int ikizGunlukSoru;
  
  // Sollama için üst üste kazanma
  final int ustUsteGalibiyetSayisi;
  
  // Alınan reaksiyonlar
  final List<String> sonReaksiyonlar;

  ExamTwin({
    required this.id,
    required this.odgrenciId,
    required this.ikizId,
    required this.ikizKodAdi,
    required this.ikizEmoji,
    this.ikizSeviye = 1,
    this.durum = 'aktif',
    required this.eslesmeTarihi,
    this.sonAktivite,
    this.benimHaftalikSkor = 0,
    this.ikizHaftalikSkor = 0,
    this.benimGunlukSoru = 0,
    this.ikizGunlukSoru = 0,
    this.ustUsteGalibiyetSayisi = 0,
    this.sonReaksiyonlar = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'odgrenciId': odgrenciId,
    'ikizId': ikizId,
    'ikizKodAdi': ikizKodAdi,
    'ikizEmoji': ikizEmoji,
    'ikizSeviye': ikizSeviye,
    'durum': durum,
    'eslesmeTarihi': eslesmeTarihi.toIso8601String(),
    'sonAktivite': sonAktivite?.toIso8601String(),
    'benimHaftalikSkor': benimHaftalikSkor,
    'ikizHaftalikSkor': ikizHaftalikSkor,
    'benimGunlukSoru': benimGunlukSoru,
    'ikizGunlukSoru': ikizGunlukSoru,
    'ustUsteGalibiyetSayisi': ustUsteGalibiyetSayisi,
    'sonReaksiyonlar': sonReaksiyonlar,
  };

  factory ExamTwin.fromJson(Map<String, dynamic> json, String docId) => ExamTwin(
    id: docId,
    odgrenciId: json['odgrenciId'] ?? '',
    ikizId: json['ikizId'] ?? '',
    ikizKodAdi: json['ikizKodAdi'] ?? 'Gizemli İkiz',
    ikizEmoji: json['ikizEmoji'] ?? '🎭',
    ikizSeviye: json['ikizSeviye'] ?? 1,
    durum: json['durum'] ?? 'aktif',
    eslesmeTarihi: json['eslesmeTarihi'] != null 
        ? DateTime.parse(json['eslesmeTarihi']) 
        : DateTime.now(),
    sonAktivite: json['sonAktivite'] != null 
        ? DateTime.parse(json['sonAktivite']) 
        : null,
    benimHaftalikSkor: json['benimHaftalikSkor'] ?? 0,
    ikizHaftalikSkor: json['ikizHaftalikSkor'] ?? 0,
    benimGunlukSoru: json['benimGunlukSoru'] ?? 0,
    ikizGunlukSoru: json['ikizGunlukSoru'] ?? 0,
    ustUsteGalibiyetSayisi: json['ustUsteGalibiyetSayisi'] ?? 0,
    sonReaksiyonlar: List<String>.from(json['sonReaksiyonlar'] ?? []),
  );

  /// Ben mi öndeyim?
  bool get benOndeyim => benimHaftalikSkor > ikizHaftalikSkor;
  
  /// Günlük düelloda ben mi öndeyim?
  bool get gunlukteOndeyim => benimGunlukSoru > ikizGunlukSoru;
  
  /// Sollama tetiklenmeli mi? (3 gün üst üste kazandıysa)
  bool get sollamaGerekli => ustUsteGalibiyetSayisi >= 3;
}

/// 🎲 Günlük Düello/Bahis Modeli
class DailyBet {
  final String id;
  final String twinId;            // ExamTwin referansı
  final String odgrenci1Id;
  final String odgrenci2Id;
  final DateTime tarih;
  
  final int odgrenci1SoruSayisi;
  final int odgrenci2SoruSayisi;
  
  final String? kazananId;        // null = devam ediyor
  final int odul;                 // Elmas ödülü (20)
  
  // İşbirliği (Co-op) modu
  final bool coopModu;
  final int coopHedef;            // Her iki kişinin de ulaşması gereken soru sayısı
  final bool coopBasarili;        // İkisi de hedefi tutturdu mu?

  DailyBet({
    required this.id,
    required this.twinId,
    required this.odgrenci1Id,
    required this.odgrenci2Id,
    required this.tarih,
    this.odgrenci1SoruSayisi = 0,
    this.odgrenci2SoruSayisi = 0,
    this.kazananId,
    this.odul = 20,
    this.coopModu = false,
    this.coopHedef = 50,
    this.coopBasarili = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'twinId': twinId,
    'odgrenci1Id': odgrenci1Id,
    'odgrenci2Id': odgrenci2Id,
    'tarih': tarih.toIso8601String(),
    'odgrenci1SoruSayisi': odgrenci1SoruSayisi,
    'odgrenci2SoruSayisi': odgrenci2SoruSayisi,
    'kazananId': kazananId,
    'odul': odul,
    'coopModu': coopModu,
    'coopHedef': coopHedef,
    'coopBasarili': coopBasarili,
  };

  factory DailyBet.fromJson(Map<String, dynamic> json, String docId) => DailyBet(
    id: docId,
    twinId: json['twinId'] ?? '',
    odgrenci1Id: json['odgrenci1Id'] ?? '',
    odgrenci2Id: json['odgrenci2Id'] ?? '',
    tarih: json['tarih'] != null 
        ? DateTime.parse(json['tarih']) 
        : DateTime.now(),
    odgrenci1SoruSayisi: json['odgrenci1SoruSayisi'] ?? 0,
    odgrenci2SoruSayisi: json['odgrenci2SoruSayisi'] ?? 0,
    kazananId: json['kazananId'],
    odul: json['odul'] ?? 20,
    coopModu: json['coopModu'] ?? false,
    coopHedef: json['coopHedef'] ?? 50,
    coopBasarili: json['coopBasarili'] ?? false,
  );

  /// Düello bitti mi?
  bool get bitti => kazananId != null || _gunBittiMi();
  
  bool _gunBittiMi() {
    final simdi = DateTime.now();
    return simdi.day != tarih.day || simdi.month != tarih.month;
  }
}

/// 💬 Emoji Reaksiyon
class TwinReaction {
  final String id;
  final String gonderenId;
  final String alanId;
  final String emoji;   // '🔥', '👏', '💤', '⚡', '🎯'
  final DateTime tarih;

  TwinReaction({
    required this.id,
    required this.gonderenId,
    required this.alanId,
    required this.emoji,
    required this.tarih,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'gonderenId': gonderenId,
    'alanId': alanId,
    'emoji': emoji,
    'tarih': FieldValue.serverTimestamp(),
  };

  factory TwinReaction.fromJson(Map<String, dynamic> json, String docId) => TwinReaction(
    id: docId,
    gonderenId: json['gonderenId'] ?? '',
    alanId: json['alanId'] ?? '',
    emoji: json['emoji'] ?? '👏',
    tarih: (json['tarih'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  /// Reaksiyon açıklaması
  String get aciklama {
    switch (emoji) {
      case '🔥': return 'Alev attı!';
      case '👏': return 'Alkışladı!';
      case '💤': return 'Dürtük attı!';
      case '⚡': return 'Enerji gönderdi!';
      case '🎯': return 'Hedefi işaret etti!';
      default: return 'Reaksiyon gönderdi';
    }
  }
}
