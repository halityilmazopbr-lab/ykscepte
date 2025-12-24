import 'package:flutter/material.dart';
import 'randevu_models.dart';
import 'models.dart';
import 'data.dart';

/// Öğrenci Randevu Alma Ekranı
/// Öğretmen seçimi ve müsait slotları görüntüleme
class OgrenciRandevuEkrani extends StatefulWidget {
  final Ogrenci ogrenci;
  
  const OgrenciRandevuEkrani({super.key, required this.ogrenci});

  @override
  State<OgrenciRandevuEkrani> createState() => _OgrenciRandevuEkraniState();
}

class _OgrenciRandevuEkraniState extends State<OgrenciRandevuEkrani> {
  DateTime _haftaBaslangic = DateTime.now();
  String? _secilenBrans;
  Ogretmen? _secilenOgretmen;
  
  // Seçilen slotlar
  Set<String> _secilenSlotlar = {}; // "gunIndex_saat" formatında
  
  // Haftalık max kota
  static const int maxRandevuHaftalik = 2;

  @override
  void initState() {
    super.initState();
    _haftaBaslangicHesapla();
  }

  void _haftaBaslangicHesapla() {
    var now = DateTime.now();
    int weekday = now.weekday;
    _haftaBaslangic = now.subtract(Duration(days: weekday - 1));
    _haftaBaslangic = DateTime(_haftaBaslangic.year, _haftaBaslangic.month, _haftaBaslangic.day);
  }

  Map<int, Map<String, String>> get _ogretmenMusaitlikleri {
    if (_secilenOgretmen == null) return {};
    return VeriDeposu.ogretmenMusaitlikleri[_secilenOgretmen!.id] ?? {};
  }

  void _oncekiHafta() {
    setState(() {
      _haftaBaslangic = _haftaBaslangic.subtract(const Duration(days: 7));
      _secilenSlotlar.clear();
    });
  }

  void _sonrakiHafta() {
    setState(() {
      _haftaBaslangic = _haftaBaslangic.add(const Duration(days: 7));
      _secilenSlotlar.clear();
    });
  }

  String _tarihFormat(DateTime tarih) {
    return "${tarih.day}/${tarih.month}";
  }

  int _buHaftaAlinanRandevuSayisi() {
    // VeriDeposu'dan bu hafta alınan randevuları say
    return VeriDeposu.randevuBildirimleri
        .where((b) => 
            b.ogrenciId == widget.ogrenci.id && 
            b.brans == _secilenBrans)
        .length;
  }

  void _slotSec(int gunIndex, String saat) {
    var key = "${gunIndex}_$saat";
    var durum = _ogretmenMusaitlikleri[gunIndex]?[saat];
    
    if (durum != "musait") return; // Sadece müsait slotlar seçilebilir
    
    setState(() {
      if (_secilenSlotlar.contains(key)) {
        _secilenSlotlar.remove(key);
      } else {
        // Kota kontrolü
        int mevcutRandevu = _buHaftaAlinanRandevuSayisi();
        if (mevcutRandevu + _secilenSlotlar.length >= maxRandevuHaftalik) {
          _kotaUyarisiGoster();
          return;
        }
        _secilenSlotlar.add(key);
      }
    });
  }

