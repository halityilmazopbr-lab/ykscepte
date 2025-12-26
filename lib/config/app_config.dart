/// NETX Platform Ayarları
class AppConfig {
  /// DANIŞMAN MARKETPLACE SİSTEMİ
  /// 
  /// false: Sadece kurucu (Halit Hoca) görünür, başvuru butonu kapalı
  /// true: Tüm danışman marketplace sistemi aktif
  /// 
  /// Önerilen: Uygulama 100+ öğrenciye ulaşınca true yap
  static const bool ENABLE_COUNSELOR_MARKETPLACE = false;

  /// VIP PAKET LİMİTİ (Sadece senin paketine özel)
  static const int VIP_PACKAGE_MAX_SLOTS = 3;

  /// PRICING SERVICE ENABLED
  /// true: Firebase Remote Config'den dinamik fiyat çeker
  /// false: Sabit fiyatlar (şu anki durum)
  static const bool ENABLE_DYNAMIC_PRICING = false;

  /// DEBUG MODE
  /// true: Test verileri gösterir, mock servisler aktif
  /// false: Production mode
  static const bool DEBUG_MODE = true;
}
