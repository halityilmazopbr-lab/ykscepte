import 'package:flutter/material.dart';
import 'exam_service.dart';
import 'exam_list_screen.dart';

/// 🚪 Akıllı Kapı - Deneme Sınavlarına Erişim Kontrolü
/// Bireysel kullanıcılar: Public sınav varsa geçer, yoksa "Yakında" görür
/// Kurumsal kullanıcılar: Direkt geçer
class ExamGatekeeper {
  
  /// Deneme butonuna tıklandığında çağrılır
  static Future<void> onDenemeClick({
    required BuildContext context,
    required bool isKurumsal,
    String? institutionId,
  }) async {
    // 1. KURUMSAL KULLANICI -> Direkt Geç
    if (isKurumsal) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ExamListScreen()),
      );
      return;
    }

    // 2. BİREYSEL KULLANICI -> Kontrol Et
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      ),
    );

    // Public sınav var mı?
    bool hasPublic = await ExamService().hasPublicExams();

    // Loading'i kapat
    if (context.mounted) Navigator.pop(context);

    if (hasPublic) {
      // Varsa listeye al
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExamListScreen()),
        );
      }
    } else {
      // Yoksa "Yakında" uyarısı
      if (context.mounted) {
        _showComingSoonDialog(context);
      }
    }
  }

  /// Şık "Yakında" Popup'ı
  static void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.rocket_launch, size: 50, color: Colors.orange),
              ),
              const SizedBox(height: 20),
              const Text(
                "Çok Yakında! 🚀",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Türkiye Geneli Deneme Sınavlarımız hazırlanıyor.\nBildirimleri açmayı unutma!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade400, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Tamam, Bekliyorum"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
