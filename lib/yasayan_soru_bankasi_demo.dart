import 'package:flutter/material.dart';
import '../models/soru_model.dart';
import '../services/soru_bankasi_service.dart';

/// Yaşayan Soru Bankası - Demo Soru Çözüm Ekranı
/// 
/// Bu ekran sistemi test etmek için basit bir arayüz sağlar.
class YasayanSoruBankasiDemo extends StatefulWidget {
  const YasayanSoruBankasiDemo({super.key});

  @override
  State<YasayanSoruBankasiDemo> createState() => _YasayanSoruBankasiDemoState();
}

class _YasayanSoruBankasiDemoState extends State<YasayanSoruBankasiDemo> {
  final SoruBankasiService _service = SoruBankasiService();
  
  SoruModel? _mevcutSoru;
  String? _secilenSik;
  bool _cevaplandi = false;
  bool _yukleniyor = false;
  bool _cozumAcikMi = false; // 🔒 Çözüm varsayılan olarak kilitli (Active Recall)

  // Test için ders/konu seçimleri
  String _secilenDers = "Matematik";
  String _secilenKonu = "Türev";

  final List<String> _dersler = ["Matematik", "Fizik", "Kimya", "Biyoloji"];
  final Map<String, List<String>> _konular = {
    "Matematik": ["Türev", "İntegral", "Limit", "Trigonometri"],
    "Fizik": ["Kuvvet", "Hareket", "Elektrik", "Optik"],
    "Kimya": ["Mol", "Asit-Baz", "Kimyasal Tepkimeler"],
    "Biyoloji": ["Hücre", "Genetik", "Ekosistem"],
  };

  @override
  void initState() {
    super.initState();
    _yeniSoruYukle();
  }

