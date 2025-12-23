import 'package:flutter/material.dart';
import 'models.dart';

/// Paywall ve soru hakkı yönetim servisi
class PaywallService {
  static const int GUNLUK_SORU_LIMITI = 3;
  
  /// Premium özelliklerin listesi
  static const List<String> premiumFeatures = [
    'DetailedAnalysis',
    'SoruCozum',
    'AIAsistan',
    'SoruUretec',
  ];

  /// Paywall gösterilmeli mi kontrolü
  static bool shouldShowPaywall(Ogrenci user, String feature) {
    // Pro kullanıcı her şeyi kullanabilir
    if (user.isPro) return false;
    
    // Premium özellik kontrolü
    if (premiumFeatures.contains(feature)) {
      // Günlük soru hakkı kontrolü
      _checkDailyReset(user);
      return user.gunlukSoruHakki <= 0;
    }
    
    return false;
  }

  /// Gece yarısı reset kontrolü
  static void _checkDailyReset(Ogrenci user) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (user.sonSoruTarihi == null) {
      user.gunlukSoruHakki = GUNLUK_SORU_LIMITI;
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
      user.gunlukSoruHakki = GUNLUK_SORU_LIMITI;
      user.sonSoruTarihi = now;
    }
  }

  /// Soru hakkı kullan
  static bool useQuestionCredit(Ogrenci user) {
    if (user.isPro) return true;
    
    _checkDailyReset(user);
    
    if (user.gunlukSoruHakki > 0) {
      user.gunlukSoruHakki--;
      user.sonSoruTarihi = DateTime.now();
      return true;
    }
    
    return false;
  }

  /// Reklam izleyince +1 hak ver
  static void addBonusCredit(Ogrenci user) {
    user.gunlukSoruHakki++;
  }

  /// Paywall popup göster
  static void showPaywall(BuildContext context, {
    required VoidCallback onWatchAd,
    required VoidCallback onGoPro,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaywallBottomSheet(
        onWatchAd: onWatchAd,
        onGoPro: onGoPro,
      ),
    );
  }
}

/// Paywall Bottom Sheet Widget
class _PaywallBottomSheet extends StatelessWidget {
  final VoidCallback onWatchAd;
  final VoidCallback onGoPro;

  const _PaywallBottomSheet({
    required this.onWatchAd,
    required this.onGoPro,
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
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
