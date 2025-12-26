/// 🕵️ NET-X Dedektifi - Tarama ve Doğrulama Ekranı
/// Optik form tarama ve AI okuma onayı

import 'package:flutter/material.dart';
import 'detective_models.dart';
import 'detective_vision_service.dart';
import 'virtual_optical_screen.dart';

class DetectiveScanScreen extends StatefulWidget {
  final String ogrenciId;
  final YayinModel yayin;

  const DetectiveScanScreen({
    super.key,
    required this.ogrenciId,
    required this.yayin,
  });

  @override
  State<DetectiveScanScreen> createState() => _DetectiveScanScreenState();
}

class _DetectiveScanScreenState extends State<DetectiveScanScreen> {
  final DetectiveVisionService _visionService = DetectiveVisionService();
  
  TaramaSonucu? _taramaSonucu;
  bool _taramaDurumu = false; // false = taranmadı, true = tarandı
  bool _yukleniyor = false;

  // Düzenleme için
  Map<int, String?> _duzenlenmisVeri = {};

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
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _taramaDurumu
                    ? _buildDogrulamaEkrani()
                    : _buildTaramaEkrani(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.yayin.ad,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.yayin.soruSayisi} soru • ${widget.yayin.kategori}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTaramaEkrani() {
    // AI işlemi devam ediyorsa özel loading göster
    if (_yukleniyor) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated scanning icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 2 * 3.14159),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) => Transform.rotate(
                angle: value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.cyan, width: 2),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    size: 60,
                    color: Colors.cyan,
                  ),
                ),
              ),
              onEnd: () => setState(() {}), // Animasyonu tekrarla
            ),
            const SizedBox(height: 32),
            const Text(
              '🤖 YAPAY ZEKA TARAMADA...',
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Görüntü işleniyor, lütfen bekle.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white10,
                color: Colors.cyan,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // İkon ve açıklama
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              size: 80,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            '📸 KAĞIDINI TARA',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Text(
            'Optik formunu veya kitapçığın üzerine işaretlediğin cevapları fotoğrafla.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // İpuçları
          _buildIpucu('📍', 'Kağıdı düz tutun, buruşuk olmasın'),
          _buildIpucu('💡', 'Yeterli ışık altında çekin'),
          _buildIpucu('🎯', 'Tüm cevapları kadrajda tutun'),
          
          const SizedBox(height: 40),
          
          // Butonlar
          Row(
            children: [
              Expanded(
                child: _buildTaramaButonu(
                  icon: Icons.camera_alt,
                  baslik: 'Kamera',
                  onTap: _kameraIleTara,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTaramaButonu(
                  icon: Icons.photo_library,
                  baslik: 'Galeri',
                  onTap: _galeridenTara,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Manuel giriş
          TextButton.icon(
            onPressed: _manuelGiris,
            icon: const Icon(Icons.edit, color: Colors.white54),
            label: const Text(
              'Manuel Giriş Yap',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIpucu(String emoji, String metin) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              metin,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaramaButonu({
    required IconData icon,
    required String baslik,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: _yukleniyor ? null : onTap,
      icon: _yukleniyor
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Icon(icon),
      label: Text(baslik),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDogrulamaEkrani() {
    return Column(
      children: [
        // Başarı mesajı
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✅ AI kağıdını okudu!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${_duzenlenmisVeri.length} soru tespit edildi. Kontrol et ve onayla.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Cevaplar grid
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                widget.yayin.soruSayisi,
                (index) => _buildCevapKutusu(index + 1),
              ),
            ),
          ),
        ),
        
        // Alt butonlar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _taramaDurumu = false;
                    _taramaSonucu = null;
                    _duzenlenmisVeri = {};
                  }),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Tara'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _onayla,
                  icon: const Icon(Icons.check),
                  label: const Text('ONAYLA VE DEVAM'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCevapKutusu(int soruNo) {
    final cevap = _duzenlenmisVeri[soruNo];
    final bosmu = cevap == null;

    return GestureDetector(
      onTap: () => _duzenleDialog(soruNo),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: bosmu
              ? Colors.grey.withValues(alpha: 0.3)
              : Colors.blue.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: bosmu ? Colors.grey : Colors.blue,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$soruNo',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
            Text(
              cevap ?? '-',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _duzenleDialog(int soruNo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Soru $soruNo',
          style: const TextStyle(color: Colors.white),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['A', 'B', 'C', 'D', 'E', '-'].map((sik) {
            final secili = _duzenlenmisVeri[soruNo] == (sik == '-' ? null : sik);
            return GestureDetector(
              onTap: () {
                setState(() {
                  _duzenlenmisVeri[soruNo] = sik == '-' ? null : sik;
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: secili
                      ? Colors.amber
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber, width: secili ? 2 : 1),
                ),
                child: Center(
                  child: Text(
                    sik,
                    style: TextStyle(
                      color: secili ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _kameraIleTara() async {
    await _tara(_visionService.fotografCek);
  }

  Future<void> _galeridenTara() async {
    await _tara(_visionService.galeridenSec);
  }

  Future<void> _tara(Future<dynamic> Function() fotografAl) async {
    setState(() => _yukleniyor = true);

    try {
      final image = await fotografAl();
      if (image == null) {
        setState(() => _yukleniyor = false);
        return;
      }

      // AI ile tara
      final sonuc = await _visionService.taraOptikForm(image, widget.ogrenciId);
      
      if (sonuc == null || sonuc.ogrenciCevaplari.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cevaplar okunamadı. Tekrar deneyin.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _yukleniyor = false);
        return;
      }

      setState(() {
        _taramaSonucu = sonuc;
        _duzenlenmisVeri = Map.from(sonuc.ogrenciCevaplari);
        _taramaDurumu = true;
        _yukleniyor = false;
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => _yukleniyor = false);
    }
  }

  void _manuelGiris() {
    setState(() {
      // Tüm soruları boş olarak başlat
      _duzenlenmisVeri = {};
      for (int i = 1; i <= widget.yayin.soruSayisi; i++) {
        _duzenlenmisVeri[i] = null;
      }
      _taramaDurumu = true;
    });
  }

  void _onayla() {
    // Sanal Optik ekranına git (AI verisini görselleştir)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VirtualOpticalScreen(
          ogrenciId: widget.ogrenciId,
          yayin: widget.yayin,
          taramaSonucu: _duzenlenmisVeri,
        ),
      ),
    );
  }
}
