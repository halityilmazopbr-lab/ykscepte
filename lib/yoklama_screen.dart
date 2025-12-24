import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'kurum_models.dart';
import 'models.dart';
import 'data.dart';

/// Öğrenci Yoklama Ekranı
/// QR okutma ve GPS doğrulama ile yoklama
class YoklamaEkrani extends StatefulWidget {
  final Ogrenci ogrenci;
  
  const YoklamaEkrani({super.key, required this.ogrenci});

  @override
  State<YoklamaEkrani> createState() => _YoklamaEkraniState();
}

class _YoklamaEkraniState extends State<YoklamaEkrani> {
  bool _taramada = false;
  bool _isleniyor = false;
  YoklamaDurum? _sonuc;
  String? _mesaj;
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _yoklamaYap() async {
    // Web'de kamera desteği sınırlı, demo mod
    if (kIsWeb) {
      await _demoYoklama();
      return;
    }
    
    setState(() {
      _taramada = true;
      _sonuc = null;
      _mesaj = null;
    });
    
    _scannerController = MobileScannerController();
  }

  Future<void> _demoYoklama() async {
    // Web için demo yoklama
    setState(() {
      _isleniyor = true;
      _sonuc = null;
    });
    
    await Future.delayed(const Duration(seconds: 1));
    
    // Demo: Kurum varsa başarılı say
    if (VeriDeposu.aktifKurum != null) {
      final yoklama = YoklamaKaydi(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ogrenciId: widget.ogrenci.id,
        ogrenciAd: widget.ogrenci.ad,
        kurumId: VeriDeposu.aktifKurum!.id,
        girisZamani: DateTime.now(),
        gecerli: true,
        mesafe: 45.0,
      );
      
      VeriDeposu.yoklamaKayitlari.add(yoklama);
      VeriDeposu.kaydet();
      
      setState(() {
        _isleniyor = false;
        _sonuc = YoklamaDurum.basarili;
        _mesaj = "Demo yoklama kaydedildi!";
      });
    } else {
      setState(() {
        _isleniyor = false;
        _sonuc = YoklamaDurum.qrGecersiz;
        _mesaj = "Kurum tanımlanmamış. Önce yönetici panelden kurum ekleyin.";
      });
    }
  }

  Future<void> _qrTarandi(String qrData) async {
    if (_isleniyor) return;
    
    setState(() {
      _taramada = false;
      _isleniyor = true;
    });
    
    _scannerController?.stop();
    
    // 1. QR verisini çözümle
    final qrIcerik = Kurum.parseQrData(qrData);
    if (qrIcerik == null) {
      setState(() {
        _isleniyor = false;
        _sonuc = YoklamaDurum.qrGecersiz;
        _mesaj = "QR kod tanınmadı.";
      });
      return;
    }
    
    final kurumId = qrIcerik['kurum_id'];
    final kurumLat = qrIcerik['lat'] as double;
    final kurumLon = qrIcerik['lon'] as double;
    
    // 2. GPS izni kontrol
    bool izinVar = await _konumIzniKontrol();
    if (!izinVar) {
      setState(() {
        _isleniyor = false;
        _sonuc = YoklamaDurum.izinYok;
        _mesaj = "Konum izni verilmedi.";
      });
      return;
    }
    
    // 3. Mevcut konumu al
    Position konum;
    try {
      konum = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      setState(() {
        _isleniyor = false;
        _sonuc = YoklamaDurum.izinYok;
        _mesaj = "Konum alınamadı: $e";
      });
      return;
    }
    
    // 4. Mesafe hesapla
    double mesafe = Geolocator.distanceBetween(
      konum.latitude, konum.longitude,
      kurumLat, kurumLon,
    );
    
    // 5. Tolerans kontrolü (varsayılan 100m)
    int yaricap = VeriDeposu.aktifKurum?.yaricapMetre ?? 100;
    
    if (mesafe <= yaricap) {
      // BAŞARILI
      final yoklama = YoklamaKaydi(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ogrenciId: widget.ogrenci.id,
        ogrenciAd: widget.ogrenci.ad,
        kurumId: kurumId,
        girisZamani: DateTime.now(),
        gecerli: true,
        mesafe: mesafe,
      );
      
      VeriDeposu.yoklamaKayitlari.add(yoklama);
      VeriDeposu.kaydet();
      
      // Veli bildirimi (gelecekte push notification)
      // TODO: Firebase ile gerçek bildirim
      
      setState(() {
        _isleniyor = false;
        _sonuc = YoklamaDurum.basarili;
        _mesaj = "Hoş geldin ${widget.ogrenci.ad}! Mesafe: ${mesafe.toInt()}m";
      });
    } else {
      // KONUM HATASI
      setState(() {
        _isleniyor = false;
        _sonuc = YoklamaDurum.konumHatasi;
        _mesaj = "Kurum dışındasın! Mesafe: ${mesafe.toInt()}m (Limit: ${yaricap}m)";
      });
    }
  }

