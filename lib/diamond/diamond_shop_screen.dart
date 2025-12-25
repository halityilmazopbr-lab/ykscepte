import 'package:flutter/material.dart';
import 'diamond_service.dart';

/// 🛒 Elmas Mağazası Ekranı
/// Kazanç tablosu, harcama seçenekleri, bakiye gösterimi
class DiamondShopScreen extends StatefulWidget {
  final String ogrenciId;
  final String ogrenciAdi;
  
  const DiamondShopScreen({
    super.key,
    required this.ogrenciId,
    required this.ogrenciAdi,
  });

  @override
  State<DiamondShopScreen> createState() => _DiamondShopScreenState();
}

class _DiamondShopScreenState extends State<DiamondShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _balance = 0;
  bool _isLoading = true;
  bool _canWatchAd = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }
  
  Future<void> _loadData() async {
    final balance = await DiamondService.getBalance(widget.ogrenciId);
    final canWatchAd = await DiamondService.canWatchAd(widget.ogrenciId);
    
    if (mounted) {
      setState(() {
        _balance = balance;
        _canWatchAd = canWatchAd;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("💎 Elmas Mağazası", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyan,
          labelColor: Colors.cyan,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "MAĞAZA", icon: Icon(Icons.shopping_cart)),
            Tab(text: "KAZAN", icon: Icon(Icons.diamond)),
            Tab(text: "GEÇMİŞ", icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Bakiye Kartı
          _buildBalanceCard(),
          
          // Tab İçerikleri
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildShopTab(),
                _buildEarnTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // ═══════════════════════════════════════════════════════════════
  // 💰 BAKİYE KARTI
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan.shade700, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Elmas ikonu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text("💎", style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(width: 20),
          
          // Bakiye bilgisi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.ogrenciAdi,
                  style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14),
                ),
                const SizedBox(height: 4),
                _isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    : Text(
                        "$_balance",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                const Text("Elmas", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          
          // Yenile butonu
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }
  
  // ═══════════════════════════════════════════════════════════════
  // 🛒 MAĞAZA TAB
  // ═══════════════════════════════════════════════════════════════
  Widget _buildShopTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // En değerli ürün - Öne çıkan
        _buildFeaturedItem(),
        
        const SizedBox(height: 16),
        
        // Diğer ürünler
        _buildSectionTitle("🎁 Ürünler"),
        const SizedBox(height: 12),
        
        _buildShopItem(
          emoji: "🧠",
          title: "+10 AI Soru Hakkı",
          description: "Günlük kotanı aşınca bu paketle devam et",
          price: DiamondService.FIYAT_10_AI_SORU,
          color: Colors.purple,
          onPurchase: () => _purchaseItem(
            DiamondService.FIYAT_10_AI_SORU,
            DiamondService.purchaseAICredits,
            "+10 AI Soru Hakkı",
          ),
        ),
        
        _buildShopItem(
          emoji: "📚",
          title: "AI Flashcard Destesi",
          description: "Yapay zekaya otomatik kart hazırlat",
          price: DiamondService.FIYAT_AI_FLASHCARD,
          color: Colors.orange,
          onPurchase: () => _purchaseItem(
            DiamondService.FIYAT_AI_FLASHCARD,
            DiamondService.purchaseFlashcardDeck,
            "AI Flashcard Destesi",
          ),
        ),
        
        _buildShopItem(
          emoji: "🖼️",
          title: "Özel Profil Çerçevesi",
          description: "Profilini şık bir çerçeveyle süsle (Kalıcı)",
          price: DiamondService.FIYAT_PROFIL_CERCEVE,
          color: Colors.amber,
          badge: "STATÜ",
          onPurchase: () => _purchaseItem(
            DiamondService.FIYAT_PROFIL_CERCEVE,
            (id) => DiamondService.purchaseProfileFrame(id, "gold_frame"),
            "Profil Çerçevesi",
          ),
        ),
      ],
    );
  }
  
  Widget _buildFeaturedItem() {
    final canAfford = _balance >= DiamondService.FIYAT_24_SAAT_PRO;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.orange.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canAfford ? () => _purchase24HourPro() : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("👑", style: TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                "24 SAATLİK PRO",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text("⭐", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tüm Pro özelliklere 24 saat erişim",
                            style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Fiyat ve buton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text("💎", style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          "${DiamondService.FIYAT_24_SAAT_PRO}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: canAfford ? _purchase24HourPro : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange.shade800,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        canAfford ? "SATIN AL" : "YETERSİZ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                
                // İlerleme göstergesi
                if (!canAfford) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _balance / DiamondService.FIYAT_24_SAAT_PRO,
                      minHeight: 8,
                      backgroundColor: Colors.white.withAlpha(30),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${DiamondService.FIYAT_24_SAAT_PRO - _balance} elmas daha gerekli",
                    style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildShopItem({
    required String emoji,
    required String title,
    required String description,
    required int price,
    required Color color,
    required VoidCallback onPurchase,
    String? badge,
  }) {
    final canAfford = _balance >= price;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canAfford ? onPurchase : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(description, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        const Text("💎", style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          "$price",
                          style: TextStyle(
                            color: canAfford ? color : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (!canAfford)
                      Text("yetersiz", style: TextStyle(color: Colors.grey.shade600, fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ⛏️ KAZAN TAB
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEarnTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle("📊 Nasıl Kazanılır?"),
        const SizedBox(height: 12),
        
        _buildEarnItem(
          emoji: "📅",
          title: "Günlük Giriş",
          reward: DiamondService.GUNLUK_GIRIS,
          description: "Her gün uygulamaya gir",
        ),
        
        _buildEarnItem(
          emoji: "📺",
          title: "Reklam İzle",
          reward: DiamondService.REKLAM_IZLE,
          description: "Günde 1 kez",
          action: _canWatchAd ? _watchAd : null,
          actionLabel: _canWatchAd ? "İZLE" : "İZLENDİ",
        ),
        
        _buildEarnItem(
          emoji: "📝",
          title: "Ödev Tamamla",
          reward: DiamondService.ODEV_TAMAMLA,
          description: "Öğretmenin verdiği ödevi bitir",
        ),
        
        _buildEarnItem(
          emoji: "⚔️",
          title: "Düello Kazan",
          reward: DiamondService.DUELLO_KAZAN,
          description: "Günde max 3 kazanç",
        ),
        
        _buildEarnItem(
          emoji: "📕",
          title: "Hata Defteri Ekle",
          reward: DiamondService.HATA_DEFTERI_EKLE,
          description: "Yanlış soruyu kaydet",
        ),
        
        _buildEarnItem(
          emoji: "📊",
          title: "Deneme Sınavı Bitir",
          reward: DiamondService.DENEME_BITIR,
          description: "En büyük ödül!",
          highlight: true,
        ),
        
        const SizedBox(height: 24),
        
        // Hesaplama bilgisi
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withAlpha(50)),
          ),
          child: Column(
            children: [
              const Text(
                "💡 Günlük Ortalama",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Disiplinli bir öğrenci günde ~30-40 💎 kazanabilir",
                style: TextStyle(color: Colors.green.shade200, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "1 hafta = 1 adet 24 Saatlik Pro 👑",
                style: TextStyle(color: Colors.green.shade300, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildEarnItem({
    required String emoji,
    required String title,
    required int reward,
    required String description,
    VoidCallback? action,
    String? actionLabel,
    bool highlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? Colors.amber.withAlpha(20) : const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(12),
        border: highlight ? Border.all(color: Colors.amber.withAlpha(50)) : null,
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(description, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ),
          if (action != null)
            ElevatedButton(
              onPressed: action,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(actionLabel ?? "AL"),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: highlight ? Colors.amber.withAlpha(50) : Colors.cyan.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text("💎", style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    "+$reward",
                    style: TextStyle(
                      color: highlight ? Colors.amber : Colors.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  // ═══════════════════════════════════════════════════════════════
  // 📜 GEÇMİŞ TAB
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHistoryTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DiamondService.getHistory(widget.ogrenciId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final history = snapshot.data ?? [];
        
        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey.shade600),
                const SizedBox(height: 16),
                const Text("Henüz işlem geçmişi yok", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[history.length - 1 - index]; // Tersine çevir
            final isPositive = (item['change'] as int) > 0;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isPositive ? Icons.add_circle : Icons.remove_circle,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['reason'] ?? 'İşlem',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        Text(
                          item['timestamp']?.toString().substring(0, 16) ?? '',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${isPositive ? '+' : ''}${item['change']} 💎",
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  // ═══════════════════════════════════════════════════════════════
  // 🔧 YARDIMCI FONKSİYONLAR
  // ═══════════════════════════════════════════════════════════════
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
  
  Future<void> _purchase24HourPro() async {
    final confirm = await _showConfirmDialog(
      title: "24 Saatlik Pro",
      message: "250 💎 karşılığında 24 saat Pro özelliklere erişim sağlayacaksınız.",
    );
    
    if (confirm) {
      final success = await DiamondService.purchase24HourPro(widget.ogrenciId);
      _showResult(success, "24 Saatlik Pro");
    }
  }
  
  Future<void> _purchaseItem(int price, Future<bool> Function(String) purchase, String name) async {
    final confirm = await _showConfirmDialog(
      title: name,
      message: "$price 💎 karşılığında satın almak istiyor musunuz?",
    );
    
    if (confirm) {
      final success = await purchase(widget.ogrenciId);
      _showResult(success, name);
    }
  }
  
  Future<void> _watchAd() async {
    // TODO: Gerçek reklam SDK entegrasyonu
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.cyan),
            const SizedBox(height: 16),
            Text("Reklam yükleniyor...", style: TextStyle(color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
    
    // Simülasyon: 2 saniye bekle
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) Navigator.pop(context);
    
    final success = await DiamondService.claimAdReward(widget.ogrenciId);
    _showResult(success, "Reklam izleme ödülü");
  }
  
  Future<bool> _showConfirmDialog({required String title, required String message}) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: TextStyle(color: Colors.grey.shade400)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            child: const Text("Onayla"),
          ),
        ],
      ),
    ) ?? false;
  }
  
  void _showResult(bool success, String itemName) {
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ $itemName satın alındı!"),
          backgroundColor: Colors.green,
        ),
      );
      _loadData(); // Bakiyeyi güncelle
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ İşlem başarısız!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
