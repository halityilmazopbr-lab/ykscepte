import 'package:flutter/material.dart';
import 'models.dart';
import 'data.dart';

/// 🎭 Maskot Duygu Durumu Sistemi - "Vicdan & Motivasyon Sistemi"
/// 
/// Bu sistem, öğrencinin çalışma alışkanlıklarına göre maskotnun
/// ruh halini değiştirerek psikolojik motivasyon sağlar.
/// 
/// İki farklı mod:
/// 1. Ana Ekran Widget'ı (Tamagotchi Modu) - Günlük durum kontrolü
/// 2. Uygulama İçi Dashboard (Koç Modu) - Anlık performans tepkisi

// ═══════════════════════════════════════════════════════════════════════════
// EMOJI DOSYA YOLLARI
// ═══════════════════════════════════════════════════════════════════════════

class MascotAssets {
  static const String basePath = 'assets/images/emojis/';
  
  // 😠 Olumsuz Duygular
  static const String shocked = '${basePath}shocked.png';     // Şaşkın - Kötü net
  static const String dead = '${basePath}dead.png';           // Ölü - 3+ gün girmedi
  static const String angry = '${basePath}angry.png';         // Kızgın - Hedef ihlali
  static const String crying = '${basePath}crying.png';       // Ağlayan - 1 gün girmedi
  static const String scared = '${basePath}scared.png';       // Korkan - Sınav yaklaşıyor
  static const String frustrated = '${basePath}frustrated.png'; // Bunalmış - Zorluk
  
  // 😊 Olumlu Duygular
  static const String happy = '${basePath}happy.png';         // Mutlu/Heyecanlı - Zirvedeyken
  static const String cool = '${basePath}cool.png';           // Güneş gözlüklü - Net artışı
  static const String smirk = '${basePath}smirk.png';         // Yan bakış - Havalı
  
  // 🧠 Özel Durumlar
  static const String reading = '${basePath}reading.png';     // Okuyan beyin - Çalışma modu
  static const String thinking = '${basePath}thinking.png';   // Karışık düşünceler
  static const String confused = '${basePath}confused.png';   // Soru işaretleri - Hareketsizlik
  static const String idea = '${basePath}idea.png';           // Ampul - Fikir geldi
  
  // ⏰ İkonlar
  static const String alarm = '${basePath}alarm.png';         // Çalar saat - Panik modu
  static const String energy = '${basePath}energy.png';       // Enerji/Şarj - Motivasyon
}

// ═══════════════════════════════════════════════════════════════════════════
// MASKOT DURUMU MODELİ
// ═══════════════════════════════════════════════════════════════════════════

enum MascotMood {
  kayiplardasin,    // 3+ gün girilmedi
  beniUnuttun,      // 1 gün girilmedi
  panikModu,        // Sınav yaklaşıyor + hedef tutmadı
  zirvedesin,       // Hedefler tuttu, seri devam
  odaklanmaZamani,  // Aktif çalışma modu
  havalisin,        // Net artışı var
  neYaptinSen,      // Net düşüşü veya çok yanlış
  kafamKaristi,     // Uzun süredir hareketsiz
  kizginim,         // Hedef ihlali (gece oldu, hedef bitmedi)
  normal,           // Varsayılan durum
}

class MascotState {
  final MascotMood mood;
  final String imagePath;
  final String message;
  final Color accentColor;
  final IconData icon;
  
  const MascotState({
    required this.mood,
    required this.imagePath,
    required this.message,
    required this.accentColor,
    required this.icon,
  });
  
