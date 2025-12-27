import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/odul_anket_models.dart';
import '../services/anket_service.dart';

/// 🗳️ HAFTALIK ÖDÜL ANKETİ EKRANI
/// Öğrencilerin haftalık yarışma ödülünü seçtiği anket
class OdulAnketiScreen extends StatefulWidget {
  final String ogrenciId;
  
  const OdulAnketiScreen({super.key, required this.ogrenciId});
  
  @override
  State<OdulAnketiScreen> createState() => _OdulAnketiScreenState();
}

class _OdulAnketiScreenState extends State<OdulAnketiScreen> {
  final AnketService _anketService = AnketService();
  
  HaftalikOdulAnketi? _anket;
  List<OdulMagazasiUrunu> _urunler = [];
  String? _secilenUrunId;
  String? _oyKullanilanUrunId;
  bool _yukleniyor = true;
  bool _oyKullaniliyor = false;
  Timer? _timer;
  Duration _kalanSure = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  Future<void> _verileriYukle() async {
    setState(() => _yukleniyor = true);
    
    try {
      // Aktif anketi getir
      final anket = await _anketService.aktifAnketiGetir();
      
      if (anket != null) {
        // Öğrenci daha önce oy kullanmış mı?
        final oyKullandiMi = await _anketService.oyKullandiMi(anket.id, widget.ogrenciId);
        String? oyKullanilanUrun;
        if (oyKullandiMi) {
          oyKullanilanUrun = await _anketService.ogrencininOyunuGetir(anket.id, widget.ogrenciId);
        }
        
        // Ürünleri getir
        final urunler = await _anketService.urunleriGetir(anket.urunIdleri);
        
        setState(() {
          _anket = anket;
          _urunler = urunler;
          _oyKullanilanUrunId = oyKullanilanUrun;
          _kalanSure = anket.kalanSure;
        });
        
        // Timer başlat
        _timerBaslat();
      }
    } catch (e) {
      debugPrint('❌ Veri yükleme hatası: $e');
    }
    
    setState(() => _yukleniyor = false);
  }
  
