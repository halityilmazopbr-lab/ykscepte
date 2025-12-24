import 'package:flutter/material.dart';

/// Envanter (Test) Modeli
class Envanter {
  final String id;
  final String baslik;
  final String aciklama;
  final String tip; // "radar", "bar", "progress", "timed"
  final IconData ikon;
  final Color renk;
  final int sureDakika;
  final List<String> kategoriler;
  final List<EnvanterSorusu> sorular;

  Envanter({
    required this.id,
    required this.baslik,
    required this.aciklama,
    required this.tip,
    required this.ikon,
    required this.renk,
    required this.sureDakika,
    required this.kategoriler,
    required this.sorular,
  });
}

/// Envanter Sorusu Modeli
class EnvanterSorusu {
  final int soruNo;
  final String metin;
  final String kategori;
  final List<String>? secenekler; // Likert ölçeği için

  EnvanterSorusu({
    required this.soruNo,
    required this.metin,
    required this.kategori,
    this.secenekler,
  });
}

/// Envanter Sonucu Modeli
class EnvanterSonucu {
  final String? id;
  final String ogrenciId;
  final String envanterId;
  final Map<String, int> skorlar;
  final int toplamSkor;
  final String seviye;
  final String aiYorum;
  final DateTime tarih;

  EnvanterSonucu({
    this.id,
    required this.ogrenciId,
    required this.envanterId,
    required this.skorlar,
    required this.toplamSkor,
    required this.seviye,
    required this.aiYorum,
    required this.tarih,
  });

  Map<String, dynamic> toJson() => {
    'ogrenciId': ogrenciId,
    'envanterId': envanterId,
    'skorlar': skorlar,
    'toplamSkor': toplamSkor,
    'seviye': seviye,
    'aiYorum': aiYorum,
    'tarih': tarih.toIso8601String(),
  };

  factory EnvanterSonucu.fromJson(Map<String, dynamic> json, String docId) {
    return EnvanterSonucu(
      id: docId,
      ogrenciId: json['ogrenciId'] ?? '',
      envanterId: json['envanterId'] ?? '',
      skorlar: Map<String, int>.from(json['skorlar'] ?? {}),
      toplamSkor: json['toplamSkor'] ?? 0,
      seviye: json['seviye'] ?? '',
      aiYorum: json['aiYorum'] ?? '',
      tarih: json['tarih'] != null 
          ? DateTime.parse(json['tarih']) 
          : DateTime.now(),
    );
  }
}

/// Burdon Testi Sonucu
class BurdonSonucu {
  final int dogru;
  final int yanlis;
  final int atlanan;
  final int toplam;
  final double basariYuzdesi;
  final String seviye;

  BurdonSonucu({
    required this.dogru,
    required this.yanlis,
    required this.atlanan,
    required this.toplam,
    required this.basariYuzdesi,
    required this.seviye,
  });
}
