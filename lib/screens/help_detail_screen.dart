import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/help_request_model.dart';
import '../models/solution_model.dart';
import '../services/help_service.dart';
import '../data.dart';

class HelpDetailScreen extends StatefulWidget {
  final HelpRequestModel request;
  const HelpDetailScreen({super.key, required this.request});

  @override
  State<HelpDetailScreen> createState() => _HelpDetailScreenState();
}

class _HelpDetailScreenState extends State<HelpDetailScreen> {
  final _helpService = HelpService();
  final _picker = ImagePicker();
  final _solutionController = TextEditingController();
  
  File? _solutionImage;
  bool isSubmitting = false;

  Future<void> _pickSolutionImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _solutionImage = File(pickedFile.path));
    }
  }

  Future<String> _uploadImage(File file) async {
    final ref = FirebaseStorage.instance.ref().child('solution_photos/${const Uuid().v4()}.jpg');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  void _submitSolution() async {
    if (_solutionController.text.isEmpty && _solutionImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen bir çözüm yazın veya fotoğraf ekleyin")));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final userId = VeriDeposu.aktifKullaniciId ?? 'test_user';
      final personaName = _helpService.generatePersonaName(userId);

      String? photoUrl;
      if (_solutionImage != null) {
        photoUrl = await _uploadImage(_solutionImage!);
      }

      final solution = SolutionModel(
        id: const Uuid().v4(),
        requestId: widget.request.id,
        solverUserId: userId,
        solverPersonaName: personaName,
        solverPersonaAvatar: 'fox_avatar',
        text: _solutionController.text.isNotEmpty ? _solutionController.text : null,
        photoUrl: photoUrl,
        timestamp: DateTime.now(),
      );

      await _helpService.cozumGonder(solution);
      _solutionController.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Çözümünüz gönderildi! ✨")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMyQuestion = widget.request.senderUserId == VeriDeposu.aktifKullaniciId;

    return Scaffold(
      appBar: AppBar(title: const Text("Soru Detayı")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SORU KISMI ---
                  _buildQuestionSection(),
                  const Divider(height: 40),
                  
                  // --- ÇÖZÜMLER BAŞLIĞI ---
                  Row(
                    children: [
                      const Icon(Icons.question_answer, color: Colors.indigo),
                      const SizedBox(width: 10),
                      Text(
                        "Çözümler (${widget.request.solutionCount})",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- ÇÖZÜMLER LİSTESİ ---
                  _buildSolutionsList(isMyQuestion),
                ],
              ),
            ),
          ),
          
          // --- CEVAPLAMA ALANI (Sadece soru başkasına aitse) ---
          if (!isMyQuestion && !widget.request.isSolved)
            _buildReplyInput(),
        ],
      ),
    );
  }

  Widget _buildQuestionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(backgroundColor: Colors.indigo.shade100, child: const Icon(Icons.person)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.request.senderPersonaName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("${widget.request.lesson} • ${widget.request.topic}", style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const Spacer(),
            if (widget.request.isSolved)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                child: const Text("ÇÖZÜLDÜ", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (widget.request.photoUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(widget.request.photoUrl, width: double.infinity, fit: BoxFit.fitWidth),
          ),
        const SizedBox(height: 20),
        Text(widget.request.description, style: const TextStyle(fontSize: 16, height: 1.5)),
      ],
    );
  }

  Widget _buildSolutionsList(bool canAccept) {
    return StreamBuilder<QuerySnapshot>(
      stream: _helpService.cozumleriGetir(widget.request.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("Henüz çözüm gelmemiş. İlk sen yardım et!"));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final solution = SolutionModel.fromMap(docs[index].data() as Map<String, dynamic>, docs[index].id);
            return _buildSolutionCard(solution, canAccept);
          },
        );
      },
    );
  }

  Widget _buildSolutionCard(SolutionModel solution, bool canAccept) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: solution.isBestSolution ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(solution.solverPersonaName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                const Spacer(),
                if (solution.isBestSolution)
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text("EN İYİ CEVAP", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 10)),
                    ],
                  ),
                if (canAccept && !widget.request.isSolved && !solution.isBestSolution)
                  TextButton.icon(
                    onPressed: () => _helpService.enIyiCevapSec(widget.request.id, solution.id),
                    icon: const Icon(Icons.star, size: 16),
                    label: const Text("En İyi Seç"),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(solution.text ?? ""),
            if (solution.photoUrl != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(solution.photoUrl!, height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(_formatTime(solution.timestamp), style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_solutionImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_solutionImage!, height: 100, width: 100, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => _solutionImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(onPressed: () => _pickSolutionImage(ImageSource.camera), icon: const Icon(Icons.camera_alt, color: Colors.indigo)),
              Expanded(
                child: TextField(
                  controller: _solutionController,
                  decoration: const InputDecoration(hintText: "Çözümünü yaz...", border: InputBorder.none),
                  maxLines: null,
                ),
              ),
              IconButton(
                onPressed: isSubmitting ? null : _submitSolution,
                icon: isSubmitting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send, color: Colors.indigo),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return "${diff.inMinutes} dk";
    return "${diff.inHours} sa";
  }
}
