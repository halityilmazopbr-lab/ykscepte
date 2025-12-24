import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'kurum_models.dart';
import 'data.dart';
import 'models.dart';
import 'excel_import_service.dart';

/// Kurum Yönetici Paneli - 6 Sekmeli
class KurumPanelEkrani extends StatefulWidget {
  final Kurum kurum;
  
  const KurumPanelEkrani({super.key, required this.kurum});

  @override
  State<KurumPanelEkrani> createState() => _KurumPanelEkraniState();
}

class _KurumPanelEkraniState extends State<KurumPanelEkrani> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Kurum _kurum;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _kurum = widget.kurum;
  }

  void _cikisYap() async {
    await VeriDeposu.cikisYap();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(_kurum.ad),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _cikisYap),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: "Dashboard"),
            Tab(icon: Icon(Icons.qr_code_2), text: "QR"),
            Tab(icon: Icon(Icons.people), text: "Öğrenciler"),
            Tab(icon: Icon(Icons.assignment), text: "Denemeler"),
            Tab(icon: Icon(Icons.campaign), text: "Duyurular"),
            Tab(icon: Icon(Icons.settings), text: "Ayarlar"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildQrTab(),
          _buildOgrencilerTab(),
          _buildDenemelerTab(),
          _buildDuyurularTab(),
          _buildAyarlarTab(),
        ],
      ),
    );
  }

  // =================== 1. DASHBOARD ===================
  Widget _buildDashboardTab() {
    final bugun = DateTime.now();
    final bugunkuYoklamalar = VeriDeposu.yoklamaKayitlari
        .where((y) => y.kurumId == _kurum.id && 
               y.girisZamani.year == bugun.year &&
               y.girisZamani.month == bugun.month &&
               y.girisZamani.day == bugun.day)
        .toList();
    
    final dersteOlanlar = bugunkuYoklamalar.where((y) => y.derste).toList();
    final cikisYapanlar = bugunkuYoklamalar.where((y) => !y.derste).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Özet Kartları
          Row(
            children: [
              Expanded(child: _buildStatCard("Şu An Derste", "${dersteOlanlar.length}", Colors.green, Icons.person)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard("Bugün Gelen", "${bugunkuYoklamalar.length}", Colors.blue, Icons.login)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard("Çıkış Yapan", "${cikisYapanlar.length}", Colors.orange, Icons.logout)),
            ],
          ),
          const SizedBox(height: 24),
          
          // Derste Olanlar Listesi
          const Text("🟢 Şu An Derste", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (dersteOlanlar.isEmpty)
            const Card(child: ListTile(leading: Icon(Icons.info), title: Text("Şu an derste öğrenci yok")))
          else
            ...dersteOlanlar.map((y) => Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.green, child: Text(y.ogrenciAd.substring(0, 1))),
                title: Text(y.ogrenciAd),
                subtitle: Text("Giriş: ${y.girisZamani.hour}:${y.girisZamani.minute.toString().padLeft(2, '0')} • ${y.sureDakika} dk"),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  // =================== 2. QR YÖNETIMI ===================
  Widget _buildQrTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("📱 Yoklama QR Kodu", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Bu QR'ı yazdırıp dershane girişine asın.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: QrImageView(
                      data: _kurum.qrKodu ?? _kurum.generateQrData(),
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_kurum.ad, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Yarıçap: ${_kurum.yaricapMetre}m", style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _kurum.qrKodu = _kurum.generateQrData();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('QR yenilendi!'), backgroundColor: Colors.green),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text("YENİLE"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Yazdırma özelliği yakında...')),
                            );
                          },
                          icon: const Icon(Icons.print),
                          label: const Text("YAZDIR"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(child: Text("Bu QR konum kilitlidir! GPS kontrolü yapılır.", style: TextStyle(color: Colors.orange))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =================== 3. ÖĞRENCİLER ===================
  Widget _buildOgrencilerTab() {
    // TODO: Kuruma atanmış öğrencileri çek
    final kurumOgrencileri = VeriDeposu.ogrenciler;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.indigo,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Toplam: ${kurumOgrencileri.length} Öğrenci", style: const TextStyle(color: Colors.white)),
              ElevatedButton.icon(
                onPressed: () => _ogrenciEkleDialog(),
                icon: const Icon(Icons.add),
                label: const Text("EKLE"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.indigo),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: kurumOgrencileri.length,
            itemBuilder: (c, i) {
              final o = kurumOgrencileri[i];
              final sonYoklama = VeriDeposu.yoklamaKayitlari
                  .where((y) => y.ogrenciId == o.id)
                  .lastOrNull;
              
              return ListTile(
                leading: CircleAvatar(child: Text(o.ad.substring(0, 1))),
                title: Text(o.ad),
                subtitle: Text(o.sinif),
                trailing: sonYoklama?.derste == true 
                  ? const Chip(label: Text("DERSTE", style: TextStyle(fontSize: 10)), backgroundColor: Colors.green)
                  : const Chip(label: Text("YOK", style: TextStyle(fontSize: 10)), backgroundColor: Colors.grey),
              );
            },
          ),
        ),
      ],
    );
  }

  void _ogrenciEkleDialog() {
    final adC = TextEditingController();
    final sinifC = TextEditingController();
    
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Öğrenci Ekle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: adC, decoration: const InputDecoration(labelText: "Ad Soyad")),
            TextField(controller: sinifC, decoration: const InputDecoration(labelText: "Sınıf")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () {
              VeriDeposu.ogrenciEkle(adC.text, sinifC.text);
              Navigator.pop(c);
              setState(() {});
            },
            child: const Text("EKLE"),
          ),
        ],
      ),
    );
  }

  // =================== 4. DENEMELER ===================
  Widget _buildDenemelerTab() {
    final denemeler = VeriDeposu.kurumsalDenemeler;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.purple,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${denemeler.length} Deneme", style: const TextStyle(color: Colors.white)),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _excelSonucYukleDialog(),
                    icon: const Icon(Icons.upload_file),
                    label: const Text("SONUÇ YÜKLE"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _denemeEkleDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text("YENİ DENEME"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.purple),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: denemeler.isEmpty
            ? const Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text("Henüz deneme eklenmedi"),
                  SizedBox(height: 8),
                  Text("Excel ile sonuç yükleyebilirsiniz", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ))
            : ListView.builder(
                itemCount: denemeler.length,
                itemBuilder: (c, i) {
                  final d = denemeler[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.assignment, color: Colors.purple),
                      title: Text(d.baslik),
                      subtitle: Text("${d.tarih.day}/${d.tarih.month}/${d.tarih.year}"),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  void _denemeEkleDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deneme ekleme özelliği yakında...')),
    );
  }

  /// Excel sonuç yükleme dialog
  void _excelSonucYukleDialog() {
    String denemeTuru = "TYT";
    String denemeAdi = "";
    EslestirmeKriteri kriter = EslestirmeKriteri.ogrenciNo;
    bool yukleniyor = false;
    ExcelImportSonuc? sonuclar;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => StatefulBuilder(
        builder: (context, setD) => AlertDialog(
          title: const Text("📊 Excel Sonuç Yükle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deneme adı
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Deneme Adı",
                    hintText: "Örn: Türkiye Geneli TYT-1",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => denemeAdi = v,
                ),
                const SizedBox(height: 16),
                
                // Deneme türü
                DropdownButtonFormField<String>(
                  value: denemeTuru,
                  decoration: const InputDecoration(
                    labelText: "Deneme Türü",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "TYT", child: Text("TYT")),
                    DropdownMenuItem(value: "AYT Sayısal", child: Text("AYT Sayısal")),
                    DropdownMenuItem(value: "AYT Eşit Ağırlık", child: Text("AYT Eşit Ağırlık")),
                    DropdownMenuItem(value: "AYT Sözel", child: Text("AYT Sözel")),
                  ],
                  onChanged: (v) => setD(() => denemeTuru = v!),
                ),
                const SizedBox(height: 16),
                
                // Eşleştirme kriteri
                const Text("Öğrenci Eşleştirme", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<EslestirmeKriteri>(
                        value: EslestirmeKriteri.ogrenciNo,
                        groupValue: kriter,
                        title: const Text("Öğrenci Numarası ile"),
                        subtitle: const Text("Excel'deki 1. sütun = Öğrenci No"),
                        onChanged: (v) => setD(() => kriter = v!),
                      ),
                      RadioListTile<EslestirmeKriteri>(
                        value: EslestirmeKriteri.ogrenciAd,
                        groupValue: kriter,
                        title: const Text("Öğrenci Adı ile"),
                        subtitle: const Text("Excel'deki 2. sütun = Öğrenci Adı"),
                        onChanged: (v) => setD(() => kriter = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Excel formatı bilgisi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📋 Excel Format:", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text("1. sütun: Öğrenci No", style: TextStyle(fontSize: 12)),
                      Text("2. sütun: Öğrenci Adı", style: TextStyle(fontSize: 12)),
                      Text("3-4. sütun: Türkçe D/Y", style: TextStyle(fontSize: 12)),
                      Text("5-6. sütun: Mat D/Y", style: TextStyle(fontSize: 12)),
                      Text("... (diğer dersler)", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                
                // Sonuç gösterimi
                if (sonuclar != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sonuclar!.tamamenBasarili ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: sonuclar!.tamamenBasarili ? Colors.green : Colors.orange),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("✅ Başarılı: ${sonuclar!.basarili}", style: const TextStyle(color: Colors.green)),
                        if (sonuclar!.basarisiz > 0) ...[
                          Text("❌ Başarısız: ${sonuclar!.basarisiz}", style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 8),
                          ...sonuclar!.hatalar.take(5).map((h) => Text("• $h", style: const TextStyle(fontSize: 11, color: Colors.red))),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: yukleniyor ? null : () => Navigator.pop(c),
              child: const Text("İptal"),
            ),
            if (sonuclar != null && sonuclar!.basarili > 0)
              ElevatedButton(
                onPressed: () {
                  ExcelImportService.sonuclariKaydet(sonuclar!.eklenenSonuclar);
                  Navigator.pop(c);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${sonuclar!.basarili} sonuç kaydedildi!'), backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("KAYDET"),
              )
            else
              ElevatedButton(
                onPressed: yukleniyor ? null : () async {
                  if (denemeAdi.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Deneme adı giriniz'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['xlsx', 'xls'],
                    withData: true,
                  );
                  
                  if (result != null && result.files.single.bytes != null) {
                    setD(() => yukleniyor = true);
                    
                    final importResult = ExcelImportService.parseExcel(
                      bytes: result.files.single.bytes!,
                      denemeTuru: denemeTuru,
                      denemeAdi: denemeAdi,
                      kriter: kriter,
                      kurumId: _kurum.id,
                    );
                    
                    setD(() {
                      yukleniyor = false;
                      sonuclar = importResult;
                    });
                  }
                },
                child: yukleniyor
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("EXCEL SEÇ"),
              ),
          ],
        ),
      ),
    );
  }

  // =================== 5. DUYURULAR ===================
  Widget _buildDuyurularTab() {
    final duyurular = VeriDeposu.kurumDuyurulari.where((d) => d.kurumId == _kurum.id).toList();
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.teal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${duyurular.length} Duyuru", style: const TextStyle(color: Colors.white)),
              ElevatedButton.icon(
                onPressed: () => _duyuruEkleDialog(),
                icon: const Icon(Icons.add),
                label: const Text("YENİ DUYURU"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.teal),
              ),
            ],
          ),
        ),
        Expanded(
          child: duyurular.isEmpty
            ? const Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.campaign, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text("Henüz duyuru yok"),
                ],
              ))
            : ListView.builder(
                itemCount: duyurular.length,
                itemBuilder: (c, i) {
                  final d = duyurular[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(d.ikon, color: d.renk),
                      title: Text(d.baslik),
                      subtitle: Text("${d.tarih.day}/${d.tarih.month} • ${d.tip}"),
                      trailing: d.onemli ? const Icon(Icons.priority_high, color: Colors.red) : null,
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  void _duyuruEkleDialog() {
    final baslikC = TextEditingController();
    final icerikC = TextEditingController();
    String tip = "mesaj";
    String? dosyaAdi;
    String? yuklenenDosyaUrl;
    bool onemli = false;
    bool yukleniyor = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => StatefulBuilder(
        builder: (context, setD) => AlertDialog(
          title: const Text("Yeni Duyuru"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: baslikC, decoration: const InputDecoration(labelText: "Başlık", border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                  controller: icerikC, 
                  decoration: const InputDecoration(labelText: "İçerik", border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tip,
                  decoration: const InputDecoration(labelText: "Tip", border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: "mesaj", child: Text("📝 Mesaj")),
                    DropdownMenuItem(value: "etut", child: Text("📅 Etüt Programı")),
                    DropdownMenuItem(value: "deneme", child: Text("📊 Deneme Sonuçları")),
                    DropdownMenuItem(value: "pdf", child: Text("📄 PDF Duyuru")),
                  ],
                  onChanged: (v) => setD(() => tip = v!),
                ),
                const SizedBox(height: 16),
                
                // Dosya ekleme
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: yukleniyor ? Colors.grey.shade100 : null,
                  ),
                  child: Row(
                    children: [
                      if (yukleniyor)
                        const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      else
                        const Icon(Icons.attach_file, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          yukleniyor ? "Yükleniyor..." : (dosyaAdi ?? "Dosya eklenmedi"),
                          style: TextStyle(color: dosyaAdi != null ? Colors.black : Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (dosyaAdi == null && !yukleniyor)
                        TextButton(
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
                            );
                            if (result != null) {
                              final file = result.files.single;
                              
                              setD(() => yukleniyor = true);
                              
                              try {
                                final storageRef = FirebaseStorage.instance.ref();
                                final fileRef = storageRef.child("kurum_dosyalari/${_kurum.id}/${DateTime.now().millisecondsSinceEpoch}_${file.name}");
                                
                                if (kIsWeb) {
                                  if (file.bytes != null) await fileRef.putData(file.bytes!);
                                } else {
                                  if (file.path != null) await fileRef.putFile(File(file.path!));
                                }
                                
                                final url = await fileRef.getDownloadURL();
                                
                                setD(() {
                                  dosyaAdi = file.name;
                                  yuklenenDosyaUrl = url;
                                  yukleniyor = false;
                                });
                              } catch (e) {
                                setD(() => yukleniyor = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Yükleme hatası: $e')),
                                );
                              }
                            }
                          },
                          child: const Text("DOSYA SEÇ"),
                        )
                      else if (!yukleniyor)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => setD(() {
                            dosyaAdi = null;
                            yuklenenDosyaUrl = null;
                          }),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: onemli,
                  onChanged: (v) => setD(() => onemli = v!),
                  title: const Text("Önemli Duyuru"),
                  subtitle: const Text("Kırmızı işaretli gösterilir"),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: yukleniyor ? null : () => Navigator.pop(c), 
              child: const Text("İptal")
            ),
            ElevatedButton(
              onPressed: yukleniyor ? null : () {
                VeriDeposu.kurumDuyurulari.add(KurumDuyuru(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  kurumId: _kurum.id,
                  baslik: baslikC.text,
                  icerik: icerikC.text,
                  tip: tip,
                  pdfUrl: yuklenenDosyaUrl, // URL buraya
                  dosyaAdi: dosyaAdi, // Dosya adı buraya
                  onemli: onemli,
                ));
                Navigator.pop(c);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Duyuru oluşturuldu!'), backgroundColor: Colors.green),
                );
              },
              child: const Text("YAYINLA"),
            ),
          ],
        ),
      ),
    );
  }

  // =================== 6. AYARLAR ===================
  Widget _buildAyarlarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("📍 Kurum Konum Ayarları", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.business),
                    title: const Text("Kurum Adı"),
                    subtitle: Text(_kurum.ad),
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text("Adres"),
                    subtitle: Text(_kurum.adres),
                  ),
                  ListTile(
                    leading: const Icon(Icons.my_location),
                    title: const Text("GPS Koordinatları"),
                    subtitle: Text("${_kurum.latitude}, ${_kurum.longitude}"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.radar),
                    title: const Text("Tolerans Yarıçapı"),
                    subtitle: Text("${_kurum.yaricapMetre} metre"),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _ayarDuzenleDialog,
              icon: const Icon(Icons.edit),
              label: const Text("AYARLARI DÜZENLE"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _ayarDuzenleDialog() {
    final adC = TextEditingController(text: _kurum.ad);
    final adresC = TextEditingController(text: _kurum.adres);
    final latC = TextEditingController(text: _kurum.latitude.toString());
    final lonC = TextEditingController(text: _kurum.longitude.toString());
    final yaricapC = TextEditingController(text: _kurum.yaricapMetre.toString());
    
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Kurum Ayarlarını Düzenle"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: adC, 
                decoration: const InputDecoration(labelText: "Kurum Adı", prefixIcon: Icon(Icons.business), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adresC, 
                decoration: const InputDecoration(labelText: "Adres", prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: latC,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Enlem", border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: lonC,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Boylam", border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yaricapC, 
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Tolerans Yarıçapı (metre)", prefixIcon: Icon(Icons.radar), border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _kurum.ad = adC.text;
                _kurum.adres = adresC.text;
                _kurum.latitude = double.tryParse(latC.text) ?? _kurum.latitude;
                _kurum.longitude = double.tryParse(lonC.text) ?? _kurum.longitude;
                _kurum.yaricapMetre = int.tryParse(yaricapC.text) ?? _kurum.yaricapMetre;
                _kurum.qrKodu = _kurum.generateQrData(); // QR'u da güncelle
              });
              VeriDeposu.kaydet();
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ayarlar kaydedildi!'), backgroundColor: Colors.green),
              );
            },
            child: const Text("KAYDET"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
