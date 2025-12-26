/// 🕵️ NET-X Dedektifi - Sanal Optik Ekranı
/// AI'dan gelen veriyi görselleştirip, öğrencinin hatalarını işaretlemesini sağlar
/// 
/// Mantık: Tüm sorular varsayılan "DOĞRU" kabul edilir.
/// Öğrenci sadece yanlışların üzerine tıklayıp hata sebebini seçer.

import 'package:flutter/material.dart';
import 'detective_models.dart';
import 'detective_service.dart';
import 'detective_report_screen.dart';

class VirtualOpticalScreen extends StatefulWidget {
  final String ogrenciId;
  final YayinModel yayin;
  
  /// AI'dan gelen tarama sonucu: {1: 'A', 2: 'C', 3: null, ...}
  final Map<int, String?> taramaSonucu;

  const VirtualOpticalScreen({
    super.key,
    required this.ogrenciId,
    required this.yayin,
    required this.taramaSonucu,
  });

  @override
  State<VirtualOpticalScreen> createState() => _VirtualOpticalScreenState();
}

class _VirtualOpticalScreenState extends State<VirtualOpticalScreen> {
  final DetectiveService _service = DetectiveService();
  
  /// Her soru için hata sebebi (null = doğru)
  late Map<int, HataTuru?> _hataSebepler;
  
  /// AI'nın okuduğu şıklar
  late Map<int, String?> _okunanCevaplar;

  /// Hata Türleri ve Renkleri
  final Map<HataTuru, Color> _hataTuruRenkleri = {
    HataTuru.dikkatHatasi: Colors.orange,
    HataTuru.bilgiEksigi: Colors.red,
    HataTuru.sureYetmedi: Colors.purple,
    HataTuru.teredut: Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    _hazirla();
  }

