import 'package:flutter/material.dart';
import 'models.dart';
import 'data.dart';

/// 🎫 5 Altın Bilet - Program Sıfırlama Servisi
/// 
/// Kullanıcı Alıştırma (Onboarding) Stratejisi:
/// - İlk 5 sıfırlama: Serbest (Acemilik Dönemi)
/// - 6+ sıfırlama: Disiplin Modu (Free: ayda 1, Pro: haftada 1)
/// - Reklam izleyerek ekstra hak kazanabilir
class ProgramResetService {
  
  // Sabitler
  static const int ACEMILIK_HAKKI = 5;
  static const int FREE_AYLIK_LIMIT = 1;
  static const int PRO_HAFTALIK_LIMIT = 1;

  /// Sıfırlama yapılabilir mi kontrol et
  /// Returns: (izinVar, kalanHak, mesaj)
  static ({bool izinVar, int kalanHak, String mesaj}) kontrolEt(Ogrenci user) {
    final toplamReset = user.programResetCount;
    
    // ═══════════════════════════════════════════════════════════
    // 1. AŞAMA: ACEMİLİK DÖNEMİ (İlk 5 Hak)
    // ═══════════════════════════════════════════════════════════
    if (toplamReset < ACEMILIK_HAKKI) {
      final kalanHak = ACEMILIK_HAKKI - toplamReset;
      return (
        izinVar: true,
        kalanHak: kalanHak,
        mesaj: "🎟️ Deneme hakkın: $kalanHak kaldı",
      );
    }
    
    // Onboarding bittiğini işaretle (bir kez)
    if (!user.onboardingBitti) {
      user.onboardingBitti = true;
    }
    
    // ═══════════════════════════════════════════════════════════
    // 2. AŞAMA: DİSİPLİN DÖNEMİ (Kurallar Devrede)
    // ═══════════════════════════════════════════════════════════
    final sonReset = user.sonProgramResetTarihi;
    final simdi = DateTime.now();
    
    if (user.isPro) {
      // PRO: Haftada 1 sıfırlama
      if (sonReset == null || _birHaftaGectiMi(sonReset, simdi)) {
        return (
          izinVar: true,
          kalanHak: PRO_HAFTALIK_LIMIT,
          mesaj: "✨ Pro hakkın: Bu hafta 1 sıfırlama",
        );
      } else {
        final kalanGun = 7 - simdi.difference(sonReset).inDays;
        return (
          izinVar: false,
          kalanHak: 0,
          mesaj: "⏳ Bir sonraki hak: $kalanGun gün sonra",
        );
      }
    } else {
      // FREE: Ayda 1 sıfırlama
      if (sonReset == null || _birAyGectiMi(sonReset, simdi)) {
        return (
          izinVar: true,
          kalanHak: FREE_AYLIK_LIMIT,
          mesaj: "📅 Free hakkın: Bu ay 1 sıfırlama",
        );
      } else {
        final kalanGun = 30 - simdi.difference(sonReset).inDays;
        return (
          izinVar: false,
          kalanHak: 0,
          mesaj: "⏳ Bir sonraki hak: $kalanGun gün sonra\n💡 Reklam izleyerek hemen hak kazanabilirsin!",
        );
      }
    }
  }

  /// Sıfırlama yap ve sayaçları güncelle
  static void sifirlamaYap(Ogrenci user) {
    user.programResetCount++;
    user.sonProgramResetTarihi = DateTime.now();
    VeriDeposu.kaydet();
    debugPrint("🎫 Program sıfırlandı. Toplam: ${user.programResetCount}");
  }

  /// Reklam izleyerek ekstra hak kazan
  static void reklamIleHakKazan(Ogrenci user) {
    // Son reset tarihini sıfırla (sanki hiç reset yapmamış gibi)
    user.sonProgramResetTarihi = null;
    VeriDeposu.kaydet();
    debugPrint("🎬 Reklam izlendi, ekstra sıfırlama hakkı kazanıldı!");
  }

  /// "Adaptasyon Bitti" popup göster
  static void adaptasyonBittiPopup(BuildContext context, VoidCallback onDevamEt, VoidCallback onProyaGec) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              "🎉 Tebrikler, Sistemi Çözdün!",
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Acemilik (deneme) haklarını doldurdun ve uygulamayı tamamen öğrendin.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withAlpha(100)),
              ),
              child: const Column(
                children: [
                  Text(
                    "Artık oyun bitti, gerçek çalışma vakti! 💪",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Bundan sonra programını:\n• Free: Ayda 1\n• Pro: Haftada 1\nkez sıfırlayabilirsin.",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "💡 Ufak değişiklikler için dersleri sürükleyip bırakman yeterli!",
              style: TextStyle(color: Colors.amber, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              onDevamEt();
            },
            child: const Text("ANLADIM", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(c);
              onProyaGec();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.star, color: Colors.white, size: 18),
            label: const Text("PRO'YA GEÇ", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// "Reklam İzle ve Hak Kazan" popup
  static void reklamHakKazanPopup(BuildContext context, VoidCallback onReklamIzle, VoidCallback onProyaGec) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.timer_off, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text("Sıfırlama Hakkın Bitti", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Bir sonraki ücretsiz hakkın için beklemelisin.\nAma çok acilse...",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade800, Colors.teal.shade700],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.play_circle_outline, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Bir reklam izleyerek\nekstra 1 hak kazanabilirsin!",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Bekleyeceğim", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(c);
              onReklamIzle();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text("REKLAM İZLE", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              onProyaGec();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("PRO", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // YARDIMCI FONKSİYONLAR
  // ═══════════════════════════════════════════════════════════
  
  static bool _birHaftaGectiMi(DateTime sonTarih, DateTime simdi) {
    return simdi.difference(sonTarih).inDays >= 7;
  }

  static bool _birAyGectiMi(DateTime sonTarih, DateTime simdi) {
    return simdi.difference(sonTarih).inDays >= 30;
  }
}
