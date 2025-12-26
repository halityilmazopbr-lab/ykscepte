/// 📱 NETX Share Modülü - Story Kartı
/// Spotify Wrapped tarzında Instagram-ready dikey kart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StoryCard extends StatelessWidget {
  final String userName;
  final String schoolName;
  final String scoreType;    // "TYT NET", "SIRALAMA", "LİG"
  final String scoreValue;   // "85.5", "12.400", "SÜPER LİG"
  final String quote;
  final Color accentColor;

  const StoryCard({
    super.key,
    required this.userName,
    required this.schoolName,
    required this.scoreType,
    required this.scoreValue,
    this.quote = "Rekabeti seviyorum. 🔥",
    this.accentColor = Colors.cyanAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 622, // 9:16 Instagram Story oranı
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E0249), Color(0xFF0F172A), Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 2),
      ),
      child: Stack(
        children: [
          // ═══════════════════════════════════════════════════
          // ARKA PLAN DESENİ
          // ═══════════════════════════════════════════════════
          Positioned(
            top: -50,
            right: -50,
            child: Icon(
              Icons.bolt,
              size: 300,
              color: accentColor.withValues(alpha: 0.05),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Icon(
              Icons.auto_awesome,
              size: 150,
              color: Colors.purpleAccent.withValues(alpha: 0.05),
            ),
          ),

          // ═══════════════════════════════════════════════════
          // İÇERİK
          // ═══════════════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- ÜST KISIM ---
                _buildHeader(),

                // --- ORTA: BÜYÜK SKOR ---
                _buildScore(),

                // --- ALT: MOTİVASYON & QR ---
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 20),
        
        // Başlık
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "NET-X PERFORMANS RAPORU",
            style: TextStyle(
              color: Colors.grey,
              letterSpacing: 2,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Okul
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, color: Colors.orangeAccent, size: 18),
            const SizedBox(width: 8),
            Text(
              schoolName.toUpperCase(),
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 6),
        
        // Kullanıcı adı
        Text(
          userName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildScore() {
    return Column(
      children: [
        // Skor tipi
        Text(
          scoreType,
          style: TextStyle(
            color: accentColor,
            fontSize: 14,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Büyük skor
        Text(
          scoreValue,
          style: TextStyle(
            color: Colors.white,
            fontSize: 72,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            shadows: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
        
        // Alt çizgi dekorasyon
        Container(
          width: 100,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, accentColor, Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Motivasyon sözü
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '"$quote"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
              fontSize: 15,
            ),
          ),
        ),
        
        const SizedBox(height: 25),

        // QR + Branding
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // QR Kod
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: QrImageView(
                  data: 'https://netxapp.com/indir',
                  version: QrVersions.auto,
                  size: 55,
                  backgroundColor: Colors.white,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Branding
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "NET",
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                      const Text(
                        "-X",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "Dijital Sınav Koçu",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Sen de aramıza katıl! 🚀",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 15),
      ],
    );
  }
}

/// Farklı senaryolar için preset kartlar
class StoryCardPresets {
  /// Kahin sonucu için
  static StoryCard oracle({
    required String userName,
    required String schoolName,
    required double tytNet,
    required int predictedRank,
  }) {
    return StoryCard(
      userName: userName,
      schoolName: schoolName,
      scoreType: "TAHMİNİ SIRALAMA",
      scoreValue: _formatRank(predictedRank),
      quote: "Hedefime kilitlendim. 🎯",
      accentColor: Colors.purpleAccent,
    );
  }

  /// Lig yükselme için
  static StoryCard leaguePromotion({
    required String userName,
    required String schoolName,
    required String leagueName,
    required int rank,
  }) {
    return StoryCard(
      userName: userName,
      schoolName: schoolName,
      scoreType: "$leagueName'E YÜKSELDİM!",
      scoreValue:"#$rank",
      quote: "Zirveye koşuyorum! 🏆",
      accentColor: Colors.greenAccent,
    );
  }

  /// TYT net rekoru için
  static StoryCard netRecord({
    required String userName,
    required String schoolName,
    required double net,
  }) {
    return StoryCard(
      userName: userName,
      schoolName: schoolName,
      scoreType: "TYT NET REKORIM",
      scoreValue: net.toStringAsFixed(1),
      quote: "Kendi rekorumu kırdım! 💪",
      accentColor: Colors.cyanAccent,
    );
  }

  /// Okul ligi için
  static StoryCard schoolLeague({
    required String schoolName,
    required int rank,
    required int totalXp,
  }) {
    return StoryCard(
      userName: schoolName,
      schoolName: "OKUL SAVAŞLARI",
      scoreType: "LİG SIRASI",
      scoreValue: "#$rank",
      quote: "${_formatXp(totalXp)} toplam XP! 🔥",
      accentColor: Colors.orangeAccent,
    );
  }

  static String _formatRank(int rank) {
    if (rank >= 1000) {
      return '${(rank / 1000).toStringAsFixed(0)}K';
    }
    return rank.toString();
  }

  static String _formatXp(int xp) {
    if (xp >= 1000000) {
      return '${(xp / 1000000).toStringAsFixed(1)}M';
    } else if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(0)}K';
    }
    return xp.toString();
  }
}