  Future<void> _yeniSoruYukle() async {
    setState(() {
      _yukleniyor = true;
      _cevaplandi = false;
      _secilenSik = null;
      _cozumAcikMi = false; // Yeni soru yüklenirken çözümü gizle
    });

    try {
      final soru = await _service.soruGetir(
        ders: _secilenDers,
        konu: _secilenKonu,
        ogrenciId: "demo_user", // Demo için sabit ID, gerçek uygulamada aktif kullanıcı
      );

      setState(() {
        _mevcutSoru = soru;
        _yukleniyor = false;
      });
    } catch (e) {
      setState(() => _yukleniyor = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Soru yüklenemedi: $e")),
        );
      }
    }
  }

  void _cevapVer(String sik) {
    if (_cevaplandi || _mevcutSoru == null) return;

    bool dogruMu = sik == _mevcutSoru!.dogruCevap;
    
    setState(() {
      _secilenSik = sik;
      _cevaplandi = true;
      
      // 🎁 ACTIVE RECALL: Doğru bilirse ödül olarak çözümü aç
      // Yanlış bilirse kapalı kalsın, merak ederse kendisi açar
      if (dogruMu) {
        _cozumAcikMi = true;
      }
    });

    // İstatistik güncelle (async ama await etme, UI donmasın)
    _service.sonucKaydet(
      _mevcutSoru!.id!, 
      dogruMu,
      ogrenciId: "demo_user", // Demo için sabit ID
    ).then((_) {
      debugPrint("✅ İstatistik güncellendi");
    });
  }

  void _raporla() {
    if (_mevcutSoru == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Soruyu Raporla"),
        content: const Text("Bu soruyla ilgili bir sorun mu var?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _service.soruRaporla(_mevcutSoru!.id!, "Kullanıcı bildirimi");
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("🚩 Rapor kaydedildi")),
              );
            },
            child: const Text("Raporla"),
          ),
        ],
      ),
    );
  }

  void _begenDurumunuKaydet(bool begendiMi) {
    if (_mevcutSoru == null) return;
    _service.soruBegen(_mevcutSoru!.id!, begendiMi);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(begendiMi ? "👍 Beğenildi" : "👎 Beğenilmedi")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          "📚 Yaşayan Soru Bankası",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_mevcutSoru != null)
            IconButton(
              icon: const Icon(Icons.flag, color: Colors.red),
              tooltip: "Raporla",
              onPressed: _raporla,
            ),
        ],
      ),
      body: _yukleniyor
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.purple),
                  SizedBox(height: 16),
                  Text(
                    "Soru yükleniyor...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : _mevcutSoru == null
              ? Center(
                  child: ElevatedButton(
                    onPressed: _yeniSoruYukle,
                    child: const Text("Soru Yükle"),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDersKonuSecici(),
                      const SizedBox(height: 16),
                      _buildSoruKarti(),
                      const SizedBox(height: 16),
                      _buildSiklar(),
                      if (_cevaplandi) ...[
                        const SizedBox(height: 16),
                        _buildSonucKarti(),
                        const SizedBox(height: 16),
                        _buildGeriBildirimButonlari(),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _yeniSoruYukle,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Yeni Soru"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDersKonuSecici() {
    return Card(
      color: const Color(0xFF21262D),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _secilenDers,
                dropdownColor: const Color(0xFF21262D),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Ders",
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                items: _dersler
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _secilenDers = v!;
                    _secilenKonu = _konular[v]!.first;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _secilenKonu,
                dropdownColor: const Color(0xFF21262D),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Konu",
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                items: (_konular[_secilenDers] ?? [])
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setState(() => _secilenKonu = v!),
              ),
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
                // Zorluk etiketi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getZorlukRengi(_mevcutSoru!.zorlukSeviyesi),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_mevcutSoru!.zorlukEmoji} ${_mevcutSoru!.zorlukSeviyesi}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // İstatistikler
                Text(
                  "👁️ ${_mevcutSoru!.goruntulenme} | ✅ ${_mevcutSoru!.dogruSayisi} | ❌ ${_mevcutSoru!.yanlisSayisi}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _mevcutSoru!.soruMetni,
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
      children: _mevcutSoru!.siklar.map((sik) {
        bool secildi = _secilenSik == sik;
        bool dogruCevap = sik == _mevcutSoru!.dogruCevap;
        
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
          renk = secildi ? Colors.purple : Colors.grey;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _cevapVer(sik),
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
                    const Icon(Icons.cancel, color: Colors.red),
                  if (_cevaplandi) const SizedBox(width: 12),
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
    bool dogruMu = _secilenSik == _mevcutSoru!.dogruCevap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Doğru/Yanlış Kartı
        Card(
          color: dogruMu ? Colors.green.shade900 : Colors.red.shade900,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  dogruMu ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  dogruMu ? "Doğru! 🎉" : "Yanlış 😔",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 🔒 GİZLİ ÇÖZÜM ALANI (Active Recall)
        _buildCozumAlani(),
      ],
    );
  }

  /// Active Recall: Gizli Çözüm Alanı
  Widget _buildCozumAlani() {
    if (_mevcutSoru?.cozumAciklamasi == null) {
      return const SizedBox.shrink(); // Çözüm yoksa gösterme
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Başlık
        Text(
          "ÇÖZÜM VE AÇIKLAMA",
          style: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),

        // Animasyonlu Geçiş
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 400),
          
          // DURUM A: Çözüm Kilitli (Buton Göster)
          firstChild: Container(
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _cozumAcikMi = true; // Kilidi aç
                  });
                },
                icon: const Icon(Icons.lock_open_rounded, color: Colors.white),
                label: const Text(
                  "Çözümü Göster",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: const StadiumBorder(),
                  elevation: 4,
                ),
              ),
            ),
          ),

          // DURUM B: Çözüm Açık (Metni Göster)
          secondChild: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade900.withOpacity(0.3),
                  Colors.green.shade800.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.5), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber.shade400),
                    const SizedBox(width: 8),
                    const Text(
                      "Detaylı Anlatım",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    // Küçük kapatma butonu
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () {
                        setState(() {
                          _cozumAcikMi = false; // Tekrar kilitle
                        });
                      },
                    ),
                  ],
                ),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                // Çözüm metni (LaTeX render için flutter_tex kullanılabilir)
                Text(
                  _mevcutSoru!.cozumAciklamasi!,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Hangi durumda olduğumuzu belirle
          crossFadeState: _cozumAcikMi 
              ? CrossFadeState.showSecond 
              : CrossFadeState.showFirst,
        ),
      ],
    );
  }

  Widget _buildGeriBildirimButonlari() {
    return Card(
      color: const Color(0xFF21262D),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Bu soru nasıldı?",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _begenDurumunuKaydet(true),
                  icon: const Icon(Icons.thumb_up, size: 20),
                  label: const Text("Beğendim"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _begenDurumunuKaydet(false),
                  icon: const Icon(Icons.thumb_down, size: 20),
                  label: const Text("Beğenmedim"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getZorlukRengi(String zorluk) {
    switch (zorluk) {
      case "Kolay":
        return Colors.green;
      case "Orta":
        return Colors.orange;
      case "Zor":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
