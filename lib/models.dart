import 'package:flutter/material.dart';

class Ogrenci {
  String id, tcNo, sifre, ad, sinif, fotoUrl, hedefUniversite, hedefBolum;
  int puan, girisSayisi, hedefPuan;
  String? atananOgretmenId;
  int gunlukSeri;
  double ortalamaNet;
  String okul;
  
  // Pro/Monetization fields
  bool isPro;
  int gunlukSoruHakki;
  DateTime? sonSoruTarihi;
  
  // YENİ: Profil Alanları
  int avatarId;
  String alan;
  int sinifSeviyesi;
  String akademikSeviye;
  String? okulNo;
  String? kurumKodu;
  String? email;
  String? telefon;
  
  // AKILLI KOÇ EKLEMELERİ
  int dailyHours; 
  List<String> weakSubjects;
  
  // VELİ ERİŞİM
  String veliErisimKodu;
  bool devamsizlikDurum;
  
  // 🎫 5 ALTIN BİLET - ONBOARDING SİSTEMİ
  int programResetCount;
  DateTime? sonProgramResetTarihi;
  bool onboardingBitti;
  
  // 🎭 MASKOT SİSTEMİ
  DateTime? sonGirisTarihi;

  Ogrenci({
    required this.id,
    this.tcNo = "",
    this.sifre = "123456",
    required this.ad,
    required this.sinif,
    this.puan = 0,
    this.girisSayisi = 0,
    this.ortalamaNet = 0.0,
    this.okul = "Okul Girilmedi",
    this.atananOgretmenId,
    this.fotoUrl = "",
    this.hedefUniversite = "Hedef Yok",
    this.hedefBolum = "",
    this.hedefPuan = 0,
    this.gunlukSeri = 0,
    this.isPro = false,
    this.gunlukSoruHakki = 3,
    this.sonSoruTarihi,
    this.avatarId = 1,
    this.alan = "SAYISAL",
    this.sinifSeviyesi = 12,
    this.akademikSeviye = "ORTA",
    this.okulNo,
    this.kurumKodu,
    this.email,
    this.telefon,
    this.dailyHours = 6,
    this.weakSubjects = const [],
    this.veliErisimKodu = "",
    this.devamsizlikDurum = true,
    this.programResetCount = 0,
    this.sonProgramResetTarihi,
    this.onboardingBitti = false,
    this.sonGirisTarihi,
  });

  // COMPUTED GETTERS: Seviye sistemi
  /// XP'ye göre seviye hesaplama (her 1000 XP = 1 seviye)
  int get seviye => (puan / 1000).floor() + 1;
  
  /// Seviyeye göre renk döndürme
  Color get seviyeRenk {
    if (seviye <= 5) return Colors.brown; // Bronz
    if (seviye <= 10) return Colors.grey; // Gümüş
    if (seviye <= 20) return Colors.amber; // Altın
    if (seviye <= 35) return Colors.cyanAccent; // Elmas
    return Colors.redAccent; // Efsane
  }
  
  /// Seviyeye göre unvan döndürme
  String get unvan {
    if (seviye <= 2) return "Taze Aday";
    if (seviye <= 5) return "Çırak";
    if (seviye <= 10) return "Kalfa";
    if (seviye <= 15) return "Usta";
    if (seviye <= 20) return "Uzman";
    if (seviye <= 30) return "Üstat";
    if (seviye <= 40) return "Büyük Üstat";
    return "YKS Efsanesi";
  }
  
