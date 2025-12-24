/// Kurumsal Sınav Ekranı
/// 
/// Özellikler:
/// - PDF Viewer (arka plan)
/// - Watermark (öğrenci adı)
/// - Sanal Optik Form (alt bar)
/// - Zamanlayıcı (Timer)
/// - Puanlama ve sonuç kaydetme

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'kurum_models.dart';
import 'kurum_service.dart';

class SinavEkrani extends StatefulWidget {
  final KurumDenemesi deneme;
  final String ogrenciId;
  final String ogrenciAdi;

  const SinavEkrani({
    super.key,
    required this.deneme,
    required this.ogrenciId,
    required this.ogrenciAdi,
  });

  @override
  State<SinavEkrani> createState() => _SinavEkraniState();
}

class _SinavEkraniState extends State<SinavEkrani> {
  // Cevaplar
  late List<String> _cevaplar;
  int _aktifSoru = 0;
  
  // Zamanlayıcı
  late int _kalanSaniye;
  Timer? _timer;
  bool _sinavBitti = false;

  // PDF Controller
  final PdfViewerController _pdfController = PdfViewerController();

  @override
  void initState() {
    super.initState();
    _cevaplar = List.filled(widget.deneme.soruSayisi, '');
    _kalanSaniye = widget.deneme.sureDk * 60;
    _baslat();
  }

  void _baslat() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_kalanSaniye > 0) {
        setState(() => _kalanSaniye--);
      } else {
        _sinaviBitir();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pdfController.dispose();
    super.dispose();
  }

  String get _formatliSure {
    int saat = _kalanSaniye ~/ 3600;
    int dakika = (_kalanSaniye % 3600) ~/ 60;
    int saniye = _kalanSaniye % 60;
    
    if (saat > 0) {
      return '$saat:${dakika.toString().padLeft(2, '0')}:${saniye.toString().padLeft(2, '0')}';
    }
    return '${dakika.toString().padLeft(2, '0')}:${saniye.toString().padLeft(2, '0')}';
  }

  void _cevapSec(String cevap) {
    setState(() {
      if (_cevaplar[_aktifSoru] == cevap) {
        // Aynı cevaba tekrar basıldı - iptal et
        _cevaplar[_aktifSoru] = '';
      } else {
        _cevaplar[_aktifSoru] = cevap;
      }
    });
  }

  void _oncekiSoru() {
    if (_aktifSoru > 0) {
      setState(() => _aktifSoru--);
    }
  }

  void _sonrakiSoru() {
    if (_aktifSoru < widget.deneme.soruSayisi - 1) {
      setState(() => _aktifSoru++);
    }
  }

  void _soruSecDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Soru Seç",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: widget.deneme.soruSayisi,
                itemBuilder: (context, index) {
                  bool cevaplandi = _cevaplar[index].isNotEmpty;
                  bool aktif = index == _aktifSoru;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() => _aktifSoru = index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: aktif 
                            ? Colors.blue 
                            : (cevaplandi ? Colors.green : Colors.grey.shade800),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sinaviBitirOnay() {
    int bos = _cevaplar.where((c) => c.isEmpty).length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF21262D),
        title: const Text("Sınavı Bitir", style: TextStyle(color: Colors.white)),
        content: Text(
          bos > 0 
              ? "$bos soru boş bırakıldı. Sınavı bitirmek istediğinize emin misiniz?"
              : "Sınavı bitirmek istediğinize emin misiniz?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sinaviBitir();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Bitir"),
          ),
        ],
      ),
    );
  }

  Future<void> _sinaviBitir() async {
    if (_sinavBitti) return;
    
    setState(() => _sinavBitti = true);
    _timer?.cancel();

    // Puanlama
    final sonuc = PuanlamaServisi.sinaviDegerlendir(
      ogrenciId: widget.ogrenciId,
      denemeId: widget.deneme.id,
      cevapAnahtari: widget.deneme.cevapAnahtari,
      ogrenciCevaplari: _cevaplar,
    );

    // Firebase'e kaydet
    await KurumService.sonucKaydet(sonuc);

    // Sonuç ekranı göster
    if (mounted) {
      _sonucGoster(sonuc);
    }
  }

  void _sonucGoster(KurumsalDenemeSonucu sonuc) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF21262D),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
            const SizedBox(width: 12),
            const Text("Sınav Bitti!", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sonucSatir("Doğru", sonuc.dogru, Colors.green),
            _sonucSatir("Yanlış", sonuc.yanlis, Colors.red),
            _sonucSatir("Boş", sonuc.bos, Colors.grey),
            const Divider(color: Colors.white24),
            _sonucSatir("NET", sonuc.net, Colors.blue, isBold: true),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Sınav ekranından çık
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  Widget _sonucSatir(String label, num value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: isBold ? 18 : 16)),
          Text(
            value is double ? value.toStringAsFixed(2) : value.toString(),
            style: TextStyle(
              color: color,
              fontSize: isBold ? 24 : 18,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: Text(widget.deneme.dersAdi, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Zamanlayıcı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _kalanSaniye < 300 ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, size: 18, color: Colors.white),
                const SizedBox(width: 4),
                Text(_formatliSure, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Bitir butonu
          IconButton(
            onPressed: _sinaviBitirOnay,
            icon: const Icon(Icons.check_circle, color: Colors.green),
          ),
        ],
      ),
      body: Stack(
        children: [
          // PDF Viewer (arka plan)
          SfPdfViewer.network(
            widget.deneme.pdfUrl,
            controller: _pdfController,
          ),
          
          // Watermark
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Transform.rotate(
                  angle: -0.3,
                  child: Opacity(
                    opacity: 0.08,
                    child: Text(
                      '${widget.ogrenciAdi}\n${widget.ogrenciId}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Sanal Optik Form (alt bar)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22).withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Üst bar: Soru numarası ve navigasyon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _oncekiSoru,
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: _soruSecDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Soru ${_aktifSoru + 1} / ${widget.deneme.soruSayisi}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _sonrakiSoru,
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Cevap butonları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['A', 'B', 'C', 'D', 'E'].map((cevap) {
                      bool secili = _cevaplar[_aktifSoru] == cevap;
                      return GestureDetector(
                        onTap: () => _cevapSec(cevap),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: secili ? Colors.green : Colors.grey.shade800,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: secili ? Colors.greenAccent : Colors.grey.shade600,
                              width: 2,
                            ),
                            boxShadow: secili ? [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ] : null,
                          ),
                          child: Center(
                            child: Text(
                              cevap,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: secili ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
