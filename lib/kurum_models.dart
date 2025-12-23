/// Kurumsal Deneme ve Kitap Modülü - Model Sınıfları
/// 
/// Firestore koleksiyonları:
/// - kurum_denemeleri
/// - kurum_kitaplari
/// - deneme_sonuclari

import 'package:cloud_firestore/cloud_firestore.dart';

/// Kurum tarafından yüklenen sınav
class KurumDenemesi {
  final String id;
  final String kurumId;
  final String dersAdi;
  final String kategori; // "TYT" veya "AYT"
  final String pdfUrl;
  final String cevapAnahtari; // "ABCDEABCDE..." (40+ karakter)
  final int sureDk;
  final bool aktifMi;
  final DateTime yayinTarihi;

  KurumDenemesi({
    required this.id,
    required this.kurumId,
    required this.dersAdi,
    required this.kategori,
    required this.pdfUrl,
    required this.cevapAnahtari,
    required this.sureDk,
    required this.aktifMi,
    required this.yayinTarihi,
  });

  /// Firestore'dan veri çek
  factory KurumDenemesi.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KurumDenemesi(
      id: doc.id,
      kurumId: data['kurum_id'] ?? '',
      dersAdi: data['ders_adi'] ?? '',
      kategori: data['kategori'] ?? 'TYT',
      pdfUrl: data['pdf_url'] ?? '',
      cevapAnahtari: data['cevap_anahtari'] ?? '',
      sureDk: data['sure_dk'] ?? 135,
      aktifMi: data['aktif_mi'] ?? true,
      yayinTarihi: (data['yayin_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore'a yaz
  Map<String, dynamic> toFirestore() {
    return {
      'kurum_id': kurumId,
      'ders_adi': dersAdi,
      'kategori': kategori,
      'pdf_url': pdfUrl,
      'cevap_anahtari': cevapAnahtari,
      'sure_dk': sureDk,
      'aktif_mi': aktifMi,
      'yayin_tarihi': Timestamp.fromDate(yayinTarihi),
    };
  }

  /// Soru sayısı
  int get soruSayisi => cevapAnahtari.length;
}

/// Kurum kitabı (konu anlatım, soru bankası)
class KurumKitabi {
  final String id;
  final String kurumId;
  final String kitapAdi;
  final String pdfUrl;
  final String kapakResmi;

  KurumKitabi({
    required this.id,
    required this.kurumId,
    required this.kitapAdi,
    required this.pdfUrl,
    required this.kapakResmi,
  });

  factory KurumKitabi.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KurumKitabi(
      id: doc.id,
      kurumId: data['kurum_id'] ?? '',
      kitapAdi: data['kitap_adi'] ?? '',
      pdfUrl: data['pdf_url'] ?? '',
      kapakResmi: data['kapak_resmi'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'kurum_id': kurumId,
      'kitap_adi': kitapAdi,
      'pdf_url': pdfUrl,
      'kapak_resmi': kapakResmi,
    };
  }
}

/// Öğrenci sınav sonucu
class DenemeSonucu {
  final String? id;
  final String ogrenciId;
  final String denemeId;
  final String ogrenciCevaplari; // "AB DC A..." (öğrencinin işaretleri)
  final int dogru;
  final int yanlis;
  final int bos;
  final double net;
  final DateTime tarih;

  DenemeSonucu({
    this.id,
    required this.ogrenciId,
    required this.denemeId,
    required this.ogrenciCevaplari,
    required this.dogru,
    required this.yanlis,
    required this.bos,
    required this.net,
    required this.tarih,
  });

  factory DenemeSonucu.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DenemeSonucu(
      id: doc.id,
      ogrenciId: data['ogrenci_id'] ?? '',
      denemeId: data['deneme_id'] ?? '',
      ogrenciCevaplari: data['ogrenci_cevaplari'] ?? '',
      dogru: data['dogru_sayisi'] ?? 0,
      yanlis: data['yanlis_sayisi'] ?? 0,
      bos: data['bos_sayisi'] ?? 0,
      net: (data['net'] ?? 0).toDouble(),
      tarih: (data['tarih'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ogrenci_id': ogrenciId,
      'deneme_id': denemeId,
      'ogrenci_cevaplari': ogrenciCevaplari,
      'dogru_sayisi': dogru,
      'yanlis_sayisi': yanlis,
      'bos_sayisi': bos,
      'net': net,
      'tarih': Timestamp.fromDate(tarih),
    };
  }
}
