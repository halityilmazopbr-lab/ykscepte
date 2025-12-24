import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'kurum_models.dart';
import 'data.dart';
import 'models.dart';

/// Öğrenci için Kurum Duyuruları Ekranı
class KurumDuyurulariEkrani extends StatelessWidget {
  final Ogrenci ogrenci;
  
  const KurumDuyurulariEkrani({super.key, required this.ogrenci});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kurumdan Haberler'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.campaign), text: "Duyurular"),
              Tab(icon: Icon(Icons.assignment), text: "Denemeler"),
              Tab(icon: Icon(Icons.menu_book), text: "Kitaplar"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDuyurularTab(),
            _buildDenemelerTab(),
            _buildKitaplarTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDuyurularTab() {
    // Tüm kurumların duyurularını göster
    final duyurular = VeriDeposu.kurumDuyurulari;
    
    if (duyurular.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text("Henüz duyuru yok", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: duyurular.length,
      itemBuilder: (context, index) {
        final d = duyurular[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: d.renk.withAlpha(50),
              child: Icon(d.ikon, color: d.renk),
            ),
            title: Row(
              children: [
                Expanded(child: Text(d.baslik, style: const TextStyle(fontWeight: FontWeight.bold))),
                if (d.onemli) const Icon(Icons.priority_high, color: Colors.red, size: 18),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.icerik, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "${d.tarih.day}/${d.tarih.month}/${d.tarih.year}",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    if (d.pdfUrl != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.attach_file, size: 14, color: Colors.grey),
                      Text("Dosya", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ],
                ),
              ],
            ),
            onTap: () => _duyuruDetay(context, d),
          ),
        );
      },
    );
  }

  void _duyuruDetay(BuildContext context, KurumDuyuru d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(backgroundColor: d.renk.withAlpha(50), child: Icon(d.ikon, color: d.renk)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.baslik, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("${d.tarih.day}/${d.tarih.month}/${d.tarih.year}", style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  if (d.onemli) 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                      child: const Text("ÖNEMLİ", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const Divider(height: 32),
              Text(d.icerik, style: const TextStyle(fontSize: 16, height: 1.5)),
              
              // Eklenen dosya varsa
              if (d.pdfUrl != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_dosyaIkonu(d.pdfUrl!), color: Colors.blue),
                          const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  d.dosyaAdi ?? d.pdfUrl!,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _dosyaIndir(context, d.pdfUrl!, d.dosyaAdi),
                                  icon: const Icon(Icons.download),
                                  label: const Text("İNDİR"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _dosyaGoruntule(context, d.pdfUrl!),
                                  icon: const Icon(Icons.visibility),
                                  label: const Text("GÖRÜNTÜLE"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("KAPAT"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    
      IconData _dosyaIkonu(String dosyaAdi) {
        final ext = dosyaAdi.split('.').last.toLowerCase();
        if (ext.contains("pdf")) return Icons.picture_as_pdf;
        if (ext.contains("jpg") || ext.contains("png") || ext.contains("jpeg")) return Icons.image;
        if (ext.contains("doc")) return Icons.description;
        return Icons.attach_file;
      }
    
      Future<void> _dosyaIndir(BuildContext context, String url, String? dosyaAdi) async {
        if (kIsWeb) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Web sürümünde dosya yeni sekmede açılıyor...")),
           );
           // Web'de url_launcher veya html anchor kullanımı gerekir, şimdilik sadece uyarı.
           // Gerçek indirme mobilde çalışacak.
           return;
        }

        try {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("İndirilmeye başlanıyor..."), duration: Duration(seconds: 1)),
          );
          
          final dio = Dio();
          Directory? dir;
          
          if (Platform.isAndroid) {
             try {
               dir = await getExternalStorageDirectory();
             } catch (e) {
               dir = await getApplicationDocumentsDirectory();
             }
          } else {
             dir = await getApplicationDocumentsDirectory();
          }
           
          if (dir == null) {
            ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text("Depolama alanı bulunamadı!")),
            );
            return;
          }
          
          // Dosya adı belirleme
          String fileName = dosyaAdi ?? "indirilen_dosya_${DateTime.now().millisecondsSinceEpoch}";
          if (!fileName.contains('.')) {
             if (url.contains('pdf')) fileName += ".pdf";
             else if (url.contains('jpg')) fileName += ".jpg";
             else if (url.contains('png')) fileName += ".png";
             else fileName += ".pdf";
          }
           
          final savePath = "${dir.path}/$fileName";
           
          await dio.download(url, savePath, onReceiveProgress: (rec, total) {
             // İlerleme çubuğu eklenebilir
          });
           
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
               content: Text("İndirildi: $savePath"), 
               backgroundColor: Colors.green,
               duration: const Duration(seconds: 5),
            ),
          );
        } catch (e) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("İndirme başarısız: $e"), backgroundColor: Colors.red),
           );
        }
      }

  void _dosyaGoruntule(BuildContext context, String dosyaAdi) {
    // Resim dosyası ise dialog'da göster
    final ext = dosyaAdi.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
      showDialog(
        context: context,
        builder: (c) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.image, size: 100, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(dosyaAdi, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("(Demo: Gerçek dosya görüntüleme için url_launcher kullanılacak)"),
                  ],
                ),
              ),
              TextButton(onPressed: () => Navigator.pop(c), child: const Text("KAPAT")),
            ],
          ),
        ),
      );
    } else {
      // PDF veya diğer dosyalar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$dosyaAdi açılıyor... (Gerçek uygulamada PDF viewer açılır)'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Widget _buildDenemelerTab() {
    final denemeler = VeriDeposu.kurumsalDenemeler;
    
    if (denemeler.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text("Henüz deneme eklenmedi", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: denemeler.length,
      itemBuilder: (context, index) {
        final d = denemeler[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.purple,
              child: Icon(Icons.assignment, color: Colors.white),
            ),
            title: Text(d.baslik, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${d.tarih.day}/${d.tarih.month}/${d.tarih.year}"),
            trailing: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deneme PDF açılıyor...')),
                );
              },
              child: const Text("AÇ"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKitaplarTab() {
    // Demo kitap listesi
    final kitaplar = [
      {"ad": "Matematik Soru Bankası", "yayinevi": "Palme Yayınları"},
      {"ad": "Geometri Konu Anlatımı", "yayinevi": "Acil Yayınları"},
      {"ad": "TYT Paragraf 333", "yayinevi": "Bilgi Sarmal"},
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: kitaplar.length,
      itemBuilder: (context, index) {
        final k = kitaplar[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.menu_book, color: Colors.white),
            ),
            title: Text(k["ad"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(k["yayinevi"]!),
          ),
        );
      },
    );
  }
}
