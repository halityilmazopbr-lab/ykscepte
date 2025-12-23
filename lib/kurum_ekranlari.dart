/// Kurumsal Deneme ve Kitap Listesi Ekranları
/// 
/// - Deneme listesi (sınava giriş)
/// - Kitap listesi (okumaya başla)

import 'package:flutter/material.dart';
import 'kurum_models.dart';
import 'kurum_service.dart';
import 'sinav_ekrani.dart';
import 'kitap_okuyucu.dart';

/// Deneme Sınavları Listesi
class DenemeListesiEkrani extends StatefulWidget {
  final String ogrenciId;
  final String ogrenciAdi;

  const DenemeListesiEkrani({
    super.key,
    required this.ogrenciId,
    required this.ogrenciAdi,
  });

  @override
  State<DenemeListesiEkrani> createState() => _DenemeListesiEkraniState();
}

class _DenemeListesiEkraniState extends State<DenemeListesiEkrani> {
  List<KurumDenemesi> _denemeler = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _denemeleriYukle();
  }

  Future<void> _denemeleriYukle() async {
    setState(() => _yukleniyor = true);
    final denemeler = await KurumService.getTumDenemeler();
    setState(() {
      _denemeler = denemeler;
      _yukleniyor = false;
    });
  }

  void _sinavBaslat(KurumDenemesi deneme) async {
    // Daha önce girmiş mi kontrol et
    final eskiSonuc = await KurumService.getOgrenciSonucu(widget.ogrenciId, deneme.id);
    
    if (eskiSonuc != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF21262D),
          title: const Text("Sınava Daha Önce Girdiniz", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Net: ${eskiSonuc.net.toStringAsFixed(2)}", 
                   style: const TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Doğru: ${eskiSonuc.dogru} | Yanlış: ${eskiSonuc.yanlis} | Boş: ${eskiSonuc.bos}",
                   style: const TextStyle(color: Colors.white70)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tamam"),
            ),
          ],
        ),
      );
      return;
    }

    // Sınava başla onayı
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF21262D),
          title: Text(deneme.dersAdi, style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bilgiSatir(Icons.help_outline, "${deneme.soruSayisi} Soru"),
              _bilgiSatir(Icons.timer, "${deneme.sureDk} Dakika"),
              _bilgiSatir(Icons.category, deneme.kategori),
              const SizedBox(height: 16),
              const Text(
                "⚠️ Sınav başladıktan sonra geri dönülemez!",
                style: TextStyle(color: Colors.orange, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SinavEkrani(
                      deneme: deneme,
                      ogrenciId: widget.ogrenciId,
                      ogrenciAdi: widget.ogrenciAdi,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Başla"),
            ),
          ],
        ),
      );
    }
  }

  Widget _bilgiSatir(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("📝 Deneme Sınavları", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _denemeler.isEmpty
              ? _bosEkran()
              : RefreshIndicator(
                  onRefresh: _denemeleriYukle,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _denemeler.length,
                    itemBuilder: (context, index) => _denemeKarti(_denemeler[index]),
                  ),
                ),
    );
  }

  Widget _bosEkran() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text("Henüz sınav yok", style: TextStyle(color: Colors.grey.shade500, fontSize: 18)),
          const SizedBox(height: 8),
          Text("Kurumunuz sınav yüklediğinde burada görünecek",
               style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _denemeKarti(KurumDenemesi deneme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF21262D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _sinavBaslat(deneme),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // İkon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: deneme.kategori == "TYT" ? Colors.blue.withOpacity(0.2) : Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description,
                  color: deneme.kategori == "TYT" ? Colors.blue : Colors.purple,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // İçerik
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deneme.dersAdi, 
                         style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${deneme.soruSayisi} Soru • ${deneme.sureDk} Dk",
                         style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
              ),
              // Kategori badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: deneme.kategori == "TYT" ? Colors.blue : Colors.purple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(deneme.kategori, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kitaplar Listesi
class KitapListesiEkrani extends StatefulWidget {
  const KitapListesiEkrani({super.key});

  @override
  State<KitapListesiEkrani> createState() => _KitapListesiEkraniState();
}

class _KitapListesiEkraniState extends State<KitapListesiEkrani> {
  List<KurumKitabi> _kitaplar = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _kitaplariYukle();
  }

  Future<void> _kitaplariYukle() async {
    setState(() => _yukleniyor = true);
    final kitaplar = await KurumService.getTumKitaplar();
    setState(() {
      _kitaplar = kitaplar;
      _yukleniyor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("📚 Kitaplarım", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _kitaplar.isEmpty
              ? _bosEkran()
              : RefreshIndicator(
                  onRefresh: _kitaplariYukle,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _kitaplar.length,
                    itemBuilder: (context, index) => _kitapKarti(_kitaplar[index]),
                  ),
                ),
    );
  }

  Widget _bosEkran() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text("Henüz kitap yok", style: TextStyle(color: Colors.grey.shade500, fontSize: 18)),
          const SizedBox(height: 8),
          Text("Kurumunuz kitap yüklediğinde burada görünecek",
               style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _kitapKarti(KurumKitabi kitap) {
    return Card(
      color: const Color(0xFF21262D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => KitapOkuyucuEkrani(kitap: kitap)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kapak resmi
            Expanded(
              flex: 3,
              child: kitap.kapakResmi.isNotEmpty
                  ? Image.network(
                      kitap.kapakResmi,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _varsayilanKapak(),
                    )
                  : _varsayilanKapak(),
            ),
            // Kitap adı
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Text(
                  kitap.kitapAdi,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _varsayilanKapak() {
    return Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(Icons.menu_book, size: 48, color: Colors.white54),
      ),
    );
  }
}
