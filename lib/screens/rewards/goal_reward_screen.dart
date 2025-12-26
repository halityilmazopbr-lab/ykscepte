import 'package:flutter/material.dart';
import '../../models/reward_models.dart';

class GoalRewardScreen extends StatelessWidget {
  const GoalRewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Örnek Veriler
    final List<StudyGoal> goals = [
      StudyGoal(
        id: '1',
        title: "Haftalık 500 Paragraf Sorusu", 
        rewardName: "200 TL D&R Çeki", 
        targetValue: 500,
        currentValue: 325,
        isSponsored: true
      ),
      StudyGoal(
        id: '2',
        title: "AYT Matematik Denemesi", 
        rewardName: "Sinema Bileti", 
        targetValue: 10,
        currentValue: 0,
        isSponsored: false
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Hedef ve Ödüllerim", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 25),
            Text("AKTİF HEDEFLER", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) => _buildGoalCard(goals[index], context),
              ),
            ),
            const SizedBox(height: 10),
            _buildCreateGoalButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Kazanılan Ödüller", style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 5),
              Text("₺ 450.00", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 30),
          )
        ],
      ),
    );
  }

  Widget _buildGoalCard(StudyGoal goal, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text("Ödül: ${goal.rewardName}", style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                goal.isSponsored
                    ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                    : ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veliye SMS linki kopyalandı!")));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                        ),
                        child: const Text("Onay İste", style: TextStyle(fontSize: 12, color: Colors.white)),
                      )
              ],
            ),
            const SizedBox(height: 15),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                LinearProgressIndicator(
                  value: goal.progress,
                  backgroundColor: Colors.grey[200],
                  color: goal.isSponsored ? Colors.green : Colors.grey,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 5),
                Text("%${goal.progressPercent} Tamamlandı", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
            
            if (!goal.isSponsored)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "⚠ Veli onayı bekleniyor. İlerlemen kaydediliyor ancak ödül kilitli.",
                  style: TextStyle(color: Colors.orange[800], fontSize: 11, fontStyle: FontStyle.italic),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildCreateGoalButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Yeni hedef belirleme ekranına git
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hedef oluşturma ekranı yakında eklenecek!")));
        },
        icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
        label: const Text("YENİ HEDEF BELİRLE", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
