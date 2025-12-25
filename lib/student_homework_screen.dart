import 'package:flutter/material.dart';
import '../models.dart';
import '../data.dart';
import 'teacher/models/teacher_models.dart';
import 'teacher/teacher_service.dart';

/// 📚 Öğrenci Ödev Takip Ekranı
/// Bekleyenler, Tamamlanan, Gecikenler tabs
class StudentHomeworkScreen extends StatefulWidget {
  final Ogrenci ogrenci;
  
  const StudentHomeworkScreen({super.key, required this.ogrenci});

  @override
  State<StudentHomeworkScreen> createState() => _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends State<StudentHomeworkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AssignmentModel> _assignments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAssignments();
  }
  
  Future<void> _loadAssignments() async {
    // Demo veriler
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _assignments = [
        AssignmentModel(
          id: 'hw1',
          teacherId: 'ogretmen1',
          teacherName: 'Ahmet Hoca',
          targetClassIds: ['class_12a'],
          lesson: 'Matematik',
          topic: 'Türev Alma Kuralları',
          description: '3D Yayınları, Sayfa 102-105 arası çözülecek. Özellikle 12. soruya dikkat!',
          dueDate: DateTime.now().add(const Duration(days: 2)),
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          studentStatuses: {
            widget.ogrenci.id: AssignmentStatus(isCompleted: false),
          },
        ),
        AssignmentModel(
          id: 'hw2',
          teacherId: 'ogretmen1',
          teacherName: 'Mehmet Hoca',
          targetClassIds: ['class_12a'],
          lesson: 'Fizik',
          topic: 'Elektrik Devreleri',
          description: 'Palme Yayınları, Test 7-8 çözülecek.',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          studentStatuses: {
            widget.ogrenci.id: AssignmentStatus(isCompleted: false),
          },
        ),
        AssignmentModel(
          id: 'hw3',
          teacherId: 'ogretmen1',
          teacherName: 'Ayşe Hoca',
          targetClassIds: ['class_12a'],
          lesson: 'Kimya',
          topic: 'Organik Bileşikler',
          description: 'Çap Yayınları, Konu testi tamamlanacak.',
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          studentStatuses: {
            widget.ogrenci.id: AssignmentStatus(isCompleted: false),
          },
        ),
        AssignmentModel(
          id: 'hw4',
          teacherId: 'ogretmen1',
          teacherName: 'Ahmet Hoca',
          targetClassIds: ['class_12a'],
          lesson: 'Matematik',
          topic: 'İntegral Hesabı',
          description: '3D Yayınları, Sayfa 150-155.',
          dueDate: DateTime.now().subtract(const Duration(days: 3)),
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          studentStatuses: {
            widget.ogrenci.id: AssignmentStatus(
              isCompleted: true,
              completedAt: DateTime.now().subtract(const Duration(days: 4)),
            ),
          },
        ),
      ];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("Ödevlerim 📚", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Bekleyenler"),
                  const SizedBox(width: 6),
                  _buildBadge(_getPendingAssignments().length, Colors.orange),
                ],
              ),
            ),
            const Tab(text: "Tamamlanan"),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Gecikenler"),
                  if (_getOverdueAssignments().isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildBadge(_getOverdueAssignments().length, Colors.red),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHomeworkList(_getPendingAssignments(), "pending"),
                _buildHomeworkList(_getCompletedAssignments(), "completed"),
                _buildHomeworkList(_getOverdueAssignments(), "overdue"),
              ],
            ),
    );
  }
  
  Widget _buildBadge(int count, Color color) {
    if (count == 0) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "$count",
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
  
  List<AssignmentModel> _getPendingAssignments() {
    return _assignments.where((a) {
      final status = a.studentStatuses[widget.ogrenci.id];
      return !(status?.isCompleted ?? false) && !a.isOverdue;
    }).toList();
  }
  
  List<AssignmentModel> _getCompletedAssignments() {
    return _assignments.where((a) {
      final status = a.studentStatuses[widget.ogrenci.id];
      return status?.isCompleted ?? false;
    }).toList();
  }
  
  List<AssignmentModel> _getOverdueAssignments() {
    return _assignments.where((a) {
      final status = a.studentStatuses[widget.ogrenci.id];
      return !(status?.isCompleted ?? false) && a.isOverdue;
    }).toList();
  }

  Widget _buildHomeworkList(List<AssignmentModel> assignments, String status) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == "completed" ? Icons.check_circle_outline : Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              status == "completed"
                  ? "Henüz tamamlanan ödev yok"
                  : status == "overdue"
                      ? "Geciken ödevin yok! 🎉"
                      : "Bekleyen ödevin yok!",
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        return _buildHomeworkCard(assignments[index], status);
      },
    );
  }

  Widget _buildHomeworkCard(AssignmentModel assignment, String status) {
    final lessonColors = {
      'Matematik': Colors.blue,
      'Fizik': Colors.purple,
      'Kimya': Colors.green,
      'Biyoloji': Colors.teal,
      'Türkçe': Colors.orange,
      'Tarih': Colors.brown,
      'Coğrafya': Colors.cyan,
    };
    
    final color = lessonColors[assignment.lesson] ?? Colors.grey;
    Color statusColor = Colors.blue;
    String statusText = _getDaysRemaining(assignment.dueDate);
    IconData statusIcon = Icons.timer;

    if (status == "completed") {
      statusColor = Colors.green;
      statusText = "Tamamlandı ✓";
      statusIcon = Icons.check_circle;
    } else if (status == "overdue") {
      statusColor = Colors.red;
      statusText = "Süresi Geçti!";
      statusIcon = Icons.error_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(16),
        border: status == "pending" 
            ? Border.all(color: color.withAlpha(100), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showHomeworkDetail(assignment, status),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst kısım: Ders ve Tarih
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        assignment.lesson,
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(statusText, style: TextStyle(color: statusColor, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Orta kısım: Konu ve Açıklama
                Text(
                  assignment.topic,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${assignment.teacherName} • ${assignment.description}",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Alt kısım: Aksiyon butonu
                if (status == "pending" || status == "overdue") ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _markAsDone(assignment),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("Ödevi Bitirdim"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: status == "overdue" ? Colors.orange : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHomeworkDetail(AssignmentModel assignment, String status) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              Text(
                assignment.topic,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Ders ve öğretmen
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(assignment.lesson, style: const TextStyle(color: Colors.blue)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "• ${assignment.teacherName}",
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Açıklama
              Text(
                "Ödev Detayı:",
                style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF21262D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  assignment.description,
                  style: const TextStyle(color: Colors.white, height: 1.5),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Teslim tarihi
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey.shade500, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "Son Teslim: ${_formatDate(assignment.dueDate)}",
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Butonlar
              if (status != "completed")
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _markAsDone(assignment);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Tamamlandı Olarak İşaretle"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _markAsDone(AssignmentModel assignment) {
    // Gamification efekti
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Yıldız animasyonu
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stars, size: 60, color: Colors.amber),
              ),
              const SizedBox(height: 20),
              
              const Text(
                "Tebrikler! 🎉",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "+50 Puan Kazandın!",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              
              const SizedBox(height: 12),
              Text(
                "${assignment.teacherName}'a bildirim gönderildi.",
                style: TextStyle(color: Colors.grey.shade400),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Listeyi güncelle
                    setState(() {
                      final index = _assignments.indexWhere((a) => a.id == assignment.id);
                      if (index >= 0) {
                        _assignments[index] = AssignmentModel(
                          id: assignment.id,
                          teacherId: assignment.teacherId,
                          teacherName: assignment.teacherName,
                          targetClassIds: assignment.targetClassIds,
                          lesson: assignment.lesson,
                          topic: assignment.topic,
                          description: assignment.description,
                          dueDate: assignment.dueDate,
                          createdAt: assignment.createdAt,
                          studentStatuses: {
                            ...assignment.studentStatuses,
                            widget.ogrenci.id: AssignmentStatus(
                              isCompleted: true,
                              completedAt: DateTime.now(),
                            ),
                          },
                        );
                      }
                    });
                    
                    // XP ekle
                    widget.ogrenci.puan += 50;
                    VeriDeposu.kaydet();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Süper! 🚀", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
                    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
  
  String _getDaysRemaining(DateTime date) {
    final diff = date.difference(DateTime.now()).inDays;
    if (diff == 0) return "Bugün";
    if (diff == 1) return "Yarın";
    if (diff < 0) return "Süresi Geçti!";
    return "$diff gün kaldı";
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
