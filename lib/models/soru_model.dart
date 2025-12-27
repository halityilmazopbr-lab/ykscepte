import 'package:cloud_firestore/cloud_firestore.dart';

/// Yaşayan Soru Bankası - Akıllı Soru Modeli
/// 
/// Bu model sadece veriyi tutmaz, aynı zamanda kendi zorluğunu 
/// hesaplayan ve kalite durumunu takip eden bir "akıl" içerir.
class SoruModel {
  String? id; // Firestore document ID
  final String soruMetni;
  final List<String> siklar;
  final String dogruCevap; // Örn: "A" veya tam sayı cevap
  final String? cozumAciklamasi; // AI'nin ürettiği çözüm
  final String ders; // "Matematik", "Fizik" vb.
  final String konu; // "Türev", "Kuvvet" vb.
  
  // 🎯 YENİ: ÖSYM Standart Alanları
  final int? zorlukDerecesi; // 1: Kolay, 2: Orta, 3: Zor, 4: Çok Zor
  final List<String>? konuEtiketleri; // ["Matematik", "Türev", "Ekstremum"]
  final String? kazanimKodu; // MEB kazanım kodu (Örn: "12.4.1.3")
  final bool? gorselGereksinimi; // Şekil/grafik gerekiyor mu?
  
  // 📊 İstatistikler (Crowdsourced Data)
  int goruntulenme; // Kaç kişi gördü
  int dogruSayisi; // Kaç kişi doğru yaptı
  int yanlisSayisi; // Kaç kişi yanlış yaptı
  int begeni; // 👍 Kaç kişi beğendi
  int begenmeme; // 👎 Kaç kişi beğenmedi
  int rapor; // 🚩 Kaç kişi raporladı
  
  // 🏷️ Meta Veriler
  bool onayliMi; // Admin veya sistem onayı (Karantina mekanizması)
  final String kaynak; // "AI" veya "Manuel"
  final DateTime olusturulmaTarihi;

  SoruModel({
    this.id,
    required this.soruMetni,
    required this.siklar,
    required this.dogruCevap,
    this.cozumAciklamasi,
    required this.ders,
    required this.konu,
    this.zorlukDerecesi,
    this.konuEtiketleri,
    this.kazanimKodu,
    this.gorselGereksinimi,
    this.goruntulenme = 0,
    this.dogruSayisi = 0,
    this.yanlisSayisi = 0,
    this.begeni = 0,
    this.begenmeme = 0,
    this.rapor = 0,
    this.onayliMi = false, // Varsayılan: Onaysız (Candidate)
    this.kaynak = "AI",
    required this.olusturulmaTarihi,
  });

  // 🔥 DİNAMİK ZORLUK HESAPLAYICI
  /// Sorunun zorluk seviyesini gerçek kullanıcı verilerine göre hesaplar.
  /// Statik bir alan değil, anlık hesaplanan bir getter.
  String get zorlukSeviyesi {
    if (goruntulenme < 10) return "Yeni"; // Yeterli veri yok
    
    double basariOrani = (dogruSayisi / goruntulenme) * 100;
    
    if (basariOrani > 75) return "Kolay";
    if (basariOrani > 40) return "Orta";
    return "Zor"; // %40'tan az kişi çözebilmiş
  }

  /// Sorunun zorluk rengi (UI'da göstermek için)
  String get zorlukEmoji {
    switch (zorlukSeviyesi) {
      case "Kolay":
        return "🟢";
      case "Orta":
        return "🟡";
      case "Zor":
        return "🔴";
      default:
        return "⚪"; // Yeni
    }
  }

  /// Başarı oranı (0-100)
  double get basariYuzdesi {
    if (goruntulenme == 0) return 0;
    return (dogruSayisi / goruntulenme) * 100;
  }

  /// Kalite skoru (beğeni - beğenmeme oranı)
  double get kaliteSkor {
    int toplam = begeni + begenmeme;
    if (toplam == 0) return 0;
    return (begeni / toplam) * 100;
  }

  /// Soru karantinada mı? (Çok fazla rapor varsa)
  bool get karantinada {
    if (goruntulenme < 5) return false; // Çok erken karar vermeyelim
    return rapor >= 5 || (rapor / goruntulenme) > 0.1; // %10 üzeri rapor
  }

  // ================== FIREBASE SERIALIZATION ==================

  /// Firestore'dan veri çekerken kullanılır
  factory SoruModel.fromMap(Map<String, dynamic> map, String id) {
    return SoruModel(
      id: id,
      soruMetni: map['soruMetni'] ?? '',
      siklar: List<String>.from(map['siklar'] ?? []),
      dogruCevap: map['dogruCevap'] ?? '',
      cozumAciklamasi: map['cozumAciklamasi'],
      ders: map['ders'] ?? '',
      konu: map['konu'] ?? '',
      zorlukDerecesi: map['zorlukDerecesi'],
      konuEtiketleri: map['konuEtiketleri'] != null 
          ? List<String>.from(map['konuEtiketleri']) 
          : null,
      kazanimKodu: map['kazanimKodu'],
      gorselGereksinimi: map['gorselGereksinimi'],
      goruntulenme: map['goruntulenme'] ?? 0,
      dogruSayisi: map['dogruSayisi'] ?? 0,
      yanlisSayisi: map['yanlisSayisi'] ?? 0,
      begeni: map['begeni'] ?? 0,
      begenmeme: map['begenmeme'] ?? 0,
      rapor: map['rapor'] ?? 0,
      onayliMi: map['onayliMi'] ?? false,
      kaynak: map['kaynak'] ?? 'AI',
      olusturulmaTarihi: (map['olusturulmaTarihi'] as Timestamp).toDate(),
    );
  }

  /// Firestore'a veri gönderirken kullanılır
  Map<String, dynamic> toMap() {
    return {
      'soruMetni': soruMetni,
      'siklar': siklar,
      'dogruCevap': dogruCevap,
      'cozumAciklamasi': cozumAciklamasi,
      'ders': ders,
      'konu': konu,
      'zorlukDerecesi': zorlukDerecesi,
      'konuEtiketleri': konuEtiketleri,
      'kazanimKodu': kazanimKodu,
      'gorselGereksinimi': gorselGereksinimi,
      'goruntulenme': goruntulenme,
      'dogruSayisi': dogruSayisi,
      'yanlisSayisi': yanlisSayisi,
      'begeni': begeni,
      'begenmeme': begenmeme,
      'rapor': rapor,
      'onayliMi': onayliMi,
      'kaynak': kaynak,
      'olusturulmaTarihi': Timestamp.fromDate(olusturulmaTarihi),
    };
  }

  /// Debug için string representation
  @override
  String toString() {
    return 'SoruModel(id: $id, ders: $ders, konu: $konu, zorluk: $zorlukSeviyesi, görüntülenme: $goruntulenme)';
  }
}
