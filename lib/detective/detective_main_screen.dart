/// 🕵️ NET-X Dedektifi - Ana Ekran
/// Yayın seçimi ve tarama başlatma

import 'package:flutter/material.dart';
import 'detective_models.dart';
import 'detective_vision_service.dart';
import 'detective_scan_screen.dart';

class DetectiveMainScreen extends StatefulWidget {
  final String ogrenciId;

  const DetectiveMainScreen({super.key, required this.ogrenciId});

  @override
  State<DetectiveMainScreen> createState() => _DetectiveMainScreenState();
}

class _DetectiveMainScreenState extends State<DetectiveMainScreen> {
  final DetectiveVisionService _visionService = DetectiveVisionService();
  
  List<YayinModel> _yayinlar = [];
  bool _yukleniyor = true;
  int _kalanHak = 5;

  // Yeni yayın için
  final _yayinAdiController = TextEditingController();
  String _secilenKategori = 'TYT';

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => _yukleniyor = true);
    
    final yayinlar = await _visionService.getYayinlar();
    final kalanHak = await _visionService.getKalanTaramaHakki(widget.ogrenciId);
    
    setState(() {
      _yayinlar = yayinlar;
      _kalanHak = kalanHak;
      _yukleniyor = false;
    });
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
          child: Column(
            children: [
              _buildHeader(),
              _buildTaramaHakki(),
              Expanded(
                child: _yukleniyor
                    ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  '🕵️ NET-X DEDEKTİFİ',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '"Kağıdı göster, hatalarını söyleyeyim."',
                  style: TextStyle(
                    color: Colors.white70,
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

  Widget _buildTaramaHakki() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_scanner, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Text(
            'Bugünkü Tarama Hakkı: $_kalanHak / 5',
            style: TextStyle(
              color: _kalanHak > 0 ? Colors.white : Colors.red.shade300,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HIZLI BAŞLAT
          _buildHizliBaslat(),
          
          const SizedBox(height: 24),
          
          // MEVCUT YAYINLAR
          if (_yayinlar.isNotEmpty) ...[
            const Text(
              '📚 KAYITLI YAYINLAR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            ..._yayinlar.take(10).map((yayin) => _buildYayinKarti(yayin)),
          ],
        ],
      ),
    );
  }

  Widget _buildHizliBaslat() {
    return Column(
      children: [
        // YENİ YAYIN + CEVAP ANAHTARI TARA
        _buildAksiyonKarti(
          icon: Icons.add_photo_alternate,
          baslik: '📷 YENİ YAYIN EKLE',
          aciklama: 'Cevap anahtarını tarayarak yeni yayın ekle',
          renk: Colors.green,
          onTap: _yeniYayinEkle,
        ),
        
        const SizedBox(height: 12),
        
        // MEVCUT YAYINDAN DEVAM
        if (_yayinlar.isNotEmpty)
          _buildAksiyonKarti(
            icon: Icons.play_arrow,
            baslik: '▶️ HIZLI TARA',
            aciklama: 'Son kullandığın yayınla devam et',
            renk: Colors.amber,
            onTap: () => _baslatTarama(_yayinlar.first),
          ),
      ],
    );
  }

  Widget _buildAksiyonKarti({
    required IconData icon,
    required String baslik,
    required String aciklama,
    required Color renk,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _kalanHak > 0 ? onTap : () => _gosterLimitUyari(),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                renk.withValues(alpha: 0.3),
                renk.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: renk.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: renk.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: renk, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baslik,
                      style: TextStyle(
                        color: renk,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      aciklama,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: renk, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYayinKarti(YayinModel yayin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: Colors.white.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.menu_book, color: Colors.blue),
        ),
        title: Text(
          yayin.ad,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${yayin.kategori} • ${yayin.soruSayisi} soru',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: () => _baslatTarama(yayin),
      ),
    );
  }

  void _gosterLimitUyari() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Günlük tarama limitine ulaştın! Yarın tekrar dene.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _yeniYayinEkle() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                '📚 YENİ YAYIN EKLE',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Yayın adı
            TextField(
              controller: _yayinAdiController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Yayın Adı',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                hintText: 'Örn: 3D TYT Deneme 5',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Kategori
            DropdownButtonFormField<String>(
              value: _secilenKategori,
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Kategori',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: ['TYT', 'AYT-Sayısal', 'AYT-Sözel', 'AYT-EA', 'LGS', 'Diğer']
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _secilenKategori = v!),
            ),
            const SizedBox(height: 24),
            
            // Tara butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_yayinAdiController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Yayın adı girin')),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  _taraCevapAnahtari();
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('CEVAP ANAHTARINI TARA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _taraCevapAnahtari() async {
    try {
      // Fotoğraf çek
      final image = await _visionService.fotografCek();
      if (image == null) return;

      // Loading göster
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.amber),
              SizedBox(height: 16),
              Text(
                '🤖 AI cevap anahtarını okuyor...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );

      // AI ile tara
      final cevaplar = await _visionService.taraCevapAnahtari(image, widget.ogrenciId);
      
      if (!mounted) return;
      Navigator.pop(context); // Loading kapat

      if (cevaplar == null || cevaplar.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cevap anahtarı okunamadı. Tekrar deneyin.')),
        );
        return;
      }

      // Yayını kaydet
      final yayin = await _visionService.kaydetYayin(
        ad: _yayinAdiController.text,
        kategori: _secilenKategori,
        cevapAnahtari: cevaplar,
        olusturanId: widget.ogrenciId,
      );

      // Başarı mesajı
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${yayin.ad} kaydedildi! (${yayin.soruSayisi} soru)'),
          backgroundColor: Colors.green,
        ),
      );

      // Temizle ve yenile
      _yayinAdiController.clear();
      _yukle();

      // Taramaya devam et
      _baslatTarama(yayin);

    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Loading kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _baslatTarama(YayinModel yayin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetectiveScanScreen(
          ogrenciId: widget.ogrenciId,
          yayin: yayin,
        ),
      ),
    ).then((_) => _yukle()); // Geri dönünce yenile
  }

  @override
  void dispose() {
    _yayinAdiController.dispose();
    super.dispose();
  }
}
