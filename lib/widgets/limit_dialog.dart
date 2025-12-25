import 'package:flutter/material.dart';

/// Akıllı Limit Dialog - Free ve Pro kullanıcılar için farklı tasarım
/// 
/// Free: "Satın Al" odaklı (turuncu kilit)
/// Pro: "Mola Ver" odaklı (mavi pil)
class LimitReachedDialog extends StatelessWidget {
  final bool isPro;
  final VoidCallback onSubscribe; // Pro'ya geç butonu için
  final VoidCallback onWatchAd;   // Reklam izle butonu için
  final VoidCallback? onClose;    // Pencereyi kapat

  const LimitReachedDialog({
    super.key,
    required this.isPro,
    required this.onSubscribe,
    required this.onWatchAd,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 TASARIM KARARLARI (Free vs Pro)
    final icon = isPro ? Icons.battery_charging_full : Icons.lock_outline;
    final color = isPro ? Colors.teal : Colors.deepPurple;
    final title = isPro ? "Mola Zamanı ☕" : "Limit Doldu 🔒";
    
    final description = isPro
        ? "Bugün tam 80 soru çözdürdün, yapay zeka yoruldu! 🧠\n\nHarika bir çalışma temposuydu. Yarın gece 00:00'da kaldığımız yerden devam edeceğiz."
        : "Günlük 3 soru hakkın doldu.\n\nKesintisiz öğrenme ve rakiplerine fark atmak için Pro'ya geçebilirsin.";

    final buttonText = isPro ? "Tamam, Anlaşıldı 👍" : "🚀 Pro'ya Geç - Sınırsız Kullan";
    final buttonColor = isPro ? Colors.grey.shade600 : Colors.deepPurple;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFF161B22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. ÜST GÖRSEL ALANI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPro 
                    ? [Colors.teal.shade800, Colors.cyan.shade700]
                    : [Colors.deepPurple.shade800, Colors.purple.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Animasyonlu ikon efekti
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon, 
                    size: 56, 
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // 2. METİN ALANI
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade300, 
                    height: 1.6,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // 3. ANA BUTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (!isPro) {
                        onSubscribe();
                      } else {
                        onClose?.call();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: isPro ? 0 : 8,
                      shadowColor: isPro ? null : Colors.purple.withAlpha(100),
                    ),
                    child: Text(
                      buttonText, 
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                // FREE İÇİN EKSTRA: REKLAM İZLEME
                if (!isPro) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onWatchAd();
                      },
                      icon: const Icon(Icons.play_circle_outline, size: 22),
                      label: const Text("Reklam İzle (+1 Hak)"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        side: BorderSide(color: Colors.amber.withAlpha(100)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
                
                // PRO İÇİN: Gece yarısı bilgisi
                if (isPro) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, color: Colors.grey.shade500, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "Hakların gece 00:00'da yenilenecek",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
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
  
  /// Dialog'u göstermek için statik helper
  static void show(
    BuildContext context, {
    required bool isPro,
    required VoidCallback onSubscribe,
    required VoidCallback onWatchAd,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LimitReachedDialog(
        isPro: isPro,
        onSubscribe: onSubscribe,
        onWatchAd: onWatchAd,
      ),
    );
  }
}
