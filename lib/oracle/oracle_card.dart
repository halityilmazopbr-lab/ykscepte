/// 🔮 Kahin (Oracle) Modülü - Dashboard Kartı
/// Ana ekranda duran özet widget

import 'package:flutter/material.dart';
import 'oracle_service.dart';
import 'oracle_dialog.dart';
import '../share/share.dart';

class OracleCard extends StatelessWidget {
  final double currentTytNet;
  final int? targetRank;
  final Function(double)? onNetChanged;
  final String? userName;
  final String? schoolName;

  const OracleCard({
    super.key,
    required this.currentTytNet,
    this.targetRank,
    this.onNetChanged,
    this.userName,
    this.schoolName,
  });

  @override
  Widget build(BuildContext context) {
    final oracle = OracleService();
    final predictedRank = oracle.calculateTytRank(currentTytNet);
    final formattedRank = oracle.formatRank(predictedRank);
    final comment = oracle.getNetComment(currentTytNet);

    return GestureDetector(
      onTap: () async {
        final newNet = await showDialog<double>(
          context: context,
          builder: (context) => OracleDialog(
            initialTytNet: currentTytNet,
            targetRank: targetRank,
          ),
        );

        if (newNet != null && onNetChanged != null) {
          onNetChanged!(newNet);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E0249), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════
            // ÜST SATIR
            // ═══════════════════════════════════════════════════
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "KAHİN (ORACLE)",
                      style: TextStyle(
                        color: Colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "TYT: ${currentTytNet.toStringAsFixed(1)}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ═══════════════════════════════════════════════════
            // SIRALAMA TAHMİNİ
            // ═══════════════════════════════════════════════════
            const Text(
              "TAHMİNİ YKS SIRALAMASI",
              style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedRank,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    predictedRank > 1000 ? "sıra" : "",
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ═══════════════════════════════════════════════════
            // YORUM
            // ═══════════════════════════════════════════════════
            Text(
              comment,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 16),

            // ═══════════════════════════════════════════════════
            // ALT BİLGİ + PAYLAŞ BUTONU
            // ═══════════════════════════════════════════════════
            Row(
              children: [
                GestureDetector(
                  onTap: () => _openSimulation(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, color: Colors.purpleAccent, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "Simülasyon",
                          style: TextStyle(color: Colors.purpleAccent, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // PAYLAŞ BUTONU
                GestureDetector(
                  onTap: () => _shareStory(context, predictedRank),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ios_share, color: Colors.cyanAccent, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "Paylaş",
                          style: TextStyle(color: Colors.cyanAccent, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openSimulation(BuildContext context) async {
    final newNet = await showDialog<double>(
      context: context,
      builder: (context) => OracleDialog(
        initialTytNet: currentTytNet,
        targetRank: targetRank,
      ),
    );

    if (newNet != null && onNetChanged != null) {
      onNetChanged!(newNet);
    }
  }

  void _shareStory(BuildContext context, int predictedRank) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SharePreviewScreen.forOracle(
          userName: userName ?? "NET-X Kullanıcısı",
          schoolName: schoolName ?? "Türkiye",
          tytNet: currentTytNet,
          predictedRank: predictedRank,
        ),
      ),
    );
  }
}

