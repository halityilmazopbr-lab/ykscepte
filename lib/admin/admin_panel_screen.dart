import 'package:flutter/material.dart';
import 'data.dart';
import 'models.dart';
import 'kurum_models.dart';
import 'diamond/diamond_service.dart';

/// 🔧 KAPSAMLI ADMİN PANELİ
/// 7 Ana Sekme: Dashboard, Kullanıcılar, Kurumlar, Ekonomi, İçerik, Duyurular, Ayarlar
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.red),
            SizedBox(width: 10),
            Text("Admin Paneli", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await VeriDeposu.cikisYap();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.red,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: "Dashboard"),
            Tab(icon: Icon(Icons.people), text: "Kullanıcılar"),
            Tab(icon: Icon(Icons.business), text: "Kurumlar"),
            Tab(icon: Icon(Icons.diamond), text: "Ekonomi"),
            Tab(icon: Icon(Icons.quiz), text: "İçerik"),
            Tab(icon: Icon(Icons.campaign), text: "Duyurular"),
            Tab(icon: Icon(Icons.settings), text: "Ayarlar"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildUsersTab(),
          _buildInstitutionsTab(),
          _buildEconomyTab(),
          _buildContentTab(),
          _buildAnnouncementsTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📊 1. DASHBOARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDashboardTab() {
    final totalStudents = VeriDeposu.ogrenciler.length;
    final totalTeachers = VeriDeposu.ogretmenler.length;
    final totalInstitutions = VeriDeposu.kurumlar.length;
    final totalQuestions = VeriDeposu.soruCozumListesi.fold<int>(0, (sum, s) => sum + s.dogru + s.yanlis);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          const Text(
            "📊 Genel Bakış",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // KPI Kartları
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildKPICard("👨‍🎓", "Öğrenci", totalStudents.toString(), Colors.blue),
              _buildKPICard("👨‍🏫", "Öğretmen", totalTeachers.toString(), Colors.purple),
              _buildKPICard("🏛️", "Kurum", totalInstitutions.toString(), Colors.indigo),
              _buildKPICard("✏️", "Çözülen Soru", totalQuestions.toString(), Colors.green),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Son Aktiviteler
          const Text(
            "🕐 Son Aktiviteler",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => Divider(color: Colors.grey.shade800, height: 1),
              itemBuilder: (context, index) {
                final activities = [
                  ("🆕", "Yeni öğrenci kaydı: Ahmet Y.", "2 dk önce"),
                  ("📝", "125 soru çözüldü", "15 dk önce"),
                  ("🏆", "Arena yarışması başladı", "1 saat önce"),
                  ("💎", "500 elmas dağıtıldı", "2 saat önce"),
                  ("📢", "Yeni duyuru yayınlandı", "3 saat önce"),
                ];
                final (emoji, title, time) = activities[index];
                return ListTile(
                  leading: Text(emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(title, style: const TextStyle(color: Colors.white)),
                  trailing: Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Hızlı İşlemler
          const Text(
            "⚡ Hızlı İşlemler",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickAction("📢 Duyuru Gönder", Colors.blue, () => _tabController.animateTo(5)),
              _buildQuickAction("💎 Elmas Dağıt", Colors.cyan, () => _showBulkDiamondDialog()),
              _buildQuickAction("👤 Kullanıcı Ekle", Colors.green, () => _tabController.animateTo(1)),
              _buildQuickAction("🏛️ Kurum Ekle", Colors.purple, () => _tabController.animateTo(2)),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildKPICard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }
  
  Widget _buildQuickAction(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👥 2. KULLANICILAR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildUsersTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF21262D),
            child: const TabBar(
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "Öğrenciler"),
                Tab(text: "Öğretmenler"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildStudentList(),
                _buildTeacherList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStudentList() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () => _showAddUserDialog(isStudent: true),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: VeriDeposu.ogrenciler.length,
        itemBuilder: (context, index) {
          final student = VeriDeposu.ogrenciler[index];
          return Card(
            color: const Color(0xFF161B22),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(student.ad[0], style: const TextStyle(color: Colors.white)),
              ),
              title: Text(student.ad, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                "${student.sinif} • ${student.puan} XP • 💎 Elmas yükleniyor...",
                style: TextStyle(color: Colors.grey.shade400),
              ),
              trailing: PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                color: const Color(0xFF21262D),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Düzenle', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem(value: 'diamond', child: Text('💎 Elmas Ver', style: TextStyle(color: Colors.cyan))),
                  const PopupMenuItem(value: 'reset', child: Text('Şifre Sıfırla', style: TextStyle(color: Colors.orange))),
                  const PopupMenuItem(value: 'delete', child: Text('Sil', style: TextStyle(color: Colors.red))),
                ],
                onSelected: (value) => _handleUserAction(student, value),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTeacherList() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
        onPressed: () => _showAddUserDialog(isStudent: false),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: VeriDeposu.ogretmenler.length,
        itemBuilder: (context, index) {
          final teacher = VeriDeposu.ogretmenler[index];
          return Card(
            color: const Color(0xFF161B22),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple,
                child: Text(teacher.ad[0], style: const TextStyle(color: Colors.white)),
              ),
              title: Text(teacher.ad, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                "Branş: ${teacher.brans}",
                style: TextStyle(color: Colors.grey.shade400),
              ),
              trailing: PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                color: const Color(0xFF21262D),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Düzenle', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem(value: 'students', child: Text('Öğrencileri Gör', style: TextStyle(color: Colors.blue))),
                  const PopupMenuItem(value: 'delete', child: Text('Sil', style: TextStyle(color: Colors.red))),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    VeriDeposu.kullaniciSil(teacher.id);
                    setState(() {});
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏛️ 3. KURUMLAR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildInstitutionsTab() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
        onPressed: _showAddInstitutionDialog,
      ),
      body: VeriDeposu.kurumlar.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_outlined, size: 80, color: Colors.grey.shade700),
                  const SizedBox(height: 16),
                  Text("Henüz kurum eklenmemiş", style: TextStyle(color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddInstitutionDialog,
                    icon: const Icon(Icons.add),
                    label: const Text("Kurum Ekle"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: VeriDeposu.kurumlar.length,
              itemBuilder: (context, index) {
                final kurum = VeriDeposu.kurumlar[index];
                return Card(
                  color: const Color(0xFF161B22),
                  child: ExpansionTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.business, color: Colors.white),
                    ),
                    title: Text(kurum.ad, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(kurum.adres, style: TextStyle(color: Colors.grey.shade400)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow("Kurum ID", kurum.id),
                            _buildInfoRow("Aktif Öğrenci", "${kurum.aktifOgrenciSayisi}"),
                            _buildInfoRow("Limit", "${kurum.ogrenciLimiti}"),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text("Düzenle"),
                                  onPressed: () {},
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                  label: const Text("Sil", style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    VeriDeposu.kurumlar.removeAt(index);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade400)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💎 4. EKONOMİ
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildEconomyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "💎 Elmas Ekonomisi",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Ekonomi KPI'ları
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildKPICard("💎", "Toplam Dağıtılan", "45,000", Colors.cyan),
              _buildKPICard("🛒", "Harcanan", "12,300", Colors.orange),
              _buildKPICard("💰", "Dolaşımdaki", "32,700", Colors.green),
              _buildKPICard("🎁", "Bugün Verilen", "850", Colors.purple),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Elmas İşlemleri
          const Text(
            "⚙️ Elmas İşlemleri",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          _buildActionCard(
            "Toplu Elmas Dağıt",
            "Tüm öğrencilere elmas gönder",
            Colors.cyan,
            Icons.diamond,
            _showBulkDiamondDialog,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            "Özel Ödül Ver",
            "Belirli bir kullanıcıya elmas ver",
            Colors.green,
            Icons.card_giftcard,
            _showGiftDiamondDialog,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            "Elmas Fiyatlarını Ayarla",
            "Kazanma/harcama oranlarını düzenle",
            Colors.orange,
            Icons.tune,
            () => _showSnack("Bu özellik yakında!"),
          ),
          
          const SizedBox(height: 24),
          
          // Ödül Mağazası
          const Text(
            "🛒 Ödül Mağazası Yönetimi",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            "Ürün Ekle/Düzenle",
            "Mağazadaki ürünleri yönet",
            Colors.purple,
            Icons.storefront,
            () => _showSnack("Bu özellik yakında!"),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionCard(String title, String subtitle, Color color, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600, size: 16),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 5. İÇERİK
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📚 İçerik Yönetimi",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // 🚩 SORU MODERASYON BÖLÜMÜ
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      "🔍 Soru İnceleme Kuyruğu",
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "3 soru bekliyor",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Olumsuz puan alan sorular burada incelemenizi bekliyor. 10 gün içinde incelenmezse otomatik silinir.",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: const Text("İnceleme Kuyruğunu Aç"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.all(14),
                    ),
                    onPressed: _showQuestionReviewDialog,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildActionCard(
            "🏆 Arena Yarışması Oluştur",
            "Yeni global challenge başlat",
            Colors.red,
            Icons.local_fire_department,
            () => _showSnack("Arena yönetimi yakında!"),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            "📺 Trivia Soruları",
            "Canlı yarışma sorularını düzenle",
            Colors.purple,
            Icons.quiz,
            () => _showSnack("Trivia yönetimi yakında!"),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            "📝 Soru Havuzu",
            "AI soru havuzunu yönet",
            Colors.blue,
            Icons.library_books,
            () => _showSnack("Soru havuzu yakında!"),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            "🎯 Haftalık Hedefler",
            "Kullanıcı hedeflerini ayarla",
            Colors.green,
            Icons.flag,
            () => _showSnack("Hedef yönetimi yakında!"),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            "🎁 Haftalık Ödül Anketi",
            "Ödül havuzunu ve anket zamanını ayarla",
            Colors.amber,
            Icons.poll,
            () => _showSnack("Anket yönetimi yakında!"),
          ),
        ],
      ),
    );
  }
  
  void _showQuestionReviewDialog() {
    // Demo veriler - gerçek uygulamada QuestionModerationService.getFlaggedQuestions() kullanılacak
    final flaggedQuestions = [
      {'id': 'q1', 'preview': 'Türev soru #124', 'negatives': 5, 'positives': 2, 'daysLeft': 3, 'reasons': ['Yanlış cevap', 'Anlaşılmaz']},
      {'id': 'q2', 'preview': 'İntegral soru #89', 'negatives': 4, 'positives': 1, 'daysLeft': 7, 'reasons': ['Yazım hatası']},
      {'id': 'q3', 'preview': 'Limit soru #56', 'negatives': 3, 'positives': 0, 'daysLeft': 9, 'reasons': ['Konu dışı', 'Yanlış cevap', 'Diğer']},
    ];
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF161B22),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF21262D),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      "İnceleme Bekleyen Sorular",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: flaggedQuestions.length,
                  itemBuilder: (context, index) {
                    final q = flaggedQuestions[index];
                    final isUrgent = (q['daysLeft'] as int) <= 2;
                    
                    return Card(
                      color: const Color(0xFF21262D),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    q['preview'] as String,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (isUrgent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "⏰ ${q['daysLeft']} gün kaldı!",
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else
                                  Text(
                                    "${q['daysLeft']} gün kaldı",
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Puanlar
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text("👍 ${q['positives']}", style: const TextStyle(color: Colors.green)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text("👎 ${q['negatives']}", style: const TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Sebepler
                            Wrap(
                              spacing: 4,
                              children: (q['reasons'] as List).map((r) => Chip(
                                label: Text(r, style: const TextStyle(fontSize: 10)),
                                backgroundColor: Colors.grey.shade800,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              )).toList(),
                            ),
                            const SizedBox(height: 12),
                            
                            // Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.check, color: Colors.green, size: 18),
                                  label: const Text("Onayla", style: TextStyle(color: Colors.green)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showSnack("Soru onaylandı: ${q['preview']}");
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.refresh, color: Colors.blue, size: 18),
                                  label: const Text("Sıfırla", style: TextStyle(color: Colors.blue)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showSnack("Puanlar sıfırlandı: ${q['preview']}");
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                  label: const Text("Sil", style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showSnack("Soru silindi: ${q['preview']}");
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📢 6. DUYURULAR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAnnouncementsTab() {
    final announcements = [
      ("📢", "Yeni özellik: Elmas ekonomisi!", "2 saat önce", true),
      ("🎉", "Yarışma: 1000 TL ödüllü Arena!", "1 gün önce", true),
      ("🔧", "Bakım duyurusu", "3 gün önce", false),
    ];
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text("Yeni Duyuru"),
        onPressed: _showNewAnnouncementDialog,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final (emoji, title, time, isActive) = announcements[index];
          return Card(
            color: const Color(0xFF161B22),
            child: ListTile(
              leading: Text(emoji, style: const TextStyle(fontSize: 28)),
              title: Text(title, style: const TextStyle(color: Colors.white)),
              subtitle: Text(time, style: TextStyle(color: Colors.grey.shade500)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("Aktif", style: TextStyle(color: Colors.green, fontSize: 12)),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ⚙️ 7. AYARLAR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "⚙️ Sistem Ayarları",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Genel Ayarlar
          _buildSettingsSection("Genel", [
            _buildSettingsTile("Uygulama Adı", "YKS Cepte", Icons.app_shortcut),
            _buildSettingsTile("Versiyon", "2.0.0", Icons.info),
            _buildSettingsTile("Bakım Modu", "Kapalı", Icons.build, isSwitch: true),
          ]),
          
          const SizedBox(height: 16),
          
          // Güvenlik
          _buildSettingsSection("Güvenlik", [
            _buildSettingsTile("Yeni Kayıt", "Açık", Icons.person_add, isSwitch: true, value: true),
            _buildSettingsTile("Google Girişi", "Açık", Icons.g_mobiledata, isSwitch: true, value: true),
            _buildSettingsTile("Admin Şifresi", "••••••", Icons.lock, hasAction: true),
          ]),
          
          const SizedBox(height: 16),
          
          // Tehlikeli Bölge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Tehlikeli Bölge", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text("Tüm Verileri Sil", style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: _showResetConfirmDialog,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
          ),
          ...children,
        ],
      ),
    );
  }
  
  Widget _buildSettingsTile(String title, String value, IconData icon, {bool isSwitch = false, bool value2 = false, bool hasAction = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade400),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: isSwitch
          ? Switch(value: value2, onChanged: (v) {}, activeColor: Colors.green)
          : hasAction
              ? const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16)
              : Text(value, style: TextStyle(color: Colors.grey.shade400)),
      onTap: hasAction ? () {} : null,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔧 YARDIMCI FONKSİYONLAR VE DİYALOGLAR
  // ═══════════════════════════════════════════════════════════════════════════
  
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue),
    );
  }
  
  void _handleUserAction(Ogrenci student, String action) {
    switch (action) {
      case 'edit':
        // TODO: Edit dialog
        break;
      case 'diamond':
        _showGiftDiamondToUserDialog(student);
        break;
      case 'reset':
        VeriDeposu.sifreSifirla(student.id);
        _showSnack("Şifre 123456 olarak sıfırlandı");
        break;
      case 'delete':
        VeriDeposu.kullaniciSil(student.id);
        setState(() {});
        break;
    }
  }
  
  void _showAddUserDialog({required bool isStudent}) {
    final adController = TextEditingController();
    final detayController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: Text(
          isStudent ? "Öğrenci Ekle" : "Öğretmen Ekle",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: adController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Ad Soyad",
                labelStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFF21262D),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: detayController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: isStudent ? "Sınıf (Örn: 12-A)" : "Branş (Örn: Matematik)",
                labelStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFF21262D),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (isStudent) {
                VeriDeposu.ogrenciEkle(adController.text, detayController.text);
              } else {
                VeriDeposu.ogretmenEkle(adController.text, detayController.text);
              }
              Navigator.pop(context);
              setState(() {});
              _showSnack("Kullanıcı eklendi!");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isStudent ? Colors.blue : Colors.purple,
            ),
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }
  
  void _showAddInstitutionDialog() {
    final adController = TextEditingController();
    final adresController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("Kurum Ekle", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: adController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Kurum Adı",
                labelStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFF21262D),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: adresController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Adres",
                labelStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFF21262D),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              VeriDeposu.kurumlar.add(Kurum(
                id: "kurum_${DateTime.now().millisecondsSinceEpoch}",
                ad: adController.text,
                adres: adresController.text,
                latitude: 0,
                longitude: 0,
              ));
              Navigator.pop(context);
              setState(() {});
              _showSnack("Kurum eklendi!");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }
  
  void _showBulkDiamondDialog() {
    final amountController = TextEditingController(text: "50");
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("💎 Toplu Elmas Dağıt", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Tüm öğrencilere elmas gönder",
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Elmas Miktarı",
                prefixIcon: const Icon(Icons.diamond, color: Colors.cyan),
                labelStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFF21262D),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text("Dağıt"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            onPressed: () async {
              final amount = int.tryParse(amountController.text) ?? 50;
              for (var o in VeriDeposu.ogrenciler) {
                await DiamondService.earnDiamonds(
                  ogrenciId: o.id,
                  amount: amount,
                  reason: "Admin toplu dağıtımı",
                );
              }
              Navigator.pop(context);
              _showSnack("${VeriDeposu.ogrenciler.length} öğrenciye ${amount}💎 dağıtıldı!");
            },
          ),
        ],
      ),
    );
  }
  
  void _showGiftDiamondDialog() {
    _showSnack("Kullanıcı listesinden 💎 Elmas Ver seçeneğini kullanın");
    _tabController.animateTo(1);
  }
  
  void _showGiftDiamondToUserDialog(Ogrenci student) {
    final amountController = TextEditingController(text: "100");
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: Text("💎 ${student.ad}'a Elmas Ver", style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Elmas Miktarı",
            prefixIcon: const Icon(Icons.diamond, color: Colors.cyan),
            labelStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFF21262D),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.card_giftcard),
            label: const Text("Gönder"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            onPressed: () async {
              final amount = int.tryParse(amountController.text) ?? 100;
              await DiamondService.earnDiamonds(
                ogrenciId: student.id,
                amount: amount,
                reason: "Admin ödülü",
              );
              Navigator.pop(context);
              _showSnack("${student.ad}'a ${amount}💎 gönderildi!");
            },
          ),
        ],
      ),
    );
  }
  
  void _showNewAnnouncementDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("📢 Yeni Duyuru", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Başlık",
                labelStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFF21262D),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "İçerik",
                labelStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFF21262D),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text("Yayınla"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              Navigator.pop(context);
              _showSnack("Duyuru yayınlandı: ${titleController.text}");
            },
          ),
        ],
      ),
    );
  }
  
  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text("Emin misiniz?", style: TextStyle(color: Colors.red)),
          ],
        ),
        content: const Text(
          "Bu işlem TÜM verileri silecek ve geri alınamaz!\n\nDevam etmek istiyor musunuz?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            onPressed: () async {
              await VeriDeposu.sifirla();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Evet, Sil"),
          ),
        ],
      ),
    );
  }
}