  /// Öğrenci kurumsal mı kontrolü (kurumKodu varsa kurumsal)
  bool get isKurumsal => kurumKodu != null && kurumKodu!.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tcNo': tcNo,
        'sifre': sifre,
        'ad': ad,
        'sinif': sinif,
        'puan': puan,
        'girisSayisi': girisSayisi,
        'ortalamaNet': ortalamaNet,
        'okul': okul,
        'hedefPuan': hedefPuan,
        'fotoUrl': fotoUrl,
        'hedefUniversite': hedefUniversite,
        'hedefBolum': hedefBolum,
        'gunlukSeri': gunlukSeri,
        'isPro': isPro,
        'gunlukSoruHakki': gunlukSoruHakki,
        'sonSoruTarihi': sonSoruTarihi?.toIso8601String(),
        'avatarId': avatarId,
        'alan': alan,
        'sinifSeviyesi': sinifSeviyesi,
        'akademikSeviye': akademikSeviye,
        'okulNo': okulNo,
        'kurumKodu': kurumKodu,
        'email': email,
        'telefon': telefon,
        'dailyHours': dailyHours,
        'weakSubjects': weakSubjects,
        'veliErisimKodu': veliErisimKodu,
        'devamsizlikDurum': devamsizlikDurum,
        'programResetCount': programResetCount,
        'sonProgramResetTarihi': sonProgramResetTarihi?.toIso8601String(),
        'onboardingBitti': onboardingBitti,
      };

  factory Ogrenci.fromJson(Map<String, dynamic> json) => Ogrenci(
        id: json['id'],
        tcNo: json['tcNo'],
        sifre: json['sifre'],
        ad: json['ad'],
        sinif: json['sinif'],
        puan: json['puan'],
        girisSayisi: json['girisSayisi'],
        ortalamaNet: (json['ortalamaNet'] ?? 0).toDouble(),
        okul: json['okul'] ?? "Okul Girilmedi",
        hedefPuan: json['hedefPuan'],
        fotoUrl: json['fotoUrl'],
        hedefUniversite: json['hedefUniversite'],
        hedefBolum: json['hedefBolum'],
        gunlukSeri: json['gunlukSeri'] ?? 0,
        isPro: json['isPro'] ?? false,
        gunlukSoruHakki: json['gunlukSoruHakki'] ?? 3,
        sonSoruTarihi: json['sonSoruTarihi'] != null ? DateTime.parse(json['sonSoruTarihi']) : null,
        avatarId: json['avatarId'] ?? 1,
        alan: json['alan'] ?? "SAYISAL",
        sinifSeviyesi: json['sinifSeviyesi'] ?? 12,
        akademikSeviye: json['akademikSeviye'] ?? "ORTA",
        okulNo: json['okulNo'],
        kurumKodu: json['kurumKodu'],
        email: json['email'],
        telefon: json['telefon'],
        dailyHours: json['dailyHours'] ?? 6,
        weakSubjects: List<String>.from(json['weakSubjects'] ?? []),
        veliErisimKodu: json['veliErisimKodu'] ?? '',
        devamsizlikDurum: json['devamsizlikDurum'] ?? true,
        programResetCount: json['programResetCount'] ?? 0,
        sonProgramResetTarihi: json['sonProgramResetTarihi'] != null ? DateTime.parse(json['sonProgramResetTarihi']) : null,
        onboardingBitti: json['onboardingBitti'] ?? false,
      );
}

// AKADEMİK RÖNTGEN: Konu tamamlama detayları
class KonuTamamlama {
  String ders;
  String konu;
  DateTime tarih;
  bool hatirlatmaGerekli; // Unutma Eğrisi Analizi için

  KonuTamamlama({
    required this.ders,
    required this.konu,
    required this.tarih,
    this.hatirlatmaGerekli = false,
  });

  Map<String, dynamic> toJson() => {
        'ders': ders,
        'konu': konu,
        'tarih': tarih.toIso8601String(),
        'hatirlatmaGerekli': hatirlatmaGerekli,
      };

  factory KonuTamamlama.fromJson(Map<String, dynamic> json) => KonuTamamlama(
        ders: json['ders'],
        konu: json['konu'],
        tarih: DateTime.parse(json['tarih']),
        hatirlatmaGerekli: json['hatirlatmaGerekli'] ?? false,
      );
}

class Ogretmen {
  String id, tcNo, sifre, ad, brans;
  int girisSayisi;
  Ogretmen({
    required this.id,
    this.tcNo = "",
    this.sifre = "123456",
    required this.ad,
    required this.brans,
    this.girisSayisi = 0,
  });
}

class Gorev {
  String id; // Benzersiz ID
  int hafta;
  String gun, saat, ders, konu, aciklama;
  bool yapildi;

  Gorev({
    required this.id,
    required this.hafta,
    required this.gun,
    required this.saat,
    required this.ders,
    required this.konu,
    this.aciklama = "",
    this.yapildi = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'hafta': hafta,
        'gun': gun,
        'saat': saat,
        'ders': ders,
        'konu': konu,
        'aciklama': aciklama,
        'yapildi': yapildi
      };

  factory Gorev.fromJson(Map<String, dynamic> json) => Gorev(
        id: json['id'] ?? "",
        hafta: json['hafta'],
        gun: json['gun'],
        saat: json['saat'],
        ders: json['ders'],
        konu: json['konu'],
        aciklama: json['aciklama'],
        yapildi: json['yapildi'],
      );
}

class DenemeSonucu {
  String ogrenciId, tur;
  DateTime tarih;
  double toplamNet;
  Map<String, double> dersNetleri;

  DenemeSonucu({
    required this.ogrenciId,
    required this.tur,
    required this.tarih,
    required this.toplamNet,
    required this.dersNetleri,
  });

  Map<String, dynamic> toJson() => {
        'ogrenciId': ogrenciId,
        'tur': tur,
        'tarih': tarih.toIso8601String(),
        'toplamNet': toplamNet,
        'dersNetleri': dersNetleri
      };

