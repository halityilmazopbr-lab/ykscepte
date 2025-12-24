import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'envanter_models.dart';
import 'envanter_verileri.dart';

/// Burdon Dikkat Testi Ekranı
/// 3 dakikalık zamanlı test - hedef harfleri bulma
class BurdonTestEkrani extends StatefulWidget {
  final Envanter envanter;
  
  const BurdonTestEkrani({super.key, required this.envanter});

  @override
  State<BurdonTestEkrani> createState() => _BurdonTestEkraniState();
}

class _BurdonTestEkraniState extends State<BurdonTestEkrani> {
  bool _baslamadi = true;
  bool _bitti = false;
  int _kalanSaniye = 180; // 3 dakika
  Timer? _timer;
  
  // Hedef harfler
  final List<String> _hedefHarfler = ['d', 'p', 'b'];
  
  // Harf matrisi
  late List<List<String>> _matris;
  late List<List<bool>> _secimler;
  late List<List<bool>> _dogruMu;
  
  // Skorlar
  int _dogru = 0;
  int _yanlis = 0;
  int _toplam = 0;
  
  @override
  void initState() {
    super.initState();
    _matrisOlustur();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _matrisOlustur() {
    final random = Random();
    final harfler = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 
                     'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'];
    
    _matris = [];
    _secimler = [];
    _dogruMu = [];
    
    // 20 satır, 30 sütun
    for (int i = 0; i < 20; i++) {
      List<String> satir = [];
      List<bool> secimSatir = [];
      List<bool> dogruSatir = [];
      
      for (int j = 0; j < 30; j++) {
        String harf = harfler[random.nextInt(harfler.length)];
        satir.add(harf);
        secimSatir.add(false);
        dogruSatir.add(_hedefHarfler.contains(harf));
      }
      
      _matris.add(satir);
      _secimler.add(secimSatir);
      _dogruMu.add(dogruSatir);
    }
    
    // Toplam hedef harf sayısını hesapla
    for (var satir in _dogruMu) {
      for (var d in satir) {
        if (d) _toplam++;
      }
    }
  }

  void _testiBaslat() {
    setState(() {
      _baslamadi = false;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _kalanSaniye--;
        if (_kalanSaniye <= 0) {
          _testiBitir();
        }
      });
    });
  }

  void _testiBitir() {
    _timer?.cancel();
    
    // Skorları hesapla
    int dogru = 0;
    int yanlis = 0;
    
    for (int i = 0; i < _matris.length; i++) {
      for (int j = 0; j < _matris[i].length; j++) {
        if (_secimler[i][j]) {
          if (_dogruMu[i][j]) {
            dogru++;
          } else {
            yanlis++;
          }
        }
      }
    }
    
    setState(() {
      _bitti = true;
      _dogru = dogru;
      _yanlis = yanlis;
    });
  }

  void _harfSec(int satir, int sutun) {
    if (_baslamadi || _bitti) return;
    
    setState(() {
      _secimler[satir][sutun] = !_secimler[satir][sutun];
    });
  }

  String _formatSure(int saniye) {
    int dk = saniye ~/ 60;
    int sn = saniye % 60;
    return '${dk.toString().padLeft(2, '0')}:${sn.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_baslamadi) {
      return _buildBaslangicEkrani();
    }
    
    if (_bitti) {
      return _buildSonucEkrani();
    }
    
    return _buildTestEkrani();
  }

  Widget _buildBaslangicEkrani() {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Burdon Dikkat Testi'),
        backgroundColor: widget.envanter.renk,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.visibility,
                size: 80,
                color: widget.envanter.renk,
              ),
              const SizedBox(height: 24),
              const Text(
                'Burdon Dikkat Testi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Bu test dikkat ve konsantrasyon seviyeni ölçer.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              
              // Talimatlar
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📋 Talimatlar:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('• 3 dakika süren var'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('• Hedef harfler: '),
                          ..._hedefHarfler.map((h) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.envanter.renk,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(h.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          )),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text('• Bu harfleri gördüğünde üzerine dokun'),
                      const SizedBox(height: 6),
                      const Text('• Ne kadar çok doğru bulursan o kadar iyi!'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _testiBaslat,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('TESTİ BAŞLAT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.envanter.renk,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestEkrani() {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.timer, size: 20),
            const SizedBox(width: 8),
            Text(_formatSure(_kalanSaniye)),
          ],
        ),
        backgroundColor: _kalanSaniye <= 30 ? Colors.red : widget.envanter.renk,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _testiBitir,
            child: const Text('BİTİR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hedef harfler bilgisi
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Hedefler: ', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._hedefHarfler.map((h) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.envanter.renk,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(h.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )),
              ],
            ),
          ),
          
          // Harf matrisi
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: List.generate(_matris.length, (i) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_matris[i].length, (j) {
                      final harf = _matris[i][j];
                      final secili = _secimler[i][j];
                      
                      return GestureDetector(
                        onTap: () => _harfSec(i, j),
                        child: Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: secili ? widget.envanter.renk : Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              harf,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: secili ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSonucEkrani() {
    final atlanan = _toplam - _dogru;
    final basariYuzdesi = _toplam > 0 ? (_dogru / _toplam) * 100 : 0.0;
    final aiYorum = EnvanterVerileri.burdonYorumu(basariYuzdesi, _dogru, _yanlis);
    
    Color renk;
    String seviye;
    if (basariYuzdesi >= 90) {
      renk = Colors.green;
      seviye = 'Mükemmel';
    } else if (basariYuzdesi >= 75) {
      renk = Colors.lightGreen;
      seviye = 'İyi';
    } else if (basariYuzdesi >= 50) {
      renk = Colors.orange;
      seviye = 'Orta';
    } else {
      renk = Colors.red;
      seviye = 'Geliştirilmeli';
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Sonuçlar'),
        backgroundColor: widget.envanter.renk,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Başlık kartı
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: [renk, renk.withOpacity(0.7)]),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.white, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Dikkat Seviyesi: $seviye',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Yüzde gösterimi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: basariYuzdesi / 100,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey.shade200,
                              color: renk,
                            ),
                          ),
                          Text(
                            '%${basariYuzdesi.toStringAsFixed(1)}',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: renk),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSkorKutu('Doğru', _dogru, Colors.green),
                        _buildSkorKutu('Yanlış', _yanlis, Colors.red),
                        _buildSkorKutu('Atlanan', atlanan, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // AI Yorum
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.withOpacity(0.1), Colors.purple.withOpacity(0.05)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.psychology, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text('AI Yorumu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(aiYorum, style: const TextStyle(fontSize: 15, height: 1.6)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Geri Dön'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.envanter.renk,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkorKutu(String baslik, int deger, Color renk) {
    return Column(
      children: [
        Text(baslik, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: renk.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            deger.toString(),
            style: TextStyle(color: renk, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