  // Varsayılan durum
  static const MascotState defaultState = MascotState(
    mood: MascotMood.normal,
    imagePath: MascotAssets.happy,
    message: "Bugün ne çalışıyoruz?",
    accentColor: Colors.purple,
    icon: Icons.emoji_emotions,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// MASKOT SERVİSİ
// ═══════════════════════════════════════════════════════════════════════════

class MascotService {
  
  /// 🏠 Ana Ekran Widget Durumu (Tamagotchi Modu)
  /// Bu fonksiyon, home_widget paketi ile background fetch'te çağrılır.
  static MascotState getHomeWidgetState(Ogrenci ogrenci) {
    final now = DateTime.now();
    final sonGiris = ogrenci.sonGirisTarihi ?? now.subtract(const Duration(days: 5));
    final gunFarki = now.difference(sonGiris).inDays;
    
    // Senaryo 1: "Kayıplardasın" - 3+ gün girmedi
    if (gunFarki >= 3) {
      return const MascotState(
        mood: MascotMood.kayiplardasin,
        imagePath: MascotAssets.dead,
        message: "Netlerin can çekişiyor... Beni buraya gömdün! 💀",
        accentColor: Colors.red,
        icon: Icons.warning_amber,
      );
    }
    
    // Senaryo 2: "Beni Unuttun" - 1 gün girmedi
    if (gunFarki >= 1) {
      return const MascotState(
        mood: MascotMood.beniUnuttun,
        imagePath: MascotAssets.crying,
        message: "Dün yoktun... Başkasıyla mı soru çözdün? 😢",
        accentColor: Colors.blue,
        icon: Icons.sentiment_dissatisfied,
      );
    }
    
    // Senaryo 3: "Panik Modu" - Sınav yaklaşıyor
    final sinavTarihi = DateTime(2025, 6, 14); // YKS 2025
    final kalanGun = sinavTarihi.difference(now).inDays;
    if (kalanGun <= 60 && ogrenci.gunlukSeri < 1) {
      return const MascotState(
        mood: MascotMood.panikModu,
        imagePath: MascotAssets.scared,
        message: "Süre akıyor, biz hala yatıyoruz! Kalk! ⏰",
        accentColor: Colors.orange,
        icon: Icons.access_alarm,
      );
    }
    
    // Senaryo 4: "Zirvedesin" - Haftalık hedefler tuttu
    if (ogrenci.gunlukSeri >= 7) {
      return const MascotState(
        mood: MascotMood.zirvedesin,
        imagePath: MascotAssets.happy,
        message: "Ooo! Şov yapıyorsun. Aynen böyle devam! 🔥",
        accentColor: Colors.green,
        icon: Icons.emoji_events,
      );
    }
    
    // Varsayılan
    return MascotState.defaultState;
  }
  
  /// 📱 Dashboard Durumu (Koç Modu)
  /// Bu fonksiyon, uygulama içinde anlık durumu kontrol eder.
  static MascotState getDashboardState({
    required Ogrenci ogrenci,
    bool isStudying = false,
    double? lastNetChange,
    int wrongStreak = 0,
    int idleMinutes = 0,
    bool isNightAndGoalNotMet = false,
  }) {
    
    // Senaryo 1: "Odaklanma Zamanı" - Aktif çalışma
    if (isStudying) {
      return const MascotState(
        mood: MascotMood.odaklanmaZamani,
        imagePath: MascotAssets.reading,
        message: "Rahatsız etmeyin, beyin kasları gelişiyor... 🧠",
        accentColor: Colors.purple,
        icon: Icons.auto_stories,
      );
    }
    
    // Senaryo 2: "Havalısın" - Net artışı var
    if (lastNetChange != null && lastNetChange > 0) {
      return const MascotState(
        mood: MascotMood.havalisin,
        imagePath: MascotAssets.cool,
        message: "Bu işi çözdün sen. Rakipler ağlıyor şu an. 😎",
        accentColor: Colors.green,
        icon: Icons.trending_up,
      );
    }
    
    // Senaryo 3: "Ne Yaptın Sen?" - Net düştü veya çok yanlış
    if ((lastNetChange != null && lastNetChange < -5) || wrongStreak >= 5) {
      return MascotState(
        mood: MascotMood.neYaptinSen,
        imagePath: MascotAssets.shocked,
        message: "O sonuç ne öyle? Nazar boncuğu olsun, gel toparlayalım. 🧿",
        accentColor: Colors.orange,
        icon: Icons.sentiment_very_dissatisfied,
      );
    }
    
    // Senaryo 4: "Kafam Karıştı" - 10+ dk hareketsiz
    if (idleMinutes >= 10) {
      return const MascotState(
        mood: MascotMood.kafamKaristi,
        imagePath: MascotAssets.confused,
        message: "Orada mısın? Yoksa daldın gittin mi? 🤔",
        accentColor: Colors.grey,
        icon: Icons.help_outline,
      );
    }
    
    // Senaryo 5: "Kızgınım" - Gece oldu, hedef bitmedi
    if (isNightAndGoalNotMet) {
      return const MascotState(
        mood: MascotMood.kizginim,
        imagePath: MascotAssets.angry,
        message: "Benimle oyun oynama! O sorular çözülecek! 😤",
        accentColor: Colors.red,
        icon: Icons.mood_bad,
      );
    }
    
    // Varsayılan
    return MascotState.defaultState;
  }
  
  /// Gece hedef kontrolü (23:00'den sonra)
  static bool isNightAndGoalNotMet(Ogrenci ogrenci, int gunlukHedefSoru, int cozulenSoru) {
    final now = DateTime.now();
    return now.hour >= 23 && cozulenSoru < gunlukHedefSoru;
  }
  
  /// Son deneme netindeki değişimi hesapla
  static double? calculateNetChange() {
    final denemeler = VeriDeposu.denemeListesi;
    if (denemeler.length < 2) return null;
    
    final son = denemeler.last.toplamNet;
    final onceki = denemeler[denemeler.length - 2].toplamNet;
    return son - onceki;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MASKOT WİDGET'I (Dashboard Hero Card)
// ═══════════════════════════════════════════════════════════════════════════

class MascotCard extends StatelessWidget {
  final MascotState state;
  final VoidCallback? onTap;
  
  const MascotCard({
    super.key,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              state.accentColor.withAlpha(30),
              const Color(0xFF21262D),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: state.accentColor.withAlpha(50)),
          boxShadow: [
            BoxShadow(
              color: state.accentColor.withAlpha(20),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            // Maskot Görseli
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: state.accentColor.withAlpha(30),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  state.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    state.icon,
                    size: 48,
                    color: state.accentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Mesaj
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(state.icon, color: state.accentColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _getMoodTitle(state.mood),
                        style: TextStyle(
                          color: state.accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getMoodTitle(MascotMood mood) {
    switch (mood) {
      case MascotMood.kayiplardasin: return "💀 KAYIPLARDASIN";
      case MascotMood.beniUnuttun: return "😢 BENİ UNUTTUN";
      case MascotMood.panikModu: return "⏰ PANİK MODU";
      case MascotMood.zirvedesin: return "🔥 ZİRVEDESİN";
      case MascotMood.odaklanmaZamani: return "🧠 ODAKLANMA";
      case MascotMood.havalisin: return "😎 HAVALISIN";
      case MascotMood.neYaptinSen: return "😱 NE YAPTIN?";
      case MascotMood.kafamKaristi: return "🤔 KAFAM KARIŞTI";
      case MascotMood.kizginim: return "😤 KIZGINIM";
      case MascotMood.normal: return "👋 MERHABA";
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MASKOT ANİMASYONLU AVATAR (Küçük versiyon)
// ═══════════════════════════════════════════════════════════════════════════

class MascotAvatar extends StatefulWidget {
  final MascotState state;
  final double size;
  
  const MascotAvatar({
    super.key,
    required this.state,
    this.size = 48,
  });

  @override
  State<MascotAvatar> createState() => _MascotAvatarState();
}

class _MascotAvatarState extends State<MascotAvatar> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _bounceAnimation = Tween<double>(begin: 0, end: 5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_bounceAnimation.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.state.accentColor.withAlpha(30),
              shape: BoxShape.circle,
              border: Border.all(color: widget.state.accentColor, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                widget.state.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  widget.state.icon,
                  size: widget.size * 0.6,
                  color: widget.state.accentColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