  factory DenemeSonucu.fromJson(Map<String, dynamic> json) => DenemeSonucu(
        ogrenciId: json['ogrenciId'],
        tur: json['tur'],
        tarih: DateTime.parse(json['tarih']),
        toplamNet: json['toplamNet'],
        dersNetleri: Map<String, double>.from(json['dersNetleri']),
      );
}

class SoruCozumKaydi {
  String ogrenciId, ders, konu;
  int dogru, yanlis;
  DateTime tarih;

  SoruCozumKaydi({
    required this.ogrenciId,
    required this.ders,
    required this.konu,
    required this.dogru,
    required this.yanlis,
    required this.tarih,
  });

  Map<String, dynamic> toJson() => {
        'ogrenciId': ogrenciId,
        'ders': ders,
        'konu': konu,
        'dogru': dogru,
        'yanlis': yanlis,
        'tarih': tarih.toIso8601String()
      };

  factory SoruCozumKaydi.fromJson(Map<String, dynamic> json) => SoruCozumKaydi(
        ogrenciId: json['ogrenciId'],
        ders: json['ders'],
        konu: json['konu'],
        dogru: json['dogru'],
        yanlis: json['yanlis'],
        tarih: DateTime.parse(json['tarih']),
      );
}

class Rozet {
  String id, ad, aciklama, kategori, seviye;
  int puanDegeri, hedefSayi, mevcutSayi;
  IconData ikon;
  Color renk;
  bool kazanildi;
  bool imgVar;

  Rozet({
    required this.id,
    required this.ad,
    required this.aciklama,
    required this.kategori,
    required this.seviye, // Bronz, Gümüş, Altın...
    required this.puanDegeri,
    required this.ikon,
    required this.renk,
    required this.hedefSayi,
    required this.mevcutSayi,
    this.kazanildi = false,
    this.imgVar = false,
  });

  Map<String, dynamic> toStateJson() => {
        'id': id,
        'mevcutSayi': mevcutSayi,
        'kazanildi': kazanildi
      };
}

class KonuDetay {
  String ad;
  int agirlik;
  KonuDetay(this.ad, this.agirlik);
}

class PdfDeneme {
  String baslik;
  DateTime tarih;
  String dosyaYolu;
  PdfDeneme(this.baslik, this.tarih, this.dosyaYolu);
}

class OkulDersi {
  String ad;
  double yazili1, yazili2, performans;
  OkulDersi({
    required this.ad,
    this.yazili1 = 0,
    this.yazili2 = 0,
    this.performans = 0,
  });
  double get ortalama {
    int b = 0;
    if (yazili1 > 0) b++;
    if (yazili2 > 0) b++;
    if (performans > 0) b++;
    return b == 0 ? 0 : (yazili1 + yazili2 + performans) / b;
  }
}

class KayitliProgramGecmisi {
  DateTime tarih;
  String tur;
  List<Gorev> programVerisi;
  KayitliProgramGecmisi({
    required this.tarih,
    required this.tur,
    required this.programVerisi,
  });
}

class DersGiris {
  String n;
  int soruSayisi;
  TextEditingController d = TextEditingController(),
      y = TextEditingController();
  double net = 0;
  DersGiris(this.n, this.soruSayisi);
}

class Mesaj {
  String text;
  bool isUser;
  Mesaj({required this.text, required this.isUser});
}

/// Hata Defteri Soru Modeli
/// Öğrencinin yapamadığı soruları kaydetmesi için
class HataDefteriSoru {
  String id;
  String ogrenciId;
  String imageBase64;     // Base64 encoded resim
  String ders;            // Matematik, Fizik, vb.
  String konu;            // Türev, Olasılık, vb.
  String? aciklama;       // "İşlem hatası yaptım"
  String? videoCozumLinki; // 🎯 PRO ÖZEL: YouTube linki veya hoca notu
  bool cozuldu;           // Çözüldü mü?
  DateTime tarih;

  HataDefteriSoru({
    required this.id,
    required this.ogrenciId,
    required this.imageBase64,
    required this.ders,
    required this.konu,
    this.aciklama,
    this.videoCozumLinki,
    this.cozuldu = false,
    required this.tarih,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'ogrenciId': ogrenciId,
    'imageBase64': imageBase64,
    'ders': ders,
    'konu': konu,
    'aciklama': aciklama,
    'videoCozumLinki': videoCozumLinki,
    'cozuldu': cozuldu,
    'tarih': tarih.toIso8601String(),
  };

  factory HataDefteriSoru.fromJson(Map<String, dynamic> json) => HataDefteriSoru(
    id: json['id'],
    ogrenciId: json['ogrenciId'],
    imageBase64: json['imageBase64'],
    ders: json['ders'],
    konu: json['konu'],
    aciklama: json['aciklama'],
    videoCozumLinki: json['videoCozumLinki'],
    cozuldu: json['cozuldu'] ?? false,
    tarih: DateTime.parse(json['tarih']),
  );
}
