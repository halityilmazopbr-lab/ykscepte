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
  
  // Admin Giriş Bilgileri
  String adminEmail;
  String adminSifre;

  Kurum({
    required this.id,
    required this.ad,
    this.adres = "",
    required this.latitude,
    required this.longitude,
    this.yaricapMetre = 100,
    this.qrKodu,
    DateTime? olusturmaTarihi,
    this.adminEmail = '',
    this.adminSifre = '',
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
    'adminEmail': adminEmail,
    'adminSifre': adminSifre,
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
    adminEmail: json['adminEmail'] ?? '',
    adminSifre: json['adminSifre'] ?? '',
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

// ═══════════════════════════════════════════════════════════════════════════
// KURUMSAL DENEME SİSTEMİ MODELLERİ
// B2B'nin can damarı - Kağıt israfı, optik okuyucu ve Excel hamallığından kurtuluş
// ═══════════════════════════════════════════════════════════════════════════

/// Kurumsal Deneme - Ana Sınav Modeli
class KurumsalDeneme {
  String id;
  String kurumId;
  String kurumAdi;
  String baslik;           // "TYT 1. Deneme" / "AYT Fen 2. Deneme"
  String tur;              // "TYT" / "AYT_SAY" / "AYT_EA" / "AYT_SOZ"
  DateTime tarih;
  int sureDakika;          // 165 (TYT) / 180 (AYT)
  bool aktif;              // Sınav şu an çözülebilir mi?
  DateTime? baslangicZamani; // Kurum sınavı başlattığında
  String? pdfUrl;          // Dijital sınav için PDF linki
  List<KurumsalDenemeTest> testler;
  Map<int, String> cevapAnahtari; // {1: "A", 2: "C", 3: "B", ...}
  Map<int, String?> videoCozumler; // {5: "youtube.com/...", 12: null, ...}
  
  KurumsalDeneme({
    required this.id,
    required this.kurumId,
    this.kurumAdi = '',
    required this.baslik,
    required this.tur,
    required this.tarih,
    required this.sureDakika,
    this.aktif = false,
    this.baslangicZamani,
    this.pdfUrl,
    required this.testler,
    required this.cevapAnahtari,
    this.videoCozumler = const {},
  });
  
  int get toplamSoruSayisi => testler.fold(0, (sum, t) => sum + t.soruSayisi);
  
  /// Belirli bir sorunun hangi teste ait olduğunu bul
  KurumsalDenemeTest? testiGetir(int soruNo) {
    int sayac = 0;
    for (var test in testler) {
      if (soruNo <= sayac + test.soruSayisi) {
        return test;
      }
      sayac += test.soruSayisi;
    }
    return null;
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'kurum_id': kurumId,
    'kurum_adi': kurumAdi,
    'baslik': baslik,
    'tur': tur,
    'tarih': tarih.toIso8601String(),
    'sure_dakika': sureDakika,
    'aktif': aktif,
    'baslangic_zamani': baslangicZamani?.toIso8601String(),
    'pdf_url': pdfUrl,
    'testler': testler.map((t) => t.toJson()).toList(),
    'cevap_anahtari': cevapAnahtari.map((k, v) => MapEntry(k.toString(), v)),
    'video_cozumler': videoCozumler.map((k, v) => MapEntry(k.toString(), v)),
  };
  
  factory KurumsalDeneme.fromJson(Map<String, dynamic> json) => KurumsalDeneme(
    id: json['id'],
    kurumId: json['kurum_id'],
    kurumAdi: json['kurum_adi'] ?? '',
    baslik: json['baslik'],
    tur: json['tur'],
    tarih: DateTime.parse(json['tarih']),
    sureDakika: json['sure_dakika'],
    aktif: json['aktif'] ?? false,
    baslangicZamani: json['baslangic_zamani'] != null ? DateTime.parse(json['baslangic_zamani']) : null,
    pdfUrl: json['pdf_url'],
    testler: (json['testler'] as List).map((t) => KurumsalDenemeTest.fromJson(t)).toList(),
    cevapAnahtari: (json['cevap_anahtari'] as Map<String, dynamic>).map((k, v) => MapEntry(int.parse(k), v as String)),
    videoCozumler: json['video_cozumler'] != null 
        ? (json['video_cozumler'] as Map<String, dynamic>).map((k, v) => MapEntry(int.parse(k), v as String?))
        : {},
  );
  
  /// Demo TYT Denemesi Oluştur
  factory KurumsalDeneme.demoTYT({required String kurumId, required String kurumAdi}) {
    return KurumsalDeneme(
      id: 'tyt_demo_${DateTime.now().millisecondsSinceEpoch}',
      kurumId: kurumId,
      kurumAdi: kurumAdi,
      baslik: 'TYT 1. Deneme',
      tur: 'TYT',
      tarih: DateTime.now(),
      sureDakika: 165,
      aktif: true,
      testler: [
        KurumsalDenemeTest(ad: 'Türkçe', soruSayisi: 40, baslangicSoru: 1),
        KurumsalDenemeTest(ad: 'Sosyal', soruSayisi: 20, baslangicSoru: 41),
        KurumsalDenemeTest(ad: 'Matematik', soruSayisi: 40, baslangicSoru: 61),
        KurumsalDenemeTest(ad: 'Fen', soruSayisi: 20, baslangicSoru: 101),
      ],
      cevapAnahtari: _rastgeleCevapAnahtari(120),
    );
  }
  
  static Map<int, String> _rastgeleCevapAnahtari(int soruSayisi) {
    final siklar = ['A', 'B', 'C', 'D', 'E'];
    return Map.fromEntries(
      List.generate(soruSayisi, (i) => MapEntry(i + 1, siklar[i % 5]))
    );
  }
}

/// Deneme içindeki Test Bölümü (Türkçe, Matematik, vb.)
class KurumsalDenemeTest {
  String ad;           // "Türkçe", "Matematik", ...
  int soruSayisi;      // 40, 20, ...
  int baslangicSoru;   // Bu testin ilk soru numarası (1, 41, 61, 101 gibi)
  
  KurumsalDenemeTest({
    required this.ad,
    required this.soruSayisi,
    required this.baslangicSoru,
  });
  
  int get bitisSoru => baslangicSoru + soruSayisi - 1;
  
  Map<String, dynamic> toJson() => {
    'ad': ad,
    'soru_sayisi': soruSayisi,
    'baslangic_soru': baslangicSoru,
  };
  
  factory KurumsalDenemeTest.fromJson(Map<String, dynamic> json) => KurumsalDenemeTest(
    ad: json['ad'],
    soruSayisi: json['soru_sayisi'],
    baslangicSoru: json['baslangic_soru'],
  );
}

/// Öğrenci Deneme Sonucu
class KurumsalDenemeSonuc {
  String id;
  String denemeId;
  String ogrenciId;
  String ogrenciAd;
  Map<int, String?> cevaplar; // {1: "A", 2: null, 3: "B", ...} (null = boş)
  DateTime baslangicZamani;
  DateTime? bitisZamani;
  int ihlalSayisi;       // Focus mode ihlalleri
  bool tamamlandi;
  
  // Hesaplanan değerler (bitişte doldurulur)
  Map<String, double>? testNetleri; // {"Türkçe": 35.5, "Matematik": 28.0}
  double? toplamNet;
  int? kurumSirasi;
  int? kurumKatilimci;
  
  KurumsalDenemeSonuc({
    required this.id,
    required this.denemeId,
    required this.ogrenciId,
    this.ogrenciAd = '',
    required this.cevaplar,
    required this.baslangicZamani,
    this.bitisZamani,
    this.ihlalSayisi = 0,
    this.tamamlandi = false,
    this.testNetleri,
    this.toplamNet,
    this.kurumSirasi,
    this.kurumKatilimci,
  });
  
  /// Net hesapla (D - Y/4)
  double hesaplaNet(Map<int, String> cevapAnahtari, int baslangic, int bitis) {
    int dogru = 0, yanlis = 0;
    for (int i = baslangic; i <= bitis; i++) {
      final cevap = cevaplar[i];
      final dogruCevap = cevapAnahtari[i];
      if (cevap != null && dogruCevap != null) {
        if (cevap == dogruCevap) {
          dogru++;
        } else {
          yanlis++;
        }
      }
    }
    return dogru - (yanlis / 4);
  }
  
  /// Tüm netleri hesapla
  void netleriHesapla(KurumsalDeneme deneme) {
    testNetleri = {};
    double toplam = 0;
    
    for (var test in deneme.testler) {
      double net = hesaplaNet(deneme.cevapAnahtari, test.baslangicSoru, test.bitisSoru);
      testNetleri![test.ad] = net;
      toplam += net;
    }
    
    toplamNet = toplam;
  }
  
  /// Boş soru sayısı
  int get bosSayisi {
    int bos = 0;
    cevaplar.forEach((k, v) { if (v == null) bos++; });
    return bos;
  }
  
  /// Doluluk yüzdesi
  double doluYuzdesi(int toplamSoru) => 
      ((toplamSoru - bosSayisi) / toplamSoru * 100);
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'deneme_id': denemeId,
    'ogrenci_id': ogrenciId,
    'ogrenci_ad': ogrenciAd,
    'cevaplar': cevaplar.map((k, v) => MapEntry(k.toString(), v)),
    'baslangic_zamani': baslangicZamani.toIso8601String(),
    'bitis_zamani': bitisZamani?.toIso8601String(),
    'ihlal_sayisi': ihlalSayisi,
    'tamamlandi': tamamlandi,
    'test_netleri': testNetleri,
    'toplam_net': toplamNet,
    'kurum_sirasi': kurumSirasi,
    'kurum_katilimci': kurumKatilimci,
  };
  
  factory KurumsalDenemeSonuc.fromJson(Map<String, dynamic> json) => KurumsalDenemeSonuc(
    id: json['id'],
    denemeId: json['deneme_id'],
    ogrenciId: json['ogrenci_id'],
    ogrenciAd: json['ogrenci_ad'] ?? '',
    cevaplar: (json['cevaplar'] as Map<String, dynamic>).map((k, v) => MapEntry(int.parse(k), v as String?)),
    baslangicZamani: DateTime.parse(json['baslangic_zamani']),
    bitisZamani: json['bitis_zamani'] != null ? DateTime.parse(json['bitis_zamani']) : null,
    ihlalSayisi: json['ihlal_sayisi'] ?? 0,
    tamamlandi: json['tamamlandi'] ?? false,
    testNetleri: json['test_netleri'] != null 
        ? Map<String, double>.from(json['test_netleri'])
        : null,
    toplamNet: json['toplam_net']?.toDouble(),
    kurumSirasi: json['kurum_sirasi'],
    kurumKatilimci: json['kurum_katilimci'],
  );
}

/// Aktif Sınav Oturumu (Focus Mode ve anlık kayıt için)
class KurumsalDenemeOturumu {
  String denemeId;
  String ogrenciId;
  DateTime baslangic;
  int ihlalSayisi;
  bool aktif;
  Map<int, String?> geciciCevaplar;
  
  KurumsalDenemeOturumu({
    required this.denemeId,
    required this.ogrenciId,
    required this.baslangic,
    this.ihlalSayisi = 0,
    this.aktif = true,
    Map<int, String?>? geciciCevaplar,
  }) : geciciCevaplar = geciciCevaplar ?? {};
  
  /// Kalan süre (saniye)
  int kalanSure(int toplamDakika) {
    final gecenSure = DateTime.now().difference(baslangic).inSeconds;
    final toplamSaniye = toplamDakika * 60;
    return (toplamSaniye - gecenSure).clamp(0, toplamSaniye);
  }
  
  /// Süre doldu mu?
  bool sureDolduMu(int toplamDakika) => kalanSure(toplamDakika) <= 0;
  
  /// İhlal ekle
  void ihlalEkle() {
    ihlalSayisi++;
    if (ihlalSayisi >= 2) {
      aktif = false; // Sınav iptal
    }
  }
}

