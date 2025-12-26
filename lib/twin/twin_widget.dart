import 'package:flutter/material.dart';
import 'twin_models.dart';
import 'twin_service.dart';
import 'twin_screen.dart';

/// 🎭 Twin Widget - Ana Sayfada Gösterilecek Kompakt Kart
/// Tıklanınca TwinScreen açılır
class TwinDailyWidget extends StatefulWidget {
  final String odgrenciId;
  final String alan;
  final String hedefBolum;

  const TwinDailyWidget({
    super.key,
    required this.odgrenciId,
    required this.alan,
    required this.hedefBolum,
  });

  @override
  State<TwinDailyWidget> createState() => _TwinDailyWidgetState();
}

class _TwinDailyWidgetState extends State<TwinDailyWidget> {
  final TwinService _twinService = TwinService();
  ExamTwin? _ikiz;
  bool _yukliyor = true;

  @override
  void initState() {
    super.initState();
    _yukleIkiz();
  }

  Future<void> _yukleIkiz() async {
    try {
      var ikiz = await _twinService.getAktifIkiz(widget.odgrenciId);
      ikiz ??= _twinService.getDemoIkiz(widget.odgrenciId);
      
      if (mounted) {
        setState(() {
          _ikiz = ikiz;
          _yukliyor = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _ikiz = _twinService.getDemoIkiz(widget.odgrenciId);
          _yukliyor = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_yukliyor) {
      return _buildLoadingCard();
    }

    final ikiz = _ikiz!;
    final benOndeyim = ikiz.benimGunlukSoru > ikiz.ikizGunlukSoru;
    
    return GestureDetector(
      onTap: () => _navigateToTwinScreen(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a1a2e),
              benOndeyim 
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.cyan.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.cyan.withOpacity(0.3),
                    Colors.purple.withOpacity(0.2),
                  ],
                ),
                border: Border.all(color: Colors.cyan.withOpacity(0.5), width: 2),
              ),
              child: Center(
                child: Text(ikiz.ikizEmoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            
            // Bilgiler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        ikiz.ikizKodAdi,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Canlı indikatör
                      if (ikiz.sonAktivite != null &&
                          DateTime.now().difference(ikiz.sonAktivite!).inMinutes < 30)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bugün: Sen ${ikiz.benimGunlukSoru} • İkiz ${ikiz.ikizGunlukSoru} soru',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Durum İkonu ve Ok
            Column(
              children: [
                Text(
                  benOndeyim ? '🏆' : '📈',
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  void _navigateToTwinScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TwinScreen(
          odgrenciId: widget.odgrenciId,
          alan: widget.alan,
          hedefBolum: widget.hedefBolum,
        ),
      ),
    );
  }
}

/// 🔔 İkiz Bildirim Widget'ı
/// İkiz aktif olduğunda gösterilecek küçük bildirim
class TwinActivityNotification extends StatelessWidget {
  final ExamTwin ikiz;
  final VoidCallback? onTap;

  const TwinActivityNotification({
    super.key,
    required this.ikiz,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.withOpacity(0.9),
              Colors.deepOrange.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ikiz.ikizEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ikiz.ikizKodAdi} çalışmaya başladı!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Text(
                    'Sen hala burada mısın? 🔥',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
