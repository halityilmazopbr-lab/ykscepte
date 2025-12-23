/// Kurumsal Kitap Okuyucu Ekranı
/// 
/// Özellikler:
/// - PDF Viewer
/// - Sayfa hatırlama (kaldığı yerden devam)
/// - Sayfa numarası gösterimi

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'kurum_models.dart';

class KitapOkuyucuEkrani extends StatefulWidget {
  final KurumKitabi kitap;

  const KitapOkuyucuEkrani({
    super.key,
    required this.kitap,
  });

  @override
  State<KitapOkuyucuEkrani> createState() => _KitapOkuyucuEkraniState();
}

class _KitapOkuyucuEkraniState extends State<KitapOkuyucuEkrani> {
  final PdfViewerController _pdfController = PdfViewerController();
  int _sayfaSayisi = 0;
  int _mevcutSayfa = 1;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _kayitliSayfaYukle();
  }

  @override
  void dispose() {
    _sayfaKaydet();
    _pdfController.dispose();
    super.dispose();
  }

  /// Kaldığı sayfayı SharedPreferences'tan yükle
  Future<void> _kayitliSayfaYukle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kayitliSayfa = prefs.getInt('kitap_${widget.kitap.id}_sayfa') ?? 1;
      
      // PDF yüklendikten sonra sayfaya git
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && kayitliSayfa > 1) {
          _pdfController.jumpToPage(kayitliSayfa);
        }
      });
    } catch (e) {
      print('Sayfa yüklenemedi: $e');
    }
  }

  /// Mevcut sayfayı kaydet
  Future<void> _sayfaKaydet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('kitap_${widget.kitap.id}_sayfa', _mevcutSayfa);
    } catch (e) {
      print('Sayfa kaydedilemedi: $e');
    }
  }

  void _sayfaDegisti(PdfPageChangedDetails details) {
    setState(() {
      _mevcutSayfa = details.newPageNumber;
    });
    _sayfaKaydet();
  }

  void _dokumandYuklendi(PdfDocumentLoadedDetails details) {
    setState(() {
      _sayfaSayisi = details.document.pages.count;
      _yukleniyor = false;
    });
  }

  void _sayfayaGitDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF21262D),
        title: const Text("Sayfaya Git", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Sayfa numarası (1-$_sayfaSayisi)",
            hintStyle: const TextStyle(color: Colors.grey),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              final sayfa = int.tryParse(controller.text);
              if (sayfa != null && sayfa >= 1 && sayfa <= _sayfaSayisi) {
                _pdfController.jumpToPage(sayfa);
                Navigator.pop(context);
              }
            },
            child: const Text("Git"),
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
        title: Text(
          widget.kitap.kitapAdi,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Sayfa göstergesi
          GestureDetector(
            onTap: _sayfayaGitDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    _yukleniyor ? "..." : "$_mevcutSayfa / $_sayfaSayisi",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // PDF Viewer
          SfPdfViewer.network(
            widget.kitap.pdfUrl,
            controller: _pdfController,
            onDocumentLoaded: _dokumandYuklendi,
            onPageChanged: _sayfaDegisti,
            enableDoubleTapZooming: true,
            canShowScrollHead: true,
            canShowScrollStatus: true,
          ),
          
          // Yüklenme göstergesi
          if (_yukleniyor)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text("Kitap yükleniyor...", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
      // Alt navigasyon
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // İlk sayfa
            IconButton(
              onPressed: () => _pdfController.jumpToPage(1),
              icon: const Icon(Icons.first_page, color: Colors.white),
              tooltip: "İlk Sayfa",
            ),
            // Önceki sayfa
            IconButton(
              onPressed: () {
                if (_mevcutSayfa > 1) {
                  _pdfController.previousPage();
                }
              },
              icon: const Icon(Icons.navigate_before, color: Colors.white),
              tooltip: "Önceki Sayfa",
            ),
            // Sayfa durumu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Sayfa $_mevcutSayfa",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            // Sonraki sayfa
            IconButton(
              onPressed: () {
                if (_mevcutSayfa < _sayfaSayisi) {
                  _pdfController.nextPage();
                }
              },
              icon: const Icon(Icons.navigate_next, color: Colors.white),
              tooltip: "Sonraki Sayfa",
            ),
            // Son sayfa
            IconButton(
              onPressed: () => _pdfController.jumpToPage(_sayfaSayisi),
              icon: const Icon(Icons.last_page, color: Colors.white),
              tooltip: "Son Sayfa",
            ),
          ],
        ),
      ),
    );
  }
}
