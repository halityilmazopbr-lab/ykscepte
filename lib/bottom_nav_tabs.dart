import 'package:flutter/material.dart';
import 'models.dart';
import 'data.dart';
import 'screens.dart' hide DenemeListesiEkrani;
import 'pro_screen.dart';
import 'hata_defteri_screen.dart';
import 'odak_modu_screen.dart';
import 'flashcards_screen.dart';
import 'rapor_screen.dart';
import 'program_wizard_screen.dart';
import 'profil_ekrani.dart';
import 'envanter_listesi_screen.dart';
import 'ogrenci_randevu_screen.dart';
import 'yoklama_screen.dart';
import 'kurum_duyurulari_screen.dart';
import 'kurum_ekranlari.dart';
import 'student_homework_screen.dart'; // 🔥 Yeni Ödev Modülü
import 'twin/twin.dart'; // 🧬 Sınav İkizi Modülü
import 'detective/detective.dart'; // 🕵️ NET-X Dedektifi
import 'league/league.dart'; // 🏆 NET-X Lig Modülü
import 'oracle/oracle.dart'; // 🔮 Kahin Modülü
import 'focus/focus.dart'; // 🎯 Focus Modülü
import 'trivia/trivia.dart'; // 📱 Canlı Trivia Modülü
import 'screens/library/silent_library_screen.dart'; // 🤫 Sessiz Kütüphane
import 'screens/rewards/goal_reward_screen.dart'; // 🎯 Hedef & Ödül Sistemi
import 'screens/rewards/reward_catalog_screen.dart'; // 🛒 Ödül Mağazası
import 'screens/counseling/counseling_packages_screen.dart'; // 🧠 Psikolojik Destek
import 'screens/counseling/my_counseling_screen.dart'; // 💼 Aktif Paket

/// Ana Sayfa Widget - Öğrenci Dashboard
/// Bottom Navigation Bar'ın "Ana Sayfa" sekmesi
class AnaSayfaSekmesi extends StatelessWidget {
  final Ogrenci ogrenci;
  const AnaSayfaSekmesi({super.key, required this.ogrenci});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- KİŞİYE ÖZEL KARŞILAMA ---
          _buildKarsilamaKarti(context),
          
          const SizedBox(height: 10),

          // --- YKS SAYACI ---
          _buildYksSayaci(context),
          
