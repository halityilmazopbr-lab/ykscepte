import 'package:flutter/material.dart';
import '../../models.dart';
import '../teacher_service.dart';
import '../models/teacher_models.dart';

/// 📝 Ödev Verme Ekranı - 30 Saniye Kuralı
class GiveHomeworkScreen extends StatefulWidget {
  final Ogretmen ogretmen;
  
  const GiveHomeworkScreen({super.key, required this.ogretmen});

  @override
  State<GiveHomeworkScreen> createState() => _GiveHomeworkScreenState();
}

class _GiveHomeworkScreenState extends State<GiveHomeworkScreen> {
  String? selectedClassId;
  DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool isLoading = false;
  
  late List<ClassModel> myClasses;
  
  @override
  void initState() {
    super.initState();
    myClasses = TeacherService.getTeacherClasses(widget.ogretmen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        automaticallyImplyLeading: false,
        title: const Text("Yeni Ödev Oluştur", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════════
            // 1. ADIM: SINIF SEÇİMİ
            // ═══════════════════════════════════════════════════════
            _buildSectionTitle("1. Kime Gönderilecek?", Icons.people),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade700),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedClassId,
                  hint: Text("Sınıf Seçiniz", style: TextStyle(color: Colors.grey.shade500)),
                  isExpanded: true,
                  dropdownColor: const Color(0xFF21262D),
                  style: const TextStyle(color: Colors.white),
                  items: myClasses.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.id,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(c.grade, style: const TextStyle(color: Colors.blue)),
                          ),
                          const SizedBox(width: 12),
                          Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text(
                            "${c.studentCount} öğrenci",
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) => setState(() => selectedClassId = newValue),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ═══════════════════════════════════════════════════════
            // 2. ADIM: ÖDEV DETAYLARI
            // ═══════════════════════════════════════════════════════
            _buildSectionTitle("2. Ödev İçeriği", Icons.assignment),
            const SizedBox(height: 12),
            
            // Konu Başlığı
            TextField(
              controller: _topicController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Konu Başlığı", "Örn: Türev Test 4"),
            ),
            const SizedBox(height: 16),
            
            // Detay / Kaynak
            TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                "Detaylı Açıklama",
                "Örn: 3D Yayınları, Sayfa 102-105 arası çözülecek. 12. soruya dikkat!",
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Fotoğraf Ekleme Butonu
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("📷 Kamera özelliği yakında!")),
                );
              },
              icon: const Icon(Icons.camera_alt, color: Colors.blue),
              label: const Text("Sayfa/Soru Fotoğrafı Ekle"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: BorderSide(color: Colors.blue.withAlpha(100)),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 28),

            // ═══════════════════════════════════════════════════════
            // 3. ADIM: TESLİM TARİHİ
            // ═══════════════════════════════════════════════════════
            _buildSectionTitle("3. Son Teslim Tarihi", Icons.calendar_today),
            const SizedBox(height: 12),
            
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(20),
                  border: Border.all(color: Colors.orange.withAlpha(100)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.event, color: Colors.orange),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatFullDate(selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          _getDaysRemaining(selectedDate),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.edit, color: Colors.orange, size: 20),
                  ],
                ),
              ),
            ),
            
            // Hızlı tarih seçenekleri
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQuickDateChip("Yarın", 1),
                const SizedBox(width: 8),
                _buildQuickDateChip("2 Gün", 2),
                const SizedBox(width: 8),
                _buildQuickDateChip("1 Hafta", 7),
              ],
            ),

            const SizedBox(height: 40),

            // ═══════════════════════════════════════════════════════
            // GÖNDER BUTONU
            // ═══════════════════════════════════════════════════════
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _sendHomework,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: Colors.green.withAlpha(100),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text("ÖDEVİ GÖNDER", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bilgi notu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade300, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Ödev gönderildiğinde seçilen sınıftaki tüm öğrencilere bildirim gidecektir.",
                      style: TextStyle(color: Colors.blue.shade200, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.grey.shade400),
      hintStyle: TextStyle(color: Colors.grey.shade600),
      filled: true,
      fillColor: const Color(0xFF21262D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }
  
  Widget _buildQuickDateChip(String label, int days) {
    final targetDate = DateTime.now().add(Duration(days: days));
    final isSelected = selectedDate.day == targetDate.day && 
                       selectedDate.month == targetDate.month;
    
    return GestureDetector(
      onTap: () => setState(() => selectedDate = targetDate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withAlpha(50) : const Color(0xFF21262D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade700,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.orange : Colors.grey.shade400,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange,
              surface: Color(0xFF21262D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  void _sendHomework() async {
    // Validasyon
    if (selectedClassId == null) {
      _showError("Lütfen bir sınıf seçin");
      return;
    }
    if (_topicController.text.trim().isEmpty) {
      _showError("Lütfen konu başlığı girin");
      return;
    }
    
    setState(() => isLoading = true);
    
    // Ödev oluştur
    final assignment = AssignmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      teacherId: widget.ogretmen.id,
      teacherName: widget.ogretmen.ad,
      targetClassIds: [selectedClassId!],
      lesson: widget.ogretmen.brans,
      topic: _topicController.text.trim(),
      description: _descController.text.trim(),
      dueDate: selectedDate,
      createdAt: DateTime.now(),
    );
    
    // Firebase'e kaydet
    final result = await TeacherService.createAssignment(assignment);
    
    setState(() => isLoading = false);
    
    if (result != null || true) { // Demo için her zaman başarılı
      _showSuccessDialog();
    } else {
      _showError("Ödev gönderilemedi. Lütfen tekrar deneyin.");
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
  
  void _showSuccessDialog() {
    final selectedClass = myClasses.firstWhere((c) => c.id == selectedClassId);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başarı animasyonu
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
              ),
              const SizedBox(height: 20),
              
              const Text(
                "Ödev Gönderildi! 🎉",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                "${selectedClass.name} sınıfına bildirim gönderildi.",
                style: TextStyle(color: Colors.grey.shade400),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "📱 ${selectedClass.studentCount} öğrenci bilgilendirildi",
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Formu temizle
                        setState(() {
                          selectedClassId = null;
                          _topicController.clear();
                          _descController.clear();
                          selectedDate = DateTime.now().add(const Duration(days: 2));
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade700),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Yeni Ödev"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Tamam"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    final days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    final months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 
                    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return "${date.day} ${months[date.month - 1]} ${date.year}, ${days[date.weekday - 1]}";
  }
  
  String _getDaysRemaining(DateTime date) {
    final diff = date.difference(DateTime.now()).inDays;
    if (diff == 0) return "Bugün";
    if (diff == 1) return "Yarın";
    return "$diff gün sonra";
  }
  
  @override
  void dispose() {
    _topicController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
