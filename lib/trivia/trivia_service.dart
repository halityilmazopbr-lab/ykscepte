/// 📡 NETX Trivia Modülü - Canlı Yayın Motoru (Admin Kontrollü)
/// Singleton servis - Admin ve öğrenci aynı yayını görür

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'trivia_models.dart';

class TriviaService {
  // Singleton yapısı
  static final TriviaService _instance = TriviaService._internal();
  factory TriviaService() => _instance;
  TriviaService._internal();

  // Yayın Stream'i
  final _stateController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get gameStream => _stateController.stream;

  // Aktif sorular (Admin dolduracak)
  List<TriviaQuestion> _activeQuestions = [];
  List<TriviaQuestion> get activeQuestions => _activeQuestions;

  // Durum
  bool _isLive = false;
  bool get isLive => _isLive;
  int _userCount = 0;
  int get userCount => _userCount;

  // ═══════════════════════════════════════════════════════════════
  // 👮 ADMİN FONKSİYONLARI
  // ═══════════════════════════════════════════════════════════════

  /// Lobiyi aç (Admin soruları yükler)
  void openLobby(List<TriviaQuestion> questions, String message) {
    _activeQuestions = questions;
    _userCount = 0;
    debugPrint('📡 Lobi açıldı: ${questions.length} soru yüklendi');
    _emit(TriviaGameState.lobby, {
      'message': message,
      'userCount': _userCount,
      'questionCount': questions.length,
    });
  }

  /// Kullanıcı lobiye katıldı
  void joinLobby() {
    _userCount++;
    _emit(TriviaGameState.lobby, {
      'message': 'Yarışmacılar toplanıyor...',
      'userCount': _userCount,
      'questionCount': _activeQuestions.length,
    });
  }

  /// Canlı yayını başlat (Admin tetikler)
  Future<void> startLiveSession() async {
    if (_activeQuestions.isEmpty) {
      debugPrint('❌ Soru listesi boş!');
      return;
    }
    if (_isLive) {
      debugPrint('❌ Zaten canlı yayında!');
      return;
    }

    _isLive = true;
    debugPrint('🔴 CANLI YAYIN BAŞLADI!');

    try {
      // 3-2-1 geri sayım
      for (int i = 3; i > 0; i--) {
        _emit(TriviaGameState.countdown, {'count': i});
        await Future.delayed(const Duration(seconds: 1));
      }

      // Soruları gönder
      int questionIndex = 0;
      for (var q in _activeQuestions) {
        questionIndex++;

        // Soru göster ve geri sayım
        for (int timeLeft = q.timeSeconds; timeLeft > 0; timeLeft--) {
          _emit(TriviaGameState.question, {
            'question': q,
            'questionIndex': questionIndex,
            'totalQuestions': _activeQuestions.length,
            'timeLeft': timeLeft,
          });
          await Future.delayed(const Duration(seconds: 1));
        }

        // Cevabı açıkla (5 saniye)
        _emit(TriviaGameState.reveal, {
          'question': q,
          'correctIndex': q.correctIndex,
          'stats': _generateFakeStats(),
        });
        await Future.delayed(const Duration(seconds: 4));
      }

      // Bitiş
      _emit(TriviaGameState.finished, {
        'winners': (_userCount * 0.1).round().clamp(1, 100),
        'prize': 500,
        'totalParticipants': _userCount,
      });

    } finally {
      _isLive = false;
      debugPrint('⏹️ Yayın bitti.');
    }
  }

  /// Yayını sıfırla
  void reset() {
    _isLive = false;
    _userCount = 0;
    _activeQuestions.clear();
    _emit(TriviaGameState.lobby, {
      'message': 'Yayın bekleniyor...',
      'userCount': 0,
      'questionCount': 0,
    });
    debugPrint('🔄 Trivia sıfırlandı.');
  }

  /// Idle durumuna geç
  void goIdle() {
    _isLive = false;
    _emit(TriviaGameState.lobby, {
      'message': 'Yayın bekleniyor...',
      'userCount': _userCount,
      'questionCount': 0,
      'isIdle': true,
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // 📚 HAZIR SORU SETLERİ
  // ═══════════════════════════════════════════════════════════════

  /// Örnek YKS soruları
  List<TriviaQuestion> getSampleQuestions() {
    return [
      TriviaQuestion(
        id: 1,
        question: "Hangisi 'Beş Hececiler'den biri DEĞİLDİR?",
        options: ["Orhan Seyfi Orhon", "Faruk Nafiz Çamlıbel", "Yahya Kemal Beyatlı", "Yusuf Ziya Ortaç"],
        correctIndex: 2,
        category: "Edebiyat",
      ),
      TriviaQuestion(
        id: 2,
        question: "Türkiye'nin en yüksek dağı hangisidir?",
        options: ["Erciyes Dağı", "Ağrı Dağı", "Süphan Dağı", "Kaçkar Dağları"],
        correctIndex: 1,
        category: "Coğrafya",
      ),
      TriviaQuestion(
        id: 3,
        question: "İstiklal Marşı hangi yıl kabul edilmiştir?",
        options: ["1919", "1920", "1921", "1923"],
        correctIndex: 2,
        category: "Tarih",
      ),
      TriviaQuestion(
        id: 4,
        question: "Cumhuriyet hangi yıl ilan edilmiştir?",
        options: ["1920", "1921", "1922", "1923"],
        correctIndex: 3,
        category: "Tarih",
      ),
      TriviaQuestion(
        id: 5,
        question: "'Nutuk' hangi yıl yayımlanmıştır?",
        options: ["1923", "1925", "1927", "1929"],
        correctIndex: 2,
        category: "Tarih",
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔧 YARDIMCI
  // ═══════════════════════════════════════════════════════════════

  void _emit(TriviaGameState state, Map<String, dynamic> data) {
    if (!_stateController.isClosed) {
      _stateController.add({
        'state': state,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  Map<String, int> _generateFakeStats() {
    return {
      'A': 15 + (DateTime.now().millisecond % 20),
      'B': 25 + (DateTime.now().millisecond % 30),
      'C': 10 + (DateTime.now().millisecond % 15),
      'D': 20 + (DateTime.now().millisecond % 25),
    };
  }

  void dispose() {
    _stateController.close();
  }
}
