import 'package:flutter/material.dart';
import 'twin_models.dart';
import 'twin_service.dart';
import 'twin_personas.dart';
import '../diamond/diamond_service.dart';

/// 🎭 Sınav İkizi Ana Ekranı
/// İkiz kartı, günlük düello, haftalık skor ve reaksiyonları gösterir
class TwinScreen extends StatefulWidget {
  final String odgrenciId;
  final String alan;
  final String hedefBolum;

  const TwinScreen({
    super.key,
    required this.odgrenciId,
    required this.alan,
    required this.hedefBolum,
  });

  @override
  State<TwinScreen> createState() => _TwinScreenState();
}

class _TwinScreenState extends State<TwinScreen> with SingleTickerProviderStateMixin {
  final TwinService _twinService = TwinService();
  ExamTwin? _aktifIkiz;
  DailyBet? _gunlukDuello;
  bool _yukliyor = true;
  String? _hata;
  
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    
    _yukleVeriler();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _yukleVeriler() async {
    setState(() => _yukliyor = true);
    
    try {
      // Profili al veya oluştur
      await _twinService.getOrCreateProfile(
        widget.odgrenciId,
        alan: widget.alan,
        hedefBolum: widget.hedefBolum,
      );
      
      // Aktif ikizi al
      var ikiz = await _twinService.getAktifIkiz(widget.odgrenciId);
      
      // İkiz yoksa eşleştir
      if (ikiz == null) {
        ikiz = await _twinService.bulVeEslestirIkiz(widget.odgrenciId);
      }
      
      // Hala yoksa demo ikiz göster
      ikiz ??= _twinService.getDemoIkiz(widget.odgrenciId);
      
      // Günlük düelloyu al
      DailyBet? duello;
      if (ikiz.id != 'demo_twin') {
        duello = await _twinService.getOrCreateGunlukDuello(ikiz.id);
      }
      
      setState(() {
        _aktifIkiz = ikiz;
        _gunlukDuello = duello;
        _yukliyor = false;
      });
    } catch (e) {
      setState(() {
        _hata = e.toString();
        _yukliyor = false;
        // Demo moduna geç
        _aktifIkiz = _twinService.getDemoIkiz(widget.odgrenciId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Text('🎭', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'Sınav İkizin',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _yukleVeriler,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _gosterBilgiDialog,
          ),
        ],
      ),
      body: _yukliyor
          ? const Center(child: CircularProgressIndicator())
          : _hata != null && _aktifIkiz == null
              ? _buildHataWidget()
              : _buildContent(),
    );
  }

  Widget _buildHataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Hata: $_hata', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _yukleVeriler,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _yukleVeriler,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Motivasyon Sloganı
            _buildSloganCard(),
            const SizedBox(height: 20),
            
            // İkiz Kartı
            _buildIkizKarti(),
            const SizedBox(height: 20),
            
            // Günlük Düello
            _buildGunlukDuello(),
            const SizedBox(height: 20),
            
            // Haftalık Skor
            _buildHaftalikSkor(),
            const SizedBox(height: 20),
            
            // Reaksiyon Gönder
            _buildReaksiyonlar(),
            const SizedBox(height: 20),
            
            // Son Aktivite
            if (_aktifIkiz?.sonAktivite != null)
              _buildSonAktivite(),
          ],
        ),
      ),
    );
  }

  Widget _buildSloganCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.blue.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.5)),
      ),
      child: const Column(
        children: [
          Text(
            '✨ Yalnız Değilsin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Seninle aynı hayali kuran, seninle aynı seviyede biri şu an çalışıyor.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIkizKarti() {
    final ikiz = _aktifIkiz!;
    final seviye = TwinPersonas.hesaplaSeviye(ikiz.ikizSeviye * 50);
    final unvan = TwinPersonas.seviyeUnvani(seviye);
    
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.cyan.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar ve İsim
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.cyan.withOpacity(0.3),
                        Colors.purple.withOpacity(0.3),
                      ],
                    ),
                    border: Border.all(color: Colors.cyan, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      ikiz.ikizEmoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ikiz.ikizKodAdi,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.cyan.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Seviye ${ikiz.ikizSeviye}',
                              style: const TextStyle(
                                color: Colors.cyan,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• $unvan',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Canlı İndikatör
                if (ikiz.sonAktivite != null &&
                    DateTime.now().difference(ikiz.sonAktivite!).inMinutes < 30)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.circle,
                      color: Colors.green,
                      size: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Alan ve Hedef
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoChip('📚', widget.alan),
                  Container(width: 1, height: 30, color: Colors.white24),
                  _buildInfoChip('🎯', widget.hedefBolum),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildGunlukDuello() {
    final ikiz = _aktifIkiz!;
    final benimSoru = _gunlukDuello?.odgrenci1SoruSayisi ?? ikiz.benimGunlukSoru;
    final ikizSoru = _gunlukDuello?.odgrenci2SoruSayisi ?? ikiz.ikizGunlukSoru;
    final maxSoru = (benimSoru > ikizSoru ? benimSoru : ikizSoru).clamp(1, 500);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚔️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                'Bugünkü Düello',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text('💎', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 4),
                    Text(
                      '20',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Benim Progress
          _buildProgressBar(
            label: 'Sen',
            value: benimSoru,
            maxValue: maxSoru,
            color: Colors.green,
            isLeading: benimSoru > ikizSoru,
          ),
          const SizedBox(height: 12),
          
          // İkizin Progress
          _buildProgressBar(
            label: ikiz.ikizKodAdi.split(' ').first,
            value: ikizSoru,
            maxValue: maxSoru,
            color: Colors.red,
            isLeading: ikizSoru > benimSoru,
          ),
          
          const SizedBox(height: 12),
          Center(
            child: Text(
              benimSoru > ikizSoru
                  ? '🏆 Öndesin! Devam et!'
                  : benimSoru < ikizSoru
                      ? '📈 İkizin önde! Yakala onu!'
                      : '⚖️ Beraberesiniz!',
              style: TextStyle(
                color: benimSoru >= ikizSoru ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required int value,
    required int maxValue,
    required Color color,
    required bool isLeading,
  }) {
    final progress = (value / maxValue).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Text(
                  '$value soru',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLeading) ...[
                  const SizedBox(width: 4),
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 12,
              width: MediaQuery.of(context).size.width * 0.85 * progress,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHaftalikSkor() {
    final ikiz = _aktifIkiz!;
    final benimSkor = ikiz.benimHaftalikSkor;
    final ikizSkor = ikiz.ikizHaftalikSkor;
    final toplam = benimSkor + ikizSkor;
    final benimOran = toplam > 0 ? benimSkor / toplam : 0.5;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📊', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Haftalık Skor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sen: $benimSkor',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'İkiz: $ikizSkor',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Karşılaştırma çubuğu
          Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 20,
                width: MediaQuery.of(context).size.width * 0.85 * benimOran,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.teal],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Center(
            child: Text(
              ikiz.benOndeyim ? '🏆 Bu hafta öndesin!' : '💪 Biraz daha çalış!',
              style: TextStyle(
                color: ikiz.benOndeyim ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReaksiyonlar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💬', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Reaksiyon Gönder',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: TwinReactions.tumReaksiyonlar.map((r) {
              return _buildReaksiyonButon(r['emoji']!, r['ad']!);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReaksiyonButon(String emoji, String ad) {
    return InkWell(
      onTap: () => _gonderReaksiyon(emoji),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              ad,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSonAktivite() {
    final ikiz = _aktifIkiz!;
    final aktivite = ikiz.sonAktivite!;
    final fark = DateTime.now().difference(aktivite);
    
    String zamanStr;
    if (fark.inMinutes < 1) {
      zamanStr = 'Şu an aktif 🟢';
    } else if (fark.inMinutes < 60) {
      zamanStr = '${fark.inMinutes} dk önce';
    } else if (fark.inHours < 24) {
      zamanStr = '${fark.inHours} saat önce';
    } else {
      zamanStr = '${fark.inDays} gün önce';
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            fark.inMinutes < 30 ? Icons.local_fire_department : Icons.access_time,
            color: fark.inMinutes < 30 ? Colors.orange : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            'İkizin son aktivite: $zamanStr',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _gonderReaksiyon(String emoji) async {
    if (_aktifIkiz == null) return;
    
    await _twinService.gonderReaksiyon(
      widget.odgrenciId,
      _aktifIkiz!.ikizId,
      emoji,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$emoji gönderildi!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _gosterBilgiDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('🎭', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Sınav İkizi Nedir?', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• Seninle aynı alan ve hedefe sahip biriyle eşleşirsin\n'
              '• İkizinin gerçek adını göremezsin (anonim)\n'
              '• Her gün kim daha çok soru çözerse 💎20 Elmas kazanır\n'
              '• Emoji reaksiyonlarla motivasyon gönderebilirsin\n'
              '• İkizini 3 gün üst üste geçersen lig atlarsın! 🚀',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }
}