  void _hazirla() {
    // AI sonuçlarını al
    _okunanCevaplar = Map.from(widget.taramaSonucu);
    
    // Tüm sorular başlangıçta "doğru" (null = hata yok)
    _hataSebepler = {};
    for (int i = 1; i <= widget.yayin.soruSayisi; i++) {
      _hataSebepler[i] = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("📋 Analiz Masası", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Bilgi Kartı
          _buildBilgiKarti(),
          
          // İstatistik
          _buildIstatistik(),
          
          // Grid (Kutucuklar)
          Expanded(child: _buildGrid()),
          
          // Analizi Tamamla Butonu
          _buildAltButon(),
        ],
      ),
    );
  }

  Widget _buildBilgiKarti() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.cyanAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.yayin.ad,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "AI kağıdını taradı. Varsayılan olarak hepsi 'DOĞRU'. Sadece yanlışlarına tıkla.",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIstatistik() {
    final hatalSayisi = _hataSebepler.values.where((h) => h != null).length;
    final dogruSayisi = widget.yayin.soruSayisi - hatalSayisi;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatKutu('✅ Doğru', dogruSayisi, Colors.green),
          const SizedBox(width: 12),
          _buildStatKutu('❌ Yanlış', hatalSayisi, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatKutu(String baslik, int sayi, Color renk) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: renk.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: renk.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontSize: 13)),
            Text(
              '$sayi',
              style: TextStyle(color: renk, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: widget.yayin.soruSayisi,
      itemBuilder: (context, index) {
        final soruNo = index + 1;
        final hataTuru = _hataSebepler[soruNo];
        final okunanCevap = _okunanCevaplar[soruNo];
        
        // Renk Mantığı: Hata varsa hatanın rengi, yoksa Yeşil (Doğru)
        Color boxColor;
        Color borderColor;
        
        if (hataTuru != null) {
          boxColor = _hataTuruRenkleri[hataTuru]!.withValues(alpha: 0.3);
          borderColor = _hataTuruRenkleri[hataTuru]!;
        } else if (okunanCevap == null) {
          // Boş bırakılmış
          boxColor = Colors.grey.withValues(alpha: 0.2);
          borderColor = Colors.grey;
        } else {
          // Doğru (varsayılan)
          boxColor = Colors.green.withValues(alpha: 0.2);
          borderColor = Colors.green.withValues(alpha: 0.5);
        }

        return GestureDetector(
          onTap: () => _soruTiklandi(soruNo),
          child: Container(
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$soruNo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                // AI'nın okuduğu şık
                if (okunanCevap != null)
                  Text(
                    okunanCevap,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                else
                  Text(
                    '-',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                // Hata simgesi
                if (hataTuru != null)
                  Text(
                    hataTuru.emoji,
                    style: const TextStyle(fontSize: 10),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _soruTiklandi(int soruNo) {
    final mevcutHata = _hataSebepler[soruNo];
    final okunanCevap = _okunanCevaplar[soruNo] ?? 'Boş';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              Text(
                "$soruNo. Soruyu Neden Kaçırdın?",
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Okunan Şık: $okunanCevap",
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              
              // Hata seçenekleri
              ...HataTuru.values.map((tur) {
                final secili = mevcutHata == tur;
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _hataTuruRenkleri[tur]!.withValues(alpha: secili ? 0.5 : 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _hataTuruRenkleri[tur]!,
                        width: secili ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(tur.emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  title: Text(
                    tur.baslik,
                    style: TextStyle(
                      color: secili ? _hataTuruRenkleri[tur] : Colors.white,
                      fontWeight: secili ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    tur.aciklama,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  onTap: () {
                    setState(() {
                      _hataSebepler[soruNo] = tur;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              
              const Divider(color: Colors.grey),
              
              // İptal / Doğru olarak işaretle
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Center(
                    child: Icon(Icons.check, color: Colors.green),
                  ),
                ),
                title: const Text(
                  "Bu Soru Doğruydu",
                  style: TextStyle(color: Colors.green),
                ),
                subtitle: Text(
                  "Hatayı kaldır, doğru yap",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                onTap: () {
                  setState(() {
                    _hataSebepler[soruNo] = null;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAltButon() {
    final hatalSayisi = _hataSebepler.values.where((h) => h != null).length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _analiziTamamla,
          child: Text(
            hatalSayisi > 0 
                ? "ANALİZİ TAMAMLA ($hatalSayisi hata)" 
                : "ANALİZİ TAMAMLA",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _analiziTamamla() {
    // Sorgu kayıtları oluştur
    final sorguKayitlari = <SorguKaydi>[];
    
    _hataSebepler.forEach((soruNo, hataTuru) {
      if (hataTuru != null) {
        final dogruCevap = widget.yayin.cevapAnahtari[soruNo] ?? '?';
        final ogrenciCevabi = _okunanCevaplar[soruNo];
        
        sorguKayitlari.add(SorguKaydi(
          soruNo: soruNo,
          dogruCevap: dogruCevap,
          ogrenciCevabi: ogrenciCevabi,
          hataTuru: hataTuru,
        ));
      }
    });

    // Detaylı sonuç hesapla
    final dogru = widget.yayin.soruSayisi - sorguKayitlari.length;
    final yanlis = sorguKayitlari.where((k) => !k.bosmu).length;
    final bos = sorguKayitlari.where((k) => k.bosmu).length;
    final net = dogru - (yanlis / 4);

    // Rapor oluştur
    final rapor = _service.olusturRapor(
      ogrenciId: widget.ogrenciId,
      yayinId: widget.yayin.id,
      yayinAdi: widget.yayin.ad,
      sorguKayitlari: sorguKayitlari,
      toplamSoru: widget.yayin.soruSayisi,
      dogru: dogru,
      yanlis: yanlis,
      bos: bos,
      mevcutNet: net,
    );

    // Rapor ekranına git
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DetectiveReportScreen(rapor: rapor),
      ),
    );
  }
}
