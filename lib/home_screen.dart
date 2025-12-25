import 'package:flutter/material.dart';
import 'models.dart';
import 'data.dart';

/// 🏠 YKS Cepte - Ana İskelet Ekranı
/// 
/// Dinamik Yapı:
/// - Kurumsal: "Kurumum" menüsü, QR Yoklama, Birebir Randevu
/// - Bireysel: "Mağaza" menüsü, Rehberlik, Odak Modu
class HomeScreen extends StatefulWidget {
  final Ogrenci ogrenci;
  const HomeScreen({super.key, required this.ogrenci});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _seciliIndex = 0;
  
  Ogrenci get user => widget.ogrenci;

  // Sayfa Listesi
  late final List<Widget> _sayfalar;

  @override
  void initState() {
    super.initState();
    _sayfalar = [
      _DashboardEkrani(ogrenci: user),           // 0: Ana Sayfa
      const Center(child: Text("Akademik / Program")),  // 1: Akademik (TODO: program_wizard_screen)
      
      // 2. Sayfa: Kişiye göre değişir
      user.isKurumsal 
          ? const Center(child: Text("Kurum İşlemleri (Randevu/Ödev)")) 
          : const Center(child: Text("Mağaza / Pro Üyelik")),
          
      const Center(child: Text("Profil Ayarları")),     // 3: Profil
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _sayfalar[_seciliIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seciliIndex,
        onDestinationSelected: (index) => setState(() => _seciliIndex = index),
        backgroundColor: const Color(0xFF0D1117),
        indicatorColor: Colors.purple.withAlpha(50),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          const NavigationDestination(icon: Icon(Icons.school), label: 'Akademik'),
          
          // 🎯 DİNAMİK MENÜ BUTONU
          NavigationDestination(
            icon: Icon(user.isKurumsal ? Icons.business : Icons.shopping_bag), 
            label: user.isKurumsal ? 'Kurumum' : 'Mağaza',
          ),
          
          const NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 📊 DASHBOARD EKRANI
// ═══════════════════════════════════════════════════════════════
class _DashboardEkrani extends StatelessWidget {
  final Ogrenci ogrenci;
  const _DashboardEkrani({required this.ogrenci});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1117), Color(0xFF161B22)],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ═══════════════════════════════════════════════════════════
            // 1. ÜST BAŞLIK (HEADER)
            // ═══════════════════════════════════════════════════════════
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Merhaba, ${ogrenci.ad.split(' ').first} 👋", 
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Bugün hedeflerini parçala!", 
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    ),
                  ],
                ),
                // Zincir ve Bildirim
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                          const SizedBox(width: 4),
                          Text("${ogrenci.gunlukSeri} Gün", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {}, 
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════
            // 2. AKSİYON KARTI (Hero Section)
            // ═══════════════════════════════════════════════════════════
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade700, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withAlpha(60),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag, color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      Text("Şu Anki Hedefin:", style: TextStyle(color: Colors.white.withAlpha(180))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ogrenci.hedefUniversite, 
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (ogrenci.hedefBolum.isNotEmpty)
                    Text(
                      ogrenci.hedefBolum, 
                      style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/program'),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("Çalışmaya Başla"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, 
                            foregroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════
            // 3. KISAYOLLAR GRİD MENÜSÜ (DİNAMİK ALAN)
            // ═══════════════════════════════════════════════════════════
            const Text("Hızlı Erişim", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildMenuCard(context, Icons.quiz, "Denemelerim", Colors.purple, '/denemeler'),
                _buildMenuCard(context, Icons.camera_alt, "Hata Defteri", Colors.orange, '/hataDefteriEkrani'),
                
                // ═══════ ŞARTA BAĞLI BUTONLAR ═══════
                
                if (ogrenci.isKurumsal)
                  _buildMenuCard(context, Icons.qr_code, "Dersteyim (QR)", Colors.green, '/yoklama')
                else
                  _buildMenuCard(context, Icons.psychology, "AI Koç", Colors.teal, '/sohbet'),

                if (ogrenci.isKurumsal)
                  _buildMenuCard(context, Icons.calendar_month, "Birebir Randevu", Colors.blue, '/randevu')
                else
                  _buildMenuCard(context, Icons.timer, "Odak Modu", Colors.red, '/odak'),
              ],
            ),

            const SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════
            // 4. FREE KULLANICI İÇİN PRO BANNER
            // ═══════════════════════════════════════════════════════════
            if (!ogrenci.isPro)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/pro'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade700, Colors.orange.shade600],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Limitlere takılma!", 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              "Pro'ya geç, rakiplerine fark at.", 
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
              
            // ═══════════════════════════════════════════════════════════
            // 5. KURUMSAL KULLANICI İÇİN DUYURU BANNER
            // ═══════════════════════════════════════════════════════════
            if (ogrenci.isKurumsal) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.withAlpha(40),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.indigo.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.campaign, color: Colors.indigo),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Kurum Duyuruları", 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${VeriDeposu.kurumDuyurulari.length} yeni duyuru var", 
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/kurumDuyurulari'),
                      child: const Text("Gör", style: TextStyle(color: Colors.indigo)),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 100), // Bottom nav için boşluk
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, IconData icon, String title, Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title, 
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
