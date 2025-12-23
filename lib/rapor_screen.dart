import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'data.dart';
import 'models.dart';
import 'gemini_service.dart';

/// Rapor ve Sıralama Ekranı
/// PDF Karnesi + Türkiye Sıralaması Simülasyonu
class RaporEkrani extends StatefulWidget {
  final Ogrenci ogrenci;
  const RaporEkrani({super.key, required this.ogrenci});

  @override
  State<RaporEkrani> createState() => _RaporEkraniState();
}

class _RaporEkraniState extends State<RaporEkrani> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGeneratingPdf = false;
  bool _isLoadingAI = false;
  String? _aiSummary;

  // Simüle edilmiş sıralama verileri
  Map<String, int> _rankings = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _calculateRankings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _calculateRankings() {
    // Simülasyon: Öğrencinin netlerine göre sıralama hesapla
    final denemeler = VeriDeposu.denemeListesi
        .where((d) => d.ogrenciId == widget.ogrenci.id)
        .toList();

    if (denemeler.isEmpty) return;

    // Son denemenin netlerini al
    final sonDeneme = denemeler.last;
    final dersNetleri = sonDeneme.dersNetleri;

    // Her ders için simüle sıralama (%'lik dilim)
    setState(() {
      _rankings = dersNetleri.map((ders, net) {
        // Simülasyon: net'e göre yüzdelik dilim hesapla
        double maxNet = 40;
        int percentile = 100 - ((net / maxNet) * 100).clamp(0, 100).toInt();
        return MapEntry(ders, percentile);
      });
    });
  }

  int get _toplamCozulenSoru {
    return VeriDeposu.soruCozumListesi
        .where((s) => s.ogrenciId == widget.ogrenci.id)
        .length;
  }

  int get _toplamDeneme {
    return VeriDeposu.denemeListesi
        .where((d) => d.ogrenciId == widget.ogrenci.id)
        .length;
  }

  double get _ortalamaNet {
    final denemeler = VeriDeposu.denemeListesi
        .where((d) => d.ogrenciId == widget.ogrenci.id)
        .toList();
    if (denemeler.isEmpty) return 0;
    return denemeler.fold(0.0, (sum, d) => sum + d.toplamNet) / denemeler.length;
  }

  String get _tahminiSiralama {
    // Basit simülasyon: net'e göre tahmini sıralama
    double net = _ortalamaNet;
    if (net >= 100) return "1.000 - 5.000";
    if (net >= 80) return "5.000 - 15.000";
    if (net >= 60) return "15.000 - 50.000";
    if (net >= 40) return "50.000 - 100.000";
    if (net >= 20) return "100.000 - 300.000";
    return "300.000+";
  }

  Future<void> _generateAISummary() async {
    setState(() => _isLoadingAI = true);

    try {
      final prompt = '''
Bir YKS rehber öğretmeni olarak, aşağıdaki öğrenci verilerine bakarak kısa ve motive edici bir değerlendirme yaz:

Öğrenci: ${widget.ogrenci.ad}
Hedef Üniversite: ${widget.ogrenci.hedefUniversite}
Hedef Bölüm: ${widget.ogrenci.hedefBolum}
Toplam Çözülen Soru: $_toplamCozulenSoru
Toplam Deneme: $_toplamDeneme
Ortalama Net: ${_ortalamaNet.toStringAsFixed(1)}
Tahmini Sıralama: $_tahminiSiralama

3-4 cümlelik samimi ve motive edici bir değerlendirme yaz. Eksiklere nazikçe değin, güçlü yönleri vurgula.
''';

      final response = await GravityAI.generateText(prompt);
      setState(() => _aiSummary = response);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("AI hatası: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoadingAI = false);
    }
  }

  Future<void> _generateAndSharePdf() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF web'de desteklenmiyor, mobil uygulamayı kullanın"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isGeneratingPdf = true);

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.purple,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("YKS CEPTE", style: pw.TextStyle(color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text("Aylık Performans Raporu", style: pw.TextStyle(color: PdfColors.grey400, fontSize: 14)),
                        ],
                      ),
                      pw.Text(DateTime.now().toString().substring(0, 10), style: pw.TextStyle(color: PdfColors.grey400)),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Öğrenci Bilgileri
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("ÖĞRENCİ BİLGİLERİ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                      pw.SizedBox(height: 10),
                      pw.Row(children: [
                        pw.Expanded(child: pw.Text("Ad Soyad: ${widget.ogrenci.ad}")),
                        pw.Expanded(child: pw.Text("Sınıf: ${widget.ogrenci.sinif}")),
                      ]),
                      pw.SizedBox(height: 5),
                      pw.Row(children: [
                        pw.Expanded(child: pw.Text("Hedef: ${widget.ogrenci.hedefUniversite} - ${widget.ogrenci.hedefBolum}")),
                      ]),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // İstatistikler
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildPdfStat("Çözülen Soru", _toplamCozulenSoru.toString()),
                      _buildPdfStat("Deneme Sayısı", _toplamDeneme.toString()),
                      _buildPdfStat("Ort. Net", _ortalamaNet.toStringAsFixed(1)),
                      _buildPdfStat("Tahmini Sıralama", _tahminiSiralama),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Ders Bazlı Performans
                pw.Text("DERS BAZLI PERFORMANS", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.SizedBox(height: 10),
                ..._rankings.entries.map((e) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 5),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 2, child: pw.Text(e.key)),
                      pw.Expanded(
                        flex: 5,
                        child: pw.Container(
                          height: 15,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                            borderRadius: pw.BorderRadius.circular(5),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Container(
                                width: (100 - e.value) * 2.0,
                                decoration: pw.BoxDecoration(
                                  color: e.value < 30 ? PdfColors.green : (e.value < 60 ? PdfColors.orange : PdfColors.red),
                                  borderRadius: pw.BorderRadius.circular(5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Text("İlk %${e.value}", style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                )),

                pw.SizedBox(height: 20),

                // AI Yorum
                if (_aiSummary != null) ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.purple50,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColors.purple200),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("🤖 AI DEĞERLENDİRMESİ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        pw.SizedBox(height: 8),
                        pw.Text(_aiSummary!, style: const pw.TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ],

                pw.Spacer(),

                // Footer
                pw.Center(
                  child: pw.Text("YKS Cepte ile hazırlandı • ${DateTime.now().year}", style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10)),
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/yks_cepte_rapor_${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.ogrenci.ad} - YKS Cepte Aylık Raporu',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ PDF oluşturuldu!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }

  pw.Widget _buildPdfStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.purple)),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("📊 Rapor & Sıralama", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purple,
          labelColor: Colors.purple,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.picture_as_pdf), text: "PDF Rapor"),
            Tab(icon: Icon(Icons.leaderboard), text: "Sıralama"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPdfTab(),
          _buildRankingTab(),
        ],
      ),
    );
  }

  Widget _buildPdfTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Özet Kartları
          Row(
            children: [
              Expanded(child: _buildStatCard("📝", "Çözülen Soru", _toplamCozulenSoru.toString(), Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard("📊", "Deneme", _toplamDeneme.toString(), Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard("🎯", "Ort. Net", _ortalamaNet.toStringAsFixed(1), Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard("🏆", "Tahmini", _tahminiSiralama, Colors.purple)),
            ],
          ),

          const SizedBox(height: 24),

          // AI Değerlendirme
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amber),
                    const SizedBox(width: 8),
                    const Text("AI Değerlendirmesi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (_aiSummary == null)
                      TextButton(
                        onPressed: _isLoadingAI ? null : _generateAISummary,
                        child: _isLoadingAI 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text("Oluştur ✨"),
                      ),
                  ],
                ),
                if (_aiSummary != null) ...[
                  const SizedBox(height: 12),
                  Text(_aiSummary!, style: TextStyle(color: Colors.grey.shade300, height: 1.5)),
                ] else ...[
                  const SizedBox(height: 8),
                  Text("AI'dan kişiselleştirilmiş değerlendirme al", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // PDF Oluştur Butonu
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isGeneratingPdf ? null : _generateAndSharePdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: _isGeneratingPdf 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.picture_as_pdf),
              label: Text(_isGeneratingPdf ? "Oluşturuluyor..." : "PDF Oluştur ve Paylaş", style: const TextStyle(fontSize: 16)),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            "PDF'i WhatsApp, e-posta veya diğer uygulamalarla paylaşabilirsin",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRankingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Tahmini Sıralama Kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade800, Colors.deepPurple.shade700],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.purple.withAlpha(60), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
                const SizedBox(height: 16),
                const Text("TAHMİNİ YKS SIRALAMANIZ", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
                const SizedBox(height: 8),
                Text(
                  _tahminiSiralama,
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Ortalama Net: ${_ortalamaNet.toStringAsFixed(1)}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Ders Bazlı Sıralama
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("📊 DERS BAZLI SIRALAMA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Sistemi kullanan 10.000+ öğrenci arasında", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 16),

                if (_rankings.isEmpty)
                  Center(
                    child: Text("Henüz deneme verisi yok", style: TextStyle(color: Colors.grey.shade500)),
                  )
                else
                  ..._rankings.entries.map((e) => _buildRankingBar(e.key, e.value)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // İpucu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withAlpha(50)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Daha fazla deneme girdikçe tahmin doğruluğu artar!",
                    style: TextStyle(color: Colors.amber.shade200, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingBar(String ders, int percentile) {
    Color color;
    String emoji;
    
    if (percentile < 20) {
      color = Colors.green;
      emoji = "🔥";
    } else if (percentile < 40) {
      color = Colors.lightGreen;
      emoji = "👍";
    } else if (percentile < 60) {
      color = Colors.orange;
      emoji = "💪";
    } else {
      color = Colors.red;
      emoji = "📚";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ders, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              Text("$emoji İlk %$percentile", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (100 - percentile) / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withAlpha(180)]),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
