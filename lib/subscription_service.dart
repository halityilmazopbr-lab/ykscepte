import 'package:flutter/foundation.dart';

// purchases_flutter package will be added
// For now, this is a placeholder that works without the package

/// RevenueCat Abonelik Servisi
/// 
/// NOT: Production için purchases_flutter paketini ekleyin:
/// flutter pub add purchases_flutter
/// 
/// RevenueCat Dashboard'dan API Key alın:
/// https://app.revenuecat.com/
class SubscriptionService {
  static bool _initialized = false;

  // RevenueCat API Keys
  // Production için kendi API key'inizle değiştirin
  static String _apiKeyAndroid = ''; // YOUR_REVENUECAT_ANDROID_API_KEY
  static String _apiKeyIOS = ''; // YOUR_REVENUECAT_IOS_API_KEY

  // Ürün ID'leri (Google Play Console'da tanımlayın)
  static const String monthlyProductId = 'ykscepte_pro_monthly';
  static const String yearlyProductId = 'ykscepte_pro_yearly';

  // Fiyatlar (Görüntüleme için)
  static const String monthlyPrice = '₺29.99/ay';
  static const String yearlyPrice = '₺199.99/yıl';
  static const String yearlySavings = '%45 Tasarruf';

  /// Abonelik sistemini başlat
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // TODO: purchases_flutter paketi eklendiğinde:
      // await Purchases.setDebugLogsEnabled(true);
      // 
      // if (Platform.isAndroid) {
      //   await Purchases.configure(PurchasesConfiguration(_apiKeyAndroid));
      // } else if (Platform.isIOS) {
      //   await Purchases.configure(PurchasesConfiguration(_apiKeyIOS));
      // }
      
      _initialized = true;
      debugPrint('SubscriptionService: Initialized (Test Mode)');
    } catch (e) {
      debugPrint('SubscriptionService: Initialize error - $e');
    }
  }

  /// Pro abonelik durumu kontrol
  static Future<bool> isPro() async {
    try {
      // TODO: purchases_flutter paketi eklendiğinde:
      // CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      // return customerInfo.entitlements.active.containsKey('pro');
      
      // Test mode - always return false
      return false;
    } catch (e) {
      debugPrint('SubscriptionService: isPro error - $e');
      return false;
    }
  }

  /// Mevcut paketleri getir
  static Future<List<SubscriptionPackage>> getPackages() async {
    try {
      // TODO: purchases_flutter paketi eklendiğinde:
      // Offerings offerings = await Purchases.getOfferings();
      // ...

      // Test mode - return mock packages
      return [
        SubscriptionPackage(
          id: monthlyProductId,
          title: 'Aylık Pro',
          price: monthlyPrice,
          description: 'Her ay otomatik yenilenir',
          isPopular: false,
        ),
        SubscriptionPackage(
          id: yearlyProductId,
          title: 'Yıllık Pro',
          price: yearlyPrice,
          description: yearlySavings,
          isPopular: true,
        ),
      ];
    } catch (e) {
      debugPrint('SubscriptionService: getPackages error - $e');
      return [];
    }
  }

  /// Satın al
  static Future<bool> purchase(String productId) async {
    try {
      // TODO: purchases_flutter paketi eklendiğinde:
      // CustomerInfo customerInfo = await Purchases.purchaseProduct(productId);
      // return customerInfo.entitlements.active.containsKey('pro');
      
      debugPrint('SubscriptionService: Purchase attempted for $productId (Test Mode)');
      
      // Test mode - simulate purchase flow
      await Future.delayed(const Duration(seconds: 1));
      return false; // Gerçek satın alma gerekli
      
    } catch (e) {
      debugPrint('SubscriptionService: Purchase error - $e');
      return false;
    }
  }

  /// Satın alımları geri yükle
  static Future<bool> restore() async {
    try {
      // TODO: purchases_flutter paketi eklendiğinde:
      // CustomerInfo customerInfo = await Purchases.restorePurchases();
      // return customerInfo.entitlements.active.containsKey('pro');
      
      debugPrint('SubscriptionService: Restore attempted (Test Mode)');
      return false;
      
    } catch (e) {
      debugPrint('SubscriptionService: Restore error - $e');
      return false;
    }
  }

  /// API Key'leri ayarla (Production için)
  static void setApiKeys({
    required String androidKey,
    required String iosKey,
  }) {
    _apiKeyAndroid = androidKey;
    _apiKeyIOS = iosKey;
    debugPrint('SubscriptionService: API keys updated');
  }
}

/// Abonelik paketi modeli
class SubscriptionPackage {
  final String id;
  final String title;
  final String price;
  final String description;
  final bool isPopular;

  SubscriptionPackage({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    this.isPopular = false,
  });
}
