import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'diamond_service.dart';
import 'diamond_shop_screen.dart';

/// 🎯 BUGÜN KAZANABİLECEĞİN ELMASLAR WİDGET'I
/// Öğrenciye hangi görevlerden elmas kazanabileceğini gösterir
class DiamondOpportunitiesWidget extends StatefulWidget {
  final String ogrenciId;
  final String ogrenciAdi;
  final VoidCallback? onReklamIzle;
  final VoidCallback? onDuelloAc;
  final int bekleyenOdevSayisi;
  
  const DiamondOpportunitiesWidget({
    super.key,
    required this.ogrenciId,
    required this.ogrenciAdi,
    this.onReklamIzle,
    this.onDuelloAc,
    this.bekleyenOdevSayisi = 0,
  });
  
  @override
  State<DiamondOpportunitiesWidget> createState() => _DiamondOpportunitiesWidgetState();
}

class _DiamondOpportunitiesWidgetState extends State<DiamondOpportunitiesWidget> {
  bool _loading = true;
  int _balance = 0;
  
  // Günlük durum
  bool _gunlukGirisAlindi = false;
  bool _reklamIzlendi = false;
  int _bugunDuelloKazanilan = 0;
  
  @override
  void initState() {
    super.initState();
    _loadStatus();
  }
  
  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    
    // Bakiye
    final balance = await DiamondService.getBalance(widget.ogrenciId);
    
    // Günlük giriş
    final lastDaily = prefs.getString('last_daily_claim_${widget.ogrenciId}');
    
    // Reklam
    final lastAd = prefs.getString('last_ad_watch_${widget.ogrenciId}');
    
    // Düello
    final duelloKey = 'duel_wins_${widget.ogrenciId}_$today';
    final duelloWins = prefs.getInt(duelloKey) ?? 0;
    
    if (mounted) {
      setState(() {
        _balance = balance;
        _gunlukGirisAlindi = lastDaily == today;
        _reklamIzlendi = lastAd == today;
        _bugunDuelloKazanilan = duelloWins;
        _loading = false;
      });
    }
  }
  
  // Bugün toplamda kazanılabilecek elmas
  int get _kazanilabilirToplam {
    int toplam = 0;
    if (!_gunlukGirisAlindi) toplam += DiamondService.GUNLUK_GIRIS;
    if (!_reklamIzlendi) toplam += DiamondService.REKLAM_IZLE;
    if (_bugunDuelloKazanilan < DiamondService.GUNLUK_DUELLO_ODUL_LIMITI) {
      toplam += (DiamondService.GUNLUK_DUELLO_ODUL_LIMITI - _bugunDuelloKazanilan) * DiamondService.DUELLO_KAZAN;
    }
    if (widget.bekleyenOdevSayisi > 0) {
      toplam += widget.bekleyenOdevSayisi * DiamondService.ODEV_TAMAMLA;
    }
    return toplam;
  }
  
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan.shade800, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              const Text("💎", style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Bugün Kazanabileceğin",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiamondShopScreen(
                      ogrenciId: widget.ogrenciId,
                      ogrenciAdi: widget.ogrenciAdi,
                    ),
                  ),
                ).then((_) => _loadStatus()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "$_balance",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text("💎", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Toplam kazanılabilir
          Row(
            children: [
              Text(
                "+$_kazanilabilirToplam Elmas",
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (_kazanilabilirToplam == 0)
                const Text("✅ Bugünlük tamam!", style: TextStyle(color: Colors.green)),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Görev listesi
          _buildGorevItem(
            icon: "📅",
            baslik: "Günlük Giriş",
            elmas: DiamondService.GUNLUK_GIRIS,
            yapildiMi: _gunlukGirisAlindi,
            hazirMi: !_gunlukGirisAlindi,
            onTap: _gunlukGirisAlindi ? null : _gunlukGirisAl,
          ),
          
          const SizedBox(height: 8),
          
          _buildGorevItem(
            icon: "📺",
            baslik: "Reklam İzle",
            elmas: DiamondService.REKLAM_IZLE,
            yapildiMi: _reklamIzlendi,
            hazirMi: !_reklamIzlendi,
            onTap: _reklamIzlendi ? null : widget.onReklamIzle,
          ),
          
          const SizedBox(height: 8),
          
          _buildGorevItem(
            icon: "⚔️",
            baslik: "Düello Kazan",
            elmas: DiamondService.DUELLO_KAZAN,
            yapildiMi: _bugunDuelloKazanilan >= DiamondService.GUNLUK_DUELLO_ODUL_LIMITI,
            hazirMi: _bugunDuelloKazanilan < DiamondService.GUNLUK_DUELLO_ODUL_LIMITI,
            altBilgi: "${DiamondService.GUNLUK_DUELLO_ODUL_LIMITI - _bugunDuelloKazanilan} hak kaldı",
            onTap: widget.onDuelloAc,
          ),
          
          const SizedBox(height: 8),
          
          _buildGorevItem(
            icon: "📝",
            baslik: "Ödev Tamamla",
            elmas: DiamondService.ODEV_TAMAMLA,
            yapildiMi: widget.bekleyenOdevSayisi == 0,
            hazirMi: widget.bekleyenOdevSayisi > 0,
            altBilgi: widget.bekleyenOdevSayisi > 0 ? "${widget.bekleyenOdevSayisi} ödev bekliyor" : "Ödev yok",
          ),
        ],
      ),
    );
  }
  
  Widget _buildGorevItem({
    required String icon,
    required String baslik,
    required int elmas,
    required bool yapildiMi,
    required bool hazirMi,
    String? altBilgi,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: hazirMi && onTap != null ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: yapildiMi
              ? Colors.green.withOpacity(0.2)
              : hazirMi
                  ? Colors.amber.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: yapildiMi
                ? Colors.green.withOpacity(0.5)
                : hazirMi
                    ? Colors.amber.withOpacity(0.5)
                    : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // İkon
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            
            // Başlık ve alt bilgi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baslik,
                    style: TextStyle(
                      color: yapildiMi ? Colors.green : Colors.white,
                      fontWeight: FontWeight.w600,
                      decoration: yapildiMi ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (altBilgi != null)
                    Text(
                      altBilgi,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            
            // Elmas miktarı veya durum
            if (yapildiMi)
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 4),
                  Text("Alındı", style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              )
            else if (hazirMi)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "+$elmas",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Text("💎", style: TextStyle(fontSize: 11)),
                  ],
                ),
              )
            else
              Text(
                "+$elmas 💎",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _gunlukGirisAl() async {
    final success = await DiamondService.claimDailyLogin(widget.ogrenciId);
    if (success && mounted) {
      setState(() => _gunlukGirisAlindi = true);
      _loadStatus(); // Bakiyeyi güncelle
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ +5 Elmas kazandın! Günlük giriş ödülü alındı."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
