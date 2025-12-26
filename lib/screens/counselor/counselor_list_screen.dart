import 'package:flutter/material.dart';
import '../../models/counselor_models.dart';
import '../../config/app_config.dart';

/// Danışman Listesi (Öğrenci Tarafı)
class CounselorListScreen extends StatelessWidget {
  const CounselorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    var counselors = _getMockCounselors();
    
    // Marketplace kapalıysa sadece kurucu görünsün
    if (!AppConfig.ENABLE_COUNSELOR_MARKETPLACE) {
      counselors = counselors.where((c) => c.isSupervisor).toList();
    }
    
    // SIRALAMA: Süpervizör → Online → Puan
    counselors.sort((a, b) {
      if (a.isSupervisor && !b.isSupervisor) return -1;
      if (!a.isSupervisor && b.isSupervisor) return 1;
      if (a.isOnlineNow && !b.isOnlineNow) return -1;
      if (!a.isOnlineNow && b.isOnlineNow) return 1;
      return b.rating.compareTo(a.rating);
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Uzman Danışmanlar', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: counselors.length,
        itemBuilder: (context, index) => _buildCounselorCard(counselors[index], context),
      ),
    );
  }

  Widget _buildCounselorCard(Counselor counselor, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: counselor.isSupervisor ? const Color(0xFFFFD700) : Colors.grey[200]!,
          width: counselor.isSupervisor ? 2 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (counselor.isSupervisor)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '👑 KURUCU DANIŞMAN - SÜPERVIZÖR',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: counselor.isSupervisor ? const Color(0xFFFFD700) : const Color(0xFF6366F1),
                      child: Text(
                        counselor.name[0],
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (counselor.isOnlineNow)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(counselor.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${counselor.rating.toStringAsFixed(1)} (${counselor.totalReviews} yorum)', 
                               style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${counselor.experienceYears} yıl deneyim', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      if (counselor.isOnlineNow)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('🟢 ŞİMDİ MÜSAIT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text('₺${counselor.monthlyPrice.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                    const Text('/ay', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    if (counselor.isOnlineNow)
                      ElevatedButton.icon(
                        onPressed: () => _showQuickCallDialog(context, counselor),
                        icon: const Icon(Icons.bolt, size: 16),
                        label: const Text('Hemen Görüş', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: () => _showCounselorDetail(context, counselor),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Detay', style: TextStyle(color: Colors.white)),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickCallDialog(BuildContext context, Counselor counselor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.bolt, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Text('${counselor.name} ile Hemen Görüş'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚡ 15 Dakikalık Ekspres Görüşme', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ Anında bağlanma', style: TextStyle(fontSize: 13)),
                  Text('✅ Acil destek', style: TextStyle(fontSize: 13)),
                  Text('✅ Sınav öncesi psikolojik hazırlık', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ücret:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₺150 (15 dk)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Zoom linki şuan devrede değil. Yakında aktif!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('BAĞLAN', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCounselorDetail(BuildContext context, Counselor counselor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF6366F1),
                  child: Text(counselor.name[0], style: const TextStyle(color: Colors.white, fontSize: 20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(counselor.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('${counselor.experienceYears} yıl deneyim', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('Uzmanlık Alanları:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: counselor.specializations.map((s) => Chip(label: Text(s))).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Hakkında:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(counselor.bio, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ödeme sistemi yakında aktif!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('₺${counselor.monthlyPrice.toInt()}/ay - PAKET SATIN AL', 
                     style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Counselor> _getMockCounselors() {
    return [
      // SEN - KURUCU DANIŞMAN (En üstte görünecek)
      Counselor(
        id: '0',
        name: 'Halit Yılmaz',
        email: 'halit@netx.app',
        phone: '555',
        specializations: ['Sınav Kaygısı', 'Motivasyon', 'Kariyer Danışmanlığı'],
        experienceYears: 15,
        level: CounselorLevel.expert,
        bio: 'NETX kurucusu. 15+ yıldır psikolojik danışmanlık alanında çalışıyorum. YKS öğrencilerine özel destek programları geliştirdim.',
        rating: 5.0,
        totalReviews: 247,
        monthlyPrice: 2499, // VIP paket fiyatı
        isSupervisor: true,
        isOnlineNow: true, // Şu an müsait
        createdAt: DateTime.now(),
      ),
      Counselor(
        id: '1',
        name: 'Dr. Ayşe Yılmaz',
        email: 'ayse@example.com',
        phone: '555',
        specializations: ['Sınav Kaygısı', 'Burnout'],
        experienceYears: 10,
        level: CounselorLevel.expert,
        bio: 'Öğrencilerle çalışmayı seviyorum. YKS sürecinde 500+ öğrenciye destek verdim.',
        rating: 4.8,
        totalReviews: 127,
        monthlyPrice: 1999,
        isOnlineNow: false,
        createdAt: DateTime.now(),
      ),
      Counselor(
        id: '2',
        name: 'Mehmet Demir',
        email: 'mehmet@example.com',
        phone: '555',
        specializations: ['Burnout', 'Kariyer Danışmanlığı'],
        experienceYears: 5,
        level: CounselorLevel.standard,
        bio: 'Genç yetişkinlerle kariyer ve motivasyon konularında çalışıyorum.',
        rating: 4.5,
        totalReviews: 63,
        monthlyPrice: 1599,
        isOnlineNow: true, // Şu an müsait
        createdAt: DateTime.now(),
      ),
      Counselor(
        id: '3',
        name: 'Zeynep Ak',
        email: 'zeynep@example.com',
        phone: '555',
        specializations: ['Sosyal Kaygı', 'Aile İlişkileri'],
        experienceYears: 2,
        level: CounselorLevel.beginner,
        bio: 'Yeni mezun psikologum. Öğrencilere destek olmayı hedefliyorum.',
        rating: 4.2,
        totalReviews: 18,
        monthlyPrice: 1199,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
