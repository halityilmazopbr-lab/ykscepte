import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models.dart';
import '../teacher_service.dart';
import '../models/teacher_models.dart';

/// 📋 Öğretmen QR Yoklama Ekranı
/// QR oluştur, canlı yoklama takibi
class TeacherAttendanceScreen extends StatefulWidget {
  final Ogretmen ogretmen;
  
  const TeacherAttendanceScreen({super.key, required this.ogretmen});

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  ClassModel? _selectedClass;
  AttendanceModel? _activeAttendance;
  bool _isActive = false;
  Timer? _refreshTimer;
  
  late List<ClassModel> _classes;
  
  // Demo öğrenci listesi (simülasyon için)
  final List<Map<String, dynamic>> _demoStudents = [
    {'id': 'ogrenci1', 'name': 'Ali Yılmaz', 'present': false},
    {'id': 'ogrenci2', 'name': 'Ayşe Demir', 'present': false},
    {'id': 'ogrenci3', 'name': 'Mehmet Kaya', 'present': false},
    {'id': 'ogrenci4', 'name': 'Zeynep Arslan', 'present': false},
    {'id': 'ogrenci5', 'name': 'Can Özkan', 'present': false},
  ];

  @override
  void initState() {
    super.initState();
    _classes = TeacherService.getTeacherClasses(widget.ogretmen.id);
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("QR Yoklama", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isActive)
            TextButton.icon(
              onPressed: _stopAttendance,
              icon: const Icon(Icons.stop_circle, color: Colors.red),
              label: const Text("Bitir", style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: _isActive ? _buildActiveAttendance() : _buildStartScreen(),
    );
  }
  
  // ═══════════════════════════════════════════════════════════════
  // BAŞLANGIÇ EKRANI
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStartScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade500],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "QR Kod ile Yoklama",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Sınıf seçin, QR gösterin, öğrenciler tarasın!",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Sınıf seçimi
          const Text(
            "Hangi sınıfın yoklamasını alacaksınız?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Sınıf kartları
          Expanded(
            child: ListView.builder(
              itemCount: _classes.length,
              itemBuilder: (context, index) {
                final classInfo = _classes[index];
                final isSelected = _selectedClass?.id == classInfo.id;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedClass = classInfo),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal.withAlpha(30) : const Color(0xFF21262D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.teal : Colors.grey.shade800,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.teal.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              classInfo.grade,
                              style: const TextStyle(
                                color: Colors.teal,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                classInfo.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${classInfo.studentCount} Öğrenci • ${classInfo.room ?? 'Sınıf belirtilmemiş'}",
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.teal),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Başlat butonu
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _selectedClass == null ? null : _startAttendance,
              icon: const Icon(Icons.qr_code),
              label: const Text("YOKLAMAYI BAŞLAT", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade800,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // ═══════════════════════════════════════════════════════════════
  // AKTİF YOKLAMA EKRANI
  // ═══════════════════════════════════════════════════════════════
  Widget _buildActiveAttendance() {
    final presentCount = _demoStudents.where((s) => s['present'] == true).length;
    final totalCount = _demoStudents.length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // QR Kod
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                QrImageView(
                  data: _activeAttendance?.qrCode ?? "000000",
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Kod: ${_activeAttendance?.qrCode ?? '------'}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedClass?.name ?? "",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Durum özeti
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.check_circle,
                  label: "Geldi",
                  count: presentCount,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.timer,
                  label: "Bekliyor",
                  count: totalCount - presentCount,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.people,
                  label: "Toplam",
                  count: totalCount,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Öğrenci listesi
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        "Öğrenci Durumu",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "Canlı",
                              style: TextStyle(color: Colors.green, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.grey),
                
                ..._demoStudents.map((student) => _buildStudentRow(student)),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Demo simülasyon butonu
          OutlinedButton.icon(
            onPressed: _simulateCheckIn,
            icon: const Icon(Icons.flash_on, color: Colors.amber),
            label: const Text("Demo: Rastgele Öğrenci Gelsin"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.amber,
              side: const BorderSide(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            "$count",
            style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
  
  Widget _buildStudentRow(Map<String, dynamic> student) {
    final isPresent = student['present'] as bool;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isPresent ? Colors.green.withAlpha(30) : Colors.grey.withAlpha(30),
            child: Text(
              student['name'].toString()[0],
              style: TextStyle(
                color: isPresent ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              student['name'],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPresent ? Colors.green.withAlpha(30) : Colors.grey.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPresent ? Icons.check : Icons.schedule,
                  size: 14,
                  color: isPresent ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  isPresent ? "Geldi" : "Bekliyor",
                  style: TextStyle(
                    color: isPresent ? Colors.green : Colors.grey,
                    fontSize: 12,
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
  // YOKLAMA İŞLEMLERİ
  // ═══════════════════════════════════════════════════════════════
  
  void _startAttendance() async {
    if (_selectedClass == null) return;
    
    // QR kod oluştur
    final qrCode = TeacherService.generateQRCode();
    
    setState(() {
      _activeAttendance = AttendanceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        classId: _selectedClass!.id,
        className: _selectedClass!.name,
        teacherId: widget.ogretmen.id,
        date: DateTime.now(),
        qrCode: qrCode,
        isActive: true,
      );
      _isActive = true;
      
      // Öğrenci listesini sıfırla
      for (var s in _demoStudents) {
        s['present'] = false;
      }
    });
    
    // 5 saniyede bir listeyi yenile (demo için)
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) setState(() {});
    });
  }
  
  void _stopAttendance() {
    _refreshTimer?.cancel();
    
    final presentCount = _demoStudents.where((s) => s['present'] == true).length;
    final absentCount = _demoStudents.length - presentCount;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Yoklama Tamamlandı", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDialogStat("Geldi", presentCount, Colors.green),
                _buildDialogStat("Gelmedi", absentCount, Colors.red),
              ],
            ),
            if (absentCount > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Gelmeyen $absentCount öğrencinin velisine bildirim gönderilsin mi?",
                        style: TextStyle(color: Colors.orange.shade200, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (absentCount > 0)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("📱 $absentCount veliye SMS gönderildi!"),
                    backgroundColor: Colors.green,
                  ),
                );
                setState(() => _isActive = false);
              },
              child: const Text("Bildirim Gönder", style: TextStyle(color: Colors.orange)),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isActive = false);
            },
            child: const Text("Kapat"),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDialogStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey.shade400)),
      ],
    );
  }
  
  void _simulateCheckIn() {
    final notPresent = _demoStudents.where((s) => s['present'] == false).toList();
    if (notPresent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tüm öğrenciler zaten geldi!")),
      );
      return;
    }
    
    final random = Random();
    final student = notPresent[random.nextInt(notPresent.length)];
    
    setState(() {
      student['present'] = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ ${student['name']} derse katıldı!"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
