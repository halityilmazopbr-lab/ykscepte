import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'kurum_models.dart';
import 'models.dart';
import 'data.dart';

/// 🏛️ Kurum Denemesi Çözüm Ekranı - Sanal Optik Form
/// B2B'nin can damarı - Kağıt israfı, optik okuyucu ve Excel hamallığından kurtuluş
class KurumDenemeCozumScreen extends StatefulWidget {
  final KurumsalDeneme deneme;
  final Ogrenci ogrenci;
  final bool dijitalMod; // true ise PDF split view göster
  
  const KurumDenemeCozumScreen({
    super.key,
    required this.deneme,
    required this.ogrenci,
    this.dijitalMod = false,
  });

  @override
  State<KurumDenemeCozumScreen> createState() => _KurumDenemeCozumScreenState();
}

class _KurumDenemeCozumScreenState extends State<KurumDenemeCozumScreen> 
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  late KurumsalDenemeOturumu _oturum;
  late Map<int, String?> _cevaplar;
  Timer? _sayacTimer;
  int _kalanSaniye = 0;
  bool _sinavBitti = false;
  int _aktifTestIndex = 0;
  
  // Focus Mode
  int _arkaPlanSayaci = 0;
  bool _uyariGosterildi = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Focus mode için
    
    _tabController = TabController(
      length: widget.deneme.testler.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _aktifTestIndex = _tabController.index);
      }
    });
    
    // Oturum başlat
    _oturum = KurumsalDenemeOturumu(
      denemeId: widget.deneme.id,
      ogrenciId: widget.ogrenci.id,
      baslangic: DateTime.now(),
    );
    
    // Cevapları başlat
    _cevaplar = {};
    for (int i = 1; i <= widget.deneme.toplamSoruSayisi; i++) {
      _cevaplar[i] = null;
    }
    
    // Geri sayım başlat
    _kalanSaniye = widget.deneme.sureDakika * 60;
    _sayacTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_kalanSaniye > 0) {
        setState(() => _kalanSaniye--);
      } else {
        _sinaviBitir(otomatik: true);
      }
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _sayacTimer?.cancel();
    super.dispose();
  }
  
  // Focus Mode - Uygulama arka plana alındığında
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_sinavBitti) return;
    
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _arkaPlanSayaci++;
      _oturum.ihlalEkle();
      
      if (_arkaPlanSayaci == 1 && !_uyariGosterildi) {
        _uyariGosterildi = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _focusModeUyarisi();
        });
      } else if (_arkaPlanSayaci >= 2) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _sinaviIptalEt();
        });
      }
    }
  }
  
  void _focusModeUyarisi() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.red.shade900,
        icon: const Icon(Icons.warning_amber, color: Colors.yellow, size: 48),
        title: const Text("⚠️ DİKKAT!", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Sınavdasın! Uygulamadan çıkarsan sınavın İPTAL olacak ve kuruma 'Kopya Şüphesi' raporu gidecek.\n\nBu ilk ve son uyarın.",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(c),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, foregroundColor: Colors.black),
            child: const Text("ANLADIM, DEVAM"),
          ),
        ],
      ),
    );
  }
  
  void _sinaviIptalEt() {
    _sinavBitti = true;
    _sayacTimer?.cancel();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.red.shade900,
        icon: const Icon(Icons.gpp_bad, color: Colors.white, size: 48),
        title: const Text("🚫 SINAV İPTAL!", style: TextStyle(color: Colors.white)),
        content: const Text(
          "2 kez uygulamadan çıktığın için sınavın iptal edildi.\n\nKuruma 'Kopya Şüphesi' raporu gönderildi.",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red),
            child: const Text("KAPAT"),
          ),
        ],
      ),
    );
  }
  
  void _sikIsaretle(int soruNo, String sik) {
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    setState(() {
      // Çift tıklama ile temizle
      if (_cevaplar[soruNo] == sik) {
        _cevaplar[soruNo] = null;
      } else {
        _cevaplar[soruNo] = sik;
      }
      _oturum.geciciCevaplar = Map.from(_cevaplar);
    });
    
    // TODO: Firebase'e anlık sync
  }
  
  void _sinaviBitirOnay() {
    final bosSayisi = _cevaplar.values.where((v) => v == null).length;
    
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF21262D),
        title: const Text("Sınavı Bitir", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (bosSayisi > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 12),
                    Text(
                      "$bosSayisi boş sorun var!",
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              "Sınavı bitirmek istediğine emin misin?",
              style: TextStyle(color: Colors.grey.shade300),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("DEVAM ET"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              _sinaviBitir(otomatik: false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("BİTİR"),
          ),
        ],
      ),
    );
  }
  
  void _sinaviBitir({required bool otomatik}) {
    _sinavBitti = true;
    _sayacTimer?.cancel();
    
    // Sonuç hesapla
    final sonuc = KurumsalDenemeSonuc(
      id: 'sonuc_${DateTime.now().millisecondsSinceEpoch}',
      denemeId: widget.deneme.id,
      ogrenciId: widget.ogrenci.id,
      ogrenciAd: widget.ogrenci.ad,
      cevaplar: Map.from(_cevaplar),
      baslangicZamani: _oturum.baslangic,
      bitisZamani: DateTime.now(),
      ihlalSayisi: _oturum.ihlalSayisi,
      tamamlandi: true,
    );
    
    sonuc.netleriHesapla(widget.deneme);
    
    // Demo sıralama (gerçekte Firebase'den gelecek)
    sonuc.kurumSirasi = 7;
    sonuc.kurumKatilimci = 120;
    
    // Sonuç ekranına git
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (c) => KurumsalDenemeSonucScreen(
          deneme: widget.deneme,
          sonuc: sonuc,
          otomatikBitis: otomatik,
        ),
      ),
    );
  }
  
  String _formatSure(int saniye) {
    final dakika = saniye ~/ 60;
    final kalan = saniye % 60;
    return '${dakika.toString().padLeft(2, '0')}:${kalan.toString().padLeft(2, '0')}';
  }
  
  Color _getSureRengi() {
    if (_kalanSaniye < 300) return Colors.red; // Son 5 dk
    if (_kalanSaniye < 900) return Colors.orange; // Son 15 dk
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _sinaviBitirOnay();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        appBar: AppBar(
          backgroundColor: const Color(0xFF161B22),
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.deneme.kurumAdi,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
              Text(
                widget.deneme.baslik,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            // Geri Sayım
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getSureRengi().withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getSureRengi()),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, color: _getSureRengi(), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _formatSure(_kalanSaniye),
                    style: TextStyle(
                      color: _getSureRengi(),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Courier',
                    ),
                  ),
                ],
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.purple,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: widget.deneme.testler.map((test) {
              final testCevaplar = _cevaplar.entries
                  .where((e) => e.key >= test.baslangicSoru && e.key <= test.bitisSoru)
                  .where((e) => e.value != null)
                  .length;
              return Tab(
                child: Row(
                  children: [
                    Text(test.ad),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: testCevaplar == test.soruSayisi ? Colors.green : Colors.grey.withAlpha(50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$testCevaplar/${test.soruSayisi}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        body: widget.dijitalMod ? _buildDijitalSinavBody() : TabBarView(
          controller: _tabController,
          children: widget.deneme.testler.map((test) => _buildOptikForm(test)).toList(),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                // İlerleme
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "İlerleme: ${_cevaplar.values.where((v) => v != null).length}/${widget.deneme.toplamSoruSayisi}",
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _cevaplar.values.where((v) => v != null).length / widget.deneme.toplamSoruSayisi,
                          backgroundColor: Colors.grey.withAlpha(50),
                          valueColor: const AlwaysStoppedAnimation(Colors.purple),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Bitir Butonu
                ElevatedButton.icon(
                  onPressed: _sinaviBitirOnay,
                  icon: const Icon(Icons.flag),
                  label: const Text("SINAVI BİTİR"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildOptikForm(KurumsalDenemeTest test) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: test.soruSayisi,
      itemBuilder: (context, index) {
        final soruNo = test.baslangicSoru + index;
        final secilenSik = _cevaplar[soruNo];
        
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF21262D),
            borderRadius: BorderRadius.circular(12),
            border: secilenSik != null 
                ? Border.all(color: Colors.purple.withAlpha(100))
                : null,
          ),
          child: Row(
            children: [
              // Soru Numarası
              Container(
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: secilenSik != null ? Colors.purple.withAlpha(50) : Colors.grey.withAlpha(30),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                ),
                child: Text(
                  '$soruNo',
                  style: TextStyle(
                    color: secilenSik != null ? Colors.purple : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Şıklar (A-B-C-D-E)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['A', 'B', 'C', 'D', 'E'].map((sik) {
                    final secili = secilenSik == sik;
                    return GestureDetector(
                      onTap: () => _sikIsaretle(soruNo, sik),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: secili ? Colors.purple : Colors.transparent,
                          border: Border.all(
                            color: secili ? Colors.purple : Colors.grey.shade600,
                            width: secili ? 2 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          sik,
                          style: TextStyle(
                            color: secili ? Colors.white : Colors.grey.shade400,
                            fontWeight: secili ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// 📱 Dijital Sınav Modu - PDF Split View
  /// Üst %60: PDF Görüntüleyici
  /// Alt %40: Yatay Kayan Optik Şerit
  Widget _buildDijitalSinavBody() {
    final aktifTest = widget.deneme.testler[_aktifTestIndex];
    
    return Column(
      children: [
        // Üst Kısım - PDF Görüntüleyici (%60)
        Expanded(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.deneme.pdfUrl != null && widget.deneme.pdfUrl!.isNotEmpty
                  ? SfPdfViewer.network(
                      widget.deneme.pdfUrl!,
                      enableDoubleTapZooming: true,
                      canShowScrollHead: true,
                      canShowScrollStatus: true,
                      pageLayoutMode: PdfPageLayoutMode.continuous,
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            "PDF yüklenmedi",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Aşağıdaki optik formdan cevapları işaretleyebilirsin",
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        
        // Test Seçici Barı
        Container(
          height: 40,
          color: const Color(0xFF161B22),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: widget.deneme.testler.length,
            itemBuilder: (context, index) {
              final test = widget.deneme.testler[index];
              final isActive = index == _aktifTestIndex;
              final testCevaplar = _cevaplar.entries
                  .where((e) => e.key >= test.baslangicSoru && e.key <= test.bitisSoru)
                  .where((e) => e.value != null)
                  .length;
              
              return GestureDetector(
                onTap: () => setState(() => _aktifTestIndex = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.purple : Colors.grey.withAlpha(30),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text(
                        test.ad,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: testCevaplar == test.soruSayisi 
                              ? Colors.green 
                              : Colors.black.withAlpha(50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$testCevaplar/${test.soruSayisi}',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Alt Kısım - Yatay Kayan Optik Şerit (%40)
        Expanded(
          flex: 4,
          child: Container(
            color: const Color(0xFF161B22),
            child: _buildHorizontalOptikStrip(aktifTest),
          ),
        ),
      ],
    );
  }
  
  /// Yatay Kayan Optik Form Şeridi
  Widget _buildHorizontalOptikStrip(KurumsalDenemeTest test) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(8),
      itemCount: test.soruSayisi,
      itemBuilder: (context, index) {
        final soruNo = test.baslangicSoru + index;
        final secilenSik = _cevaplar[soruNo];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF21262D),
            borderRadius: BorderRadius.circular(12),
            border: secilenSik != null 
                ? Border.all(color: Colors.purple.withAlpha(100))
                : null,
          ),
          child: Row(
            children: [
              // Soru Numarası
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: secilenSik != null ? Colors.purple.withAlpha(50) : Colors.grey.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$soruNo',
                  style: TextStyle(
                    color: secilenSik != null ? Colors.purple : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Şıklar (A-B-C-D-E)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['A', 'B', 'C', 'D', 'E'].map((sik) {
                    final secili = secilenSik == sik;
                    return GestureDetector(
                      onTap: () => _sikIsaretle(soruNo, sik),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: secili ? Colors.purple : Colors.transparent,
                          border: Border.all(
                            color: secili ? Colors.purple : Colors.grey.shade600,
                            width: secili ? 3 : 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          sik,
                          style: TextStyle(
                            color: secili ? Colors.white : Colors.grey.shade400,
                            fontWeight: secili ? FontWeight.bold : FontWeight.normal,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SONUÇ KARNESİ EKRANI - "The Wow Moment"
// ═══════════════════════════════════════════════════════════════════════════

class KurumsalDenemeSonucScreen extends StatelessWidget {
  final KurumsalDeneme deneme;
  final KurumsalDenemeSonuc sonuc;
  final bool otomatikBitis;
  
  const KurumsalDenemeSonucScreen({
    super.key,
    required this.deneme,
    required this.sonuc,
    this.otomatikBitis = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: CustomScrollView(
        slivers: [
          // Hero Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF161B22),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.purple.shade900, const Color(0xFF161B22)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Kurum ve Deneme
                      Text(
                        deneme.kurumAdi,
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      ),
                      Text(
                        deneme.baslik,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      
                      // Toplam Net (Büyük)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withAlpha(30)),
                        ),
                        child: Column(
                          children: [
                            const Text("TOPLAM NET", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(
                              sonuc.toplamNet?.toStringAsFixed(2) ?? "0.00",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Kurum Sıralama
                      if (sonuc.kurumSirasi != null && sonuc.kurumKatilimci != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.orange.shade700]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "${sonuc.kurumSirasi}. / ${sonuc.kurumKatilimci} kişi",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Test Netleri
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "📊 Test Bazlı Sonuçlar",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  ...deneme.testler.map((test) {
                    final net = sonuc.testNetleri?[test.ad] ?? 0;
                    final yuzde = (net / test.soruSayisi * 100).clamp(0, 100);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF21262D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(test.ad, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(
                                "${net.toStringAsFixed(2)} Net",
                                style: TextStyle(
                                  color: yuzde > 70 ? Colors.green : (yuzde > 40 ? Colors.orange : Colors.red),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: yuzde / 100,
                              backgroundColor: Colors.grey.withAlpha(50),
                              valueColor: AlwaysStoppedAnimation(
                                yuzde > 70 ? Colors.green : (yuzde > 40 ? Colors.orange : Colors.red),
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 24),
                  
                  // Kapat Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.home),
                      label: const Text("ANA SAYFAYA DÖN"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
