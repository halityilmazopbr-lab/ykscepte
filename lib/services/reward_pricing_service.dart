import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Dinamik Fiyatlandırma Servisi
/// Ürün fiyatlarını Firebase Remote Config'den çeker ve komisyon ekler
class RewardPricingService {
  static final RewardPricingService _instance = RewardPricingService._internal();
  factory RewardPricingService() => _instance;
  RewardPricingService._internal();

  late FirebaseRemoteConfig _remoteConfig;
  
  // 🎯 SABİT KOMİSYON ORANI (Sadece burayı değiştir!)
  static const double MARKUP_RATE = 1.10; // %10 kar marjı
  
  // Varsayılan fiyatlar (Remote Config yüklenemezse)
  final Map<String, double> _defaultPrices = {
    'dr_200': 190.0,
    'valorant_1450vp': 165.0,
    'steam_10usd': 310.0,
    'trendyol_100': 100.0,
    'duolingo_1year': 475.0,
    'pubg_600uc': 175.0,
    'brawlstars_170gems': 78.0,
    'playstation_100': 100.0,
    'xbox_100': 100.0,
    'spotify_3month': 165.0,
    'youtube_3month': 190.0,
    'cinemaximum_ticket': 87.0,
    'cinemapink_ticket': 82.0,
  };

  /// Servisini başlat
  Future<void> initialize() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1), // Saatte bir güncelle
      ));

      // Varsayılan değerleri ayarla
      await _remoteConfig.setDefaults(_defaultPrices);
      
      // İlk fetch
      await _remoteConfig.fetchAndActivate();
      
      print('✅ RewardPricingService initialized');
    } catch (e) {
      print('⚠️ Remote Config init failed: $e. Using defaults.');
    }
  }

  /// Ürün fiyatını getir (komisyon dahil)
  double getPrice(String productId) {
    try {
      // Remote Config'den maliyet fiyatını al
      double baseCost = _remoteConfig.getDouble(productId);
      
      // Komisyon ekle ve döndür
      return baseCost * MARKUP_RATE;
    } catch (e) {
      // Fallback: varsayılan fiyat
      double baseCost = _defaultPrices[productId] ?? 100.0;
      return baseCost * MARKUP_RATE;
    }
  }

  /// Manuel güncelleme (ihtiyaç olursa)
  Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
      print('✅ Prices refreshed from Remote Config');
    } catch (e) {
      print('⚠️ Refresh failed: $e');
    }
  }
}
