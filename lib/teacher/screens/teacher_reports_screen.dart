import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Chart kütüphanesi
import '../../models.dart';
import '../models/teacher_models.dart';

class TeacherReportsScreen extends StatefulWidget {
  final Ogretmen ogretmen;

  const TeacherReportsScreen({super.key, required this.ogretmen});

  @override
  State<TeacherReportsScreen> createState() => _TeacherReportsScreenState();
}

class _TeacherReportsScreenState extends State<TeacherReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Sınıf ve Öğrenci Analizleri', style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purple,
          labelColor: Colors.purple,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Genel Başarı"),
            Tab(text: "Ödev Takibi"),
            Tab(text: "Deneme Analizi"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralSuccessTab(),
          _buildHomeworkTrackingTab(),
          _buildTrialAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralSuccessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Sınıf Bazlı Ortalama Netler (TYT)"),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 120,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.round()} Net',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12);
                        String text;
                        switch (value.toInt()) {
                          case 0: text = '12-A'; break;
                          case 1: text = '12-B'; break;
                          case 2: text = '12-C'; break;
                          case 3: text = '12-D'; break;
                          default: text = '';
                        }
                        return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, 65, Colors.blue),
                  _makeBarGroup(1, 58, Colors.purple),
                  _makeBarGroup(2, 72, Colors.green),
                  _makeBarGroup(3, 49, Colors.orange),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildSectionTitle("Son 30 Günlük Aktivite"),
          const SizedBox(height: 16),
          _buildActivityItem("📅 Toplam Ders Saati", "124 Saat", Icons.access_time, Colors.blue),
          _buildActivityItem("✅ Tamamlanan Konular", "18 Konu", Icons.check_circle, Colors.green),
          _buildActivityItem("👥 Ortalama Katılım", "%87", Icons.people, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildHomeworkTrackingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle("Ödev Teslim Oranları"),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: List.generate(3, (i) {
                final isTouched = i == _touchedIndex;
                final fontSize = isTouched ? 20.0 : 14.0;
                final radius = isTouched ? 60.0 : 50.0;
                switch (i) {
                  case 0:
                    return PieChartSectionData(
                      color: Colors.green,
                      value: 65,
                      title: '%65',
                      radius: radius,
                      titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  case 1:
                    return PieChartSectionData(
                      color: Colors.orange,
                      value: 25,
                      title: '%25',
                      radius: radius,
                      titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  case 2:
                    return PieChartSectionData(
                      color: Colors.red,
                      value: 10,
                      title: '%10',
                      radius: radius,
                      titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  default:
                    throw Error();
                }
              }),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.green, "Tamamlandı"),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.orange, "Eksik"),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.red, "Yapılmadı"),
          ],
        ),
        const SizedBox(height: 30),
        _buildSectionTitle("Son Verilen Ödevler"),
        const SizedBox(height: 10),
        _buildHomeworkItem("Türev Karma Test 1", "12-A", 0.9, DateTime.now().subtract(const Duration(days: 1))),
        _buildHomeworkItem("İntegral Giriş", "12-C", 0.4, DateTime.now().add(const Duration(days: 1))),
        _buildHomeworkItem("Logaritma Özellikleri", "12-B", 0.75, DateTime.now()),
      ],
    );
  }

  Widget _buildTrialAnalysisTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle("Son Deneme Sınavı (TYT-4) Analizi"),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF21262D),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard("En Yüksek", "112.5", Colors.green),
                  _buildStatCard("Ortalama", "68.4", Colors.blue),
                  _buildStatCard("En Düşük", "34.5", Colors.red),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.grey),
              const SizedBox(height: 10),
              _buildSubjectProgress("Türkçe (33.2 Net)", 0.83, Colors.blue),
              _buildSubjectProgress("Matematik (18.5 Net)", 0.46, Colors.orange),
              _buildSubjectProgress("Sosyal (14.1 Net)", 0.70, Colors.purple),
              _buildSubjectProgress("Fen (5.6 Net)", 0.28, Colors.red),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle("Gelişim Önerileri"),
        const SizedBox(height: 10),
        _buildSuggestionCard(
          "12-C Sınıfı Matematik",
          "Geometri netleri son 3 denemedir düşüşte. Ek etüt planlanabilir.",
          Icons.trending_down,
          Colors.red,
        ),
        _buildSuggestionCard(
          "12-A Sınıfı Türkçe",
          "Paragraf netlerinde belirgin artış var. Motivasyon konuşması yapılabilir.",
          Icons.trending_up,
          Colors.green,
        ),
      ],
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 120,
            color: Colors.white10,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildActivityItem(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12, 
          height: 12, 
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.grey.shade400)),
      ],
    );
  }

  Widget _buildHomeworkItem(String title, String className, double progress, DateTime dueDate) {
    final daysLeft = dueDate.difference(DateTime.now()).inDays;
    String dateText = daysLeft < 0 ? "Süresi Doldu" : "$daysLeft gün kaldı";
    Color dateColor = daysLeft < 0 ? Colors.red : (daysLeft < 2 ? Colors.orange : Colors.green);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(className, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(dateText, style: TextStyle(color: dateColor, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              SizedBox(
                width: 100,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade800,
                  color: progress > 0.8 ? Colors.green : Colors.blue,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      ],
    );
  }

  Widget _buildSubjectProgress(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
              Text("%${(value * 100).toInt()}", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.grey.shade800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String title, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.grey.shade300, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
