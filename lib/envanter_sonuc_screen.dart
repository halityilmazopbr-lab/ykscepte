import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'envanter_models.dart';

/// Envanter Sonuç Ekranı
/// Radar Chart, Bar Chart veya Progress gösterimi ile sonuçları gösterir
class EnvanterSonucEkrani extends StatelessWidget {
  final Envanter envanter;
  final Map<String, int> skorlar;
  final int toplamSkor;
  final String seviye;
  final String aiYorum;

  const EnvanterSonucEkrani({
    super.key,
    required this.envanter,
    required this.skorlar,
    required this.toplamSkor,
    required this.seviye,
    required this.aiYorum,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Sonuçlar'),
        backgroundColor: envanter.renk,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Başlık kartı
            _buildBaslikKarti(),
            
            const SizedBox(height: 20),
            
            // Grafik kartı
            _buildGrafikKarti(),
            
            const SizedBox(height: 20),
            
            // Skor detayları
            _buildSkorDetaylari(),
            
            const SizedBox(height: 20),
            
            // AI Yorum kartı
            _buildAiYorumKarti(),
            
            const SizedBox(height: 20),
            
            // Tekrar çöz butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Başka Test Çöz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: envanter.renk,
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
    );
  }

  Widget _buildBaslikKarti() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [envanter.renk, envanter.renk.withOpacity(0.7)],
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.emoji_events, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            Text(
              'Test Tamamlandı!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              envanter.baslik,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (seviye.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Seviye: $seviye',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGrafikKarti() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: envanter.renk),
                const SizedBox(width: 8),
                const Text(
                  'Sonuç Grafiği',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 280,
              child: envanter.tip == 'radar' 
                  ? _buildRadarChart() 
                  : envanter.tip == 'bar'
                      ? _buildBarChart()
                      : _buildProgressChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarChart() {
    final kategoriler = envanter.kategoriler;
    final maxSkor = 10.0; // 5 soru x 2 puan
    
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        radarBorderData: BorderSide(color: Colors.grey.shade300),
        gridBorderData: BorderSide(color: Colors.grey.shade200, width: 1),
        tickBorderData: BorderSide(color: Colors.transparent),
        tickCount: 5,
        ticksTextStyle: const TextStyle(fontSize: 10, color: Colors.grey),
        titleTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        getTitle: (index, angle) {
          return RadarChartTitle(
            text: kategoriler[index],
            angle: 0,
          );
        },
        dataSets: [
          RadarDataSet(
            dataEntries: kategoriler.map((k) {
              final skor = (skorlar[k] ?? 0).toDouble();
              return RadarEntry(value: skor);
            }).toList(),
            fillColor: envanter.renk.withOpacity(0.3),
            borderColor: envanter.renk,
            borderWidth: 2,
            entryRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final kategoriler = envanter.kategoriler;
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        barGroups: List.generate(kategoriler.length, (i) {
          final kategori = kategoriler[i];
          final skor = (skorlar[kategori] ?? 0).toDouble();
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: skor,
                color: _barRenk(i),
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < kategoriler.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      kategoriler[index].substring(0, 3),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Color _barRenk(int index) {
    final renkler = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ];
    return renkler[index % renkler.length];
  }

  Widget _buildProgressChart() {
    // Sınav kaygısı için progress gösterimi
    final maxSkor = 100.0; // 20 soru x 5 puan
    final yuzde = (toplamSkor / maxSkor).clamp(0.0, 1.0);
    
    Color renk;
    if (yuzde <= 0.4) {
      renk = Colors.green;
    } else if (yuzde <= 0.6) {
      renk = Colors.orange;
    } else {
      renk = Colors.red;
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: yuzde,
                  strokeWidth: 16,
                  backgroundColor: Colors.grey.shade200,
                  color: renk,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$toplamSkor',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: renk,
                    ),
                  ),
                  Text(
                    '/ ${maxSkor.toInt()}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: renk.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            seviye,
            style: TextStyle(
              color: renk,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkorDetaylari() {
    if (envanter.tip == 'progress') return const SizedBox();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: envanter.renk),
                const SizedBox(width: 8),
                const Text(
                  'Detaylı Skorlar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...skorlar.entries.map((e) => _buildSkorSatiri(e.key, e.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildSkorSatiri(String kategori, int skor) {
    final maxSkor = envanter.tip == 'bar' ? 10 : 10; // Her kategori için max
    final yuzde = (skor / maxSkor).clamp(0.0, 1.0);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(kategori, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('$skor/$maxSkor', style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: yuzde,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: envanter.renk,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiYorumKarti() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.withOpacity(0.1),
              Colors.purple.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.psychology, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'AI Yorumu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              aiYorum,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
