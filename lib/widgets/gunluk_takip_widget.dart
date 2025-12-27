import 'package:flutter/material.dart';
import '../core/akademik_veri.dart';

/// 📅 GÜNLÜK TAKİP WİDGET'I
/// Ana sayfaya konulacak, sadece bugünü gösteren etkileşimli widget
class GunlukTakipWidget extends StatefulWidget {
  final List<PlanliGorev> tumProgram;
  final Function(PlanliGorev)? onGorevTamamlandi;
  
  const GunlukTakipWidget({
    super.key,
    required this.tumProgram,
    this.onGorevTamamlandi,
  });
  
  @override
  State<GunlukTakipWidget> createState() => _GunlukTakipWidgetState();
}

class _GunlukTakipWidgetState extends State<GunlukTakipWidget> {
  late List<PlanliGorev> _bugununGorevleri;
  
  // Gün isimleri
  static const List<String> _gunIsimleri = [
    "", "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"
  ];
  
  @override
  void initState() {
    super.initState();
    _bugununGorevleriniFiltrele();
  }
  
  @override
  void didUpdateWidget(GunlukTakipWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tumProgram != widget.tumProgram) {
      _bugununGorevleriniFiltrele();
    }
  }
  
  void _bugununGorevleriniFiltrele() {
    // Bugünün gün ismini al
    final now = DateTime.now();
    final gunIsmi = _gunIsimleri[now.weekday];
    
    // Bugünün haftasını hesapla (program başlangıcından itibaren)
    // Şimdilik basit: ilk haftanın görevlerini göster
    final buHafta = 1; // Gerçek uygulamada hesaplanmalı
    
    _bugununGorevleri = widget.tumProgram
        .where((g) => g.gun == gunIsmi && g.hafta == buHafta)
        .toList()
      ..sort((a, b) => a.saat.compareTo(b.saat));
  }
  
  double get _tamamlanmaOrani {
    if (_bugununGorevleri.isEmpty) return 0;
    return _bugununGorevleri.where((g) => g.yapildi).length / _bugununGorevleri.length;
  }
  
  int get _tamamlananSayi => _bugununGorevleri.where((g) => g.yapildi).length;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.purple.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve ilerleme
          _buildHeader(),
          
          const SizedBox(height: 16),
          
          // İlerleme çubuğu
          _buildProgressBar(),
          
          const SizedBox(height: 16),
          
          // Görev listesi
          if (_bugununGorevleri.isEmpty)
            _buildBosGun()
          else
            _buildGorevListesi(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    final now = DateTime.now();
    final gunIsmi = _gunIsimleri[now.weekday];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bugünün Hedefi",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              gunIsmi,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _tamamlanmaOrani == 1.0 ? Colors.green : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                _tamamlanmaOrani == 1.0 ? Icons.check_circle : Icons.pending,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                "$_tamamlananSayi/${_bugununGorevleri.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildProgressBar() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: _tamamlanmaOrani,
            minHeight: 10,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              _tamamlanmaOrani == 1.0 ? Colors.green : Colors.amber,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "%${(_tamamlanmaOrani * 100).toInt()} tamamlandı",
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
            if (_tamamlanmaOrani == 1.0)
              const Text(
                "🎉 Harika!",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildBosGun() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("🏖️", style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              "Bugün boşsun!",
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGorevListesi() {
    // Sadece ilk 5 görevi göster (widget çok uzun olmasın)
    final gorunecekler = _bugununGorevleri.take(5).toList();
    final kalanSayi = _bugununGorevleri.length - 5;
    
    return Column(
      children: [
        ...gorunecekler.map((gorev) => _buildGorevItem(gorev)),
        if (kalanSayi > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "+ $kalanSayi görev daha",
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
          ),
      ],
    );
  }
  
  Widget _buildGorevItem(PlanliGorev gorev) {
    return GestureDetector(
      onTap: () {
        setState(() {
          gorev.yapildi = !gorev.yapildi;
        });
        widget.onGorevTamamlandi?.call(gorev);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: gorev.yapildi 
              ? Colors.green.withOpacity(0.3) 
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: gorev.yapildi ? Colors.green : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: gorev.yapildi ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: gorev.yapildi ? Colors.green : Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: gorev.yapildi 
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            
            // Saat
            SizedBox(
              width: 50,
              child: Text(
                gorev.saat,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Konu ve ders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gorev.konu,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: gorev.yapildi ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${gorev.ders} • ${gorev.calismaTuru}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            
            // Süre
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getDersRengi(gorev.ders).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${gorev.sureDakika} dk",
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ),
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
    return Colors.grey;
  }
}
