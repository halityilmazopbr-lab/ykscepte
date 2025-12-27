/// 🕵️ NET-X Dedektifi - Sorgu Odası
/// Hata etiketleme ekranı

import 'package:flutter/material.dart';
import 'detective_models.dart';
import 'detective_service.dart';
import 'detective_report_screen.dart';

class DetectiveInterrogationScreen extends StatefulWidget {
  final String ogrenciId;
  final YayinModel yayin;
  final Map<int, String?> ogrenciCevaplari;

  const DetectiveInterrogationScreen({
    super.key,
    required this.ogrenciId,
    required this.yayin,
    required this.ogrenciCevaplari,
  });

  @override
  State<DetectiveInterrogationScreen> createState() => _DetectiveInterrogationScreenState();
}

class _DetectiveInterrogationScreenState extends State<DetectiveInterrogationScreen> {
  final DetectiveService _service = DetectiveService();
  
  late List<SorguKaydi> _hatalaSorular;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _hazirla();
  }

  void _hazirla() {
    // Cevapları karşılaştır ve hatalıları al
    _hatalaSorular = _service.karsilastir(
      dogruCevaplar: widget.yayin.cevapAnahtari,
      ogrenciCevaplari: widget.ogrenciCevaplari,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: _hatalaSorular.isEmpty
              ? _buildTebrikEkrani()
              : _buildSorguEkrani(),
        ),
      ),
    );
  }

  Widget _buildTebrikEkrani() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            const Text(
              'TEBRİKLER!',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hiç yanlışın yok! ${widget.yayin.soruSayisi} sorunun hepsini doğru yaptın.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              icon: const Icon(Icons.home),
              label: const Text('Ana Sayfaya Dön'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSorguEkrani() {
    final mevcutSoru = _hatalaSorular[_currentIndex];
    final ilerleme = (_currentIndex + 1) / _hatalaSorular.length;

    return Column(
      children: [
        // Header
        _buildHeader(),
        
        // İlerleme
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sorgu ${_currentIndex + 1} / ${_hatalaSorular.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    '${(ilerleme * 100).toInt()}%',
                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ilerleme,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
            ],
          ),
        ),

        // Soru kartı
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildSoruKarti(mevcutSoru),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            onPressed: () => _cikisOnay(),
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  '🔍 SORGU ODASI',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '"Savaşçı, neden hata yaptın?"',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSoruKarti(SorguKaydi soru) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          // Soru numarası ve durum
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Soru ${soru.soruNo}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Cevap karşılaştırma
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCevapKutusu(
                'Doğru',
                soru.dogruCevap,
                Colors.green,
              ),
              const SizedBox(width: 24),
              const Icon(Icons.close, color: Colors.red, size: 32),
              const SizedBox(width: 24),
              _buildCevapKutusu(
                'Sen',
                soru.ogrenciCevabi ?? 'BOŞ',
                soru.bosmu ? Colors.grey : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Sorgu sorusu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              soru.bosmu
                  ? '"Savaşçı, bu soruyu neden boş bıraktın?"'
                  : '"Savaşçı, bu soruyu neden kaçırdın?"',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),

          // Etiket butonları (2x2 grid)
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            physics: const NeverScrollableScrollPhysics(),
            children: HataTuru.values.map((tur) => _buildEtiketButonu(tur)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCevapKutusu(String baslik, String cevap, Color renk) {
    return Column(
      children: [
        Text(
          baslik,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: renk.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: renk, width: 2),
          ),
          child: Center(
            child: Text(
              cevap,
              style: TextStyle(
                color: renk,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEtiketButonu(HataTuru tur) {
    final secili = _hatalaSorular[_currentIndex].hataTuru == tur;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _secHataTuru(tur),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: secili
                ? Color(int.parse(tur.renk.replaceFirst('#', '0xFF')))
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(int.parse(tur.renk.replaceFirst('#', '0xFF'))),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${tur.emoji} ${tur.baslik}',
                style: TextStyle(
                  color: secili ? Colors.white : Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
                Text(
                  tur.aciklama,
                  style: TextStyle(
                    color: secili ? Colors.white70 : Colors.white54,
                    fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _secHataTuru(HataTuru tur) {
    setState(() {
      _hatalaSorular[_currentIndex].hataTuru = tur;
    });

    // Kısa gecikme sonra sonraki soruya geç
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentIndex < _hatalaSorular.length - 1) {
        setState(() => _currentIndex++);
      } else {
        // Tüm sorular etiketlendi, rapora git
        _raporaGit();
      }
    });
  }

  void _raporaGit() {
    // Detaylı sonuç hesapla
    final detay = _service.getDetayliSonuc(
      dogruCevaplar: widget.yayin.cevapAnahtari,
      ogrenciCevaplari: widget.ogrenciCevaplari,
    );

    // Rapor oluştur
    final rapor = _service.olusturRapor(
      ogrenciId: widget.ogrenciId,
      yayinId: widget.yayin.id,
      yayinAdi: widget.yayin.ad,
      sorguKayitlari: _hatalaSorular,
      toplamSoru: detay['toplam'],
      dogru: detay['dogru'],
      yanlis: detay['yanlis'],
      bos: detay['bos'],
      mevcutNet: detay['net'],
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DetectiveReportScreen(rapor: rapor),
      ),
    );
  }

  void _cikisOnay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Çıkış', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Etiketleme işlemi yarıda kalacak. Çıkmak istediğine emin misin?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Çık', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
