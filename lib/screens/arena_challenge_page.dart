import 'package:flutter/material.dart';
import 'package:yks_cepte/services/soru_bankasi_service.dart';
import '../models/arena_challenge_model.dart';
import '../models/soru_model.dart';
import '../services/arena_service.dart';
import 'arena_leaderboard_page.dart';
import 'dart:async';

/// Arena Challenge Page
/// 
/// Challenge'a katılım ekranı:
/// - Soru gösterimi
/// - Stopwatch timer
/// - Şık seçimi
/// - Cevap gönderme (anti-cheat)
/// - Puan gösterimi
class ArenaChallengePage extends StatefulWidget {
  final ArenaChallengeModel challenge;

  const ArenaChallengePage({super.key, required this.challenge});

  @override
  State<ArenaChallengePage> createState() => _ArenaChallengePageState();
}

class _ArenaChallengePageState extends State<ArenaChallengePage> {
  final ArenaService _arenaService = ArenaService();
  final SoruBankasiService _soruService = SoruBankasiService();

  SoruModel? _soru;
  bool _yukleniyor = true;
  bool _cevaplandi = false;
  String? _secilenSik;
  
  // Timer
  Timer? _stopwatch;
  int _gecenSureSaniye = 0;
  bool _timerBasladi = false;

  // Sonuç
  int? _alinanPuan;
  String? _sonucMesaji;

  @override
  void initState() {
    super.initState();
    _soruYukle();
  }

  @override
  void dispose() {
    _stopwatch?.cancel();
    super.dispose();
  }

  Future<void> _soruYukle() async {
    setState(() => _yukleniyor = true);
    
    try {
      // Challenge'ın sorusunu getir
      var soru = await _soruService.getSoruById(widget.challenge.soruId);

      if (soru != null) {
        setState(() {
          _soru = soru;
          _yukleniyor = false;
        });
        
        // Timer'ı otomatik başlat
        _timerBaslat();
      } else {
        throw Exception("Soru bulunamadı");
      }
    } catch (e) {
      setState(() => _yukleniyor = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Soru yüklenemedi: $e')),
        );
      }
    }
  }

  void _timerBaslat() {
    if (_timerBasladi) return;
    
    _timerBasladi = true;
    _stopwatch = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_cevaplandi) {
        setState(() {
          _gecenSureSaniye++;
        });
      }
    });
  }

  void _sikSec(String sik) {
    if (_cevaplandi) return;
    setState(() {
      _secilenSik = sik;
    });
  }

  Future<void> _cevapGonder() async {
    if (_secilenSik == null || _cevaplandi) return;

    // Timer'ı durdur
    _stopwatch?.cancel();
    setState(() => _cevaplandi = true);

    bool dogruMu = _secilenSik == _soru!.dogruCevap;

    // Arena servisine gönder (anti-cheat)
    var result = await _arenaService.cevapGonder(
      challengeId: widget.challenge.id!,
      userId: 'demo_user', // Gerçek uygulamada auth.currentUser.uid
      kullaniciAdi: 'Demo User',
      dogruMu: dogruMu,
      gecenSureSaniye: _gecenSureSaniye,
      sehir: 'İstanbul', // Opsiyonel
    );

    setState(() {
      _alinanPuan = result['puan'];
      _sonucMesaji = result['message'];
    });

    if (result['success']) {
      // Başarılı - puan animasyonu göster
      _puanAnimasyonu();
    } else {
      // Hata - mesaj göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  void _puanAnimasyonu() {
    // Basit puan gösterimi, daha fancy animasyon eklenebilir
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade700, Colors.orange.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              Text(
                '+$_alinanPuan',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'PUAN',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Dialog kapat
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange.shade900,
                ),
                child: const Text('Devam Et'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: Text(
          widget.challenge.baslik,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Timer göstergesi
          if (_timerBasladi)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatSure(_gecenSureSaniye),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _yukleniyor
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            )
          : _soru == null
              ? const Center(
                  child: Text(
                    'Soru bulunamadı',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSoruKarti(),
                      const SizedBox(height: 16),
                      _buildSiklar(),
                      const SizedBox(height: 24),
                      if (!_cevaplandi)
                        ElevatedButton(
                          onPressed: _secilenSik != null ? _cevapGonder : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            disabledBackgroundColor: Colors.grey.shade700,
                          ),
                          child: Text(
                            _secilenSik != null ? 'CEVABI GÖNDER' : 'BİR ŞIK SEÇİN',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Column(
                          children: [
                            _buildSonucKarti(),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArenaLeaderboardPage(
                                      challengeId: widget.challenge.id!,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.leaderboard),
                              label: const Text('LİDER TABLOSUNU GÖR'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSoruKarti() {
    return Card(
      color: const Color(0xFF21262D),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.challenge.tur.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.challenge.xpOdul} XP',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _soru!.soruMetni,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiklar() {
    return Column(
      children: _soru!.siklar.map((sik) {
        bool secildi = _secilenSik == sik;
        bool dogruCevap = sik == _soru!.dogruCevap;
        
        Color renk;
        if (_cevaplandi) {
          if (dogruCevap) {
            renk = Colors.green;
          } else if (secildi) {
            renk = Colors.red;
          } else {
            renk = Colors.grey;
          }
        } else {
          renk = secildi ? Colors.orange : Colors.grey;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _sikSec(sik),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: renk.withOpacity(0.1),
                border: Border.all(color: renk, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (_cevaplandi && dogruCevap)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else if (_cevaplandi && secildi)
                    const Icon(Icons.cancel, color: Colors.red)
                  else if (secildi)
                    const Icon(Icons.radio_button_checked, color: Colors.orange)
                  else
                    const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      sik,
                      style: TextStyle(
                        color: renk,
                        fontWeight: secildi ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSonucKarti() {
    bool dogruMu = _secilenSik == _soru!.dogruCevap;

    return Card(
      color: dogruMu ? Colors.green.shade900 : Colors.red.shade900,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  dogruMu ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  dogruMu ? 'DOĞRU!' : 'YANLIŞ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _sonucMesaji ?? '',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            if (dogruMu && _alinanPuan != null) ...[
              const SizedBox(height: 12),
              Text(
                '+$_alinanPuan Puan',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatSure(int saniye) {
    final dakika = saniye ~/ 60;
    final sn = saniye % 60;
    return '${dakika.toString().padLeft(2, '0')}:${sn.toString().padLeft(2, '0')}';
  }
}
