import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'data.dart';
import 'models.dart';
import 'screens.dart';
import 'paywall_service.dart';
import 'ad_service.dart';
import 'pro_screen.dart';
import 'cache_service.dart';
import 'hata_defteri_screen.dart';
import 'odak_modu_screen.dart';
import 'flashcards_screen.dart';
import 'rapor_screen.dart';
import 'program_wizard_screen.dart';
import 'profil_ekrani.dart';
import 'envanter_listesi_screen.dart';
import 'veli_panel_screen.dart';
import 'ogretmen_randevu_screen.dart';
import 'ogrenci_randevu_screen.dart';
import 'yoklama_screen.dart';
import 'kurum_panel_screen.dart';
import 'kurum_duyurulari_screen.dart';
import 'user_provider.dart';
import 'bottom_nav_tabs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase başlatılamadı (Henüz google-services.json eklenmemiş olabilir): $e");
  }
  await VeriDeposu.init(); // Veritabanını başlat
  await CacheService.init(); // AI cache'i başlat
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YKS Cepte',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AcilisEkrani(),
    );
  }
}

// --- GİRİŞ EKRANI ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _k = TextEditingController(text: "ogrenci1"),
      _s = TextEditingController(text: "1234");
  // Veli için ayrı kontrolcüler
  final _veliOgrenciId = TextEditingController(text: "101");
  final _veliErisimKodu = TextEditingController(text: "123456");
  
  // Kurum yöneticisi için kontrolcüler
  final _kurumId = TextEditingController(text: "kurum1");
  final _kurumSifre = TextEditingController(text: "123456");
  
  late TabController _tc;
  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 5, vsync: this);
  }

  void _login() {
    var user = VeriDeposu.girisKontrol(_k.text, _s.text);
    if (user != null) {
      if (user == "admin") {
        VeriDeposu.girisKaydet("admin", "Yönetici");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (c) => const YoneticiPaneli()));
      } else if (user is Ogrenci) {
        VeriDeposu.girisKaydet(user.id, "Öğrenci");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (c) => OgrenciPaneli(aktifOgrenci: user)));
      } else if (user is Ogretmen) {
        VeriDeposu.girisKaydet(user.id, "Öğretmen");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (c) => OgretmenPaneli(aktifOgretmen: user as Ogretmen)));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Hatalı Giriş")));
    }
  }

  void _veliGiris() {
    var ogrenci = VeriDeposu.veliGirisKontrol(
      _veliOgrenciId.text, 
      _veliErisimKodu.text
    );
    if (ogrenci != null) {
      VeriDeposu.girisKaydet("veli_${ogrenci.id}", "Veli");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => VeliPaneli(ogrenci: ogrenci)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hatalı öğrenci ID veya erişim kodu")),
      );
    }
  }

  void _kurumGiris() {
    var (yonetici, kurum) = VeriDeposu.kurumYoneticisiGirisKontrol(
      _kurumId.text, 
      _kurumSifre.text
    );
    if (yonetici != null && kurum != null) {
      VeriDeposu.girisKaydet(yonetici.id, "KurumYoneticisi");
      VeriDeposu.aktifKurum = kurum;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => KurumPanelEkrani(kurum: kurum)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hatalı kurum ID veya şifre")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.deepPurple.shade200, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                    margin: const EdgeInsets.all(32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child:
                          Column(mainAxisSize: MainAxisSize.min, children: [
                          Image.asset(
                            'assets/logo.png',
                            height: 140,
                            width: 140,
                          ),
                          const SizedBox(height: 20),
                          TabBar(
                              controller: _tc,
                              labelColor: Colors.purple,
                              unselectedLabelColor: Colors.grey,
                              isScrollable: true,
                              tabs: const [
                                Tab(text: "Öğrenci"),
                                Tab(text: "Öğretmen"),
                                Tab(icon: Icon(Icons.business), text: "Kurum"),
                                Tab(icon: Icon(Icons.family_restroom), text: "Veli"),
                                Tab(text: "Admin"),
                              ]),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 180,
                            child: TabBarView(
                              controller: _tc,
                              children: [
                                _buildStandardLoginForm(),
                                _buildStandardLoginForm(),
                                _buildKurumLoginForm(),
                                _buildVeliLoginForm(),
                                _buildStandardLoginForm(),
                              ],
                            ),
                          ),
                        ]))))),
      ),
    );
  }

  Widget _buildStandardLoginForm() {
    return Column(
      children: [
        TextField(
            controller: _k,
            decoration: const InputDecoration(
                labelText: "Kullanıcı Adı",
                border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(
            controller: _s,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: "Şifre",
                border: OutlineInputBorder())),
        const SizedBox(height: 20),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: _login,
                child: const Text("GİRİŞ YAP"))),
      ],
    );
  }

  Widget _buildVeliLoginForm() {
    return Column(
      children: [
        TextField(
            controller: _veliOgrenciId,
            decoration: const InputDecoration(
                labelText: "Öğrenci ID / TC No",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(
            controller: _veliErisimKodu,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: "Veli Erişim Kodu",
                prefixIcon: Icon(Icons.vpn_key),
                border: OutlineInputBorder())),
        const SizedBox(height: 20),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
                onPressed: _veliGiris,
                icon: const Icon(Icons.family_restroom),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                label: const Text("VELİ GİRİŞİ"))),
      ],
    );
  }

  Widget _buildKurumLoginForm() {
    return Column(
      children: [
        TextField(
            controller: _kurumId,
            decoration: const InputDecoration(
                labelText: "Kurum ID",
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(
            controller: _kurumSifre,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: "Şifre",
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder())),
        const SizedBox(height: 20),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
                onPressed: _kurumGiris,
                icon: const Icon(Icons.business),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                label: const Text("KURUM GİRİŞİ", style: TextStyle(color: Colors.white)))),
      ],
    );
  }
}


