/// 🎁 ÖDÜL MAĞAZASI VE HAFTALIK ANKET MODELLERİ

/// Ödül Mağazasındaki Ürün Modeli
class OdulMagazasiUrunu {
  String id;
  String ad;
  String aciklama;
  String gorselUrl;
  double fiyat; // TL cinsinden
  String kategori; // 'hediye_ceki', 'elektronik', 'kitap' vb.
  bool aktif;
  int stok;
  
  OdulMagazasiUrunu({
    required this.id,
    required this.ad,
    this.aciklama = "",
    required this.gorselUrl,
    required this.fiyat,
    this.kategori = "genel",
    this.aktif = true,
    this.stok = 1,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'ad': ad,
    'aciklama': aciklama,
    'gorselUrl': gorselUrl,
    'fiyat': fiyat,
    'kategori': kategori,
    'aktif': aktif,
    'stok': stok,
  };
  
  factory OdulMagazasiUrunu.fromMap(Map<String, dynamic> map, String docId) => OdulMagazasiUrunu(
    id: docId,
    ad: map['ad'] ?? '',
    aciklama: map['aciklama'] ?? '',
    gorselUrl: map['gorselUrl'] ?? '',
    fiyat: (map['fiyat'] ?? 0).toDouble(),
    kategori: map['kategori'] ?? 'genel',
    aktif: map['aktif'] ?? true,
    stok: map['stok'] ?? 1,
  );
}

/// Haftalık Ödül Anketi Modeli
class HaftalikOdulAnketi {
  String id;
  DateTime baslangicTarihi; // Cuma 20:00
  DateTime bitisTarihi;     // Cumartesi 20:00
  String? yarismaId;        // İlişkili yarışma ID
  double minFiyat;          // 50 TL
  double maxFiyat;          // 150 TL
  List<String> urunIdleri;  // Anketteki ürün ID'leri
  Map<String, int> oylar;   // {urunId: oySayisi}
  List<String> oyKullananlar; // Oy kullanan öğrenci ID'leri
  String? kazananUrunId;    // En çok oy alan ürün
  bool kapandi;             // Anket kapandı mı
  int haftaNumarasi;        // Yılın kaçıncı haftası
  
  HaftalikOdulAnketi({
    required this.id,
    required this.baslangicTarihi,
    required this.bitisTarihi,
    this.yarismaId,
    this.minFiyat = 50.0,
    this.maxFiyat = 150.0,
    this.urunIdleri = const [],
    Map<String, int>? oylar,
    this.oyKullananlar = const [],
    this.kazananUrunId,
    this.kapandi = false,
    required this.haftaNumarasi,
  }) : oylar = oylar ?? {};
  
  /// Anket aktif mi?
  bool get aktifMi {
    final now = DateTime.now();
    return now.isAfter(baslangicTarihi) && now.isBefore(bitisTarihi) && !kapandi;
  }
  
  /// Kalan süre
  Duration get kalanSure {
    final now = DateTime.now();
    if (now.isAfter(bitisTarihi)) return Duration.zero;
    return bitisTarihi.difference(now);
  }
  
  /// Toplam oy sayısı
  int get toplamOy => oylar.values.fold(0, (a, b) => a + b);
  
  /// Kazananı belirle (en çok oy alan)
  String? hesaplaKazanan() {
    if (oylar.isEmpty) return null;
    return oylar.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'baslangicTarihi': baslangicTarihi.toIso8601String(),
    'bitisTarihi': bitisTarihi.toIso8601String(),
    'yarismaId': yarismaId,
    'minFiyat': minFiyat,
    'maxFiyat': maxFiyat,
    'urunIdleri': urunIdleri,
    'oylar': oylar,
    'oyKullananlar': oyKullananlar,
    'kazananUrunId': kazananUrunId,
    'kapandi': kapandi,
    'haftaNumarasi': haftaNumarasi,
  };
  
  factory HaftalikOdulAnketi.fromMap(Map<String, dynamic> map, String docId) => HaftalikOdulAnketi(
    id: docId,
    baslangicTarihi: DateTime.parse(map['baslangicTarihi']),
    bitisTarihi: DateTime.parse(map['bitisTarihi']),
    yarismaId: map['yarismaId'],
    minFiyat: (map['minFiyat'] ?? 50).toDouble(),
    maxFiyat: (map['maxFiyat'] ?? 150).toDouble(),
    urunIdleri: List<String>.from(map['urunIdleri'] ?? []),
    oylar: Map<String, int>.from(map['oylar'] ?? {}),
    oyKullananlar: List<String>.from(map['oyKullananlar'] ?? []),
    kazananUrunId: map['kazananUrunId'],
    kapandi: map['kapandi'] ?? false,
    haftaNumarasi: map['haftaNumarasi'] ?? 1,
  );
}

/// Bireysel Oy Kaydı (değişmezlik ve şeffaflık için)
class OyKaydi {
  String id;
  String anketId;
  String ogrenciId;
  String secilenUrunId;
  DateTime oyTarihi;
  
  OyKaydi({
    required this.id,
    required this.anketId,
    required this.ogrenciId,
    required this.secilenUrunId,
    required this.oyTarihi,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'anketId': anketId,
    'ogrenciId': ogrenciId,
    'secilenUrunId': secilenUrunId,
    'oyTarihi': oyTarihi.toIso8601String(),
  };
  
  factory OyKaydi.fromMap(Map<String, dynamic> map, String docId) => OyKaydi(
    id: docId,
    anketId: map['anketId'] ?? '',
    ogrenciId: map['ogrenciId'] ?? '',
    secilenUrunId: map['secilenUrunId'] ?? '',
    oyTarihi: DateTime.parse(map['oyTarihi']),
  );
}