          // --- KAHİN KARTI ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OracleCard(
              currentTytNet: ogrenci.ortalamaNet ?? 50.0,
              targetRank: 20000,
              userName: ogrenci.ad,
              schoolName: ogrenci.okul,
            ),
          ),
          
          // --- SINAV İKİZİ KARTI ---
          TwinDailyWidget(
            odgrenciId: ogrenci.id,
            alan: ogrenci.alan,
            hedefBolum: ogrenci.hedefBolum,
          ),
          
          // --- HIZLI ERİŞİM ---
          _buildSectionHeader("⚡ HIZLI ERİŞİM", "En çok kullandığın özellikler"),
          _buildHorizontalList([
            _buildMenuCard(context, "Dedektif", Icons.search, DetectiveMainScreen(ogrenciId: ogrenci.id), Colors.red.shade700, Colors.redAccent),
            _buildMenuCard(context, "Programım", Icons.schedule, const TumProgramEkrani(), Colors.blueAccent, Colors.lightBlueAccent),
            _buildMenuCard(context, "Deneme Ekle", Icons.add_chart, DenemeEkleEkrani(ogrenciId: ogrenci.id), Colors.green, Colors.lightGreenAccent),
            _buildMenuCard(context, "Soru Çöz", Icons.camera_alt, SoruCozumEkrani(ogrenci: ogrenci), Colors.amber, Colors.yellow),
            _buildMenuCard(context, "Odak Modu", Icons.lock_clock, const FocusMenuScreen(), Colors.purple, Colors.purpleAccent),
          ]),

          // --- İLERLEME ANALİZİ ---
          _buildSectionHeader("📊 İLERLEME", "Başarına göz at"),
          _buildHorizontalList([
            _buildMenuCard(context, "Lig", Icons.emoji_events, LeagueScreen(ogrenciId: ogrenci.id, ogrenciAdi: ogrenci.ad, okulAdi: ogrenci.okul), Colors.amber.shade800, Colors.orangeAccent),
            _buildMenuCard(context, "Grafik", Icons.show_chart, BasariGrafigiEkrani(ogrenciId: ogrenci.id), Colors.purpleAccent, Colors.deepPurpleAccent),
            _buildMenuCard(context, "Rozetlerim", Icons.emoji_events, RozetlerEkrani(ogrenci: ogrenci), Colors.yellow.shade700, Colors.amberAccent),
            _buildMenuCard(context, "Günlük Takip", Icons.today, const GunlukTakipEkrani(), Colors.teal, Colors.greenAccent),
            _buildMenuCard(context, "Rapor", Icons.leaderboard, RaporEkrani(ogrenci: ogrenci), Colors.indigo, Colors.indigoAccent),
          ]),
          
          // --- CANLI TRIVIA BANNER ---
          _buildTriviaBanner(context),
          
          // --- PRO KARTI ---
          if (!ogrenci.isPro) ...[ 
            _buildProCard(context),
          ],
          
          const SizedBox(height: 100), // Bottom nav için boşluk
        ],
      ),
    );
  }

  Widget _buildKarsilamaKarti(BuildContext context) {
    final saat = DateTime.now().hour;
    String selamlama;
    if (saat < 12) {
      selamlama = "Günaydın";
    } else if (saat < 18) {
      selamlama = "İyi günler";
    } else {
      selamlama = "İyi akşamlar";
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.indigoAccent],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$selamlama, ${ogrenci.ad.split(' ').first}! 👋",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: VeriDeposu.seviyeYuzdesi,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    color: Colors.amberAccent,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Seviye ${VeriDeposu.seviye} • ${ogrenci.puan} XP",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
                Text(
                  "${ogrenci.gunlukSeri} Gün",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYksSayaci(BuildContext context) {
    final yksTarihi = DateTime(2026, 6, 20, 10, 0);
    final simdi = DateTime.now();
    final fark = yksTarihi.difference(simdi);
    final gun = fark.inDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade700, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            "YKS'ye $gun Gün",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Text("⏰", style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildTriviaBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LiveTriviaScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6200EA), Color(0xFF0F0F2D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.live_tv, color: Colors.redAccent, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "CANLI",
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Trivia Yarışması",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Bilgi yarışmasına katıl, elmas kazan!",
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
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
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: children,
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Widget page, Color startColor, Color endColor) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 6,
        shadowColor: startColor.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => page)),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shadowColor: Colors.amber.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ProScreen())),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.orange.shade600]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium, size: 28, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("PRO'YA GEÇ", style: TextStyle(fontSize: 16, color: Colors.amber, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Sınırsız soru, reklamsız!", style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Akademik Sekmesi - Ders takibi ve sınavlar
class AkademikSekmesi extends StatelessWidget {
  final Ogrenci ogrenci;
  const AkademikSekmesi({super.key, required this.ogrenci});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- DERSLER & TAKIP ---
          _buildSectionHeader("📘 DERSLER & TAKİP", "Planlı çalış, başarıyı yakala!"),
          _buildGridMenu(context, [
            _buildGridCard(context, "Programım", Icons.schedule, const TumProgramEkrani(), Colors.blueAccent),
            _buildGridCard(context, "Konu Takip", Icons.check_circle_outline, const KonuTakipEkrani(), Colors.teal),
            _buildGridCard(context, "Soru Takip", Icons.format_list_numbered, SoruTakipEkrani(ogrenciId: ogrenci.id), Colors.indigo),
            _buildGridCard(context, "Notlarım", Icons.notes, const OkulSinavlariEkrani(), Colors.brown),
            _buildGridCard(context, "Ödevlerim", Icons.assignment, StudentHomeworkScreen(ogrenci: ogrenci), Colors.pink),
          ]),
          
          // --- SINAV & ANALİZ ---
          _buildSectionHeader("📊 SINAV & ANALİZ", "Verilerle gelişimini gör."),
          _buildGridMenu(context, [
            _buildGridCard(context, "Deneme Ekle", Icons.add_chart, DenemeEkleEkrani(ogrenciId: ogrenci.id), Colors.green),
            _buildGridCard(context, "Denemelerim", Icons.assessment, DenemeListesiEkrani(ogrenciId: ogrenci.id, ogrenciAdi: ogrenci.ad), Colors.redAccent),
            _buildGridCard(context, "Grafik", Icons.show_chart, BasariGrafigiEkrani(ogrenciId: ogrenci.id), Colors.purpleAccent),
            _buildGridCard(context, "Rapor & Sıralama", Icons.leaderboard, RaporEkrani(ogrenci: ogrenci), Colors.indigo),
            _buildGridCard(context, "Günlük Takip", Icons.today, const GunlukTakipEkrani(), Colors.teal),
          ]),
          
          const SizedBox(height: 100),
        ],
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

  Widget _buildGridMenu(BuildContext context, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: children,
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, String title, IconData icon, Widget page, Color color) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 56) / 3,
      height: 100,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => page)),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: Colors.white),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Araçlar Sekmesi - AI ve yardımcı araçlar
