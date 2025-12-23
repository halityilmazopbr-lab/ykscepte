import 'package:flutter/foundation.dart';

// google_mobile_ads package will be added
// For now, this is a placeholder that works without the package

/// AdMob Reklam Servisi
/// 
/// NOT: Production için google_mobile_ads paketini ekleyin:
/// flutter pub add google_mobile_ads
/// 
/// AndroidManifest.xml'e ekleyin:
/// <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID"
///            android:value="YOUR_ADMOB_APP_ID"/>
class AdService {
  static bool _initialized = false;
  static bool _adLoaded = false;

  // Test Ad Unit IDs (Google'ın resmi test ID'leri)
  // Production için kendi ID'lerinizle değiştirin
  static const String testAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String testRewardedAdId = 'ca-app-pub-3940256099942544/5224354917';
  
  // Şu an TEST modundayız - Production için yukarıdaki ID'leri değiştirin
  static String appId = testAppId;
  static String rewardedAdUnitId = testRewardedAdId;

  /// Reklam sistemini başlat
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // TODO: google_mobile_ads paketi eklendiğinde:
      // await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('AdService: Initialized (Test Mode)');
      
      // İlk reklamı yükle
      await loadRewardedAd();
    } catch (e) {
      debugPrint('AdService: Initialize error - $e');
    }
  }

  /// Ödüllü reklam yükle
  static Future<void> loadRewardedAd() async {
    try {
      // TODO: google_mobile_ads paketi eklendiğinde:
      // await RewardedAd.load(
      //   adUnitId: rewardedAdUnitId,
      //   request: const AdRequest(),
      //   rewardedAdLoadCallback: RewardedAdLoadCallback(
      //     onAdLoaded: (ad) { _rewardedAd = ad; _adLoaded = true; },
      //     onAdFailedToLoad: (error) { _adLoaded = false; },
      //   ),
      // );
      
      // Test mode - simulate ad loaded
      await Future.delayed(const Duration(milliseconds: 500));
      _adLoaded = true;
      debugPrint('AdService: Rewarded ad loaded (Test Mode)');
    } catch (e) {
      debugPrint('AdService: Load error - $e');
      _adLoaded = false;
    }
  }

  /// Reklam hazır mı?
  static bool get isAdReady => _adLoaded;

  /// Ödüllü reklam göster
  /// [onRewarded] - Reklam tamamlandığında çağrılır, ödül miktarını verir
  /// [onAdClosed] - Reklam kapatıldığında çağrılır
  static Future<void> showRewardedAd({
    required Function(int rewardAmount) onRewarded,
    VoidCallback? onAdClosed,
  }) async {
    if (!_adLoaded) {
      debugPrint('AdService: No ad ready, loading...');
      await loadRewardedAd();
      
      if (!_adLoaded) {
        // Reklam yüklenemedi, yine de ödül ver (test mode)
        debugPrint('AdService: Giving reward anyway (Test Mode)');
        onRewarded(1);
        return;
      }
    }

    try {
      // TODO: google_mobile_ads paketi eklendiğinde:
      // _rewardedAd?.show(
      //   onUserEarnedReward: (ad, reward) {
      //     onRewarded(reward.amount.toInt());
      //   },
      // );
      
      // Test mode - simulate watching ad
      debugPrint('AdService: Showing rewarded ad (Test Mode)');
      await Future.delayed(const Duration(seconds: 2)); // Simulate ad duration
      
      _adLoaded = false;
      onRewarded(1); // Give 1 credit
      onAdClosed?.call();
      
      // Yeni reklam yükle
      loadRewardedAd();
      
    } catch (e) {
      debugPrint('AdService: Show error - $e');
      onRewarded(1); // Hata durumunda da ödül ver (kullanıcı deneyimi için)
    }
  }

  /// Production moduna geç
  static void setProductionIds({
    required String productionAppId,
    required String productionRewardedAdId,
  }) {
    appId = productionAppId;
    rewardedAdUnitId = productionRewardedAdId;
    debugPrint('AdService: Switched to production IDs');
  }
}
