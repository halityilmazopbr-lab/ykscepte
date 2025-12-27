import 'package:flutter/material.dart';
import '../../models.dart';
import '../teacher_service.dart';
import '../models/teacher_models.dart';
import 'teacher_reports_screen.dart';

/// 📊 Öğretmen Kokpit (Dashboard) - KPI'lar ve Günlük Özet
class TeacherDashboard extends StatelessWidget {
  final Ogretmen ogretmen;
  
  const TeacherDashboard({super.key, required this.ogretmen});

  @override
  Widget build(BuildContext context) {
    final schedule = TeacherService.getDemoSchedule(ogretmen.id);
    final assignments = TeacherService.getDemoAssignments(ogretmen.id);
    
    // Bugünkü dersler
    final todayLessons = schedule.where(
      (l) => l.dayOfWeek == DateTime.now().weekday
    ).toList();
    
    // Bekleyen ödevler
    final pendingAssignments = assignments.where(
      (a) => !a.isOverdue && a.completionRate < 1.0
    ).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Merhaba, ${ogretmen.ad} 👋",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              "${ogretmen.brans} Zümresi",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_active, color: Colors.orange),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('3', style: TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ═══════════════════════════════════════════════════════
          // 1. KPI KARTLARI
          // ═══════════════════════════════════════════════════════
          Row(
            children: [
              _buildSummaryCard("Bekleyen Ödev", "${pendingAssignments.length}", Colors.orange),
              const SizedBox(width: 10),
              _buildSummaryCard("Bugünkü Ders", "${todayLessons.length}", Colors.blue),
              const SizedBox(width: 10),
              _buildSummaryCard("Mesaj", "3", Colors.purple),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // ═══════════════════════════════════════════════════════
          // 2. SIRADAKİ DERS KARTI
          // ═══════════════════════════════════════════════════════
          const Text(
            "Sıradaki Dersin",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 12),
          
          if (todayLessons.isNotEmpty)
            _buildNextLessonCard(todayLessons.first, context)
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade400),
                  const SizedBox(width: 12),
                  const Text(
                    "Bugün dersin yok, rahatla! ☕",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // ═══════════════════════════════════════════════════════
          // 3. SON VERİLEN ÖDEV DURUMU
          // ═══════════════════════════════════════════════════════
          const Text(
            "Ödev Takip Özeti",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 12),
          
          ...assignments.take(2).map((a) => _buildAssignmentCard(a)),
          
          const SizedBox(height: 24),
          
          // ═══════════════════════════════════════════════════════
          // 4. HIZLI ERİŞİM BUTONLARI
          // ═══════════════════════════════════════════════════════
          const Text(
            "Hızlı Erişim",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildQuickAction(
                icon: Icons.qr_code_scanner,
                label: "QR Yoklama",
                color: Colors.teal,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("🚧 QR Yoklama yakında!")),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildQuickAction(
                icon: Icons.send,
                label: "Veliye Mesaj",
                color: Colors.green,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("🚧 Veli mesajı yakında!")),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildQuickAction(
                icon: Icons.analytics,
                label: "Raporlar",
                color: Colors.amber,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeacherReportsScreen(ogretmen: ogretmen),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNextLessonCard(LessonSchedule lesson, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: Colors.blue.shade400, width: 4)),
      ),
      child: Row(
        children: [
          // Saat
          Column(
            children: [
              Text(
                lesson.startTime,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              Text(
                lesson.endTime,
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(width: 20),
          
          // Ders bilgisi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.className,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                Text(
                  "Konu: ${lesson.topic}",
                  style: TextStyle(color: Colors.grey.shade400),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      lesson.room ?? "Sınıf belirtilmemiş",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // QR Yoklama butonu
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.qr_code_scanner, size: 28, color: Colors.blue),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🚧 QR Yoklama yakında!")),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAssignmentCard(AssignmentModel assignment) {
    final completionPercent = (assignment.completionRate * 100).toInt();
    final isOverdue = assignment.isOverdue;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: assignment.completionRate,
                color: isOverdue ? Colors.red : Colors.green,
                backgroundColor: Colors.grey.shade700,
                strokeWidth: 4,
              ),
              Center(
                child: Text(
                  "$completionPercent%",
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          assignment.topic,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${assignment.targetClassIds.length} Sınıf • ${_formatDate(assignment.dueDate)}",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        trailing: isOverdue
            ? const Icon(Icons.warning, color: Colors.red)
            : Icon(Icons.check_circle, color: Colors.green.shade400),
      ),
    );
  }
  
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(40)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    
    if (diff == 0) return "Bugün";
    if (diff == 1) return "Yarın";
    if (diff < 0) return "Süresi Geçti!";
    return "$diff gün kaldı";
  }
}
