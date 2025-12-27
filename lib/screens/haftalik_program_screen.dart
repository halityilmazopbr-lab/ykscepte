import 'package:flutter/material.dart';
import '../core/akademik_veri.dart';

/// 📊 HAFTALIK PROGRAM EKRANI
/// Oluşturulan programı güzel bir timeline view ile gösterir
class HaftalikProgramEkrani extends StatefulWidget {
  final List<PlanliGorev> program;
  final String baslik;
  
  const HaftalikProgramEkrani({
    super.key,
    required this.program,
    this.baslik = "Programım",
  });
  
  @override
  State<HaftalikProgramEkrani> createState() => _HaftalikProgramEkraniState();
}

class _HaftalikProgramEkraniState extends State<HaftalikProgramEkrani> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<int, Map<String, List<PlanliGorev>>> _haftaGruplu;
  late List<int> _haftalar;
  
  @override
  void initState() {
    super.initState();
    _programiGrupla();
    _tabController = TabController(length: _haftalar.length, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _programiGrupla() {
    _haftaGruplu = {};
    
    for (var gorev in widget.program) {
      _haftaGruplu.putIfAbsent(gorev.hafta, () => {});
      _haftaGruplu[gorev.hafta]!.putIfAbsent(gorev.gun, () => []);
      _haftaGruplu[gorev.hafta]![gorev.gun]!.add(gorev);
    }
    
    // Her günün görevlerini saate göre sırala
    for (var hafta in _haftaGruplu.values) {
      for (var gunGorevleri in hafta.values) {
        gunGorevleri.sort((a, b) => a.saat.compareTo(b.saat));
      }
    }
    
    _haftalar = _haftaGruplu.keys.toList()..sort();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: Text(widget.baslik, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.purple,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: _haftalar.map((h) => Tab(text: "Hafta $h")).toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _programiKaydet,
            tooltip: "Kaydet",
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: _haftalar.map((hafta) => _buildHaftaGorunumu(hafta)).toList(),
      ),
    );
  }
  
  Widget _buildHaftaGorunumu(int hafta) {
    final haftaVerisi = _haftaGruplu[hafta] ?? {};
    final gunler = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: gunler.length,
      itemBuilder: (context, index) {
        final gun = gunler[index];
        final gorevler = haftaVerisi[gun] ?? [];
        
        if (gorevler.isEmpty) return const SizedBox.shrink();
        
        return _buildGunKarti(gun, gorevler);
      },
    );
  }
  
  Widget _buildGunKarti(String gun, List<PlanliGorev> gorevler) {
    final bool isHaftaSonu = gun == "Cumartesi" || gun == "Pazar";
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gün başlığı
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isHaftaSonu ? Colors.blue.withOpacity(0.2) : Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  gun,
                  style: TextStyle(
                    color: isHaftaSonu ? Colors.blue : Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${gorevler.length} etüt",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
              const Spacer(),
              Text(
                "${gorevler.fold<int>(0, (sum, g) => sum + g.sureDakika)} dk",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
        ),
        
        // Görevler (Timeline)
        ...gorevler.asMap().entries.map((entry) {
          final index = entry.key;
          final gorev = entry.value;
          final isLast = index == gorevler.length - 1;
          
          return _buildTimelineItem(gorev, isLast);
        }),
        
         const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildTimelineItem(PlanliGorev gorev, bool isLast) {
    final renk = _getDersRengi(gorev.ders);
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol: Saat + Timeline çizgisi
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  gorev.saat,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 8),
                      color: Colors.grey.shade700,
                    ),
                  ),
              ],
            ),
          ),
          
          // Orta: Nokta
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: gorev.yapildi ? Colors.green : renk,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: gorev.yapildi 
                    ? const Icon(Icons.check, size: 8, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade700,
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 12),
          
          // Sağ: Görev kartı
          Expanded(
            child: GestureDetector(
              onTap: () => _gorevTiklandi(gorev),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: gorev.yapildi 
                      ? Colors.green.withOpacity(0.1) 
                      : const Color(0xFF21262D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(color: renk, width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ders ve süre
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          gorev.ders,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: renk.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${gorev.sureDakika} dk",
                            style: TextStyle(color: renk, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Konu
                    Text(
                      gorev.konu,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: gorev.yapildi ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Çalışma türü
                    Row(
                      children: [
                        Icon(
                          _getCalismaIkonu(gorev.calismaTuru),
                          size: 14,
                          color: Colors.blue.shade300,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          gorev.calismaTuru,
                          style: TextStyle(color: Colors.blue.shade300, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _gorevTiklandi(PlanliGorev gorev) {
    setState(() {
      gorev.yapildi = !gorev.yapildi;
    });
  }
  
  void _programiKaydet() {
    // TODO: Veritabanına kaydet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Program kaydedildi!"),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Color _getDersRengi(String ders) {
    if (ders.contains("Matematik") || ders.contains("Geometri")) return Colors.blue;
    if (ders.contains("Fizik")) return Colors.purple;
    if (ders.contains("Kimya")) return Colors.orange;
    if (ders.contains("Biyoloji")) return Colors.green;
    if (ders.contains("Türkçe") || ders.contains("Edebiyat")) return Colors.red;
    if (ders.contains("Tarih")) return Colors.brown;
    if (ders.contains("Coğrafya")) return Colors.teal;
    if (ders.contains("Deneme")) return Colors.amber;
    if (ders.contains("Genel")) return Colors.grey;
    return Colors.blueGrey;
  }
  
  IconData _getCalismaIkonu(String tur) {
    if (tur.contains("Konu")) return Icons.menu_book;
    if (tur.contains("Soru")) return Icons.edit;
    if (tur.contains("Tekrar")) return Icons.replay;
    if (tur.contains("Deneme")) return Icons.assignment;
    if (tur.contains("Video")) return Icons.play_circle;
    return Icons.school;
  }
}
