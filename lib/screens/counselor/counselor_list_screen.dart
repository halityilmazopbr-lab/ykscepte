import 'package:flutter/material.dart';
import '../../models/counselor_models.dart';

/// Danışman Listesi (Öğrenci Tarafı)
class CounselorListScreen extends StatelessWidget {
  const CounselorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final counselors = _getMockCounselors();

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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: const Color(0xFF6366F1),
              child: Text(
                counselor.name[0],
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
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
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: counselor.specializations.take(2).map((s) => Chip(
                      label: Text(s, style: const TextStyle(fontSize: 11)),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shirinkWrap,
                    )).toList(),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text('₺${counselor.monthlyPrice.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                const Text('/ay', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
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
                    const SnackBar(content: Text('Randevu sistemi yakında aktif olacak!')),
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
      Counselor(
        id: '1',
        name: 'Dr. Ayşe Yılmaz',
        email: 'ayse@example.com',
        phone: '555',
        specializations: ['Sınav Kaygısı', 'Motivasyon'],
        experienceYears: 10,
        level: CounselorLevel.expert,
        bio: 'Öğrencilerle çalışmayı seviyorum. YKS sürecinde 500+ öğrenciye destek verdim.',
        rating: 4.8,
        totalReviews: 127,
        monthlyPrice: 1999,
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