  Future<bool> _konumIzniKontrol() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    
    if (permission == LocationPermission.deniedForever) return false;
    
    return true;
  }

  void _cikisYap() async {
    // Son yoklama kaydını bul ve çıkış zamanı ekle
    final sonYoklama = VeriDeposu.yoklamaKayitlari
        .where((y) => y.ogrenciId == widget.ogrenci.id && y.cikisZamani == null)
        .lastOrNull;
    
    if (sonYoklama != null) {
      sonYoklama.cikisZamani = DateTime.now();
      VeriDeposu.kaydet();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Çıkış yapıldı! Süre: ${sonYoklama.sureDakika} dakika'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktif yoklama bulunamadı')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Aktif yoklama var mı?
    final aktifYoklama = VeriDeposu.yoklamaKayitlari
        .where((y) => y.ogrenciId == widget.ogrenci.id && y.cikisZamani == null)
        .lastOrNull;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Yoklama'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _taramada 
        ? _buildTaramaEkrani()
        : _buildAnaEkran(aktifYoklama),
    );
  }

  Widget _buildTaramaEkrani() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) {
            final barcode = capture.barcodes.firstOrNull;
            if (barcode != null && barcode.rawValue != null) {
              _qrTarandi(barcode.rawValue!);
            }
          },
        ),
        // Overlay
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green, width: 3),
          ),
        ),
        // İptal butonu
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton.icon(
              onPressed: () {
                _scannerController?.stop();
                setState(() => _taramada = false);
              },
              icon: const Icon(Icons.close),
              label: const Text("İPTAL"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
        // Kılavuz
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_scanner, size: 100, color: Colors.white54),
              SizedBox(height: 16),
              Text(
                "QR kodu çerçeveye hizalayın",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnaEkran(YoklamaKaydi? aktifYoklama) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Durum kartı
          if (aktifYoklama != null) _buildAktifYoklamaKarti(aktifYoklama),
          
          // Sonuç kartı
          if (_sonuc != null) _buildSonucKarti(),
          
          const SizedBox(height: 24),
          
          // Ana buton
          if (aktifYoklama == null)
            _buildGirisButonu()
          else
            _buildCikisButonu(),
          
          const SizedBox(height: 32),
          
          // Geçmiş yoklamalar
          _buildGecmisYoklamalar(),
        ],
      ),
    );
  }

  Widget _buildAktifYoklamaKarti(YoklamaKaydi yoklama) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade400],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          const Text(
            "ŞU AN DERSTESIN",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Giriş: ${yoklama.girisZamani.hour}:${yoklama.girisZamani.minute.toString().padLeft(2, '0')}",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            "Süre: ${yoklama.sureDakika} dakika",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSonucKarti() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _sonuc!.renk.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _sonuc!.renk),
      ),
      child: Column(
        children: [
          Icon(_sonuc!.ikon, color: _sonuc!.renk, size: 48),
          const SizedBox(height: 12),
          Text(
            _sonuc!.mesaj,
            style: TextStyle(color: _sonuc!.renk, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (_mesaj != null) ...[
            const SizedBox(height: 8),
            Text(_mesaj!, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }

  Widget _buildGirisButonu() {
    return Column(
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withAlpha(100),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isleniyor ? null : _yoklamaYap,
              borderRadius: BorderRadius.circular(100),
              child: _isleniyor
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, color: Colors.white, size: 64),
                      SizedBox(height: 8),
                      Text(
                        "DERSTEYİM",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          kIsWeb ? "Demo yoklama için dokun" : "QR okutmak için dokun",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildCikisButonu() {
    return ElevatedButton.icon(
      onPressed: _cikisYap,
      icon: const Icon(Icons.logout),
      label: const Text("ÇIKIŞ YAP"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildGecmisYoklamalar() {
    final gecmis = VeriDeposu.yoklamaKayitlari
        .where((y) => y.ogrenciId == widget.ogrenci.id && y.cikisZamani != null)
        .toList()
        .reversed
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Son Yoklamalar",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (gecmis.isEmpty)
          const Text("Henüz yoklama kaydı yok", style: TextStyle(color: Colors.grey))
        else
          ...gecmis.map((y) => ListTile(
            leading: Icon(
              y.gecerli ? Icons.check_circle : Icons.warning,
              color: y.gecerli ? Colors.green : Colors.orange,
            ),
            title: Text(
              "${y.girisZamani.day}/${y.girisZamani.month}/${y.girisZamani.year}",
            ),
            subtitle: Text(
              "${y.girisZamani.hour}:${y.girisZamani.minute.toString().padLeft(2, '0')} - "
              "${y.cikisZamani!.hour}:${y.cikisZamani!.minute.toString().padLeft(2, '0')} "
              "(${y.sureDakika} dk)",
            ),
            trailing: Text("${y.mesafe.toInt()}m"),
          )),
      ],
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }
}
