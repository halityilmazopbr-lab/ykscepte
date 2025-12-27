/// 🎯 NETX Focus Modülü - Ana Menü
/// Operasyon seçim ekranı

import 'package:flutter/material.dart';
import 'sensor_mode_screen.dart';
import 'optical_mode_screen.dart';
import 'chrono_mode_screen.dart';

class FocusMenuScreen extends StatelessWidget {
  const FocusMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          "OPERASYON SEÇİMİ",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 30),

            // ═══════════════════════════════════════════════════
            // MOD 1: SIKIYÖNETİM (Sensörlü)
            // ═══════════════════════════════════════════════════
            _buildCard(
              context,
              title: "SIKIYÖNETİM MODU",
              subtitle: "Telefon masaya kilitlenir. Hareket ederse yanarsın.",
              icon: Icons.phonelink_lock,
              color: Colors.redAccent,
              badge: "🔒 HARDCORE",
              page: const SensorModeScreen(),
            ),

            const SizedBox(height: 15),

            // ═══════════════════════════════════════════════════
            // MOD 2: OPTİK MOD (App Lifecycle)
            // ═══════════════════════════════════════════════════
            _buildCard(
              context,
              title: "OPTİK MOD",
              subtitle: "Şıkları buradan gir. Uygulamadan çıkmak yasak.",
              icon: Icons.edit_note,
              color: Colors.cyanAccent,
              badge: "📝 DENEME",
              page: const OpticalModeScreen(),
            ),

            const SizedBox(height: 15),

            // ═══════════════════════════════════════════════════
            // MOD 3: SERBEST MOD (Kronometre)
            // ═══════════════════════════════════════════════════
            _buildCard(
              context,
              title: "SERBEST ÇALIŞMA",
              subtitle: "Video/Konu çalışması. Sadece kronometre.",
              icon: Icons.timer_outlined,
              color: Colors.greenAccent,
              badge: "⏱️ RAHAT",
              page: const ChronoModeScreen(),
            ),

            const Spacer(),

            // Alt bilgi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white24, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Sıkıyönetim modunda ekran açık kalır ve sensörler aktif olur.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.1),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ODAK MODUNİ SEÇ",
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Ders çalışma yöntemine uygun modu seç. Başladığın işi yarım bırakma Şampiyon!",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String badge,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.15), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
