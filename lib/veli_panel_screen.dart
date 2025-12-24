import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models.dart';

/// Veli Gözcü Paneli
/// Velilerin çocuklarının durumunu izleyebildiği read-only panel
class VeliPaneli extends StatefulWidget {
  final Ogrenci ogrenci;
  
  const VeliPaneli({super.key, required this.ogrenci});

  @override
  State<VeliPaneli> createState() => _VeliPaneliState();
}

class _VeliPaneliState extends State<VeliPaneli> {
  int _currentIndex = 0;
  
  // Örnek ödev verileri
  final List<Map<String, dynamic>> _odevler = [
    {'baslik': 'Türev Soru Çözümü', 'ders': 'Matematik', 'yapildi': true, 'tarih': '25 Aralık'},
    {'baslik': 'Paragraf Analizi', 'ders': 'Türkçe', 'yapildi': false, 'tarih': '26 Aralık'},
    {'baslik': 'Fizik Deney Raporu', 'ders': 'Fizik', 'yapildi': true, 'tarih': '27 Aralık'},
    {'baslik': 'Kimya Formül Tekrarı', 'ders': 'Kimya', 'yapildi': false, 'tarih': '28 Aralık'},
  ];
  
  // Örnek duyurular
  final List<Map<String, dynamic>> _duyurular = [
    {'baslik': 'Veli Toplantısı', 'icerik': 'Sayın velimiz, 28 Aralık Cumartesi saat 14:00\'te veli toplantısı yapılacaktır.', 'tarih': '24 Aralık', 'okundu': false},
    {'baslik': 'Taksit Hatırlatması', 'icerik': 'Ocak ayı taksit ödemesi için son tarih 5 Ocak\'tır.', 'tarih': '23 Aralık', 'okundu': true},
    {'baslik': 'Deneme Sınavı', 'icerik': 'Bu hafta sonu deneme sınavı yapılacaktır. Öğrencilerimizin hazır bulunması rica olunur.', 'tarih': '22 Aralık', 'okundu': true},
  ];
  
  // Haftalık soru verileri (örnek)
  final List<double> _haftalikSorular = [25, 42, 38, 55, 48, 62, 35];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // İçerik
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.orange.shade100,
              child: Text(
                widget.ogrenci.ad.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Bilgiler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.ogrenci.ad,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.ogrenci.sinif} - Veli Paneli',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Çıkış
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildKarne();
      case 2:
        return _buildOdevler();
      case 3:
        return _buildDuyurular();
      default:
        return _buildDashboard();
    }
  }

  // ============================================
  // TAB 1: DASHBOARD
  // ============================================
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bugünkü Durum',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Devamsızlık kartı
          _buildDevamsizlikKarti(),
          
          const SizedBox(height: 24),
          
          const Text(
            'Haftalık Soru Grafiği',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Haftalık grafik
          _buildHaftalikGrafik(),
          
          const SizedBox(height: 24),
          
          // Özet kartlar
          Row(
            children: [
              Expanded(child: _buildOzetKart('Toplam Puan', '${widget.ogrenci.puan}', Icons.star, Colors.amber)),
              const SizedBox(width: 12),
              Expanded(child: _buildOzetKart('Günlük Seri', '${widget.ogrenci.gunlukSeri} gün', Icons.local_fire_department, Colors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildOzetKart('Seviye', widget.ogrenci.seviye, Icons.emoji_events, widget.ogrenci.seviyeRenk)),
              const SizedBox(width: 12),
              Expanded(child: _buildOzetKart('Unvan', widget.ogrenci.unvan, Icons.military_tech, Colors.deepPurple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDevamsizlikKarti() {
    final derste = widget.ogrenci.devamsizlikDurum;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: derste ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: derste ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: derste ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              derste ? Icons.check : Icons.close,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  derste ? 'Bugün Derste ✅' : 'Yoklamada Yok ❌',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: derste ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  derste ? 'Öğrenciniz bugün derse katıldı.' : 'Öğrenciniz bugün yoklamada görünmüyor.',
                  style: TextStyle(
                    color: derste ? Colors.green.shade600 : Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHaftalikGrafik() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final gunler = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                  if (value.toInt() < gunler.length) {
                    return Text(gunler[value.toInt()], style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(_haftalikSorular.length, (i) => FlSpot(i.toDouble(), _haftalikSorular[i])),
              isCurved: true,
              color: Colors.deepOrange,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.deepOrange.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOzetKart(String baslik, String deger, IconData ikon, Color renk) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(ikon, color: renk, size: 28),
          const SizedBox(height: 8),
          Text(deger, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: renk)),
          Text(baslik, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  // ============================================
  // TAB 2: KARNE
  // ============================================
  Widget _buildKarne() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Son Deneme Sonucu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Deneme sonucu kartı
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange, Colors.orange],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TYT Denemesi', style: TextStyle(color: Colors.white, fontSize: 18)),
                    const Text('22 Aralık 2024', style: TextStyle(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNetKutu('Toplam Net', '72.5'),
                    _buildNetKutu('Sıralama', '#45'),
                    _buildNetKutu('Yüzdelik', '%85'),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Ders Bazlı Netler',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Ders netleri
          _buildDersNet('Matematik', 28, 40, Colors.blue),
          _buildDersNet('Türkçe', 32, 40, Colors.green),
          _buildDersNet('Fen Bilimleri', 12, 20, Colors.orange),
          _buildDersNet('Sosyal Bilimler', 15, 20, Colors.purple),
          
          const SizedBox(height: 24),
          
          // Gelişim göstergesi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gelişim Durumu', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                      Text('Son 3 denemede +8.5 net artış! 📈', style: TextStyle(color: Colors.green.shade600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetKutu(String baslik, String deger) {
    return Column(
      children: [
        Text(deger, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(baslik, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildDersNet(String ders, double net, double max, Color renk) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ders, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('$net / $max', style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: net / max,
              minHeight: 10,
              backgroundColor: renk.withOpacity(0.2),
              color: renk,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // TAB 3: ÖDEVLER
  // ============================================
  Widget _buildOdevler() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _odevler.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ödev Takibi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Öğretmenler tarafından verilen ödevlerin durumu',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
            ],
          );
        }
        
        final odev = _odevler[index - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: odev['yapildi'] ? Colors.green.shade50 : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  odev['yapildi'] ? Icons.check : Icons.close,
                  color: odev['yapildi'] ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(odev['baslik'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${odev['ders']} • ${odev['tarih']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: odev['yapildi'] ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  odev['yapildi'] ? 'Yapıldı' : 'Bekliyor',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================
  // TAB 4: DUYURULAR
  // ============================================
  Widget _buildDuyurular() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _duyurular.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kurumsal Duyurular',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Okul ve kurum tarafından yapılan duyurular',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
            ],
          );
        }
        
        final duyuru = _duyurular[index - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: duyuru['okundu'] ? Colors.white : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: duyuru['okundu'] ? Colors.grey.shade200 : Colors.orange,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!duyuru['okundu'])
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      duyuru['baslik'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: duyuru['okundu'] ? Colors.black87 : Colors.deepOrange,
                      ),
                    ),
                  ),
                  Text(duyuru['tarih'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                duyuru['icerik'],
                style: TextStyle(color: Colors.grey.shade700, height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Karne'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Ödevler'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Duyurular'),
        ],
      ),
    );
  }
}
