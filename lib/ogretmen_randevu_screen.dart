import 'package:flutter/material.dart';
import 'randevu_models.dart';
import 'models.dart';
import 'data.dart';

/// Öğretmen Randevu Yönetim Ekranı
/// Haftalık görünüm ile 30 dakikalık slotları yeşil/kırmızı olarak işaretleme
class OgretmenRandevuEkrani extends StatefulWidget {
  final Ogretmen ogretmen;
  
  const OgretmenRandevuEkrani({super.key, required this.ogretmen});

  @override
  State<OgretmenRandevuEkrani> createState() => _OgretmenRandevuEkraniState();
}

class _OgretmenRandevuEkraniState extends State<OgretmenRandevuEkrani> {
  DateTime _haftaBaslangic = DateTime.now();

  @override
  void initState() {
    super.initState();
    _haftaBaslangicHesapla();
    _randevulariYukle();
  }

  void _haftaBaslangicHesapla() {
    var now = DateTime.now();
    int weekday = now.weekday;
    _haftaBaslangic = now.subtract(Duration(days: weekday - 1));
    _haftaBaslangic = DateTime(_haftaBaslangic.year, _haftaBaslangic.month, _haftaBaslangic.day);
  }

  Map<int, Map<String, String>> get _randevular {
    // VeriDeposu'dan al, yoksa oluştur
    if (!VeriDeposu.ogretmenMusaitlikleri.containsKey(widget.ogretmen.id)) {
      VeriDeposu.ogretmenMusaitlikleri[widget.ogretmen.id] = {};
    }
    return VeriDeposu.ogretmenMusaitlikleri[widget.ogretmen.id]!;
  }

  void _randevulariYukle() {
    // 7 gün için boş randevu oluştur (eğer yoksa)
    for (int i = 0; i < 7; i++) {
      if (!_randevular.containsKey(i)) {
        _randevular[i] = {};
      }
      for (var saat in RandevuSaatleri.tumSaatler) {
        if (!_randevular[i]!.containsKey(saat)) {
          _randevular[i]![saat] = "bos";
        }
      }
    }
  }

  List<RandevuBildirimi> get _bildirimler {
    return VeriDeposu.randevuBildirimleri
        .where((b) => b.ogretmenId == widget.ogretmen.id)
        .toList();
  }

  void _durumDegistir(int gunIndex, String saat) {
    setState(() {
      var mevcutDurum = _randevular[gunIndex]![saat];
      if (mevcutDurum == "bos") {
        _randevular[gunIndex]![saat] = "musait";
      } else if (mevcutDurum == "musait") {
        _randevular[gunIndex]![saat] = "bos";
      }
      // "dolu" ise değiştirme (öğrenci almış)
    });
  }

  void _oncekiHafta() {
    setState(() {
      _haftaBaslangic = _haftaBaslangic.subtract(const Duration(days: 7));
    });
  }

  void _sonrakiHafta() {
    setState(() {
      _haftaBaslangic = _haftaBaslangic.add(const Duration(days: 7));
    });
  }

  String _tarihFormat(DateTime tarih) {
    return "${tarih.day}/${tarih.month}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Randevu Yönetimi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // Bildirim ikonu
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: _bildirimleriGoster,
              ),
              if (_bildirimler.where((b) => !b.okundu).isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_bildirimler.where((b) => !b.okundu).length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          // Yenile butonu
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHaftaNavigasyon(),
          _buildAciklama(),
          Expanded(child: _buildHaftalikTablo()),
          _buildKaydetButonu(),
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
          _buildLegend(Colors.grey.shade300, "Boş"),
          const SizedBox(width: 16),
          _buildLegend(Colors.green, "Müsait"),
          const SizedBox(width: 16),
          _buildLegend(Colors.red, "Dolu"),
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
                  var durum = _randevular[gunIndex]?[saat] ?? "bos";
                  Color renk;
                  switch (durum) {
                    case 'musait': renk = Colors.green; break;
                    case 'dolu': renk = Colors.red; break;
                    default: renk = Colors.grey.shade300;
                  }
                  return DataCell(
                    GestureDetector(
                      onTap: durum == 'dolu' ? null : () => _durumDegistir(gunIndex, saat),
                      child: Container(
                        width: 40,
                        height: 28,
                        decoration: BoxDecoration(
                          color: renk,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: durum == 'dolu' 
                          ? const Icon(Icons.person, color: Colors.white, size: 16)
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

  Widget _buildKaydetButonu() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _kaydet,
          icon: const Icon(Icons.save),
          label: const Text('MÜSAİTLİKLERİ KAYDET'),
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

  void _kaydet() {
    VeriDeposu.kaydet();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Müsaitlikler kaydedildi!'), backgroundColor: Colors.green),
    );
  }

  void _bildirimleriGoster() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Randevu Bildirimleri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (_bildirimler.isEmpty)
                const Center(child: Text('Yeni bildirim yok'))
              else
                ...List.generate(_bildirimler.length, (i) {
                  var b = _bildirimler[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: b.okundu ? Colors.grey : Colors.teal,
                      child: const Icon(Icons.calendar_today, color: Colors.white),
                    ),
                    title: Text('${b.ogrenciAd} randevu aldı'),
                    subtitle: Text('${b.randevuTarihi.day}/${b.randevuTarihi.month} - ${b.saat}'),
                    trailing: !b.okundu 
                      ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))
                      : null,
                    onTap: () {
                      setState(() => VeriDeposu.randevuBildirimleri[VeriDeposu.randevuBildirimleri.indexOf(b)].okundu = true);
                      Navigator.pop(context);
                    },
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