// --- OTURUM KONTROL (SPLASH) ---
class AcilisEkrani extends StatefulWidget {
  const AcilisEkrani({super.key});
  @override
  State<AcilisEkrani> createState() => _AcilisEkraniState();
}

class _AcilisEkraniState extends State<AcilisEkrani>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animasyonu (nefes alma efekti)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    
    _oturumKontrol();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _oturumKontrol() async {
    await Future.delayed(const Duration(seconds: 3));
    String? kayitliId = VeriDeposu.aktifKullaniciId;
    String? kayitliRol = VeriDeposu.aktifKullaniciRol;
    if (kayitliId != null && kayitliRol != null) {
      if (kayitliRol == "Yönetici") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (c) => const YoneticiPaneli()));
      } else if (kayitliRol == "Öğrenci") {
        var user = VeriDeposu.ogrenciler.firstWhere((e) => e.id == kayitliId,
            orElse: () => VeriDeposu.ogrenciler[0]);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (c) => OgrenciPaneli(aktifOgrenci: user)));
      } else {
        var user = VeriDeposu.ogretmenler.firstWhere((e) => e.id == kayitliId,
            orElse: () => VeriDeposu.ogretmenler[0]);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (c) => OgretmenPaneli(aktifOgretmen: user)));
      }
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (c) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.grey.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animasyonlu Logo
              ScaleTransition(
                scale: _pulseAnimation,
                child: Image.asset(
                  'assets/logo.png',
                  height: 180,
                  width: 180,
                ),
              ),
              const SizedBox(height: 24),
              // Slogan
              const Text(
                "YKS Cepte",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Dijital Koçunuz",
                style: TextStyle(
                  color: Colors.deepPurple.withOpacity(0.7),
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Yükleme göstergesi
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.deepPurple,
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ÖĞRENCİ PANELİ (YENİ - BOTTOM NAV BAR) ---
class OgrenciPaneli extends StatefulWidget {
  final Ogrenci aktifOgrenci;
  const OgrenciPaneli({super.key, required this.aktifOgrenci});

  @override
  State<OgrenciPaneli> createState() => _OgrenciPaneliState();
}

class _OgrenciPaneliState extends State<OgrenciPaneli> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Tab içerikleri
    final List<Widget> _pages = [
      AnaSayfaSekmesi(ogrenci: widget.aktifOgrenci),
      AkademikSekmesi(ogrenci: widget.aktifOgrenci),
      AraclarSekmesi(ogrenci: widget.aktifOgrenci),
      KurumumSekmesi(ogrenci: widget.aktifOgrenci),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Row(
          children: [
            // Küçük logo
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo.png',
                height: 36,
                width: 36,
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: const Color(0xFF1A3A5C),
              radius: 18,
              child: Text(
                widget.aktifOgrenci.ad[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => ProfilEkrani(ogrenci: widget.aktifOgrenci)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.aktifOgrenci.ad,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.aktifOgrenci.seviyeRenk.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.aktifOgrenci.unvan,
                          style: TextStyle(
                            color: widget.aktifOgrenci.seviyeRenk,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Profil için dokun",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                      color: const Color(0xFF1A3A5C).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A3A5C),
        elevation: 2,
        shadowColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await VeriDeposu.cikisYap();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Akademik',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.build_outlined),
              activeIcon: Icon(Icons.build),
              label: 'Araçlar',
            ),
            BottomNavigationBarItem(
              icon: Icon(widget.aktifOgrenci.isKurumsal ? Icons.business_outlined : Icons.person_outlined),
              activeIcon: Icon(widget.aktifOgrenci.isKurumsal ? Icons.business : Icons.person),
              label: widget.aktifOgrenci.isKurumsal ? 'Kurumum' : 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
