import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';
import 'exam_service.dart';
import 'exam_model.dart';

/// 📋 Deneme Listesi Ekranı
/// Kullanıcının yetkili olduğu sınavları listeler
class ExamListScreen extends StatelessWidget {
  const ExamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final examService = ExamService();
    
    // Kullanıcı bilgilerini al
    final userRole = user?.isKurumsal == true ? 'kurumsal_ogrenci' : 'bireysel';
    final institutionId = user?.kurumKodu;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("Deneme Sınavları 📝", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<ExamModel>>(
        stream: examService.getExamsForUser(userRole, institutionId),
        builder: (context, snapshot) {
          // 1. Yükleniyor
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 16),
                  Text("Sınavlar yükleniyor...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // 2. Hata
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "Bir hata oluştu",
                    style: TextStyle(color: Colors.red.shade400, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${snapshot.error}",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final exams = snapshot.data ?? [];

          // 3. Liste Boş
          if (exams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey.shade600),
                  const SizedBox(height: 20),
                  const Text(
                    "Aktif deneme sınavı bulunamadı",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Yeni sınavlar eklendiğinde burada göreceksiniz",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          // 4. Sınav Listesi
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              return _buildExamCard(context, exams[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, ExamModel exam) {
    final bool isPublic = exam.visibility == 'public';
    final Color cardColor = isPublic ? Colors.green : Colors.orange;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withAlpha(50)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openExam(context, exam),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Sol İkon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    exam.pdfUrl != null ? Icons.picture_as_pdf : Icons.quiz,
                    color: cardColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Orta Bilgi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(exam.date),
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPublic ? Colors.green.withAlpha(30) : Colors.orange.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isPublic ? "Türkiye Geneli" : "Kurum Sınavı",
                              style: TextStyle(
                                color: cardColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Sağ Ok
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward, size: 18, color: cardColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openExam(BuildContext context, ExamModel exam) {
    // PDF varsa aç, yoksa sınava başla dialogu göster
    if (exam.pdfUrl != null && exam.pdfUrl!.isNotEmpty) {
      // TODO: PDF Viewer aç
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("📄 PDF açılıyor: ${exam.title}"),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      // Sınava başla dialogu
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF161B22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(exam.title, style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.timer, color: Colors.blue, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                "Bu sınava başlamak istiyor musunuz?",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Süre başladıktan sonra geri sayım başlayacaktır.",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Vazgeç"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("🚀 Sınav başlatılıyor..."),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Başla"),
            ),
          ],
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