class AraclarSekmesi extends StatelessWidget {
  final Ogrenci ogrenci;
  const AraclarSekmesi({super.key, required this.ogrenci});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- AI & ARAÇLAR ---
          _buildSectionHeader("🧠 AI & ARAÇLAR", "Teknolojinin gücünü kullan."),
          _buildGridMenu(context, [
            _buildGridCard(context, "Hata Defteri", Icons.menu_book, HataDefteriEkrani(ogrenciId: ogrenci.id), Colors.red),
            _buildGridCard(context, "Odak Modu", Icons.headphones, const OdakModuEkrani(), Colors.purple),
            _buildGridCard(context, "Flashcards", Icons.style, const FlashcardsEkrani(), Colors.pink),
            _buildGridCard(context, "Soru Üreteci", Icons.psychology, SoruUretecEkrani(ogrenci: ogrenci), Colors.deepOrange),
            _buildGridCard(context, "Program Sihirbazı", Icons.auto_awesome, const YeniProgramSihirbaziEkrani(), Colors.orange),
            _buildGridCard(context, "AI Asistan", Icons.chat, YapayZekaSohbetEkrani(ogrenci: ogrenci), Colors.cyan),
            _buildGridCard(context, "Soru Çöz", Icons.camera_alt, SoruCozumEkrani(ogrenci: ogrenci), Colors.amber),
            _buildGridCard(context, "Kronometre", Icons.timer, const KronometreEkrani(), Colors.lightBlue),
            _buildGridCard(context, "Rehberlik", Icons.psychology_alt, const EnvanterListesiEkrani(), Colors.teal),
            _buildGridCard(context, "Rozetlerim", Icons.emoji_events, RozetlerEkrani(ogrenci: ogrenci), Colors.yellow.shade700),
            _buildGridCard(context, "Sessiz Kütüphane", Icons.meeting_room, const SilentLibraryScreen(), Colors.indigo.shade800),
            _buildGridCard(context, "Hedeflerim", Icons.flag, const GoalRewardScreen(), Colors.green.shade700),
            _buildGridCard(context, "Ödül Mağazası", Icons.redeem, const RewardCatalogScreen(), Colors.orange.shade700),
            _buildGridCard(context, "Psikolojik Destek", Icons.psychology, const CounselingPackagesScreen(), Color(0xFF6366F1)),
            _buildGridCard(context, "Paketim", Icons.card_membership, const MyCounselingScreen(), Color(0xFF8B5CF6)),
          ]),
          
          const SizedBox(height: 100),
        ],
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

  Widget _buildGridMenu(BuildContext context, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: children,
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, String title, IconData icon, Widget page, Color color) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 56) / 3,
      height: 100,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => page)),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: Colors.white),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kurumum / Profil Sekmesi
/// Kurumsal öğrenciler için: Kurum özellikleri
/// Bireysel öğrenciler için: Profil ekranı
class KurumumSekmesi extends StatelessWidget {
  final Ogrenci ogrenci;
  const KurumumSekmesi({super.key, required this.ogrenci});

  @override
  Widget build(BuildContext context) {
    if (ogrenci.isKurumsal) {
      return _buildKurumsalIcerik(context);
    } else {
      return _buildBireyselIcerik(context);
    }
  }

  Widget _buildKurumsalIcerik(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kurum bilgi kartı
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade700, Colors.indigo.shade500],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ogrenci.kurumKodu ?? "Kurumum",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Kurumsal Öğrenci",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _buildSectionHeader("🏫 KURUM ÖZELLİKLERİ", "Kurumunuzla bağlantınız"),
          _buildGridMenu(context, [
            _buildGridCard(context, "Dersteyim", Icons.qr_code_scanner, YoklamaEkrani(ogrenci: ogrenci), Colors.green),
            _buildGridCard(context, "Birebir Al", Icons.calendar_today, OgrenciRandevuEkrani(ogrenci: ogrenci), Colors.indigo),
            _buildGridCard(context, "Duyurular", Icons.campaign, KurumDuyurulariEkrani(ogrenci: ogrenci), Colors.teal),
            _buildGridCard(context, "Denemeler", Icons.quiz, DenemeListesiEkrani(ogrenciId: ogrenci.id, ogrenciAdi: ogrenci.ad), Colors.deepOrange),
          ]),
          
          _buildSectionHeader("👤 PROFİL", "Hesap ayarları"),
          _buildGridMenu(context, [
            _buildGridCard(context, "Profilim", Icons.person, ProfilEkrani(ogrenci: ogrenci), Colors.deepPurple),
          ]),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBireyselIcerik(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil kartı
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade500],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    ogrenci.ad[0],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ogrenci.ad,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ogrenci.seviyeRenk.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ogrenci.unvan,
                          style: TextStyle(color: ogrenci.seviyeRenk, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 20),
              ],
            ),
          ),

          _buildSectionHeader("👤 PROFİL & AYARLAR", "Hesap yönetimi"),
          _buildGridMenu(context, [
            _buildGridCard(context, "Profilim", Icons.person, ProfilEkrani(ogrenci: ogrenci), Colors.deepPurple),
            _buildGridCard(context, "Hedeflerim", Icons.flag, ProfilEkrani(ogrenci: ogrenci), Colors.orange),
          ]),
          
          // Pro kartı (bireysel için)
          if (!ogrenci.isPro) ...[
            _buildSectionHeader("⭐ PRO ÜYELİK", "Sınırsız erişim için Pro'ya geç!"),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ProScreen())),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.workspace_premium, color: Colors.amber, size: 32),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text("PRO'ya Geç", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 100),
        ],
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

  Widget _buildGridMenu(BuildContext context, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: children,
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, String title, IconData icon, Widget page, Color color) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 56) / 3,
      height: 100,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => page)),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: Colors.white),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
