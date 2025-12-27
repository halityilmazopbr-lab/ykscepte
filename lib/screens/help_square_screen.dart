import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/help_request_model.dart';
import '../services/help_service.dart';
import 'help_ask_screen.dart';
import 'help_detail_screen.dart';

class HelpSquareScreen extends StatefulWidget {
  const HelpSquareScreen({super.key});

  @override
  State<HelpSquareScreen> createState() => _HelpSquareScreenState();
}

class _HelpSquareScreenState extends State<HelpSquareScreen> {
  final HelpService _helpService = HelpService();
  String? selectedLesson;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("🏛️ SORU MEYDANI", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- FİLTRE ÇUBUĞU ---
          _buildFilterBar(),

          // --- SORU AKIŞI ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _helpService.soruAkisiGetir(lesson: selectedLesson),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Hata: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final request = HelpRequestModel.fromMap(
                      docs[index].data() as Map<String, dynamic>,
                      docs[index].id,
                    );
                    return _buildQuestionCard(request);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => const HelpAskScreen()),
        ),
        label: const Text("Soru Sor"),
        icon: const Icon(Icons.add_a_photo),
        backgroundColor: Colors.indigo.shade700,
      ),
    );
  }

  Widget _buildFilterBar() {
    final lessons = ['Matematik', 'Fizik', 'Kimya', 'Biyoloji', 'Türkçe', 'Tarih', 'Coğrafya'];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: lessons.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final lesson = isAll ? null : lessons[index - 1];
          final isSelected = selectedLesson == lesson;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(isAll ? "Tümü" : lesson!),
              selected: isSelected,
              onSelected: (val) => setState(() => selectedLesson = lesson),
              selectedColor: Colors.indigo.shade100,
              checkmarkColor: Colors.indigo,
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(HelpRequestModel request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => HelpDetailScreen(request: request)),
        ),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Bilgi (Persona)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                child: const Icon(Icons.person_search, color: Colors.indigo),
              ),
              title: Text(request.senderPersonaName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${request.lesson} • ${request.topic}"),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${request.coinsOffered} Coin",
                  style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            
            // Soru Fotoğrafı (Küçük önizleme)
            if (request.photoUrl.isNotEmpty)
              ClipRRect(
                child: Image.network(
                  request.photoUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 150,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),

            // Açıklama
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                request.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87),
              ),
            ),

            // Alt Bilgi
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.comment_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${request.solutionCount} Çözüm", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  Text(
                    _formatTime(request.timestamp),
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: Colors.indigo.shade200),
          const SizedBox(height: 16),
          const Text(
            "Meydan Şimdilik Sessiz...",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            "İlk soruyu sen sormak ister misin?",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return "${diff.inMinutes} dk önce";
    if (diff.inHours < 24) return "${diff.inHours} sa önce";
    return "${diff.inDays} gün önce";
  }
}
