/// 👮 NETX Trivia - Admin Paneli
/// Soru ekleme ve canlı yayın başlatma

import 'package:flutter/material.dart';
import 'trivia_models.dart';
import 'trivia_service.dart';

class AdminTriviaPanel extends StatefulWidget {
  const AdminTriviaPanel({super.key});

  @override
  State<AdminTriviaPanel> createState() => _AdminTriviaPanelState();
}

class _AdminTriviaPanelState extends State<AdminTriviaPanel> {
  final TriviaService _service = TriviaService();

  // Form kontrolcüleri
  final _questionCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls = List.generate(4, (_) => TextEditingController());
  final _timeCtrl = TextEditingController(text: '15');

  int _correctOptionIndex = 0;
  String _selectedCategory = 'Genel Kültür';
  List<TriviaQuestion> _addedQuestions = [];

  final List<String> _categories = [
    'Genel Kültür',
    'Tarih',
    'Coğrafya',
    'Edebiyat',
    'Matematik',
    'Fen Bilimleri',
  ];

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (var ctrl in _optionCtrls) {
      ctrl.dispose();
    }
    _timeCtrl.dispose();
    super.dispose();
  }

  void _addQuestionToList() {
    if (_questionCtrl.text.isEmpty) {
      _showSnack('Soru metni boş olamaz!', Colors.orange);
      return;
    }

    // Şıkların dolu olduğunu kontrol et
    for (int i = 0; i < 4; i++) {
      if (_optionCtrls[i].text.isEmpty) {
        _showSnack('${['A', 'B', 'C', 'D'][i]} şıkkı boş!', Colors.orange);
        return;
      }
    }

    setState(() {
      _addedQuestions.add(TriviaQuestion(
        id: _addedQuestions.length + 1,
        question: _questionCtrl.text.trim(),
        options: _optionCtrls.map((c) => c.text.trim()).toList(),
        correctIndex: _correctOptionIndex,
        timeSeconds: int.tryParse(_timeCtrl.text) ?? 15,
        category: _selectedCategory,
      ));
    });

    // Formu temizle
    _questionCtrl.clear();
    for (var ctrl in _optionCtrls) {
      ctrl.clear();
    }
    _correctOptionIndex = 0;

    _showSnack('✅ Soru eklendi! Toplam: ${_addedQuestions.length}', Colors.green);
  }

  void _loadSampleQuestions() {
    setState(() {
      _addedQuestions = _service.getSampleQuestions();
    });
    _showSnack('📚 ${_addedQuestions.length} örnek soru yüklendi!', Colors.blue);
  }

  void _clearAllQuestions() {
    setState(() => _addedQuestions.clear());
    _showSnack('🗑️ Tüm sorular silindi!', Colors.grey);
  }

  void _goLive() {
    if (_addedQuestions.isEmpty) {
      _showSnack('❌ Önce soru ekle!', Colors.red);
      return;
    }

    // Lobini aç
    _service.openLobby(_addedQuestions, 'Admin yayını başlattı!');

    // Dialog ile başlatma onayı
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.live_tv, color: Colors.red),
            SizedBox(width: 10),
            Text('YAYIN HAZIR', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_addedQuestions.length} soru yüklendi.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            const Text(
              'BAŞLAT\'a basınca 3 saniye geri sayım sonrası ilk soru gönderilecek.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İPTAL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _service.startLiveSession();
              Navigator.pop(context); // Panelden çık
              _showSnack('🔴 CANLI YAYIN BAŞLADI!', Colors.red);
            },
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text('BAŞLAT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A15),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.red),
            SizedBox(width: 10),
            Text('YÖNETİCİ PANELİ'),
          ],
        ),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sıfırla',
            onPressed: () {
              _service.reset();
              _showSnack('🔄 Trivia sıfırlandı', Colors.grey);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════
            // SORU EKLEME FORMU
            // ═══════════════════════════════════════════════════
            _buildSectionHeader('📝 YENİ SORU EKLE'),
            const SizedBox(height: 12),

            // Soru metni
            _buildTextField(_questionCtrl, 'Soru metni', Icons.help_outline, maxLines: 2),
            const SizedBox(height: 12),

            // Şıklar (2x2 grid)
            Row(
              children: [
                Expanded(child: _buildTextField(_optionCtrls[0], 'A şıkkı', Icons.looks_one)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(_optionCtrls[1], 'B şıkkı', Icons.looks_two)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildTextField(_optionCtrls[2], 'C şıkkı', Icons.looks_3)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(_optionCtrls[3], 'D şıkkı', Icons.looks_4)),
              ],
            ),
            const SizedBox(height: 16),

            // Doğru cevap + Kategori + Süre
            Row(
              children: [
                // Doğru cevap
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Doğru Cevap', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<int>(
                          value: _correctOptionIndex,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1A1A2E),
                          underline: const SizedBox(),
                          items: List.generate(4, (i) {
                            return DropdownMenuItem(
                              value: i,
                              child: Text(
                                ['A', 'B', 'C', 'D'][i],
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }),
                          onChanged: (val) => setState(() => _correctOptionIndex = val!),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Kategori
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kategori', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1A1A2E),
                          underline: const SizedBox(),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat, style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCategory = val!),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Süre
                SizedBox(
                  width: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Süre (sn)', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _timeCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Butonlar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _addQuestionToList,
                    icon: const Icon(Icons.add),
                    label: const Text('EKLE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  onPressed: _loadSampleQuestions,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('ÖRNEK'),
                ),
              ],
            ),

            const Divider(color: Colors.white24, height: 40),

            // ═══════════════════════════════════════════════════
            // EKLENEN SORULAR LİSTESİ
            // ═══════════════════════════════════════════════════
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('📋 SORULAR (${_addedQuestions.length})'),
                if (_addedQuestions.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearAllQuestions,
                    icon: const Icon(Icons.delete_sweep, size: 16, color: Colors.red),
                    label: const Text('Tümünü Sil', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: _addedQuestions.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Text(
                          'Henüz soru eklenmedi.\nYukarıdan soru ekle veya örnek yükle.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _addedQuestions.length,
                      separatorBuilder: (_, __) => Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                      itemBuilder: (ctx, i) {
                        final q = _addedQuestions[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2),
                            child: Text('${i + 1}', style: const TextStyle(color: Colors.cyanAccent)),
                          ),
                          title: Text(
                            q.question,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          subtitle: Text(
                            '${q.category ?? "Genel"} • ${q.timeSeconds}sn • Doğru: ${['A', 'B', 'C', 'D'][q.correctIndex]}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 11),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => setState(() => _addedQuestions.removeAt(i)),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 30),

            // ═══════════════════════════════════════════════════
            // CANLI YAYIN BUTONU
            // ═══════════════════════════════════════════════════
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _addedQuestions.isEmpty ? Colors.grey : Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: _addedQuestions.isEmpty ? 0 : 8,
                  shadowColor: Colors.red.withValues(alpha: 0.5),
                ),
                onPressed: _addedQuestions.isEmpty ? null : _goLive,
                icon: const Icon(Icons.live_tv, size: 28),
                label: const Text(
                  'CANLI YAYINI BAŞLAT',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.cyanAccent,
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white38),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
