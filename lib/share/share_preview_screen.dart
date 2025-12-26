/// 📱 NETX Share Modülü - Paylaşım Önizleme Ekranı
/// Screenshot al ve Instagram/WhatsApp'a paylaş

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'story_card.dart';

class SharePreviewScreen extends StatefulWidget {
  final String userName;
  final String schoolName;
  final String scoreType;
  final String scoreValue;
  final String? quote;
  final Color accentColor;

  const SharePreviewScreen({
    super.key,
    required this.userName,
    required this.schoolName,
    required this.scoreType,
    required this.scoreValue,
    this.quote,
    this.accentColor = Colors.cyanAccent,
  });

  /// Kahin sonucu için
  static SharePreviewScreen forOracle({
    required String userName,
    required String schoolName,
    required double tytNet,
    required int predictedRank,
  }) {
    final formattedRank = predictedRank >= 1000 
        ? '${(predictedRank / 1000).toStringAsFixed(0)}K'
        : predictedRank.toString();
    
    return SharePreviewScreen(
      userName: userName,
      schoolName: schoolName,
      scoreType: "TAHMİNİ SIRALAMA",
      scoreValue: formattedRank,
      quote: "Hedefime kilitlendim. 🎯",
      accentColor: Colors.purpleAccent,
    );
  }

  /// Net rekoru için
  static SharePreviewScreen forNetRecord({
    required String userName,
    required String schoolName,
    required double net,
  }) {
    return SharePreviewScreen(
      userName: userName,
      schoolName: schoolName,
      scoreType: "TYT NET REKORIM",
      scoreValue: net.toStringAsFixed(1),
      quote: "Kendi rekorumu kırdım! 💪",
      accentColor: Colors.cyanAccent,
    );
  }

  /// Lig yükselme için
  static SharePreviewScreen forLeaguePromotion({
    required String userName,
    required String schoolName,
    required String leagueName,
    required int rank,
  }) {
    return SharePreviewScreen(
      userName: userName,
      schoolName: schoolName,
      scoreType: "$leagueName'E YÜKSELDİM!",
      scoreValue: "#$rank",
      quote: "Zirveye koşuyorum! 🏆",
      accentColor: Colors.greenAccent,
    );
  }

  @override
  State<SharePreviewScreen> createState() => _SharePreviewScreenState();
}

class _SharePreviewScreenState extends State<SharePreviewScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;
  String? _errorMessage;

  Future<void> _shareStory() async {
    setState(() {
      _isSharing = true;
      _errorMessage = null;
    });

    try {
      // Widget'ın fotoğrafını çek (HD kalite için pixelRatio: 3.0)
      final Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0,
        delay: const Duration(milliseconds: 100),
      );

      if (imageBytes == null) {
        throw Exception('Görsel oluşturulamadı');
      }

      if (kIsWeb) {
        // Web için: download link oluştur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Web\'de paylaşım mobil cihazlarda çalışır'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Mobile için: geçici dosya oluştur ve paylaş
        final directory = await getTemporaryDirectory();
        final imagePath = File('${directory.path}/netx_story_${DateTime.now().millisecondsSinceEpoch}.png');
        await imagePath.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: "NET-X ile hedeflerime kilitlendim! 🔥🎯 #yks2025 #netx #yksçalışma",
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "BAŞARINI KUTLA",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const Spacer(),

          // ═══════════════════════════════════════════════════
          // ÖNİZLEME KARTI
          // ═══════════════════════════════════════════════════
          Center(
            child: Screenshot(
              controller: _screenshotController,
              child: StoryCard(
                userName: widget.userName,
                schoolName: widget.schoolName,
                scoreType: widget.scoreType,
                scoreValue: widget.scoreValue,
                quote: widget.quote ?? "Rekabeti seviyorum. 🔥",
                accentColor: widget.accentColor,
              ),
            ),
          ),

          const Spacer(),

          // ═══════════════════════════════════════════════════
          // ALT BUTONLAR
          // ═══════════════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Paylaş butonu
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor: widget.accentColor.withValues(alpha: 0.5),
                    ),
                    onPressed: _isSharing ? null : _shareStory,
                    icon: _isSharing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.share, size: 22),
                    label: Text(
                      _isSharing ? "HAZIRLANIYOR..." : "STORY PAYLAŞ",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Bilgi metni
                Text(
                  "Instagram, WhatsApp, Twitter veya Kaydet",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
