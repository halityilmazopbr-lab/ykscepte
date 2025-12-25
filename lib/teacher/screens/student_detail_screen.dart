import 'package:flutter/material.dart';
import '../../models.dart';
import '../../data.dart';
import '../teacher_service.dart';
import '../models/teacher_models.dart';

/// 🕵️ Öğrenci Detay Ekranı (Ajan Modu)
/// Öğretmen için öğrenci röntgeni: Aktivite, Net takibi, Veli mesaj
class StudentDetailScreen extends StatelessWidget {
  final Ogrenci ogrenci;
  final String teacherId;
  
  const StudentDetailScreen({
    super.key, 
    required this.ogrenci,
    required this.teacherId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: Text(ogrenci.ad, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Colors.green),
            tooltip: 'Veliye Mesaj Gönder',
            onPressed: () => _showVeliMesajDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════════
            // PROFİL KARTI
            // ═══════════════════════════════════════════════════════
            _buildProfilKarti(),
            
            const SizedBox(height: 20),
            
            // ═══════════════════════════════════════════════════════
            // HAFTALIK AKTİVİTE
            // ═══════════════════════════════════════════════════════
            _buildSectionTitle("📊 Haftalık Aktivite"),
            const SizedBox(height: 12),
            _buildAktiviteKartlari(),
            
            const SizedBox(height: 20),
            
            // ═══════════════════════════════════════════════════════
            // NET TAKİBİ
            // ═══════════════════════════════════════════════════════
            _buildSectionTitle("📈 Net Değişimi (Son 5 Deneme)"),
            const SizedBox(height: 12),
            _buildNetGrafik(),
            
            const SizedBox(height: 20),
            
            // ═══════════════════════════════════════════════════════
            // ÖDEV DURUMU
            // ═══════════════════════════════════════════════════════
            _buildSectionTitle("📝 Ödev Durumu"),
            const SizedBox(height: 12),
            _buildOdevDurumu(),
            
            const SizedBox(height: 20),
            
            // ═══════════════════════════════════════════════════════
            // HIZLI AKSIYONLAR
            // ═══════════════════════════════════════════════════════
            _buildSectionTitle("⚡ Hızlı Aksiyonlar"),
            const SizedBox(height: 12),
            _buildAksiyonlar(context),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfilKarti() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade800, Colors.indigo.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                ogrenci.ad[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Bilgiler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ogrenci.ad,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${ogrenci.sinif} • ${ogrenci.hedefBolum ?? 'Hedef belirlenmemiş'}",
                  style: TextStyle(color: Colors.white.withAlpha(180)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMiniStat("🔥", "${ogrenci.gunlukSeri} Gün"),
                    const SizedBox(width: 12),
                    _buildMiniStat("⭐", "${ogrenci.puan} XP"),
                    const SizedBox(width: 12),
                    if (ogrenci.isPro)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "PRO",
                          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMiniStat(String emoji, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$emoji $value",
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildAktiviteKartlari() {
    // Demo veriler
    final aktivite = {
      'Bu Hafta Giriş': '5 kez',
      'Çözülen Soru': '127 soru',
      'Ortalama Süre': '2.5 saat/gün',
      'Son Giriş': 'Bugün 14:30',
    };
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: aktivite.entries.map((e) => _buildStatCard(e.key, e.value)).toList(),
    );
  }
  
  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNetGrafik() {
    // Demo net verileri
    final netler = [42.5, 45.0, 43.0, 48.5, 52.0];
    final maxNet = netler.reduce((a, b) => a > b ? a : b);
    final minNet = netler.reduce((a, b) => a < b ? a : b);
    final sonFark = netler.last - netler[netler.length - 2];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Özet satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNetStat("Son Net", "${netler.last}", Colors.blue),
              _buildNetStat("Değişim", "${sonFark >= 0 ? '+' : ''}${sonFark.toStringAsFixed(1)}", 
                  sonFark >= 0 ? Colors.green : Colors.red),
              _buildNetStat("En Yüksek", "$maxNet", Colors.amber),
            ],
          ),
          const SizedBox(height: 16),
          
          // Basit çubuk grafik
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: netler.asMap().entries.map((e) {
                final index = e.key;
                final net = e.value;
                final height = (net / 60) * 80; // 60 max net varsayımı
                final isLast = index == netler.length - 1;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      net.toStringAsFixed(1),
                      style: TextStyle(
                        color: isLast ? Colors.blue : Colors.grey.shade500,
                        fontSize: 10,
                        fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 40,
                      height: height,
                      decoration: BoxDecoration(
                        color: isLast ? Colors.blue : Colors.blue.withAlpha(100),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "D${index + 1}",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNetStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      ],
    );
  }
  
  Widget _buildOdevDurumu() {
    // Demo ödev durumu
    final odevler = [
      {'konu': 'Türev Test 4', 'durum': 'yapildi', 'tarih': 'Dün'},
      {'konu': 'Trigonometri', 'durum': 'bekliyor', 'tarih': 'Yarın'},
      {'konu': 'Limit Sorları', 'durum': 'gecikti', 'tarih': '2 gün önce'},
    ];
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: odevler.asMap().entries.map((e) {
          final odev = e.value;
          final isLast = e.key == odevler.length - 1;
          
          Color statusColor;
          IconData statusIcon;
          String statusText;
          
          switch (odev['durum']) {
            case 'yapildi':
              statusColor = Colors.green;
              statusIcon = Icons.check_circle;
              statusText = 'Yapıldı';
              break;
            case 'bekliyor':
              statusColor = Colors.orange;
              statusIcon = Icons.schedule;
              statusText = 'Bekliyor';
              break;
            default:
              statusColor = Colors.red;
              statusIcon = Icons.warning;
              statusText = 'Gecikti';
          }
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade800)),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        odev['konu']!,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        odev['tarih']!,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildAksiyonlar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildAksiyonButon(
            icon: Icons.message,
            label: "Veliye Bildir",
            color: Colors.green,
            onTap: () => _showVeliMesajDialog(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAksiyonButon(
            icon: Icons.assignment_add,
            label: "Ödev Ver",
            color: Colors.orange,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ödev verme ekranına git")),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAksiyonButon(
            icon: Icons.psychology,
            label: "AI Analiz",
            color: Colors.purple,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("🚧 AI Analiz yakında!")),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAksiyonButon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showVeliMesajDialog(BuildContext context) {
    final mesajController = TextEditingController();
    
    // Hazır mesaj şablonları
    final sablonlar = [
      "Sayın veli, ${ogrenci.ad} bu hafta ödevlerini düzenli olarak tamamladı. Tebrikler!",
      "Sayın veli, ${ogrenci.ad}'ın bu hafta derse katılımı düşük. Takip etmenizi rica ederiz.",
      "Sayın veli, ${ogrenci.ad}'ın son deneme netinde artış gözlemlendi. Harika bir gelişme!",
      "Sayın veli, ${ogrenci.ad}'ın geciken ödevleri bulunmaktadır. Lütfen kontrol ediniz.",
    ];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF161B22),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Başlık
                const Text(
                  "📱 Veliye Mesaj Gönder",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${ogrenci.ad}'ın velisine bildirim",
                  style: TextStyle(color: Colors.grey.shade500),
                ),
                
                const SizedBox(height: 20),
                
                // Hazır şablonlar
                const Text(
                  "Hazır Şablonlar:",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sablonlar.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => mesajController.text = sablonlar[index],
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF21262D),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade700),
                          ),
                          child: Text(
                            sablonlar[index],
                            style: TextStyle(color: Colors.grey.shade300, fontSize: 11),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Mesaj girişi
                TextField(
                  controller: mesajController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Mesajınızı yazın veya yukarıdan şablon seçin...",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: const Color(0xFF21262D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Gönder butonu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("✅ Veliye mesaj gönderildi: ${mesajController.text.substring(0, 30.clamp(0, mesajController.text.length))}..."),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text("Mesaj Gönder"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
