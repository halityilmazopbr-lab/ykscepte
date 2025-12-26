/// 🕵️ NET-X Dedektifi - Veri Modelleri
/// Optik form tarama, hata etiketleme ve analiz için modeller

import 'package:cloud_firestore/cloud_firestore.dart';

// ═══════════════════════════════════════════════════════════════
// 📚 YAYIN MODELİ
// ═══════════════════════════════════════════════════════════════

/// Yayın/Kitap Bilgisi
class YayinModel {
  final String id;
  final String ad;                    // "3D Yayınları TYT Deneme 5"
  final String kategori;              // "TYT", "AYT-Sayısal", vb.
  final Map<int, String> cevapAnahtari; // {1: 'A', 2: 'C', 3: 'D'...}
  final int soruSayisi;
  final String olusturanId;           // Kim taradı?
  final DateTime olusturmaTarihi;
  final bool herkeseAcik;             // Diğer kullanıcılar da kullanabilir mi?

  YayinModel({
    required this.id,
    required this.ad,
    required this.kategori,
    required this.cevapAnahtari,
    required this.soruSayisi,
    required this.olusturanId,
    required this.olusturmaTarihi,
    this.herkeseAcik = true,
  });

  factory YayinModel.fromJson(Map<String, dynamic> json, String id) {
    final cevaplar = <int, String>{};
    final cevapMap = json['cevapAnahtari'] as Map<String, dynamic>?;
    cevapMap?.forEach((key, value) {
      cevaplar[int.parse(key)] = value.toString();
    });

    return YayinModel(
      id: id,
      ad: json['ad'] ?? '',
      kategori: json['kategori'] ?? 'TYT',
      cevapAnahtari: cevaplar,
      soruSayisi: json['soruSayisi'] ?? 0,
      olusturanId: json['olusturanId'] ?? '',
      olusturmaTarihi: (json['olusturmaTarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
      herkeseAcik: json['herkeseAcik'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final cevapMap = <String, String>{};
    cevapAnahtari.forEach((key, value) {
      cevapMap[key.toString()] = value;
    });

    return {
      'ad': ad,
      'kategori': kategori,
      'cevapAnahtari': cevapMap,
      'soruSayisi': soruSayisi,
      'olusturanId': olusturanId,
      'olusturmaTarihi': Timestamp.fromDate(olusturmaTarihi),
      'herkeseAcik': herkeseAcik,
    };
  }
}

// ═══════════════════════════════════════════════════════════════
// 📋 TARAMA SONUCU
// ═══════════════════════════════════════════════════════════════

/// Öğrenci Tarama Sonucu (AI'dan gelen ham veri)
class TaramaSonucu {
  final Map<int, String?> ogrenciCevaplari;  // {1: 'A', 2: null (boş), 3: 'B'...}
  final double guvenSkoru;                    // 0.0 - 1.0 arası AI güveni
  final DateTime tarih;

  TaramaSonucu({
    required this.ogrenciCevaplari,
    this.guvenSkoru = 0.8,
    DateTime? tarih,
  }) : tarih = tarih ?? DateTime.now();

  /// Boş değilse cevap sayısı
  int get cevaplanmisSoruSayisi => 
      ogrenciCevaplari.values.where((v) => v != null).length;
      
  /// Toplam soru sayısı
  int get toplamSoruSayisi => ogrenciCevaplari.length;
}

// ═══════════════════════════════════════════════════════════════
// 🏷️ HATA ETİKETLEME
// ═══════════════════════════════════════════════════════════════

/// Hata Türleri
enum HataTuru {
  dikkatHatasi,    // 🟠 İşlem hatası, yanlış okuma
  bilgiEksigi,     // 🔴 Konuyu bilmiyordum
  sureYetmedi,     // 🟣 Oraya gelemedim
  teredut,         // 🔵 Salladım tutmadı
}

extension HataTuruExtension on HataTuru {
  String get emoji {
    switch (this) {
      case HataTuru.dikkatHatasi: return '🟠';
      case HataTuru.bilgiEksigi: return '🔴';
      case HataTuru.sureYetmedi: return '🟣';
      case HataTuru.teredut: return '🔵';
    }
  }

  String get baslik {
    switch (this) {
      case HataTuru.dikkatHatasi: return 'Dikkat Hatası';
      case HataTuru.bilgiEksigi: return 'Bilgi Eksiği';
      case HataTuru.sureYetmedi: return 'Süre Yetmedi';
      case HataTuru.teredut: return 'Tereddüt/Risk';
    }
  }

  String get aciklama {
    switch (this) {
      case HataTuru.dikkatHatasi: return 'İşlem hatası, yanlış okuma';
      case HataTuru.bilgiEksigi: return 'Konuyu bilmiyordum';
      case HataTuru.sureYetmedi: return 'Oraya gelemedim';
      case HataTuru.teredut: return 'Salladım tutmadı';
    }
  }

  String get renk {
    switch (this) {
      case HataTuru.dikkatHatasi: return '#FF9800'; // Orange
      case HataTuru.bilgiEksigi: return '#F44336';  // Red
      case HataTuru.sureYetmedi: return '#9C27B0';  // Purple
      case HataTuru.teredut: return '#2196F3';      // Blue
    }
  }
}

/// Sorgu Kaydı (Her yanlış/boş soru için)
class SorguKaydi {
  final int soruNo;
  final String dogruCevap;
  final String? ogrenciCevabi;
  final bool bosmu;
  HataTuru? hataTuru;

  SorguKaydi({
    required this.soruNo,
    required this.dogruCevap,
    this.ogrenciCevabi,
    this.hataTuru,
  }) : bosmu = ogrenciCevabi == null;

  bool get yanlisMi => !bosmu && ogrenciCevabi != dogruCevap;
  bool get dogruMu => !bosmu && ogrenciCevabi == dogruCevap;
}

// ═══════════════════════════════════════════════════════════════
// 📊 DEDEKTİF RAPORU
// ═══════════════════════════════════════════════════════════════

/// Dedektif Raporu (Final analiz)
class DedektifRaporu {
  final String id;
  final String ogrenciId;
  final String yayinId;
  final String yayinAdi;
  final DateTime tarih;

  // Net bilgileri
  final int toplamSoru;
  final int dogru;
  final int yanlis;
  final int bos;
  final double mevcutNet;
  final double potansiyelNet; // Dikkat hataları düzeltilseydi

  // Hata dağılımı
  final int dikkatHatasiSayisi;
  final int bilgiEksigiSayisi;
  final int sureYetmediSayisi;
  final int teredutSayisi;

  // Ham veri (ileride detay için)
  final List<SorguKaydi> sorguKayitlari;

  DedektifRaporu({
    required this.id,
    required this.ogrenciId,
    required this.yayinId,
    required this.yayinAdi,
    required this.tarih,
    required this.toplamSoru,
    required this.dogru,
    required this.yanlis,
    required this.bos,
    required this.mevcutNet,
    required this.potansiyelNet,
    required this.dikkatHatasiSayisi,
    required this.bilgiEksigiSayisi,
    required this.sureYetmediSayisi,
    required this.teredutSayisi,
    required this.sorguKayitlari,
  });

  /// Dikkat hatası olmasaydı kazanılacak net
  double get dikkatKaybi => potansiyelNet - mevcutNet;

  /// Toplam hatalı soru sayısı
  int get toplamHata => yanlis + bos;

  /// Potansiyel mesajı
  String get potansiyelMesaji {
    if (dikkatKaybi >= 5) {
      return 'Sen aslında ${potansiyelNet.toStringAsFixed(1)} netlik bir öğrencisin!\nBilgi eksiğin yok, ODAK problemin var.';
    } else if (dikkatKaybi >= 2) {
      return 'Dikkat hatalarını azaltsan ${dikkatKaybi.toStringAsFixed(1)} net daha yaparsın.';
    } else if (bilgiEksigiSayisi > dikkatHatasiSayisi) {
      return 'Konu eksiklerini kapat, potansiyelin çok yüksek!';
    } else {
      return 'İyi gidiyorsun! Küçük hatalarla net kaybediyorsun.';
    }
  }

  factory DedektifRaporu.fromJson(Map<String, dynamic> json, String id) {
    return DedektifRaporu(
      id: id,
      ogrenciId: json['ogrenciId'] ?? '',
      yayinId: json['yayinId'] ?? '',
      yayinAdi: json['yayinAdi'] ?? '',
      tarih: (json['tarih'] as Timestamp?)?.toDate() ?? DateTime.now(),
      toplamSoru: json['toplamSoru'] ?? 0,
      dogru: json['dogru'] ?? 0,
      yanlis: json['yanlis'] ?? 0,
      bos: json['bos'] ?? 0,
      mevcutNet: (json['mevcutNet'] ?? 0).toDouble(),
      potansiyelNet: (json['potansiyelNet'] ?? 0).toDouble(),
      dikkatHatasiSayisi: json['dikkatHatasiSayisi'] ?? 0,
      bilgiEksigiSayisi: json['bilgiEksigiSayisi'] ?? 0,
      sureYetmediSayisi: json['sureYetmediSayisi'] ?? 0,
      teredutSayisi: json['teredutSayisi'] ?? 0,
      sorguKayitlari: [], // Detay için ayrı collection'dan çekilebilir
    );
  }

  Map<String, dynamic> toJson() => {
    'ogrenciId': ogrenciId,
    'yayinId': yayinId,
    'yayinAdi': yayinAdi,
    'tarih': Timestamp.fromDate(tarih),
    'toplamSoru': toplamSoru,
    'dogru': dogru,
    'yanlis': yanlis,
    'bos': bos,
    'mevcutNet': mevcutNet,
    'potansiyelNet': potansiyelNet,
    'dikkatHatasiSayisi': dikkatHatasiSayisi,
    'bilgiEksigiSayisi': bilgiEksigiSayisi,
    'sureYetmediSayisi': sureYetmediSayisi,
    'teredutSayisi': teredutSayisi,
  };
}

// ═══════════════════════════════════════════════════════════════
// 🎯 GÖREV ÖNERİSİ (İleride kullanılacak)
// ═══════════════════════════════════════════════════════════════

/// Kişiye özel görev önerisi
class GorevOnerisi {
  final String baslik;
  final String aciklama;
  final String tur;          // "video", "soru_coz", "odak_modu"
  final String? yonlendirme; // URL veya ekran adı
  final int onem;            // 1-5 arası

  GorevOnerisi({
    required this.baslik,
    required this.aciklama,
    required this.tur,
    this.yonlendirme,
    this.onem = 3,
  });
}
