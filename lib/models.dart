import 'package:flutter/material.dart';

class Ogrenci {
  String id, tcNo, sifre, ad, sinif, fotoUrl, hedefUniversite, hedefBolum;
  int puan, girisSayisi, hedefPuan;
  String? atananOgretmenId;
  int gunlukSeri;
  
  // Pro/Monetization fields
  bool isPro;
  int gunlukSoruHakki;
  DateTime? sonSoruTarihi;
  
  // YENİ: Profil Alanları
  int avatarId; // 1-15 arası hazır avatar
  String alan; // SAYISAL, EA, SOZEL, DIL
  int sinifSeviyesi; // 9, 10, 11, 12, 0=Mezun
  String akademikSeviye; // BASLANGIC, ORTA, ILERI
  String? okulNo; // Kurumsal takip için
  String? kurumKodu; // Hangi okula bağlı
  String? email;
  String? telefon;

  Ogrenci({
    required this.id,
    this.tcNo = "",
    this.sifre = "123456",
    required this.ad,
    required this.sinif,
    this.puan = 0,
    this.girisSayisi = 0,
    this.atananOgretmenId,
    this.fotoUrl = "",
    this.hedefUniversite = "Hedef Yok",
    this.hedefBolum = "",
    this.hedefPuan = 0,
    this.gunlukSeri = 0,
    this.isPro = false,
    this.gunlukSoruHakki = 3,
    this.sonSoruTarihi,
    // Yeni alanlar
    this.avatarId = 1,
    this.alan = "SAYISAL",
    this.sinifSeviyesi = 12,
    this.akademikSeviye = "ORTA",
    this.okulNo,
    this.kurumKodu,
    this.email,
    this.telefon,
  });
  
  // Unvan hesaplama (XP bazlı)
  String get unvan {
    if (puan >= 10000) return "YKS Efsanesi";
    if (puan >= 5000) return "Üstat";
    if (puan >= 2500) return "Usta";
    if (puan >= 1000) return "Deneme Canavarı";
    if (puan >= 500) return "Azimli";
    if (puan >= 100) return "Meraklı";
    return "Çaylak";
  }
  
  // Seviye hesaplama
  String get seviye {
    if (puan >= 10000) return "Elmas";
    if (puan >= 5000) return "Platin";
    if (puan >= 2500) return "Altın";
    if (puan >= 1000) return "Gümüş";
    return "Bronz";
  }
  
  // Seviye rengi
  Color get seviyeRenk {
    switch (seviye) {
      case "Elmas": return Colors.cyanAccent;
      case "Platin": return Colors.purple;
      case "Altın": return Colors.amber;
      case "Gümüş": return Colors.grey;
      default: return Colors.brown;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tcNo': tcNo,
        'sifre': sifre,
        'ad': ad,
        'sinif': sinif,
        'puan': puan,
        'girisSayisi': girisSayisi,
        'hedefPuan': hedefPuan,
        'fotoUrl': fotoUrl,
        'hedefUniversite': hedefUniversite,
        'hedefBolum': hedefBolum,
        'gunlukSeri': gunlukSeri,
        'isPro': isPro,
        'gunlukSoruHakki': gunlukSoruHakki,
        'sonSoruTarihi': sonSoruTarihi?.toIso8601String(),
        // Yeni alanlar
        'avatarId': avatarId,
        'alan': alan,
        'sinifSeviyesi': sinifSeviyesi,
        'akademikSeviye': akademikSeviye,
        'okulNo': okulNo,
        'kurumKodu': kurumKodu,
        'email': email,
        'telefon': telefon,
      };

  factory Ogrenci.fromJson(Map<String, dynamic> json) => Ogrenci(
        id: json['id'],
        tcNo: json['tcNo'],
        sifre: json['sifre'],
        ad: json['ad'],
        sinif: json['sinif'],
        puan: json['puan'],
        girisSayisi: json['girisSayisi'],
        hedefPuan: json['hedefPuan'],
        fotoUrl: json['fotoUrl'],
        hedefUniversite: json['hedefUniversite'],
        hedefBolum: json['hedefBolum'],
        gunlukSeri: json['gunlukSeri'] ?? 0,
        isPro: json['isPro'] ?? false,
        gunlukSoruHakki: json['gunlukSoruHakki'] ?? 3,
        sonSoruTarihi: json['sonSoruTarihi'] != null ? DateTime.parse(json['sonSoruTarihi']) : null,
        // Yeni alanlar
        avatarId: json['avatarId'] ?? 1,
        alan: json['alan'] ?? "SAYISAL",
        sinifSeviyesi: json['sinifSeviyesi'] ?? 12,
        akademikSeviye: json['akademikSeviye'] ?? "ORTA",
        okulNo: json['okulNo'],
        kurumKodu: json['kurumKodu'],
        email: json['email'],
        telefon: json['telefon'],
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
  int hafta;
  String gun, saat, ders, konu, aciklama;
  bool yapildi;

  Gorev({
    required this.hafta,
    required this.gun,
    required this.saat,
    required this.ders,
    required this.konu,
    this.aciklama = "",
    this.yapildi = false,
  });

  Map<String, dynamic> toJson() => {
        'hafta': hafta,
        'gun': gun,
        'saat': saat,
        'ders': ders,
        'konu': konu,
        'aciklama': aciklama,
        'yapildi': yapildi
      };

  factory Gorev.fromJson(Map<String, dynamic> json) => Gorev(
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
  bool cozuldu;           // Çözüldü mü?
  DateTime tarih;

  HataDefteriSoru({
    required this.id,
    required this.ogrenciId,
    required this.imageBase64,
    required this.ders,
    required this.konu,
    this.aciklama,
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
    cozuldu: json['cozuldu'] ?? false,
    tarih: DateTime.parse(json['tarih']),
  );
}
