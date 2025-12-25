import 'package:flutter/material.dart';
import 'subscription_service.dart';

/// Pro'ya Geç Ekranı
/// Şık glassmorphism tasarımıyla abonelik sayfası
class ProScreen extends StatefulWidget {
  const ProScreen({super.key});

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  bool _loading = false;
  String _selectedPlan = SubscriptionService.yearlyProductId;

  final List<_ProFeature> _features = [
    _ProFeature(Icons.all_inclusive, "Sınırsız Soru", "Günlük limit yok, istediğin kadar sor!"),
    _ProFeature(Icons.auto_awesome, "AI Asistan", "Yapay zeka ile sınırsız sohbet"),
    _ProFeature(Icons.analytics, "Detaylı Analiz", "Gelişmiş istatistikler ve grafikler"),
    _ProFeature(Icons.block, "Reklamsız", "Hiç reklam görmeden çalış"),
    _ProFeature(Icons.speed, "Öncelikli Destek", "Sorularına hızlı yanıt"),
    _ProFeature(Icons.cloud_sync, "Bulut Yedekleme", "Verilerini güvende tut"),
  ];

  void _purchase() async {
    setState(() => _loading = true);
    
    bool success = await SubscriptionService.purchase(_selectedPlan);
    
    setState(() => _loading = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Pro'ya hoş geldin! Tüm özellikler açıldı."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Satın alma tamamlanamadı. Tekrar deneyin."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _restore() async {
    setState(() => _loading = true);
    
    bool success = await SubscriptionService.restore();
    
    setState(() => _loading = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Aboneliğiniz geri yüklendi!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Geri yüklenecek abonelik bulunamadı."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "PRO'YA GEÇ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _loading ? null : _restore,
                      child: const Text(
                        "Geri Yükle",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Crown icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber.shade400, Colors.orange.shade600],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.workspace_premium, size: 60, color: Colors.white),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "YKS Cepte Pro",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Tüm özelliklere sınırsız erişim",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Psikolojik karşılaştırma metni
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          SubscriptionService.isLaunchMode 
                              ? "🎉 Lansman Fırsatı: ${SubscriptionService.yearlyComparison}"
                              : SubscriptionService.yearlyComparison,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Features
                      ...List.generate(_features.length, (i) => _buildFeatureRow(_features[i])),

                      const SizedBox(height: 30),

                      // Plan cards - 3 seçenek
                      if (SubscriptionService.isLaunchMode) ...[
                        // LANSMAN FIRSATI KART (Büyük, öne çıkan)
                        _buildPlanCard(
                          id: SubscriptionService.launchYearlyProductId,
                          title: "🔥 Yıllık Lansman",
                          price: SubscriptionService.launchYearlyPrice,
                          originalPrice: SubscriptionService.yearlyPrice,
                          subtitle: SubscriptionService.launchSavings,
                          isPopular: true,
                          isLaunch: true,
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildPlanCard(
                              id: SubscriptionService.monthlyProductId,
                              title: "Aylık",
                              price: SubscriptionService.monthlyPrice,
                              subtitle: SubscriptionService.monthlyComparison,
                              isPopular: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPlanCard(
                              id: SubscriptionService.yearlyProductId,
                              title: "Yıllık",
                              price: SubscriptionService.yearlyPrice,
                              subtitle: SubscriptionService.yearlySavings,
                              isPopular: !SubscriptionService.isLaunchMode,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Purchase button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _purchase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  "SATIN AL",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Terms
                      Text(
                        "Abonelik satın alındığında Google Play hesabınızdan tahsil edilir.\n"
                        "İptal edilmediği sürece otomatik yenilenir.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(_ProFeature feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(feature.icon, color: Colors.amber, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  feature.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String title,
    required String price,
    String? originalPrice,
    String? subtitle,
    bool isPopular = false,
    bool isLaunch = false,
  }) {
    bool isSelected = _selectedPlan == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "EN POPÜLER",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            if (originalPrice != null) ...[
              Text(
                originalPrice,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
            Text(
              price,
              style: TextStyle(
                color: isSelected ? (isLaunch ? Colors.green : Colors.amber) : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: isLaunch ? 18 : 14,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProFeature {
  final IconData icon;
  final String title;
  final String subtitle;

  _ProFeature(this.icon, this.title, this.subtitle);
}
