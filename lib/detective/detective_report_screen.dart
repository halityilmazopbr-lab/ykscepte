/// 🕵️ NET-X Dedektifi - Rapor Ekranı (fl_chart ile)
/// Profesyonel pasta grafikleri ve Potansiyel Net analizi

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'detective_models.dart';
import 'detective_service.dart';

class DetectiveReportScreen extends StatefulWidget {
  final DedektifRaporu rapor;

  const DetectiveReportScreen({super.key, required this.rapor});

  @override
  State<DetectiveReportScreen> createState() => _DetectiveReportScreenState();
}

class _DetectiveReportScreenState extends State<DetectiveReportScreen> {
  final DetectiveService _service = DetectiveService();
  bool _kaydedildi = false;
  int _touchedIndex = -1;

  // Hata Türü Renkleri
  final Map<HataTuru, Color> _hataTuruRenkleri = {
    HataTuru.dikkatHatasi: Colors.orange,
    HataTuru.bilgiEksigi: Colors.red,
    HataTuru.sureYetmedi: Colors.purple,
    HataTuru.teredut: Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    _kaydet();
  }

  Future<void> _kaydet() async {
    try {
      await _service.kaydetRapor(widget.rapor);
      setState(() => _kaydedildi = true);
    } catch (e) {
      debugPrint('Rapor kaydetme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          "📊 Dedektif Raporu",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_kaydedildi)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.cloud_done, color: Colors.green),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KART: NET KARŞILAŞTIRMASI (Mevcut vs Potansiyel)
            _buildNetKarsilastirma(),
            
            const SizedBox(height: 30),
            
            // Başlık
            const Text(
              "🔍 Suç Mahalli Analizi",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // 2. KART: PASTA GRAFİĞİ
            _buildPastaGrafigi(),
            
            const SizedBox(height: 30),
            
            // Başlık
            const Text(
              "💊 Dedektif Reçetesi",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // 3. KART: TAVSİYE
            _buildReceteKarti(),
            
            const SizedBox(height: 30),
            
            // 4. DETAYLI İSTATİSTİKLER
            _buildDetayliIstatistikler(),
            
            const SizedBox(height: 50),
            
            // ALT BUTONLAR
            _buildAltButonlar(),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📊 NET KARŞILAŞTIRMA KARTI
  // ═══════════════════════════════════════════════════════════════

  Widget _buildNetKarsilastirma() {
    final r = widget.rapor;
    final dikkatKaybi = r.dikkatKaybi;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1E1E),
            Colors.cyan.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNetKolonu("MEVCUT NET", r.mevcutNet, Colors.white),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.cyanAccent, size: 28),
              ),
              _buildNetKolonu("POTANSİYEL", r.potansiyelNet, Colors.cyanAccent),
            ],
          ),
          
          if (dikkatKaybi > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Dikkat hataları: -${dikkatKaybi.toStringAsFixed(1)} net",
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNetKolonu(String baslik, double deger, Color renk) {
    return Column(
      children: [
        Text(
          baslik,
          style: TextStyle(color: Colors.grey[400], fontSize: 12, letterSpacing: 1.5),
        ),
        const SizedBox(height: 10),
        Text(
          deger.toStringAsFixed(2),
          style: TextStyle(
            color: renk,
            fontSize: 40,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🥧 PASTA GRAFİĞİ
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPastaGrafigi() {
    final r = widget.rapor;
    final toplamHata = r.dikkatHatasiSayisi + r.bilgiEksigiSayisi + 
                       r.sureYetmediSayisi + r.teredutSayisi;
    
    if (toplamHata == 0) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.celebration, color: Colors.green, size: 48),
              SizedBox(height: 12),
              Text(
                "🎉 Hata Yok! Mükemmel!",
                style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Pasta Grafiği
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 3,
                centerSpaceRadius: 45,
                sections: _showingSections(),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Lejant (Açıklamalar)
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.dikkatHatasiSayisi > 0)
                  _buildLejantItem(HataTuru.dikkatHatasi, r.dikkatHatasiSayisi),
                if (r.bilgiEksigiSayisi > 0)
                  _buildLejantItem(HataTuru.bilgiEksigi, r.bilgiEksigiSayisi),
                if (r.sureYetmediSayisi > 0)
                  _buildLejantItem(HataTuru.sureYetmedi, r.sureYetmediSayisi),
                if (r.teredutSayisi > 0)
                  _buildLejantItem(HataTuru.teredut, r.teredutSayisi),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLejantItem(HataTuru tur, int sayi) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _hataTuruRenkleri[tur],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${tur.baslik}: $sayi",
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections() {
    final r = widget.rapor;
    final data = <MapEntry<HataTuru, int>>[
      MapEntry(HataTuru.dikkatHatasi, r.dikkatHatasiSayisi),
      MapEntry(HataTuru.bilgiEksigi, r.bilgiEksigiSayisi),
      MapEntry(HataTuru.sureYetmedi, r.sureYetmediSayisi),
      MapEntry(HataTuru.teredut, r.teredutSayisi),
    ].where((e) => e.value > 0).toList();

    return data.asMap().entries.map((entry) {
      final idx = entry.key;
      final hataTuru = entry.value.key;
      final sayi = entry.value.value;
      final isTouched = idx == _touchedIndex;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 65.0 : 55.0;

      return PieChartSectionData(
        color: _hataTuruRenkleri[hataTuru],
        value: sayi.toDouble(),
        title: sayi.toString(),
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // 💊 REÇETE KARTI
  // ═══════════════════════════════════════════════════════════════

  Widget _buildReceteKarti() {
    final r = widget.rapor;
    final dominantProblem = _getDominantProblem();
    final prescription = _getPrescription(dominantProblem);
    final dominantColor = dominantProblem != null 
        ? _hataTuruRenkleri[dominantProblem] ?? Colors.green
        : Colors.green;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dominantColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dominantColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dominantColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medical_services_outlined,
              color: dominantColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Teşhis: ${dominantProblem?.baslik ?? 'Sorun Yok'}",
                  style: TextStyle(
                    color: dominantColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  prescription,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  HataTuru? _getDominantProblem() {
    final r = widget.rapor;
    final counts = {
      HataTuru.dikkatHatasi: r.dikkatHatasiSayisi,
      HataTuru.bilgiEksigi: r.bilgiEksigiSayisi,
      HataTuru.sureYetmedi: r.sureYetmediSayisi,
      HataTuru.teredut: r.teredutSayisi,
    };
    
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sorted.first.value == 0) return null;
    return sorted.first.key;
  }

  String _getPrescription(HataTuru? problem) {
    switch (problem) {
      case HataTuru.dikkatHatasi:
        return "⚠️ Alarm! Çok fazla basit hata yapıyorsun. Senin ilacın süre tutarak 'Odak Denemeleri' çözmek. Kronometre ile pratik yap!";
      case HataTuru.bilgiEksigi:
        return "📚 Temelde sorun var. Deneme çözmeyi bırak, eksik konuların video anlatımlarına dön. Flashcard çalış!";
      case HataTuru.sureYetmedi:
        return "⏱️ Yavaşsın Ajan. Turlama taktiğini uygulamalısın. Zor sorularda takılıp kalma, atlayıp devam et!";
      case HataTuru.teredut:
        return "🎯 Özgüven sorunu yaşıyorsun. İki şık arasında kaldığında mantıklı eleme tekniklerini öğren!";
      default:
        return "🎉 Harika iş çıkardın! Potansiyelin çok yüksek. Aynen devam!";
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 📈 DETAYLI İSTATİSTİKLER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDetayliIstatistikler() {
    final r = widget.rapor;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📋 Detaylı İstatistikler",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildStatRow("Toplam Soru", "${r.toplamSoru}"),
          _buildStatRow("Doğru", "${r.dogru}", Colors.green),
          _buildStatRow("Yanlış", "${r.yanlis}", Colors.red),
          _buildStatRow("Boş", "${r.bos}", Colors.grey),
          
          const Divider(color: Colors.grey, height: 30),
          
          _buildStatRow("Mevcut Net", r.mevcutNet.toStringAsFixed(2), Colors.white),
          _buildStatRow("Potansiyel Net", r.potansiyelNet.toStringAsFixed(2), Colors.cyanAccent),
          _buildStatRow("Kaybedilen Net", "-${r.dikkatKaybi.toStringAsFixed(2)}", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatRow(String baslik, String deger, [Color? renk]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: TextStyle(color: Colors.grey[400])),
          Text(
            deger,
            style: TextStyle(
              color: renk ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔘 ALT BUTONLAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAltButonlar() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paylaşım özelliği yakında...')),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Paylaş'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            icon: const Icon(Icons.home),
            label: const Text('ANA SAYFA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
