/// 🔮 Kahin (Oracle) Modülü - Hesaplama Servisi
/// YKS net → sıralama tahmini + motivasyonel yorumlar

class OracleService {
  static final OracleService _instance = OracleService._internal();
  factory OracleService() => _instance;
  OracleService._internal();

  // ═══════════════════════════════════════════════════════════════
  // 📊 TYT NET → SIRALAMA VERİ TABANİ (2024 Bazlı)
  // ═══════════════════════════════════════════════════════════════

  final Map<double, int> _tytData = {
    120.0: 1,         // Full çeken 1.
    115.0: 500,
    110.0: 2500,
    105.0: 6000,
    100.0: 12000,
    95.0:  22000,
    90.0:  35000,
    85.0:  52000,
    80.0:  75000,
    75.0:  110000,
    70.0:  160000,
    65.0:  230000,
    60.0:  320000,
    55.0:  450000,
    50.0:  650000,
    45.0:  850000,
    40.0:  1100000,
    35.0:  1450000,
    30.0:  1900000,
    25.0:  2250000,
    20.0:  2600000,
    15.0:  2900000,
    10.0:  3200000,
    5.0:   3400000,
    0.0:   3500000,   // Hiç yapamayan sonuncu
  };

  // ═══════════════════════════════════════════════════════════════
  // 📊 AYT NET → SIRALAMA VERİ TABANİ (Sayısal Alan)
  // ═══════════════════════════════════════════════════════════════

  final Map<double, int> _aytSayisalData = {
    80.0: 100,
    75.0: 500,
    70.0: 1500,
    65.0: 3500,
    60.0: 7000,
    55.0: 12000,
    50.0: 20000,
    45.0: 35000,
    40.0: 55000,
    35.0: 85000,
    30.0: 130000,
    25.0: 200000,
    20.0: 300000,
    15.0: 450000,
    10.0: 650000,
    5.0:  900000,
    0.0:  1200000,
  };

  // ═══════════════════════════════════════════════════════════════
  // 🧮 SIRALAMA HESAPLAMA (Interpolation)
  // ═══════════════════════════════════════════════════════════════

  /// TYT sıralama tahmini
  int calculateTytRank(double net) {
    return _interpolateRank(net, _tytData, maxNet: 120.0, maxRank: 3500000);
  }

  /// AYT Sayısal sıralama tahmini
  int calculateAytSayisalRank(double net) {
    return _interpolateRank(net, _aytSayisalData, maxNet: 80.0, maxRank: 1200000);
  }

  /// Genel interpolasyon fonksiyonu
  int _interpolateRank(double net, Map<double, int> data, {required double maxNet, required int maxRank}) {
    if (net >= maxNet) return 1;
    if (net <= 0) return maxRank;

    // Sorted keys (büyükten küçüğe)
    final sortedKeys = data.keys.toList()..sort((a, b) => b.compareTo(a));

    // Netin hangi aralıkta olduğunu bul
    double upperNet = maxNet;
    double lowerNet = 0;
    
    for (int i = 0; i < sortedKeys.length; i++) {
      if (sortedKeys[i] <= net) {
        lowerNet = sortedKeys[i];
        upperNet = i > 0 ? sortedKeys[i - 1] : maxNet;
        break;
      }
    }

    if (lowerNet == upperNet) return data[lowerNet] ?? maxRank;

    final lowerRank = data[lowerNet] ?? maxRank;
    final upperRank = data[upperNet] ?? 1;

    // Lineer interpolasyon
    final ratio = (net - lowerNet) / (upperNet - lowerNet);
    final rankDiff = lowerRank - upperRank;
    
    return (lowerRank - (rankDiff * ratio)).round();
  }

  // ═══════════════════════════════════════════════════════════════
  // 💬 KAHİN YORUMLARI
  // ═══════════════════════════════════════════════════════════════

  /// Mevcut sıralama vs hedef sıralama karşılaştırması
  String getOracleMessage(int currentRank, int targetRank) {
    final ratio = currentRank / targetRank;

    if (ratio <= 0.8) {
      return "🔥 KADERİN YENİDEN YAZILIYOR!\nBu tempoyla hedefini paramparça edersin. Çalışmaya devam!";
    } else if (ratio <= 1.0) {
      return "🎯 HEDEF MENZILDE!\nHedefindesin ama rehavete kapılma. Son sprinte hazır ol.";
    } else if (ratio <= 1.2) {
      return "🔪 BIÇAK SIRTI!\nHedefin burnunun ucunda. Biraz daha gazlarsan olacak.";
    } else if (ratio <= 1.5) {
      return "⚠️ UYARI SİNYALİ!\nHedefinden uzaklaşıyorsun. Sosyal medyayı bırak, masaya dön.";
    } else if (ratio <= 2.0) {
      return "🚨 TEHLİKE BÖLGESİ!\nCiddi bir açık var. Günlük çalışma saatini artır.";
    } else {
      return "🧊 GERÇEKLER ACI!\nBu netlerle o hedef hayal. Ya hedefini küçült ya çalışmanı büyüt.";
    }
  }

  /// Net değerine göre genel yorum
  String getNetComment(double tytNet) {
    if (tytNet >= 100) {
      return "🏆 Efsane seviyesin! Türkiye'nin en iyileri arasındasın.";
    } else if (tytNet >= 85) {
      return "💪 Çok güçlüsün! Tıp/Hukuk/Mühendislik kapıları açık.";
    } else if (tytNet >= 70) {
      return "👍 İyi durumdasın! Popüler bölümler seni bekliyor.";
    } else if (tytNet >= 55) {
      return "📈 Ortalama üstüsün. Biraz daha çaba ile zirveye çık!";
    } else if (tytNet >= 40) {
      return "⚡ Potansiyelin var! Eksiklerini kapat, yüksel.";
    } else {
      return "🎯 Başlangıç noktasındasın. Her gün bir adım at!";
    }
  }

  /// Sıralamayı okunabilir formata çevir (15000 → "15K")
  String formatRank(int rank) {
    if (rank >= 1000000) {
      return '${(rank / 1000000).toStringAsFixed(1)}M';
    } else if (rank >= 1000) {
      return '${(rank / 1000).toStringAsFixed(0)}K';
    }
    return rank.toString();
  }

  /// İki sıralama arasındaki farkı hesapla
  int rankDifference(int current, int target) {
    return current - target;
  }

  /// Hedefe ulaşmak için gereken net artışını tahmin et
  double estimateNetGain(double currentNet, int targetRank) {
    // Brute force: neti artırarak hedef sıralamayı bul
    double testNet = currentNet;
    while (testNet <= 120) {
      if (calculateTytRank(testNet) <= targetRank) {
        return testNet - currentNet;
      }
      testNet += 0.5;
    }
    return 120 - currentNet; // Maximum
  }
}