  void _kotaUyarisiGoster() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Kota Uyarısı'),
          ],
        ),
        content: Text(
          'Bu hafta ${_secilenBrans ?? "bu ders"}ten zaten $maxRandevuHaftalik randevu aldınız. '
          'Daha fazla randevu alamazsınız.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tamam')),
        ],
      ),
    );
  }

  void _randevuOlustur() {
    if (_secilenSlotlar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir saat seçin')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Randevu Onayı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Öğretmen: ${_secilenOgretmen?.ad}'),
            Text('Branş: $_secilenBrans'),
            const SizedBox(height: 8),
            const Text('Seçilen saatler:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._secilenSlotlar.map((slot) {
              var parts = slot.split('_');
              var gunIndex = int.parse(parts[0]);
              var saat = parts[1];
              var tarih = _haftaBaslangic.add(Duration(days: gunIndex));
              return Text('• ${RandevuSaatleri.gunler[gunIndex]} ${_tarihFormat(tarih)} - $saat');
            }),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _randevuyuKaydet();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Onayla', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _randevuyuKaydet() {
    // Seçilen slotları dolu yap ve bildirim oluştur
    for (var slot in _secilenSlotlar) {
      var parts = slot.split('_');
      var gunIndex = int.parse(parts[0]);
      var saat = parts[1];
      
      // Slot'u dolu yap
      if (VeriDeposu.ogretmenMusaitlikleri[_secilenOgretmen!.id] != null &&
          VeriDeposu.ogretmenMusaitlikleri[_secilenOgretmen!.id]![gunIndex] != null) {
        VeriDeposu.ogretmenMusaitlikleri[_secilenOgretmen!.id]![gunIndex]![saat] = "dolu";
      }
      
      // Bildirim oluştur
      var bildirim = RandevuBildirimi(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ogretmenId: _secilenOgretmen!.id,
        ogrenciId: widget.ogrenci.id,
        ogrenciAd: widget.ogrenci.ad,
        randevuTarihi: _haftaBaslangic.add(Duration(days: gunIndex)),
        saat: saat,
        brans: _secilenBrans ?? _secilenOgretmen!.brans,
        olusturmaTarihi: DateTime.now(),
      );
      VeriDeposu.randevuBildirimleri.add(bildirim);
    }
    
    VeriDeposu.kaydet();
    
    setState(() {
      _secilenSlotlar.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Randevu oluşturuldu! ${_secilenOgretmen?.ad} bilgilendirildi.'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Birebir Randevu Al'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSecimAlani(),
          
          if (_secilenOgretmen != null) ...[
            _buildHaftaNavigasyon(),
            _buildAciklama(),
            Expanded(child: _buildHaftalikTablo()),
            if (_secilenSlotlar.isNotEmpty) _buildRandevuButonu(),
          ] else
            const Expanded(
              child: Center(
                child: Text('Lütfen branş ve öğretmen seçin', style: TextStyle(color: Colors.grey)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecimAlani() {
    var branslar = VeriDeposu.ogretmenler.map((o) => o.brans).toSet().toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _secilenBrans,
            decoration: const InputDecoration(
              labelText: 'Branş Seçin',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.school),
            ),
            items: branslar.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            onChanged: (val) {
              setState(() {
                _secilenBrans = val;
                _secilenOgretmen = null;
              });
            },
          ),
          const SizedBox(height: 12),
          
          if (_secilenBrans != null)
            DropdownButtonFormField<Ogretmen>(
              value: _secilenOgretmen,
              decoration: const InputDecoration(
                labelText: 'Öğretmen Seçin',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: VeriDeposu.ogretmenler
                  .where((o) => o.brans == _secilenBrans)
                  .map((o) => DropdownMenuItem(value: o, child: Text(o.ad)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _secilenOgretmen = val;
                  _secilenSlotlar.clear();
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHaftaNavigasyon() {
    var haftaSonu = _haftaBaslangic.add(const Duration(days: 6));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.teal.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: _oncekiHafta, icon: const Icon(Icons.chevron_left)),
          Text('${_tarihFormat(_haftaBaslangic)} - ${_tarihFormat(haftaSonu)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(onPressed: _sonrakiHafta, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }

  Widget _buildAciklama() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegend(Colors.green, "Müsait"),
          const SizedBox(width: 16),
          _buildLegend(Colors.red, "Dolu"),
          const SizedBox(width: 16),
          _buildLegend(Colors.blue, "Seçilen"),
        ],
      ),
    );
  }

  Widget _buildLegend(Color renk, String metin) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: renk, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 4),
        Text(metin, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildHaftalikTablo() {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 8,
          headingRowHeight: 48,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 36,
          columns: [
            const DataColumn(label: Text('Saat', style: TextStyle(fontWeight: FontWeight.bold))),
            ...List.generate(7, (i) {
              var tarih = _haftaBaslangic.add(Duration(days: i));
              return DataColumn(
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(RandevuSaatleri.gunler[i].substring(0, 3), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(_tarihFormat(tarih), style: const TextStyle(fontSize: 10)),
                  ],
                ),
              );
            }),
          ],
          rows: RandevuSaatleri.tumSaatler.map((saat) {
            return DataRow(
              cells: [
                DataCell(Text(saat, style: const TextStyle(fontSize: 12))),
                ...List.generate(7, (gunIndex) {
                  var durum = _ogretmenMusaitlikleri[gunIndex]?[saat] ?? "bos";
                  var key = "${gunIndex}_$saat";
                  var secili = _secilenSlotlar.contains(key);
                  
                  Color renk;
                  if (secili) {
                    renk = Colors.blue;
                  } else {
                    switch (durum) {
                      case 'musait': renk = Colors.green; break;
                      case 'dolu': renk = Colors.red; break;
                      default: renk = Colors.grey.shade300;
                    }
                  }
                  
                  return DataCell(
                    GestureDetector(
                      onTap: () => _slotSec(gunIndex, saat),
                      child: Container(
                        width: 40,
                        height: 28,
                        decoration: BoxDecoration(
                          color: renk,
                          borderRadius: BorderRadius.circular(4),
                          border: secili ? Border.all(color: Colors.blue.shade800, width: 2) : null,
                        ),
                        child: secili 
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : durum == 'dolu'
                            ? const Icon(Icons.person, color: Colors.white, size: 14)
                            : null,
                      ),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRandevuButonu() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _randevuOlustur,
          icon: const Icon(Icons.calendar_today),
          label: Text('RANDEVU OLUŞTUR (${_secilenSlotlar.length} saat)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
