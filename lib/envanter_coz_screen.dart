import 'package:flutter/material.dart';
import 'envanter_models.dart';
import 'envanter_verileri.dart';
import 'envanter_sonuc_screen.dart';

/// Envanter Çözme Ekranı
/// Soruları tek tek gösterir ve cevapları toplar
class EnvanterCozEkrani extends StatefulWidget {
  final Envanter envanter;
  
  const EnvanterCozEkrani({super.key, required this.envanter});

  @override
  State<EnvanterCozEkrani> createState() => _EnvanterCozEkraniState();
}

class _EnvanterCozEkraniState extends State<EnvanterCozEkrani> {
  late PageController _pageController;
  int _currentIndex = 0;
  Map<int, int> _cevaplar = {}; // soruNo -> puan

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _cevapVer(int soruNo, int puan) {
    setState(() {
      _cevaplar[soruNo] = puan;
    });
    
    // Kısa gecikme sonrası sonraki soruya geç
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentIndex < widget.envanter.sorular.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Son soru, sonuç ekranına git
        _sonucaGit();
      }
    });
  }

  void _sonucaGit() {
    // Skorları hesapla
    Map<String, int> skorlar = {};
    for (var kategori in widget.envanter.kategoriler) {
      skorlar[kategori] = 0;
    }
    
    for (var soru in widget.envanter.sorular) {
      if (_cevaplar.containsKey(soru.soruNo)) {
        skorlar[soru.kategori] = (skorlar[soru.kategori] ?? 0) + _cevaplar[soru.soruNo]!;
      }
    }
    
    int toplamSkor = skorlar.values.fold(0, (a, b) => a + b);
    
    // AI yorumu al
    String aiYorum = _aiYorumAl(skorlar, toplamSkor);
    
    // Seviye belirle
    String seviye = _seviyeBelirle(toplamSkor);
    
    // Sonuç ekranına git
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (c) => EnvanterSonucEkrani(
          envanter: widget.envanter,
          skorlar: skorlar,
          toplamSkor: toplamSkor,
          seviye: seviye,
          aiYorum: aiYorum,
        ),
      ),
    );
  }

  String _aiYorumAl(Map<String, int> skorlar, int toplamSkor) {
    switch (widget.envanter.id) {
      case 'holland':
        return EnvanterVerileri.hollandYorumu(skorlar);
      case 'sinav_kaygisi':
        return EnvanterVerileri.kaygiYorumu(toplamSkor);
      case 'basarisizlik':
        return EnvanterVerileri.basarisizlikYorumu(skorlar);
      case 'vark':
        return EnvanterVerileri.varkYorumu(skorlar);
      case 'calisma_davranislari':
        return EnvanterVerileri.calismaDavranislariYorumu(skorlar);
      case 'akademik_benlik':
        return EnvanterVerileri.akademikBenlikYorumu(toplamSkor);
      case 'grit':
        return EnvanterVerileri.gritYorumu(toplamSkor);
      case 'coklu_zeka':
        return EnvanterVerileri.cokluZekaYorumu(skorlar);
      default:
        return 'Sonuçlar hesaplandı.';
    }
  }

  String _seviyeBelirle(int toplamSkor) {
    // Her test için farklı mantık
    switch (widget.envanter.id) {
      case 'sinav_kaygisi':
        if (toplamSkor <= 40) return 'Düşük';
        if (toplamSkor <= 60) return 'Orta-Düşük';
        if (toplamSkor <= 75) return 'Orta';
        if (toplamSkor <= 90) return 'Yüksek';
        return 'Çok Yüksek';
      case 'akademik_benlik':
        if (toplamSkor >= 60) return 'Yüksek';
        if (toplamSkor >= 45) return 'Orta';
        if (toplamSkor >= 30) return 'Orta-Düşük';
        return 'Düşük';
      case 'grit':
        if (toplamSkor >= 50) return 'Çok Yüksek';
        if (toplamSkor >= 40) return 'Yüksek';
        if (toplamSkor >= 30) return 'Orta';
        if (toplamSkor >= 20) return 'Düşük';
        return 'Çok Düşük';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorular = widget.envanter.sorular;
    final isLikert = sorular.isNotEmpty && sorular.first.secenekler != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.envanter.baslik),
        backgroundColor: widget.envanter.renk,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentIndex + 1}/${sorular.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // İlerleme çubuğu
          LinearProgressIndicator(
            value: (_currentIndex + 1) / sorular.length,
            backgroundColor: Colors.grey.shade300,
            color: widget.envanter.renk,
            minHeight: 6,
          ),
          
          // Sorular
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: sorular.length,
              itemBuilder: (context, index) {
                final soru = sorular[index];
                return _buildSoruKarti(soru, isLikert);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoruKarti(EnvanterSorusu soru, bool isLikert) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Soru numarası
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.envanter.renk.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Soru ${soru.soruNo}',
              style: TextStyle(
                color: widget.envanter.renk,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Soru metni
          Text(
            soru.metin,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Cevap butonları
          if (isLikert)
            _buildLikertSecenekler(soru)
          else
            _buildEvetHayirSecenekler(soru),
        ],
      ),
    );
  }

  Widget _buildEvetHayirSecenekler(EnvanterSorusu soru) {
    return Column(
      children: [
        _buildCevapButonu(
          onTap: () => _cevapVer(soru.soruNo, 2),
          text: 'Evet',
          color: Colors.green,
          icon: Icons.check_circle,
          isSelected: _cevaplar[soru.soruNo] == 2,
        ),
        const SizedBox(height: 12),
        _buildCevapButonu(
          onTap: () => _cevapVer(soru.soruNo, 1),
          text: 'Kararsızım',
          color: Colors.orange,
          icon: Icons.help,
          isSelected: _cevaplar[soru.soruNo] == 1,
        ),
        const SizedBox(height: 12),
        _buildCevapButonu(
          onTap: () => _cevapVer(soru.soruNo, 0),
          text: 'Hayır',
          color: Colors.red,
          icon: Icons.cancel,
          isSelected: _cevaplar[soru.soruNo] == 0,
        ),
      ],
    );
  }

  Widget _buildLikertSecenekler(EnvanterSorusu soru) {
    final secenekler = soru.secenekler!;
    return Column(
      children: List.generate(secenekler.length, (i) {
        final puan = i + 1; // 1-5 arası puan
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildCevapButonu(
            onTap: () => _cevapVer(soru.soruNo, puan),
            text: secenekler[i],
            color: _likertRenk(i),
            icon: null,
            isSelected: _cevaplar[soru.soruNo] == puan,
          ),
        );
      }),
    );
  }

  Color _likertRenk(int index) {
    switch (index) {
      case 0: return Colors.green;
      case 1: return Colors.lightGreen;
      case 2: return Colors.orange;
      case 3: return Colors.deepOrange;
      case 4: return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildCevapButonu({
    required VoidCallback onTap,
    required String text,
    required Color color,
    IconData? icon,
    required bool isSelected,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : Colors.white,
          foregroundColor: isSelected ? Colors.white : color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color, width: 2),
          ),
          elevation: isSelected ? 4 : 1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
