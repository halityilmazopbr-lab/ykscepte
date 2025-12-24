import 'package:flutter/material.dart';

/// Randevu Saati Modeli
class RandevuSaati {
  String id;
  String ogretmenId;
  String ogretmenAd;
  String brans;
  DateTime tarih;
  String saat; // "09:00", "09:30", "10:00" vb.
  String durum; // "bos", "musait", "dolu"
  String? alanOgrenciId;
  String? alanOgrenciAd;

  RandevuSaati({
    required this.id,
    required this.ogretmenId,
    required this.ogretmenAd,
    required this.brans,
    required this.tarih,
    required this.saat,
    this.durum = "bos",
    this.alanOgrenciId,
    this.alanOgrenciAd,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'ogretmenId': ogretmenId,
    'ogretmenAd': ogretmenAd,
    'brans': brans,
    'tarih': tarih.toIso8601String(),
    'saat': saat,
    'durum': durum,
    'alanOgrenciId': alanOgrenciId,
    'alanOgrenciAd': alanOgrenciAd,
  };

  factory RandevuSaati.fromJson(Map<String, dynamic> json) => RandevuSaati(
    id: json['id'],
    ogretmenId: json['ogretmenId'],
    ogretmenAd: json['ogretmenAd'],
    brans: json['brans'],
    tarih: DateTime.parse(json['tarih']),
    saat: json['saat'],
    durum: json['durum'] ?? 'bos',
    alanOgrenciId: json['alanOgrenciId'],
    alanOgrenciAd: json['alanOgrenciAd'],
  );

  /// Renk duruma göre
  Color get renk {
    switch (durum) {
      case 'musait': return Colors.green;
      case 'dolu': return Colors.red;
      default: return Colors.grey.shade300;
    }
  }

  /// İkon duruma göre
  IconData get ikon {
    switch (durum) {
      case 'musait': return Icons.check_circle;
      case 'dolu': return Icons.cancel;
      default: return Icons.radio_button_unchecked;
    }
  }
}

/// Randevu Bildirimi
class RandevuBildirimi {
  String id;
  String ogretmenId;
  String ogrenciId;
  String ogrenciAd;
  DateTime randevuTarihi;
  String saat;
  String brans;
  bool okundu;
  DateTime olusturmaTarihi;

  RandevuBildirimi({
    required this.id,
    required this.ogretmenId,
    required this.ogrenciId,
    required this.ogrenciAd,
    required this.randevuTarihi,
    required this.saat,
    required this.brans,
    this.okundu = false,
    required this.olusturmaTarihi,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'ogretmenId': ogretmenId,
    'ogrenciId': ogrenciId,
    'ogrenciAd': ogrenciAd,
    'randevuTarihi': randevuTarihi.toIso8601String(),
    'saat': saat,
    'brans': brans,
    'okundu': okundu,
    'olusturmaTarihi': olusturmaTarihi.toIso8601String(),
  };

  factory RandevuBildirimi.fromJson(Map<String, dynamic> json) => RandevuBildirimi(
    id: json['id'],
    ogretmenId: json['ogretmenId'],
    ogrenciId: json['ogrenciId'],
    ogrenciAd: json['ogrenciAd'],
    randevuTarihi: DateTime.parse(json['randevuTarihi']),
    saat: json['saat'],
    brans: json['brans'],
    okundu: json['okundu'] ?? false,
    olusturmaTarihi: DateTime.parse(json['olusturmaTarihi']),
  );
}

/// Sabit saat dilimleri (30 dakikalık)
class RandevuSaatleri {
  static const List<String> tumSaatler = [
    "08:00", "08:30", "09:00", "09:30", "10:00", "10:30",
    "11:00", "11:30", "12:00", "12:30", "13:00", "13:30",
    "14:00", "14:30", "15:00", "15:30", "16:00", "16:30",
    "17:00", "17:30", "18:00", "18:30", "19:00", "19:30",
  ];

  static const List<String> gunler = [
    "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"
  ];
}
