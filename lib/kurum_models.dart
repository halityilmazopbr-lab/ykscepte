import 'dart:convert';
import 'package:flutter/material.dart';

/// Kurum (Dershane/Okul) Modeli
class Kurum {
  String id;
  String ad;
  String adres;
  double latitude;
  double longitude;
  int yaricapMetre; // GPS toleransı (default: 100m)
  String? qrKodu; // Base64 encoded QR içeriği
  DateTime olusturmaTarihi;

  Kurum({
    required this.id,
    required this.ad,
    this.adres = "",
    required this.latitude,
    required this.longitude,
    this.yaricapMetre = 100,
    this.qrKodu,
    DateTime? olusturmaTarihi,
  }) : olusturmaTarihi = olusturmaTarihi ?? DateTime.now();

  /// QR kod için şifreli veri oluştur
  String generateQrData() {
    final data = {
      'kurum_id': id,
      'lat': latitude,
      'lon': longitude,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return base64Encode(utf8.encode(jsonEncode(data)));
  }

  /// QR verisini çözümle
  static Map<String, dynamic>? parseQrData(String qrData) {
    try {
      final decoded = utf8.decode(base64Decode(qrData));
      return jsonDecode(decoded);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ad': ad,
    'adres': adres,
    'latitude': latitude,
    'longitude': longitude,
    'yaricapMetre': yaricapMetre,
    'qrKodu': qrKodu,
    'olusturmaTarihi': olusturmaTarihi.toIso8601String(),
  };

  factory Kurum.fromJson(Map<String, dynamic> json) => Kurum(
    id: json['id'],
    ad: json['ad'],
    adres: json['adres'] ?? '',
    latitude: json['latitude'],
    longitude: json['longitude'],
    yaricapMetre: json['yaricapMetre'] ?? 100,
    qrKodu: json['qrKodu'],
    olusturmaTarihi: DateTime.parse(json['olusturmaTarihi']),
  );
}

/// Yoklama Kaydı
class YoklamaKaydi {
  String id;
  String ogrenciId;
  String ogrenciAd;
  String kurumId;
  DateTime girisZamani;
  DateTime? cikisZamani;
  bool gecerli; // GPS doğrulandı mı?
  double mesafe; // Kurum merkezine mesafe (metre)

  YoklamaKaydi({
    required this.id,
    required this.ogrenciId,
    required this.ogrenciAd,
    required this.kurumId,
    required this.girisZamani,
    this.cikisZamani,
    this.gecerli = true,
    this.mesafe = 0,
  });

  /// Derste mi?
  bool get derste => cikisZamani == null;

  /// Süre (dakika)
  int get sureDakika {
    final bitis = cikisZamani ?? DateTime.now();
    return bitis.difference(girisZamani).inMinutes;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ogrenciId': ogrenciId,
    'ogrenciAd': ogrenciAd,
    'kurumId': kurumId,
    'girisZamani': girisZamani.toIso8601String(),
    'cikisZamani': cikisZamani?.toIso8601String(),
    'gecerli': gecerli,
    'mesafe': mesafe,
  };

  factory YoklamaKaydi.fromJson(Map<String, dynamic> json) => YoklamaKaydi(
    id: json['id'],
    ogrenciId: json['ogrenciId'],
    ogrenciAd: json['ogrenciAd'],
    kurumId: json['kurumId'],
    girisZamani: DateTime.parse(json['girisZamani']),
    cikisZamani: json['cikisZamani'] != null ? DateTime.parse(json['cikisZamani']) : null,
    gecerli: json['gecerli'] ?? true,
    mesafe: json['mesafe'] ?? 0,
  );
}

/// Yoklama durumu için helper
enum YoklamaDurum {
  basarili,
  konumHatasi,
  qrGecersiz,
  izinYok,
}

extension YoklamaDurumExt on YoklamaDurum {
  String get mesaj {
    switch (this) {
      case YoklamaDurum.basarili:
        return "Yoklama başarıyla kaydedildi!";
      case YoklamaDurum.konumHatasi:
        return "Konumunuz kurum sınırları dışında.";
      case YoklamaDurum.qrGecersiz:
        return "QR kod geçersiz veya tanınmadı.";
      case YoklamaDurum.izinYok:
        return "Konum izni gerekli.";
    }
  }

  Color get renk {
    switch (this) {
      case YoklamaDurum.basarili:
        return Colors.green;
      case YoklamaDurum.konumHatasi:
        return Colors.orange;
      case YoklamaDurum.qrGecersiz:
        return Colors.red;
      case YoklamaDurum.izinYok:
        return Colors.grey;
    }
  }

  IconData get ikon {
    switch (this) {
      case YoklamaDurum.basarili:
        return Icons.check_circle;
      case YoklamaDurum.konumHatasi:
        return Icons.location_off;
      case YoklamaDurum.qrGecersiz:
        return Icons.qr_code_2;
      case YoklamaDurum.izinYok:
        return Icons.gps_off;
    }
  }
}

/// Kurum Yöneticisi Modeli
class KurumYoneticisi {
  String id;
  String kurumId;
  String ad;
  String sifre;
  String? email;
  String? telefon;

  KurumYoneticisi({
    required this.id,
    required this.kurumId,
    required this.ad,
    required this.sifre,
    this.email,
    this.telefon,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'kurumId': kurumId,
    'ad': ad,
    'sifre': sifre,
    'email': email,
    'telefon': telefon,
  };

  factory KurumYoneticisi.fromJson(Map<String, dynamic> json) => KurumYoneticisi(
    id: json['id'],
    kurumId: json['kurumId'],
    ad: json['ad'],
    sifre: json['sifre'],
    email: json['email'],
    telefon: json['telefon'],
  );
}

/// Kurum Duyuru Modeli
class KurumDuyuru {
  String id;
  String kurumId;
  String baslik;
  String icerik;
  String? pdfUrl;
  String? dosyaAdi; // Eklendi
  String tip; // "mesaj", "pdf", "etut", "deneme"
  DateTime tarih;
  bool onemli;

  KurumDuyuru({
    required this.id,
    required this.kurumId,
    required this.baslik,
    required this.icerik,
    this.pdfUrl,
    this.dosyaAdi,
    this.tip = "mesaj",
    DateTime? tarih,
    this.onemli = false,
  }) : tarih = tarih ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'kurumId': kurumId,
    'baslik': baslik,
    'icerik': icerik,
    'pdfUrl': pdfUrl,
    'dosyaAdi': dosyaAdi,
    'tip': tip,
    'tarih': tarih.toIso8601String(),
    'onemli': onemli,
  };

  factory KurumDuyuru.fromJson(Map<String, dynamic> json) => KurumDuyuru(
    id: json['id'],
    kurumId: json['kurumId'],
    baslik: json['baslik'],
    icerik: json['icerik'],
    pdfUrl: json['pdfUrl'],
    dosyaAdi: json['dosyaAdi'],
    tip: json['tip'] ?? 'mesaj',
    tarih: DateTime.parse(json['tarih']),
    onemli: json['onemli'] ?? false,
  );

  IconData get ikon {
    switch (tip) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'etut': return Icons.schedule;
      case 'deneme': return Icons.assignment;
      default: return Icons.message;
    }
  }

  Color get renk {
    switch (tip) {
      case 'pdf': return Colors.red;
      case 'etut': return Colors.blue;
      case 'deneme': return Colors.purple;
      default: return Colors.teal;
    }
  }
}

/// Kurum Deneme/Sınav Modeli
class KurumDenemesi {
  String id;
  String kurumId;
  String dersAdi;
  String kategori; // TYT, AYT
  int soruSayisi;
  int sureDk; // Süre dakika
  String pdfUrl;
  String cevapAnahtari; // "ABCDABCD..." formatında
  DateTime yayinTarihi;
  bool aktifMi;

