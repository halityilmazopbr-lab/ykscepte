/// ⏱️ NETX Focus - Serbest Mod
/// Basit kronometre ile çalışma takibi

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ChronoModeScreen extends StatefulWidget {
  const ChronoModeScreen({super.key});

  @override
  State<ChronoModeScreen> createState() => _ChronoModeScreenState();
}

class _ChronoModeScreenState extends State<ChronoModeScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (t) => setState(() => _seconds++),
      );
    }
    setState(() => _isRunning = !_isRunning);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _seconds = 0;
    });
  }

  void _saveAndExit() {
    _timer?.cancel();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.timer, color: Colors.greenAccent),
            SizedBox(width: 10),
            Text("ÇALIŞMA TAMAMLANDI", style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    "TOPLAM SÜRE",
                    style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(_seconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getMotivationalMessage(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("KAYDET VE ÇIK", style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage() {
    if (_seconds < 60) {
      return "Sadece ${_seconds} saniye mi? Biraz daha devam et! 💪";
    } else if (_seconds < 1800) { // 30 dakika
      return "İyi bir başlangıç! Devam et. 🔥";
    } else if (_seconds < 3600) { // 1 saat
      return "Yarım saatten fazla çalıştın. Harika! ⭐";
    } else if (_seconds < 7200) { // 2 saat
      return "Bir saati geçtin! Sen bir savaşçısın. 🏆";
    } else {
      return "İnanılmaz bir azim! Gerçek bir şampiyon. 👑";
    }
  }

  String _formatTime(int s) {
    final hours = (s ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (s % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          "SERBEST ÇALIŞMA",
          style: TextStyle(fontSize: 14, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_seconds > 0)
            IconButton(
              onPressed: _saveAndExit,
              icon: const Icon(Icons.save),
              tooltip: "Kaydet ve Çık",
            ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ═══════════════════════════════════════════════════
          // GÖRSEL SAYAÇ
          // ═══════════════════════════════════════════════════
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isRunning ? Colors.greenAccent : Colors.grey.shade800,
                  width: 5,
                ),
                boxShadow: _isRunning
                    ? [
                        BoxShadow(
                          color: Colors.greenAccent.withValues(alpha: 0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isRunning ? Icons.play_arrow : Icons.pause,
                      key: ValueKey(_isRunning),
                      size: 40,
                      color: _isRunning ? Colors.greenAccent : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatTime(_seconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isRunning 
                          ? Colors.greenAccent.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isRunning ? "ODAKLANIYOR" : "DURAKLATILDI",
                      style: TextStyle(
                        color: _isRunning ? Colors.greenAccent : Colors.grey,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 60),

          // ═══════════════════════════════════════════════════
          // KONTROL BUTONLARI
          // ═══════════════════════════════════════════════════
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset
              FloatingActionButton(
                heroTag: "reset",
                backgroundColor: Colors.grey.shade800,
                onPressed: _seconds > 0 ? _reset : null,
                child: Icon(
                  Icons.refresh,
                  color: _seconds > 0 ? Colors.white : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 30),
              // Play/Pause
              FloatingActionButton.large(
                heroTag: "play",
                backgroundColor: _isRunning ? Colors.orangeAccent : Colors.greenAccent,
                onPressed: _toggleTimer,
                child: Icon(
                  _isRunning ? Icons.pause : Icons.play_arrow,
                  size: 40,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // İpucu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _isRunning 
                  ? "Çalışmaya odaklan. Ekran açık kalacak."
                  : "Başlamak için yeşil butona bas.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