  void _timerBaslat() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_anket != null) {
        setState(() {
          _kalanSure = _anket!.kalanSure;
          if (_kalanSure.inSeconds <= 0) {
            _timer?.cancel();
          }
        });
      }
    });
  }
  
  Future<void> _oyKullan() async {
    if (_secilenUrunId == null || _oyKullanilanUrunId != null) return;
    
    // Onay dialogu göster
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🗳️ Oy Onayla'),
        content: const Text(
          'Oyunuz kaydedildikten sonra değiştirilemez!\n\nDevam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Oyumu Ver', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (onay != true) return;
    
    setState(() => _oyKullaniliyor = true);
    
    final basarili = await _anketService.oyKullan(
      anketId: _anket!.id,
      ogrenciId: widget.ogrenciId,
      urunId: _secilenUrunId!,
    );
    
    if (basarili) {
      setState(() {
        _oyKullanilanUrunId = _secilenUrunId;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Oyunuz başarıyla kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Oy verme başarısız oldu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() => _oyKullaniliyor = false);
  }
  
  void _arkadasiniDavetEt() {
    final yarismaGunu = _anket?.bitisTarihi;
    final gunText = yarismaGunu != null 
        ? '${yarismaGunu.day}.${yarismaGunu.month}.${yarismaGunu.year} saat ${yarismaGunu.hour}:00'
        : 'Bu Cumartesi 20:00';
    
    Share.share(
      '🏆 YKS Şampiyon - Haftalık Ödüllü Yarışma!\n\n'
      '📅 $gunText\'da büyük yarışma var!\n'
      '🎁 Bu hafta hangi ödülün verileceğine sen de oy ver!\n'
      '💯 Birinci olana ödül bizden!\n\n'
      '📲 Uygulamayı indir ve sen de katıl!\n'
      'https://play.google.com/store/apps/details?id=com.ykscepte.app',
      subject: 'YKS Şampiyon - Haftalık Ödüllü Yarışma',
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade700, Colors.deepPurple.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _yukleniyor
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _anket == null
                  ? _buildAnketYok()
                  : _buildAnketIcerik(),
        ),
      ),
    );
  }
  
  Widget _buildAnketYok() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.poll_outlined, size: 80, color: Colors.white54),
            const SizedBox(height: 24),
            const Text(
              'Şu an aktif anket yok',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Haftalık ödül anketi Cuma 20:00\'da açılır',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Geri Dön'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnketIcerik() {
    return Column(
      children: [
        // Header
        _buildHeader(),
        
        // Kalan Süre
        _buildKalanSure(),
        
        // Ürün Listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _urunler.length,
            itemBuilder: (context, index) => _buildUrunKart(_urunler[index]),
          ),
        ),
        
        // Alt Butonlar
        _buildAltButonlar(),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              '🎁 Haftalık Ödül Anketi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Arkadaşını Davet Et butonu
          IconButton(
            onPressed: _arkadasiniDavetEt,
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'Arkadaşını Davet Et',
          ),
        ],
      ),
    );
  }
  
  Widget _buildKalanSure() {
    final saat = _kalanSure.inHours;
    final dakika = _kalanSure.inMinutes % 60;
    final saniye = _kalanSure.inSeconds % 60;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            _oyKullanilanUrunId != null
                ? '✅ Oyunuz Kaydedildi!'
                : 'Yarışmaya Kalan Süre',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSureKutusu(saat.toString().padLeft(2, '0'), 'Saat'),
              const Text(' : ', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              _buildSureKutusu(dakika.toString().padLeft(2, '0'), 'Dakika'),
              const Text(' : ', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              _buildSureKutusu(saniye.toString().padLeft(2, '0'), 'Saniye'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Toplam ${_anket?.toplamOy ?? 0} oy kullanıldı',
            style: TextStyle(color: Colors.amber, fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSureKutusu(String deger, String etiket) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            deger,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(etiket, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
      ],
    );
  }
  
  Widget _buildUrunKart(OdulMagazasiUrunu urun) {
    final seciliMi = _secilenUrunId == urun.id;
    final oyKullandiMi = _oyKullanilanUrunId != null;
    final buUrunuSectiMi = _oyKullanilanUrunId == urun.id;
    final oySayisi = _anket?.oylar[urun.id] ?? 0;
    final toplamOy = _anket?.toplamOy ?? 1;
    final yuzde = toplamOy > 0 ? (oySayisi / toplamOy * 100) : 0;
    
    return GestureDetector(
      onTap: oyKullandiMi ? null : () {
        setState(() {
          _secilenUrunId = seciliMi ? null : urun.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: buUrunuSectiMi
              ? Colors.green.withOpacity(0.3)
              : seciliMi
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: buUrunuSectiMi
                ? Colors.green
                : seciliMi
                    ? Colors.amber
                    : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Ürün Görseli
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: urun.gorselUrl.isNotEmpty
                    ? Image.network(
                        urun.gorselUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.card_giftcard, size: 32),
                      )
                    : const Icon(Icons.card_giftcard, size: 32),
              ),
            ),
            const SizedBox(width: 16),
            
            // Ürün Bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    urun.ad,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${urun.fiyat.toStringAsFixed(0)} TL değerinde',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  // Oy çubuğu
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: yuzde / 100,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$oySayisi oy (%${yuzde.toStringAsFixed(0)})',
                    style: TextStyle(color: Colors.amber, fontSize: 11),
                  ),
                ],
              ),
            ),
            
            // Seçim İkonu
            if (buUrunuSectiMi)
              const Icon(Icons.check_circle, color: Colors.green, size: 32)
            else if (seciliMi)
              const Icon(Icons.radio_button_checked, color: Colors.amber, size: 28)
            else if (!oyKullandiMi)
              Icon(Icons.radio_button_off, color: Colors.white.withOpacity(0.5), size: 28),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAltButonlar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Arkadaşını Davet Et
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _arkadasiniDavetEt,
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text('Arkadaşını\nDavet Et', 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Oy Ver Butonu
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _oyKullanilanUrunId != null || _secilenUrunId == null || _oyKullaniliyor
                    ? null
                    : _oyKullan,
                icon: _oyKullaniliyor
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(
                        _oyKullanilanUrunId != null ? Icons.check : Icons.how_to_vote,
                      ),
                label: Text(
                  _oyKullanilanUrunId != null
                      ? 'Oy Kullandınız ✓'
                      : _secilenUrunId == null
                          ? 'Ürün Seçin'
                          : 'Oyumu Ver',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _oyKullanilanUrunId != null
                      ? Colors.green
                      : Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