  KurumDenemesi({
    required this.id,
    required this.kurumId,
    required this.dersAdi,
    required this.kategori,
    required this.soruSayisi,
    required this.sureDk,
    required this.pdfUrl,
    required this.cevapAnahtari,
    required this.yayinTarihi,
    this.aktifMi = true,
  });

  Map<String, dynamic> toFirestore() => {
    'kurum_id': kurumId,
    'ders_adi': dersAdi,
    'kategori': kategori,
    'soru_sayisi': soruSayisi,
    'sure_dk': sureDk,
    'pdf_url': pdfUrl,
    'cevap_anahtari': cevapAnahtari,
    'yayin_tarihi': yayinTarihi.toIso8601String(),
    'aktif_mi': aktifMi,
  };

  factory KurumDenemesi.fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KurumDenemesi(
      id: doc.id,
      kurumId: data['kurum_id'] ?? '',
      dersAdi: data['ders_adi'] ?? '',
      kategori: data['kategori'] ?? 'TYT',
      soruSayisi: data['soru_sayisi'] ?? 40,
      sureDk: data['sure_dk'] ?? 60,
      pdfUrl: data['pdf_url'] ?? '',
      cevapAnahtari: data['cevap_anahtari'] ?? '',
      yayinTarihi: DateTime.parse(data['yayin_tarihi'] ?? DateTime.now().toIso8601String()),
      aktifMi: data['aktif_mi'] ?? true,
    );
  }
}

/// Kurumsal Deneme Sonucu Modeli (Firebase için)
class KurumsalDenemeSonucu {
  String? id;
  String ogrenciId;
  String? denemeId;
  String? ogrenciCevaplari;
  int dogru;
  int yanlis;
  int bos;
  double net;
  DateTime tarih;

  KurumsalDenemeSonucu({
    this.id,
    required this.ogrenciId,
    this.denemeId,
    this.ogrenciCevaplari,
    this.dogru = 0,
    this.yanlis = 0,
    this.bos = 0,
    this.net = 0.0,
    required this.tarih,
  });

  Map<String, dynamic> toFirestore() => {
    'ogrenci_id': ogrenciId,
    'deneme_id': denemeId,
    'ogrenci_cevaplari': ogrenciCevaplari,
    'dogru': dogru,
    'yanlis': yanlis,
    'bos': bos,
    'net': net,
    'tarih': tarih.toIso8601String(),
  };

  factory KurumsalDenemeSonucu.fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KurumsalDenemeSonucu(
      id: doc.id,
      ogrenciId: data['ogrenci_id'] ?? '',
      denemeId: data['deneme_id'],
      ogrenciCevaplari: data['ogrenci_cevaplari'],
      dogru: data['dogru'] ?? 0,
      yanlis: data['yanlis'] ?? 0,
      bos: data['bos'] ?? 0,
      net: (data['net'] ?? 0.0).toDouble(),
      tarih: DateTime.parse(data['tarih'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Kurum Kitap Modeli
class KurumKitabi {
  String id;
  String kurumId;
  String kitapAdi;
  String kapakResmi;
  String pdfUrl;

  KurumKitabi({
    required this.id,
    required this.kurumId,
    required this.kitapAdi,
    this.kapakResmi = '',
    required this.pdfUrl,
  });

  factory KurumKitabi.fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KurumKitabi(
      id: doc.id,
      kurumId: data['kurum_id'] ?? '',
      kitapAdi: data['kitap_adi'] ?? '',
      kapakResmi: data['kapak_resmi'] ?? '',
      pdfUrl: data['pdf_url'] ?? '',
    );
  }
}
