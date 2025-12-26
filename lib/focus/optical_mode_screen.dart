/// 📝 NETX Focus - Optik Mod
/// App lifecycle tracking + optik form girişi

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class OpticalModeScreen extends StatefulWidget {
  const OpticalModeScreen({super.key});

  @override
  State<OpticalModeScreen> createState() => _OpticalModeScreenState();
}

class _OpticalModeScreenState extends State<OpticalModeScreen> with WidgetsBindingObserver {
  Timer? _timer;
  int _seconds = 0;
  final List<String?> _answers = List.filled(40, null); // 40 Soru
  
  // İhlal takibi
  int _leftAppCount = 0;
  bool _isWarningVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    _timer?.cancel();
    super.dispose();
  }

  // Uygulama durumu değiştiğinde
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      setState(() {
        _leftAppCount++;
        _isWarningVisible = true;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) => setState(() => _seconds++),
    );
  }

  void _finishExam() {
    _timer?.cancel();
    
    // Cevaplanan soru sayısı
    final answeredCount = _answers.where((a) => a != null).length;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.cyanAccent),
            SizedBox(width: 10),
            Text("SINAV TAMAMLANDI", style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow("⏱️ Süre", _formatTime(_seconds)),
            const SizedBox(height: 10),
            _buildStatRow("📝 Cevaplanan", "$answeredCount / 40"),
            const SizedBox(height: 10),
            _buildStatRow("⚠️ Uygulama çıkışı", "$_leftAppCount kez"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _leftAppCount == 0 
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    _leftAppCount == 0 ? Icons.verified : Icons.warning,
                    color: _leftAppCount == 0 ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _leftAppCount == 0 
                          ? "Harika! Hiç çıkmadın." 
                          : "Dikkat dağınıklığı tespit edildi.",
                      style: TextStyle(
                        color: _leftAppCount == 0 ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("KAYDET VE ÇIK", style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatTime(int s) {
    final hours = (s ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (s % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Geri tuşunu engelle
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Row(
            children: [
              Icon(Icons.edit_note, color: Colors.cyanAccent, size: 24),
              SizedBox(width: 10),
              Text(
                "TYT DENEMESİ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.cyanAccent, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(_seconds),
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Uyarı bandı
            if (_leftAppCount > 0)
              GestureDetector(
                onTap: () => setState(() => _isWarningVisible = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  color: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "UYGULAMADAN ÇIKTIN! ($_leftAppCount kez)",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Optik form grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 40,
                itemBuilder: (context, index) => _buildQuestionItem(index),
              ),
            ),

            // Durum barı + Bitir butonu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
              child: Column(
                children: [
                  // İlerleme
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Cevaplanan: ${_answers.where((a) => a != null).length}/40",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        "Boş: ${_answers.where((a) => a == null).length}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Bitir butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _finishExam,
                      icon: const Icon(Icons.check),
                      label: const Text(
                        "SINAVI BİTİR",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildQuestionItem(int index) {
    final isAnswered = _answers[index] != null;
    
    return Container(
      decoration: BoxDecoration(
        color: isAnswered 
            ? Colors.cyanAccent.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAnswered 
              ? Colors.cyanAccent.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Soru numarası
          Text(
            "${index + 1}",
            style: TextStyle(
              color: isAnswered ? Colors.cyanAccent : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          // Şıklar
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 2,
            runSpacing: 2,
            children: ["A", "B", "C", "D", "E"].map((opt) {
              final selected = _answers[index] == opt;
              return GestureDetector(
                onTap: () => setState(() {
                  _answers[index] = _answers[index] == opt ? null : opt;
                }),
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? Colors.cyanAccent : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.cyanAccent : Colors.grey.shade700,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
