/// Paylaşılan Soru Modeli
/// Viral Growth Loop için öğrenciler arası soru paylaşım sistemi

class PaylasilanSoru {
  final String id;
  final String soruId;           // HataDefteriSoru.id
  final String gonderenId;       // Gönderen öğrenci ID
  final String gonderenAd;       // Gönderen adı
  final String? aliciId;         // Alıcı öğrenci ID (null = henüz kabul edilmedi)
  final String ders;
  final String konu;
  final String imageBase64;      // Soru görseli
  final DateTime gonderilmeTarihi;
  final String durum;            // "bekliyor", "kabul_edildi", "reddedildi", "cozuldu"

  PaylasilanSoru({
    required this.id,
    required this.soruId,
    required this.gonderenId,
    required this.gonderenAd,
    this.aliciId,
    required this.ders,
    required this.konu,
    required this.imageBase64,
    required this.gonderilmeTarihi,
    this.durum = "bekliyor",
  });

  /// Firestore'a kaydetmek için JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'soruId': soruId,
    'gonderenId': gonderenId,
    'gonderenAd': gonderenAd,
    'aliciId': aliciId,
    'ders': ders,
    'konu': konu,
    'imageBase64': imageBase64,
    'gonderilmeTarihi': gonderilmeTarihi.toIso8601String(),
    'durum': durum,
  };

  /// Firestore'dan okumak için factory
  factory PaylasilanSoru.fromJson(Map<String, dynamic> json, [String? docId]) {
    return PaylasilanSoru(
      id: docId ?? json['id'] ?? '',
      soruId: json['soruId'] ?? '',
      gonderenId: json['gonderenId'] ?? '',
      gonderenAd: json['gonderenAd'] ?? 'Anonim',
      aliciId: json['aliciId'],
      ders: json['ders'] ?? '',
      konu: json['konu'] ?? '',
      imageBase64: json['imageBase64'] ?? '',
      gonderilmeTarihi: json['gonderilmeTarihi'] != null 
          ? DateTime.parse(json['gonderilmeTarihi']) 
          : DateTime.now(),
      durum: json['durum'] ?? 'bekliyor',
    );
  }

  /// Durum güncellenmiş kopya oluştur
  PaylasilanSoru copyWith({
    String? aliciId,
    String? durum,
  }) {
    return PaylasilanSoru(
      id: id,
      soruId: soruId,
      gonderenId: gonderenId,
      gonderenAd: gonderenAd,
      aliciId: aliciId ?? this.aliciId,
      ders: ders,
      konu: konu,
      imageBase64: imageBase64,
      gonderilmeTarihi: gonderilmeTarihi,
      durum: durum ?? this.durum,
    );
  }

  /// Durum kontrolü
  bool get bekliyor => durum == "bekliyor";
  bool get kabulEdildi => durum == "kabul_edildi";
  bool get reddedildi => durum == "reddedildi";
  bool get cozuldu => durum == "cozuldu";
}
