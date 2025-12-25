import 'package:flutter/material.dart';
import 'models.dart';

/// Paywall ve soru hakkı yönetim servisi
class PaywallService {
  static const int GUNLUK_SORU_LIMITI = 3;      // Free kullanıcı
  static const int PRO_GUNLUK_LIMITI = 80;      // 🔒 Gizli limit (Pazarlamada "Sınırsız" de)
  
  // AI Jeton Paketleri (Micro-transaction)
  static const Map<String, Map<String, dynamic>> jetonPaketleri = {
    'jeton_50': {'miktar': 50, 'fiyat': '49,99 TL', 'fiyatNum': 49.99, 'popüler': true},
    'jeton_20': {'miktar': 20, 'fiyat': '24,99 TL', 'fiyatNum': 24.99, 'popüler': false},
    'jeton_100': {'miktar': 100, 'fiyat': '89,99 TL', 'fiyatNum': 89.99, 'popüler': false},
  };
  
  /// Premium özelliklerin listesi
  static const List<String> premiumFeatures = [
    'DetailedAnalysis',
    'SoruCozum',
    'AIAsistan',
    'SoruUretec',
  ];

  /// Paywall gösterilmeli mi kontrolü
  static bool shouldShowPaywall(Ogrenci user, String feature) {
    _checkDailyReset(user);
    
    // Pro kullanıcı - gizli limit kontrolü (80 soru/gün)
    if (user.isPro) {
      return user.gunlukSoruHakki <= 0; // Limit aşıldıysa Pro paywall göster
    }
    
    // Free kullanıcı - Premium özellik kontrolü
    if (premiumFeatures.contains(feature)) {
      return user.gunlukSoruHakki <= 0;
    }
    
    return false;
  }

  /// Gece yarısı reset kontrolü
  static void _checkDailyReset(Ogrenci user) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // İlk kullanım veya veri yok
    if (user.sonSoruTarihi == null) {
      user.gunlukSoruHakki = user.isPro ? PRO_GUNLUK_LIMITI : GUNLUK_SORU_LIMITI;
      user.sonSoruTarihi = now;
      return;
    }
    
    final lastDate = DateTime(
      user.sonSoruTarihi!.year,
      user.sonSoruTarihi!.month,
      user.sonSoruTarihi!.day,
    );
    
    // Yeni gün başladıysa reset
    if (today.isAfter(lastDate)) {
      user.gunlukSoruHakki = user.isPro ? PRO_GUNLUK_LIMITI : GUNLUK_SORU_LIMITI;
      user.sonSoruTarihi = now;
    }
  }

  /// Soru hakkı kullan
  static bool useQuestionCredit(Ogrenci user) {
    _checkDailyReset(user);
    
    // Pro kullanıcı - gizli limit kontrolü
    if (user.isPro) {
      if (user.gunlukSoruHakki > 0) {
        user.gunlukSoruHakki--;
        user.sonSoruTarihi = DateTime.now();
        return true;
      }
      return false; // Pro limit aşıldı
    }
    
    // Free kullanıcı
    if (user.gunlukSoruHakki > 0) {
      user.gunlukSoruHakki--;
      user.sonSoruTarihi = DateTime.now();
      return true;
    }
    
    return false;
  }
  
  /// Pro kullanıcı limiti aştı mı?
  static bool isProLimitReached(Ogrenci user) {
    if (!user.isPro) return false;
    _checkDailyReset(user);
    return user.gunlukSoruHakki <= 0;
  }
  
  /// Pro limit uyarı mesajı
  static String getProLimitMessage() {
    return "🧠 Bugün çok çalıştın! Yapay zeka motorlarını soğutuyoruz.\n"
           "Yarın görüşmek üzere şampiyon! 🏆";
  }

  /// Reklam izleyince +1 hak ver
  static void addBonusCredit(Ogrenci user) {
    user.gunlukSoruHakki++;
  }

  /// Jeton paketi satın al (50 soru = 49.99 TL)
  static Future<bool> buyTokenPackage(Ogrenci user, String paketId) async {
    final paket = jetonPaketleri[paketId];
    if (paket == null) return false;
    
    // TODO: Gerçek satın alma işlemi (RevenueCat/Google Play)
    // Success olursa:
    final miktar = paket['miktar'] as int;
    user.gunlukSoruHakki += miktar;
    debugPrint('💰 Jeton paketi satın alındı: +$miktar soru hakkı');
    return true;
  }

  /// Paywall popup göster (Eski yöntem - uyumluluk için)
  static void showPaywall(BuildContext context, {
    required VoidCallback onWatchAd,
    required VoidCallback onGoPro,
    VoidCallback? onBuyTokens,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaywallBottomSheet(
        onWatchAd: onWatchAd,
        onGoPro: onGoPro,
        onBuyTokens: onBuyTokens,
      ),
    );
  }
  
  /// 🔥 YENİ: Akıllı Limit Dialog (Free vs Pro farklı tasarım)
  static void showLimitDialog(
    BuildContext context, {
    required bool isPro,
    required VoidCallback onSubscribe,
    required VoidCallback onWatchAd,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => _SmartLimitDialog(
        isPro: isPro,
        onSubscribe: onSubscribe,
        onWatchAd: onWatchAd,
      ),
    );
  }
}

