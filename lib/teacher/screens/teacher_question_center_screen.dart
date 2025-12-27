import 'package:flutter/material.dart';
import '../../models.dart';
import '../models/teacher_models.dart';
import '../teacher_service.dart';
import 'package:image_picker/image_picker.dart';

class TeacherQuestionCenterScreen extends StatefulWidget {
  final Ogretmen ogretmen;

  const TeacherQuestionCenterScreen({super.key, required this.ogretmen});

  @override
  State<TeacherQuestionCenterScreen> createState() => _TeacherQuestionCenterScreenState();
}

class _TeacherQuestionCenterScreenState extends State<TeacherQuestionCenterScreen> {
  List<StudentQuestionModel> _pendingQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    final questions = await TeacherService.getPendingQuestions(widget.ogretmen.id);
    if (mounted) {
      setState(() {
        _pendingQuestions = questions;
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
        title: const Text('Soru Çözüm Merkezi', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(onPressed: _loadQuestions, icon: const Icon(Icons.refresh, color: Colors.white)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingQuestions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade700),
                      const SizedBox(height: 16),
                      Text("Bekleyen soru yok!", style: TextStyle(color: Colors.grey.shade400, fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingQuestions.length,
                  itemBuilder: (context, index) {
                    return _buildQuestionCard(_pendingQuestions[index]);
                  },
                ),
    );
  }

  Widget _buildQuestionCard(StudentQuestionModel question) {
    return Card(
      color: const Color(0xFF21262D),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openSolutionDialog(question),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.purple.withAlpha(50),
                    child: const Icon(Icons.person, color: Colors.purple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(question.studentName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(
                          "${question.lesson} • ${_timeAgo(question.createdAt)}",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                    child: const Text("Bekliyor", style: TextStyle(color: Colors.orange, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (question.note != null) ...[
                Text(
                  question.note!,
                  style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  question.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150, 
                      color: Colors.black12,
                      child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey.shade800,
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openSolutionDialog(question),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Çözüm Gönder"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _openSolutionDialog(StudentQuestionModel question) {
    showDialog(
      context: context,
      barrierDismissible: false, // Yanlışlıkla kapanmasın
      builder: (context) => SolutionDialog(
        question: question, 
        onSolved: () {
          _loadQuestions(); // Listeyi yenile
        },
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return "${diff.inMinutes} dk önce";
    if (diff.inHours < 24) return "${diff.inHours} sa önce";
    return "${diff.inDays} gün önce";
  }
}

class SolutionDialog extends StatefulWidget {
  final StudentQuestionModel question;
  final VoidCallback onSolved;

  const SolutionDialog({super.key, required this.question, required this.onSolved});

  @override
  State<SolutionDialog> createState() => _SolutionDialogState();
}

class _SolutionDialogState extends State<SolutionDialog> {
  final _textController = TextEditingController();
  bool _isRecording = false;
  bool _hasAudio = false;
  XFile? _pickedImage;
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF161B22),
      insetPadding: EdgeInsets.zero, // Tam ekran hissiyatı
      child: Scaffold(
        backgroundColor: const Color(0xFF161B22),
        appBar: AppBar(
          backgroundColor: const Color(0xFF161B22),
          title: const Text("Çözüm Oluştur", style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Soru Özeti (Daraltılabilir yapılabilir ama şimdilik gösterelim)
              Text("Öğrenci: ${widget.question.studentName}", style: TextStyle(color: Colors.grey.shade400)),
              const SizedBox(height: 8),
              Center(
                child: GestureDetector(
                   onTap: () => _showFullImage(widget.question.imageUrl),
                   child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.question.imageUrl,
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (_,__,___) => const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // 1. Metin Çözüm
              const Text("📝 Metin Çözüm (Opsiyonel)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Çözümü buraya yazabilirsiniz...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  filled: true,
                  fillColor: const Color(0xFF21262D),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 24),

              // 2. Multimedya Çözüm
              const Text("📸 Sesli / Fotoğraflı Çözüm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  // Ses Kayıt Butonu
                  Expanded(
                    child: GestureDetector(
                      onLongPressStart: (_) => setState(() => _isRecording = true),
                      onLongPressEnd: (_) {
                        setState(() {
                          _isRecording = false;
                          _hasAudio = true; // Kayıt başarılı simülasyonu
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ses kaydedildi! (Demo)")));
                      },
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kaydetmek için basılı tutun")));
                      },
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: _isRecording ? Colors.red.withAlpha(50) : (_hasAudio ? Colors.green.withAlpha(50) : const Color(0xFF21262D)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _isRecording ? Colors.red : (_hasAudio ? Colors.green : Colors.grey.shade700)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _hasAudio ? Icons.mic_none : Icons.mic,
                              color: _isRecording ? Colors.red : (_hasAudio ? Colors.green : Colors.blue),
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isRecording ? "Kaydediliyor..." : (_hasAudio ? "Ses Eklenildi" : "Basılı Tut Kaydet"),
                              style: TextStyle(
                                color: _isRecording ? Colors.red : (_hasAudio ? Colors.green : Colors.blue), 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            if (_hasAudio)
                              Text("Silmek için dokun", style: TextStyle(fontSize: 10, color: Colors.grey.shade500))
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Fotoğraf Ekleme Butonu
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final img = await picker.pickImage(source: ImageSource.camera); // Kamera açsılsın
                        if (img != null) {
                          setState(() => _pickedImage = img);
                        }
                      },
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: _pickedImage != null ? Colors.green.withAlpha(50) : const Color(0xFF21262D),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _pickedImage != null ? Colors.green : Colors.grey.shade700),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: _pickedImage != null ? Colors.green : Colors.orange, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              _pickedImage != null ? "Foto Eklendi" : "Fotoğraf Çek",
                              style: TextStyle(
                                color: _pickedImage != null ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Gönder Butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _sendSolution,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isSending 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send),
                  label: Text(
                    _isSending ? "GÖNDERİLİYOR..." : "ÇÖZÜMÜ GÖNDER",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
               Center(
                child: Text(
                  "Hibrit: Hem metin, hem ses, hem fotoğraf ekleyebilirsiniz.",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImage(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: Image.network(url),
        ),
      ),
    );
  }

  Future<void> _sendSolution() async {
    // Validasyon: En az bir içerik olmalı
    if (_textController.text.trim().isEmpty && !_hasAudio && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen en az bir çözüm yöntemi (Metin, Ses veya Fotoğraf) kullanın.")));
      return;
    }

    setState(() => _isSending = true);

    // Tip belirleme
    SolutionType type = SolutionType.text;
    int count = 0;
    if (_textController.text.isNotEmpty) count++;
    if (_hasAudio) count++;
    if (_pickedImage != null) count++;
    
    if (count > 1) type = SolutionType.hybrid;
    else if (_hasAudio) type = SolutionType.audio;
    else if (_pickedImage != null) type = SolutionType.image;

    // Model oluştur
    final solution = TeacherSolutionModel(
      text: _textController.text.trim(),
      imageUrl: _pickedImage != null ? "demo_solution_image.jpg" : null,
      audioUrl: _hasAudio ? "demo_solution_audio.mp3" : null,
      type: type,
      solvedAt: DateTime.now(),
    );

    // Servise gönder
    await TeacherService.solveQuestion(widget.question.id, solution);

    if (mounted) {
       setState(() => _isSending = false);
       Navigator.pop(context); // Dialog kapat
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Çözüm başarıyla gönderildi! 🎉"), backgroundColor: Colors.green));
       widget.onSolved(); // Callback
    }
  }
}
