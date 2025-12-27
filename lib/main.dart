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
import 'teacher/teacher_main_screen.dart'; // 🔥 Yeni Öğretmen Modülü
import 'firebase_options.dart'; // Firebase yapılandırması
import 'services/cozum_gecmisi_service.dart'; // YENİ: Hybrid Filtering

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase başlatılamadı: $e");
  }
  
  await VeriDeposu.init();
  await CacheService.init();
  
  // YENİ: Hive init (Hybrid Filtering için)
  await CozumGecmisiService.init();
  
  runApp(const MainApp());
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

// --- GİRİŞ EKRANI (YENİ MODERN TASARIM) ---
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
  bool _obscurePassword = true;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 5, vsync: this);
  }
  
  @override
  void dispose() {
    _tc.dispose();
    _k.dispose();
    _s.dispose();
    _veliOgrenciId.dispose();
    _veliErisimKodu.dispose();
    _kurumId.dispose();
    _kurumSifre.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    
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
                builder: (c) => TeacherMainScreen(ogretmen: user as Ogretmen)));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(
            content: Text("❌ Hatalı kullanıcı adı veya şifre"),
            backgroundColor: Colors.red,
          ));
    }
    setState(() => _isLoading = false);
  }

  void _veliGiris() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    
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
        const SnackBar(
          content: Text("❌ Hatalı öğrenci ID veya erişim kodu"),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  void _kurumGiris() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    
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
        const SnackBar(
          content: Text("❌ Hatalı kurum ID veya şifre"),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  // Rol renkleri
  Color get _activeColor {
    switch (_tc.index) {
      case 0: return Colors.orange;      // Öğrenci
      case 1: return Colors.purple;      // Öğretmen
      case 2: return Colors.indigo;      // Kurum
      case 3: return Colors.green;       // Veli
      case 4: return Colors.red;         // Admin
      default: return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 30),
                
                // ═══════════════════════════════════════════════════════
                // LOGO VE BAŞLIK
                // ═══════════════════════════════════════════════════════
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple.shade400, Colors.purple.shade700],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    height: 80,
                    width: 80,
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  "YKS Cepte",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Dijital Koçunuz",
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 40),
                
                // ═══════════════════════════════════════════════════════
                // GİRİŞ KARTI
                // ═══════════════════════════════════════════════════════
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade800),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Tab Bar
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF21262D),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: TabBar(
                          controller: _tc,
                          onTap: (_) => setState(() {}),
                          labelColor: _activeColor,
                          unselectedLabelColor: Colors.grey.shade500,
                          indicatorColor: _activeColor,
                          indicatorWeight: 3,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                          tabs: const [
                            Tab(icon: Icon(Icons.school, size: 20), text: "Öğrenci"),
                            Tab(icon: Icon(Icons.history_edu, size: 20), text: "Öğretmen"),
                            Tab(icon: Icon(Icons.business, size: 20), text: "Kurum"),
                            Tab(icon: Icon(Icons.family_restroom, size: 20), text: "Veli"),
                            Tab(icon: Icon(Icons.admin_panel_settings, size: 20), text: "Admin"),
                          ],
                        ),
                      ),
                      
                      // Form İçeriği
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildActiveForm(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Alt Bilgi
                Text(
                  "© 2024 YKS Cepte - Tüm Hakları Saklıdır",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActiveForm() {
    switch (_tc.index) {
      case 0: return _buildOgrenciForm();
      case 1: return _buildOgretmenForm();
      case 2: return _buildKurumForm();
      case 3: return _buildVeliForm();
      case 4: return _buildAdminForm();
      default: return _buildOgrenciForm();
    }
  }
  
  Widget _buildOgrenciForm() {
    return Column(
      key: const ValueKey('ogrenci'),
      children: [
        _buildTextField(
          controller: _k,
          label: "Kullanıcı Adı / E-Posta",
          icon: Icons.person,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _s,
          label: "Şifre",
          icon: Icons.lock,
          color: Colors.orange,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        _buildLoginButton("GİRİŞ YAP", Colors.orange, _login),
        const SizedBox(height: 16),
        _buildInfoBox("Henüz hesabınız yok mu? Kayıt olmak için lütfen kurumunuza başvurun.", Colors.orange),
      ],
    );
  }
  
  Widget _buildOgretmenForm() {
    return Column(
      key: const ValueKey('ogretmen'),
      children: [
        _buildTextField(
          controller: _k,
          label: "TC No / Kullanıcı Adı",
          icon: Icons.badge,
          color: Colors.purple,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _s,
          label: "Şifre",
          icon: Icons.lock,
          color: Colors.purple,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        _buildLoginButton("ÖĞRETMEN GİRİŞİ", Colors.purple, _login),
        const SizedBox(height: 16),
        _buildInfoBox("Hesabınız kurum yöneticiniz tarafından oluşturulur.", Colors.purple),
      ],
    );
  }
  
  Widget _buildKurumForm() {
    return Column(
      key: const ValueKey('kurum'),
      children: [
        _buildTextField(
          controller: _kurumId,
          label: "Kurum ID",
          icon: Icons.business,
          color: Colors.indigo,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _kurumSifre,
          label: "Yönetici Şifresi",
          icon: Icons.lock,
          color: Colors.indigo,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        _buildLoginButton("KURUM GİRİŞİ", Colors.indigo, _kurumGiris),
      ],
    );
  }
  
  Widget _buildVeliForm() {
    return Column(
      key: const ValueKey('veli'),
      children: [
        _buildTextField(
          controller: _veliOgrenciId,
          label: "Öğrenci ID / TC No",
          icon: Icons.person_search,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _veliErisimKodu,
          label: "Veli Erişim Kodu",
          icon: Icons.vpn_key,
          color: Colors.green,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        _buildLoginButton("VELİ GİRİŞİ", Colors.green, _veliGiris),
        const SizedBox(height: 16),
        _buildInfoBox("Erişim kodunu öğrencinizden veya kurumunuzdan talep edebilirsiniz.", Colors.green),
      ],
    );
  }
  
  Widget _buildAdminForm() {
    return Column(
      key: const ValueKey('admin'),
      children: [
        _buildTextField(
          controller: _k,
          label: "Yönetici Kullanıcı Adı",
          icon: Icons.admin_panel_settings,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _s,
          label: "Şifre",
          icon: Icons.lock,
          color: Colors.red,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        _buildLoginButton("ADMİN GİRİŞİ", Colors.red, _login),
      ],
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: color),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade500,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF21262D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
    );
  }
  
  Widget _buildLoginButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 5,
          shadowColor: color.withOpacity(0.5),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                text,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
      ),
    );
  }
  
  Widget _buildInfoBox(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
        ],
      ),
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
            MaterialPageRoute(builder: (c) => TeacherMainScreen(ogretmen: user)));
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
              // Logo
              Image.asset(
                'assets/logo.png',
                height: 180,
                width: 180,
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
