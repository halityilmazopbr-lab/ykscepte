/// 📺 NETX Trivia Modülü - Canlı Yarışma Ekranı
/// HQ Trivia / Hadi tarzı interaktif quiz UI (Admin kontrollü)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'trivia_models.dart';
import 'trivia_service.dart';
import 'admin_trivia_panel.dart';
import '../diamond/diamond_service.dart'; // 💎 Elmas Servisi
import '../diamond/diamond_widgets.dart'; // 💎 Elmas Animasyonu

class LiveTriviaScreen extends StatefulWidget {
  const LiveTriviaScreen({super.key});

  @override
  State<LiveTriviaScreen> createState() => _LiveTriviaScreenState();
}

class _LiveTriviaScreenState extends State<LiveTriviaScreen> with TickerProviderStateMixin {
  final TriviaService _service = TriviaService();

  // Oyuncu durumu
  bool _isEliminated = false;
  int? _selectedOption;
  int _score = 0;
  int _correctCount = 0;
  bool _rewardGiven = false; // Ödül verildi mi?
  
  // Oğrenci ID (test için sabit)
  final String _ogrenciId = 'test_ogrenci_123';

  // Animasyon
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Lobiye katıl (kullanıcı sayısı artsın)
    _service.joinLobby();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F2D),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _service.gameStream,
        builder: (context, snapshot) {
          // Henüz data yoksa veya yayın bekleniyorsa idle göster
          if (!snapshot.hasData) {
            return SafeArea(
              child: Column(
                children: [
                  _buildIdleHeader(),
                  Expanded(child: _buildIdleView()),
                ],
              ),
            );
          }

          final state = snapshot.data!['state'] as TriviaGameState;
          final data = snapshot.data!['data'] as Map<String, dynamic>;

          // Idle kontrolü (lobi boş veya isIdle flag'i varsa)
          final isIdle = data['isIdle'] == true || 
              (state == TriviaGameState.lobby && (data['questionCount'] ?? 0) == 0);

          if (isIdle) {
            return SafeArea(
              child: Column(
                children: [
                  _buildIdleHeader(),
                  Expanded(child: _buildIdleView()),
                ],
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                _buildLiveHeader(data),
                Expanded(child: _buildGameContent(state, data)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ⏳ IDLE HEADER (Yayın bekleniyor)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildIdleHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "BEKLEMEDE",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ⏳ IDLE VIEW (Yayın bekleniyor)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildIdleView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hourglass_empty, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            "HENÜZ YAYIN YOK",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Yöneticinin yayını başlatması bekleniyor...",
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 40),

          // Bekleme animasyonu
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.3 + _pulseController.value * 0.7,
                child: const Icon(Icons.wifi, size: 40, color: Colors.cyanAccent),
              );
            },
          ),
          const SizedBox(height: 10),
          const Text(
            "Bağlantı aktif",
            style: TextStyle(color: Colors.cyanAccent, fontSize: 12),
          ),

          const SizedBox(height: 60),

          // Admin Panel Butonu (Test için)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  "🔐 YÖNETİCİ ERİŞİMİ",
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminTriviaPanel()),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.red, size: 18),
                  label: const Text(
                    "Admin Paneli",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Geri Dön", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📺 CANLI YAYIN HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLiveHeader(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          // Canlı göstergesi
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.5 + _pulseController.value * 0.5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          const Text(
            "CANLI",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const Spacer(),
          // Kullanıcı sayısı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  "${data['userCount'] ?? 0}",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Çıkış
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54, size: 20),
            onPressed: () => _showExitDialog(),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Yarışmadan Çık?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Çıkarsan yarışmaya geri dönemezsin.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("KALDIR", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("ÇIKIŞ", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎮 OYUN İÇERİĞİ
  // ═══════════════════════════════════════════════════════════════

  Widget _buildGameContent(TriviaGameState state, Map<String, dynamic> data) {
    // Elendiyse ve bitmediyse izleyici modu
    if (_isEliminated && state != TriviaGameState.finished) {
      return _buildEliminatedView(state, data);
    }

    switch (state) {
      case TriviaGameState.lobby:
        return _buildLobbyView(data);
      case TriviaGameState.countdown:
        return _buildCountdownView(data['count'] as int);
      case TriviaGameState.question:
        // Her yeni soruda seçimi sıfırla
        final timeLeft = data['timeLeft'] as int;
        final question = data['question'] as TriviaQuestion;
        if (timeLeft == question.timeSeconds) _selectedOption = null;
        return _buildQuestionView(data);
      case TriviaGameState.reveal:
        return _buildRevealView(data);
      case TriviaGameState.finished:
        return _buildFinishedView(data);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 1️⃣ LOBİ EKRANI
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLobbyView(Map<String, dynamic> data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.live_tv, size: 80, color: Colors.cyanAccent),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.cyanAccent, Colors.pinkAccent],
          ).createShader(bounds),
          child: const Text(
            "NET-X CANLI",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "${data['userCount'] ?? 0} Ajan Hazır Bekliyor",
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 10),
        Text(
          "${data['questionCount'] ?? 0} Soru Yüklendi",
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 40),
        // Bekleme animasyonu
        const CircularProgressIndicator(color: Colors.pinkAccent),
        const SizedBox(height: 20),
        Text(
          data['message'] ?? 'Yönetici başlatıyor...',
          style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2️⃣ GERİ SAYIM (3-2-1)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCountdownView(int count) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.5, end: 1.0),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Text(
              "$count",
              style: TextStyle(
                color: Colors.white,
                fontSize: 120,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: Colors.pinkAccent.withValues(alpha: 0.5),
                    blurRadius: 30,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 3️⃣ SORU EKRANI
  // ═══════════════════════════════════════════════════════════════

  Widget _buildQuestionView(Map<String, dynamic> data) {
    final question = data['question'] as TriviaQuestion;
    final timeLeft = data['timeLeft'] as int;
    final questionIndex = data['questionIndex'] as int;
    final totalQuestions = data['totalQuestions'] as int;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Soru numarası
          Text(
            "SORU $questionIndex / $totalQuestions",
            style: const TextStyle(color: Colors.white54, letterSpacing: 2, fontSize: 12),
          ),
          const SizedBox(height: 10),

          // Zaman çubuğu
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: timeLeft / question.timeSeconds,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(
                timeLeft <= 3 ? Colors.redAccent : Colors.greenAccent,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$timeLeft",
            style: TextStyle(
              color: timeLeft <= 3 ? Colors.redAccent : Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          const Spacer(),

          // Soru metni
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              question.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),

          if (question.category != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                question.category!,
                style: const TextStyle(color: Colors.pinkAccent, fontSize: 11),
              ),
            ),
          ],

          const Spacer(),

          // Şıklar
          ...List.generate(question.options.length, (index) {
            final isSelected = _selectedOption == index;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: GestureDetector(
                onTap: () {
                  if (_selectedOption == null) {
                    HapticFeedback.mediumImpact();
                    setState(() => _selectedOption = index);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Colors.cyanAccent, Colors.lightBlueAccent],
                          )
                        : null,
                    color: isSelected ? null : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected ? Colors.cyanAccent : Colors.white24,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.cyanAccent : Colors.white54,
                          ),
                        ),
                        child: Text(
                          ["A", "B", "C", "D"][index],
                          style: TextStyle(
                            color: isSelected ? Colors.cyanAccent : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question.options[index],
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 4️⃣ CEVAP AÇIKLAMA
  // ═══════════════════════════════════════════════════════════════

  Widget _buildRevealView(Map<String, dynamic> data) {
    final question = data['question'] as TriviaQuestion;
    final correctIndex = data['correctIndex'] as int;

    // Doğru/yanlış kontrolü
    bool wasCorrect = false;
    if (!_isEliminated && _selectedOption != null) {
      if (_selectedOption == correctIndex) {
        wasCorrect = true;
        // Puan ekle
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isEliminated) {
            setState(() {
              _correctCount++;
              _score += 100;
            });
          }
        });
      } else {
        // Elendi
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isEliminated) {
            setState(() => _isEliminated = true);
          }
        });
      }
    } else if (!_isEliminated && _selectedOption == null) {
      // Cevap vermedi -> elendi
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isEliminated) {
          setState(() => _isEliminated = true);
        }
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "DOĞRU CEVAP",
          style: TextStyle(color: Colors.white54, letterSpacing: 2, fontSize: 12),
        ),
        const SizedBox(height: 20),

        // Doğru cevap kartı
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.greenAccent, Colors.green],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                question.options[correctIndex],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Icon(Icons.check_circle, color: Colors.white, size: 40),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Sonuç mesajı
        if (_isEliminated)
          const Column(
            children: [
              Icon(Icons.sentiment_dissatisfied, color: Colors.redAccent, size: 50),
              SizedBox(height: 10),
              Text(
                "ELENDİNİZ!",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        else if (wasCorrect)
          Column(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 50),
              const SizedBox(height: 10),
              const Text(
                "DOĞRU!",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "+100 Puan",
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 5️⃣ BİTİŞ EKRANI
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFinishedView(Map<String, dynamic> data) {
    final winners = data['winners'] as int? ?? 0;
    final prize = data['prize'] as int? ?? 500;
    final totalQuestions = _service.activeQuestions.length;

    // 💎 KAZANDIYSA ÖDÜL VER (sadece 1 kez)
    if (!_isEliminated && !_rewardGiven) {
      _rewardGiven = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DiamondService.earnDiamonds(
          ogrenciId: _ogrenciId,
          amount: prize,
          reason: 'Trivia Şampiyonluğu! 🏆',
        );
        if (mounted) {
          showDiamondEarnPopup(context, prize, 'Trivia Şampiyonluğu! 🏆');
        }
      });
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isEliminated ? Icons.sentiment_neutral : Icons.emoji_events,
              size: 100,
              color: _isEliminated ? Colors.grey : Colors.amber,
            ),
            const SizedBox(height: 20),
            const Text(
              "YARIŞMA BİTTİ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),

            if (_isEliminated) ...[
              const Text(
                "Maalesef bu sefer kazanamadın.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Text(
                "Doğru Cevap: $_correctCount",
                style: const TextStyle(color: Colors.white54),
              ),
            ] else ...[
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                ).createShader(bounds),
                child: const Text(
                  "KAZANDIN! 🎉",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "$prize ELMAS KAZANDIN!",
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 30),

            // İstatistikler
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildStatRow("Kazanan Sayısı", "$winners kişi"),
                  const SizedBox(height: 8),
                  _buildStatRow("Senin Puanın", "$_score"),
                  const SizedBox(height: 8),
                  _buildStatRow("Doğru Cevap", "$_correctCount / $totalQuestions"),
                ],
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home),
              label: const Text("ANA SAYFAYA DÖN", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 👀 ELENDİ - İZLEYİCİ MODU
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEliminatedView(TriviaGameState state, Map<String, dynamic> data) {
    return Stack(
      children: [
        // Arka planda devam eden oyun
        Opacity(
          opacity: 0.3,
          child: IgnorePointer(
            child: _buildGameContentNoRecursion(state, data),
          ),
        ),
        // Elenme overlay
        Container(
          color: Colors.black54,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.visibility, color: Colors.white24, size: 80),
                SizedBox(height: 20),
                Text(
                  "ELENDİNİZ",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "İzleyici modunda devam ediyorsun...",
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Elenme görünümünde sonsuz döngü önlemek için
  Widget _buildGameContentNoRecursion(TriviaGameState state, Map<String, dynamic> data) {
    switch (state) {
      case TriviaGameState.lobby:
        return _buildLobbyView(data);
      case TriviaGameState.countdown:
        return _buildCountdownView(data['count'] as int);
      case TriviaGameState.question:
        return _buildQuestionView(data);
      case TriviaGameState.reveal:
        return _buildRevealView(data);
      case TriviaGameState.finished:
        return _buildFinishedView(data);
    }
  }
}