/// 🎯 Akıllı Limit Dialog - Free vs Pro farklı tasarım
class _SmartLimitDialog extends StatelessWidget {
  final bool isPro;
  final VoidCallback onSubscribe;
  final VoidCallback onWatchAd;

  const _SmartLimitDialog({
    required this.isPro,
    required this.onSubscribe,
    required this.onWatchAd,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isPro ? Icons.battery_charging_full : Icons.lock_outline;
    final gradientColors = isPro 
        ? [Colors.teal.shade800, Colors.cyan.shade700]
        : [Colors.deepPurple.shade800, Colors.purple.shade600];
    final title = isPro ? "Mola Zamanı ☕" : "Limit Doldu 🔒";
    
    final description = isPro
        ? "Bugün tam 80 soru çözdürdün, yapay zeka yoruldu! 🧠\n\nHarika bir çalışma temposuydu."
        : "Günlük 3 soru hakkın doldu.\n\nKesintisiz öğrenme için Pro'ya geçebilirsin.";

    final buttonText = isPro ? "Tamam, Anlaşıldı 👍" : "🚀 Pro'ya Geç";
    final buttonColor = isPro ? Colors.grey.shade600 : Colors.deepPurple;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFF161B22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Üst gradient alan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withAlpha(25), shape: BoxShape.circle),
                  child: Icon(icon, size: 56, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          // Alt metin ve butonlar
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(description, style: TextStyle(color: Colors.grey.shade300, height: 1.6, fontSize: 15), textAlign: TextAlign.center),
                const SizedBox(height: 24),

                // Ana buton
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (!isPro) onSubscribe();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),

                // Free için reklam butonu
                if (!isPro) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () { Navigator.pop(context); onWatchAd(); },
                      icon: const Icon(Icons.play_circle_outline, size: 22),
                      label: const Text("Reklam İzle (+1 Hak)"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        side: BorderSide(color: Colors.amber.withAlpha(100)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
                
                // Pro için gece yarısı bilgisi
                if (isPro) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, color: Colors.grey.shade500, size: 16),
                      const SizedBox(width: 6),
                      Text("Hakların gece 00:00'da yenilenecek", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Paywall Bottom Sheet Widget
class _PaywallBottomSheet extends StatelessWidget {
  final VoidCallback onWatchAd;
  final VoidCallback onGoPro;
  final VoidCallback? onBuyTokens;

  const _PaywallBottomSheet({
    required this.onWatchAd,
    required this.onGoPro,
    this.onBuyTokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Lock icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock, size: 48, color: Colors.orange),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            "Günlük Hakkın Bitti! 😢",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            "Ücretsiz kullanıcılar günde 3 soru sorabilir.\nPro'ya geç veya reklam izle!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Watch Ad Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onWatchAd();
              },
              icon: const Icon(Icons.play_circle_outline),
              label: const Text("İzle ve +1 Hak Kazan"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.deepPurple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Go Pro Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onGoPro();
              },
              icon: const Icon(Icons.star),
              label: const Text("PRO'YA GEÇ - Sınırsız Kullan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Buy Tokens Button (yeni)
          if (onBuyTokens != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onBuyTokens!();
                },
                icon: const Icon(Icons.token, color: Colors.orange),
                label: const Text("50 Soru Hakkı = 49,99 TL", style: TextStyle(color: Colors.orange)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
