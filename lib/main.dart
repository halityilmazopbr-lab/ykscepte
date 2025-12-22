import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'models.dart';
import 'screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VeriDeposu.init(); // Veritabanını ve Oturumu başlat
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bayburt YKS Cepte',
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
  late TabController _tc;
  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
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
                          const Icon(Icons.school,
                              size: 80, color: Colors.deepPurple),
                          const Text("Eğitim Asistanı",
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          TabBar(
                              controller: _tc,
                              labelColor: Colors.purple,
                              unselectedLabelColor: Colors.grey,
                              tabs: const [
                                Tab(text: "Öğrenci"),
                                Tab(text: "Öğretmen"),
                                Tab(text: "Yönetici")
                              ]),
                          const SizedBox(height: 20),
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
                                  child: const Text("GİRİŞ YAP")))
                        ]))))),
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

class _AcilisEkraniState extends State<AcilisEkrani> {
  @override
  void initState() {
    super.initState();
    _oturumKontrol();
  }

  void _oturumKontrol() async {
    await Future.delayed(const Duration(seconds: 2));
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
    return const Scaffold(
        backgroundColor: Colors.deepPurple,
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Icon(Icons.school, size: 100, color: Colors.white),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white)
            ])));
  }
}

// --- ÖĞRENCİ PANELİ ---
class OgrenciPaneli extends StatelessWidget {
  final Ogrenci aktifOgrenci;
  const OgrenciPaneli({super.key, required this.aktifOgrenci});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(aktifOgrenci.ad[0],
                    style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Merhaba, ${aktifOgrenci.ad}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Bugün harika işler başaracaksın!",
                      style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
                ],
              ),
            ],
          ),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await VeriDeposu.cikisYap();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (c) => const LoginPage()));
                })
          ]),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STATS CARD (SABİT) ---
            Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Colors.deepPurple, Colors.indigoAccent]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8))
                    ]),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Seviye ${VeriDeposu.seviye}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22)),
                            const SizedBox(height: 8),
                            SizedBox(
                                width: 160,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                      value: VeriDeposu.seviyeYuzdesi,
                                      minHeight: 8,
                                      backgroundColor: Colors.white24,
                                      color: Colors.amberAccent),
                                )),
                            const SizedBox(height: 8),
                            Text("${aktifOgrenci.puan} XP",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14))
                          ]),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: Column(children: [
                          const Icon(Icons.local_fire_department,
                              color: Colors.orange, size: 32),
                          Text("${aktifOgrenci.gunlukSeri} Gün",
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
                        ]),
                      )
                    ])),

            const SizedBox(height: 10),

            // --- 1. BOLUM: DERSLER & TAKIP ---
            _buildSectionHeader("📘 DERSLER & TAKİP", "Planlı çalış, başarıyı yakala!"),
            _buildHorizontalList([
               _buildMenuCard(context, "Programım", Icons.schedule, const TumProgramEkrani(), Colors.blueAccent, Colors.lightBlueAccent),
               _buildMenuCard(context, "Konu Takip", Icons.check_circle_outline, const KonuTakipEkrani(), Colors.teal, Colors.cyanAccent),
               _buildMenuCard(context, "Soru Takip", Icons.format_list_numbered, SoruTakipEkrani(ogrenciId: aktifOgrenci.id), Colors.indigo, Colors.blue),
               _buildMenuCard(context, "Notlarım", Icons.notes, const OkulSinavlariEkrani(), Colors.brown, Colors.orange),
               _buildMenuCard(context, "Ödevlerim", Icons.assignment, const OdevlerEkrani(), Colors.pink, Colors.red),
            ]),

            // --- 2. BOLUM: SINAV & ANALIZ ---
            _buildSectionHeader("📊 SINAV & ANALİZ", "Verilerle gelişimini gör."),
            _buildHorizontalList([
               _buildMenuCard(context, "Deneme Ekle", Icons.add_chart, DenemeEkleEkrani(ogrenciId: aktifOgrenci.id), Colors.green, Colors.lightGreenAccent),
               _buildMenuCard(context, "Denemelerim", Icons.assessment, DenemeListesiEkrani(ogrenciId: aktifOgrenci.id), Colors.redAccent, Colors.pinkAccent),
               _buildMenuCard(context, "Grafik", Icons.show_chart, BasariGrafigiEkrani(ogrenciId: aktifOgrenci.id), Colors.purpleAccent, Colors.deepPurpleAccent),
               _buildMenuCard(context, "Rozetlerim", Icons.emoji_events, RozetlerEkrani(ogrenci: aktifOgrenci), Colors.yellow.shade700, Colors.amberAccent),
               _buildMenuCard(context, "Günlük Takip", Icons.today, const GunlukTakipEkrani(), Colors.teal, Colors.greenAccent),
            ]),

            // --- 3. BOLUM: AI & ARACLAR ---
            _buildSectionHeader("🧠 AI & ARAÇLAR", "Teknolojinin gücünü kullan."),
            _buildHorizontalList([
               _buildMenuCard(context, "Soru Üreteci", Icons.psychology, const SoruUretecEkrani(), Colors.deepOrange, Colors.orangeAccent),
               _buildMenuCard(context, "Sihirbaz", Icons.auto_awesome, const ProgramSecimEkrani(), Colors.orangeAccent, Colors.yellowAccent),
               _buildMenuCard(context, "AI Asistan", Icons.chat, const YapayZekaSohbetEkrani(), Colors.cyan, Colors.lightBlue),
               _buildMenuCard(context, "Soru Çöz", Icons.camera_alt, const SoruCozumEkrani(), Colors.amber, Colors.yellow),
               _buildMenuCard(context, "Kronometre", Icons.timer, const KronometreEkrani(), Colors.lightBlue, Colors.cyan),
            ]),
            
            const SizedBox(height: 30), // Alt bosluk
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Colors.black87)),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<Widget> children) {
    return SizedBox(
      height: 160, // KART YUKSEKLIGI
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: children,
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon,
      Widget page, Color startColor, Color endColor) {
    return Container(
      width: 130, // KART GENISLIGI
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 6,
        shadowColor: startColor.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (c) => page)),
            borderRadius: BorderRadius.circular(20),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                        colors: [startColor, endColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 32, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold))
                      ]),
                ))),
      ),
    );
  }
}
