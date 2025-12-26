/// 🔒 NETX Focus - Sıkıyönetim Modu
/// Sensör tabanlı telefon hareket algılama

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../diamond/diamond_service.dart'; // 💎 Elmas Servisi

class SensorModeScreen extends StatefulWidget {
  const SensorModeScreen({super.key});

  @override
  State<SensorModeScreen> createState() => _SensorModeScreenState();
}

class _SensorModeScreenState extends State<SensorModeScreen> {
  // Oğrenci ID (test için sabit, gerçekte dışarıdan alınacak)
  final String _ogrenciId = 'test_ogrenci_123';
  // Durumlar
  bool _isActive = false;
  bool _isPhoneFlat = true;
  int _seconds = 0;
  Timer? _timer;

  // Sensör
  StreamSubscription<AccelerometerEvent>? _sensorSub;
  int _violationCount = 0;
  
  // Hassasiyet ayarı (düşük = daha hassas)
  final double _sensitivity = 3.0;

  @override
  void dispose() {
    _stopSession();
    super.dispose();
  }

  void _startSession() {
    WakelockPlus.enable(); // Ekranı açık tut
    HapticFeedback.heavyImpact(); // Başlangıç titreşimi
    
    setState(() {
      _isActive = true;
      _seconds = 0;
      _violationCount = 0;
      _isPhoneFlat = true;
    });

    // Sayaç başlat
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) => setState(() => _seconds++),
    );

    // Sensörleri dinle
    _sensorSub = accelerometerEventStream().listen((event) {
      // X veya Y ekseni çok oynarsa hareket var
      final isMoving = event.x.abs() > _sensitivity || event.y.abs() > _sensitivity;
      
      if (isMoving && _isPhoneFlat) {
        _triggerViolation();
      } else if (!isMoving && !_isPhoneFlat) {
        setState(() => _isPhoneFlat = true);
      }
    });
  }

  void _triggerViolation() {
    setState(() {
      _isPhoneFlat = false;
      _violationCount++;
    });
    
    // Titreşim ver
    HapticFeedback.vibrate();
    
    // 💎 20 ELMAS CEZASI KES!
    DiamondService.spendDiamonds(
      ogrenciId: _ogrenciId,
      amount: 20,
      reason: 'Focus İhlali Cezası',
    );
  }

  void _stopSession() {
    WakelockPlus.disable();
    _timer?.cancel();
    _sensorSub?.cancel();
  }

  void _finishAndExit() {
    _stopSession();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _violationCount == 0 ? Icons.emoji_events : Icons.warning_amber,
              color: _violationCount == 0 ? Colors.amber : Colors.redAccent,
            ),
            const SizedBox(width: 10),
            const Text("OPERASYON BİTTİ", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow("⏱️ Süre", _formatTime(_seconds)),
            const SizedBox(height: 10),
            _buildStatRow("⚠️ İhlal", "$_violationCount kez"),
            const SizedBox(height: 10),
            _buildStatRow(
              "📊 Sonuç",
              _violationCount == 0 ? "MÜKEMMEL! 🏆" : "Geliştirmeli",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("KAPAT", style: TextStyle(color: Colors.redAccent)),
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
    // İhlal durumunda kırmızı ekran
    final bgColor = _isPhoneFlat ? const Color(0xFF0A0A0A) : Colors.red.shade900;

    return PopScope(
      canPop: !_isActive, // Aktifken geri tuşunu engelle
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: bgColor,
            child: _isActive ? _buildActiveUI() : _buildStartUI(),
          ),
        ),
      ),
    );
  }

  Widget _buildStartUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.phonelink_lock, size: 80, color: Colors.redAccent),
        const SizedBox(height: 20),
        const Text(
          "SIKIYÖNETİM MODU",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Telefonu masaya düz koy. Başlat'a basınca hareket sensörleri aktif olacak. Telefonu eline alırsan alarm çalar!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ),
        const SizedBox(height: 40),
        
        // Talimatlar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildInstruction("1", "Telefonu masaya düz bırak"),
              const SizedBox(height: 8),
              _buildInstruction("2", "BAŞLAT'a bas"),
              const SizedBox(height: 8),
              _buildInstruction("3", "Çalışmaya odaklan"),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: _startSession,
          icon: const Icon(Icons.play_arrow),
          label: const Text("BAŞLAT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        
        const SizedBox(height: 20),
        
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text("Geri Dön"),
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildInstruction(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Text(number, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }

  Widget _buildActiveUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Durum başlığı
        Text(
          "ODAK SÜRESİ",
          style: TextStyle(color: Colors.grey[600], letterSpacing: 2, fontSize: 12),
        ),
        const SizedBox(height: 10),
        
        // Büyük sayaç
        Text(
          _formatTime(_seconds),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 64,
            fontWeight: FontWeight.bold,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        
        const SizedBox(height: 50),
        
        // Durum ikonu
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: _isPhoneFlat 
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: _isPhoneFlat ? Colors.green : Colors.white,
              width: 3,
            ),
          ),
          child: Icon(
            _isPhoneFlat ? Icons.check_circle : Icons.warning_amber_rounded,
            size: 80,
            color: _isPhoneFlat ? Colors.green : Colors.white,
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          _isPhoneFlat ? "SİSTEM STABİL" : "İHLAL TESPİT EDİLDİ!",
          style: TextStyle(
            color: _isPhoneFlat ? Colors.green : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
        
        if (_violationCount > 0) ...[
          const SizedBox(height: 10),
          Text(
            "Toplam ihlal: $_violationCount",
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
        
        const SizedBox(height: 60),
        
        // Bitir butonu (uzun basma)
        GestureDetector(
          onLongPress: _finishAndExit,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fingerprint, color: Colors.white30, size: 40),
              ),
              const SizedBox(height: 10),
              const Text(
                "Bitirmek için basılı tut",
                style: TextStyle(color: Colors.white30, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
