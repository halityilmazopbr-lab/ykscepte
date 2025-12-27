import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flip_card/flip_card.dart';
import 'package:share_plus/share_plus.dart';
import 'gemini_service.dart';
import 'models.dart';
import 'audio_study_service.dart';
import 'ocr_service.dart';
import 'duel_service.dart';
import 'duel_model.dart';

/// Akıllı Bilgi Kartları - Tinder Style Flashcards
/// Leitner System (Spaced Repetition) ile
class FlashcardsEkrani extends StatefulWidget {
  final Ogrenci? ogrenci;
  const FlashcardsEkrani({super.key, this.ogrenci});

  @override
  State<FlashcardsEkrani> createState() => _FlashcardsEkraniState();
}

class _FlashcardsEkraniState extends State<FlashcardsEkrani> {
  String _selectedCategory = "Edebiyat";
  List<LeitnerCard> _currentDeck = [];
  int _sessionCorrect = 0;
  int _sessionWrong = 0;
  bool _deckFinished = false;
  bool _isGenerating = false;
  
  // 🎵 Uyku Modu (Audio Flashcards)
  final AudioStudyService _audioService = AudioStudyService();
  AudioState _audioState = AudioState.stopped;
  int _currentAudioIndex = 0;
  
  // ⚔️ Düello Sistemi
  final DuelService _duelService = DuelService();
  bool _isDuelMode = false;
  DuelModel? _activeDuel;
  final Stopwatch _duelStopwatch = Stopwatch();
  
  final AppinioSwiperController _swiperController = AppinioSwiperController();
  final TextEditingController _aiTopicController = TextEditingController();

  // Hazır desteler
  final Map<String, List<Map<String, String>>> _preloadedDecks = {
    "Edebiyat": [
      {"front": "Namık Kemal'in eserleri?", "back": "Vatan yahut Silistre, İntibah, Cezmi"},
      {"front": "Suç ve Ceza'nın yazarı?", "back": "Dostoyevski"},
      {"front": "Çalıkuşu kimin eseri?", "back": "Reşat Nuri Güntekin"},
      {"front": "Yaprak Dökümü kimin eseri?", "back": "Reşat Nuri Güntekin"},
      {"front": "Fatih-Harbiye romanının yazarı?", "back": "Peyami Safa"},
      {"front": "Yaban romanının konusu?", "back": "Kurtuluş Savaşı ve köy gerçeği - Yakup Kadri"},
      {"front": "Ateşten Gömlek romanının yazarı?", "back": "Halide Edib Adıvar"},
      {"front": "Tevfik Fikret'in şiir kitapları?", "back": "Rübab-ı Şikeste, Haluk'un Defteri"},
      {"front": "Serveti Fünun dergisinin kurucusu?", "back": "Recaizade Mahmut Ekrem"},
      {"front": "Türk edebiyatında ilk realist roman?", "back": "Araba Sevdası - Recaizade Mahmut Ekrem"},
    ],
    "Tarih": [
      {"front": "Malazgirt Savaşı tarihi?", "back": "1071 - Anadolu'nun kapıları Türklere açıldı"},
      {"front": "İstanbul'un Fethi?", "back": "1453 - Fatih Sultan Mehmet"},
      {"front": "Tanzimat Fermanı ne zaman ilan edildi?", "back": "1839 - Mustafa Reşit Paşa"},
      {"front": "I. Meşrutiyet tarihi?", "back": "1876 - Kanun-i Esasi"},
      {"front": "II. Meşrutiyet tarihi?", "back": "1908 - İttihat ve Terakki"},
      {"front": "Samsun'a çıkış?", "back": "19 Mayıs 1919"},
      {"front": "TBMM'nin açılışı?", "back": "23 Nisan 1920"},
      {"front": "Sakarya Meydan Muharebesi?", "back": "1921 - Mustafa Kemal Başkomutan"},
      {"front": "Cumhuriyet'in ilanı?", "back": "29 Ekim 1923"},
      {"front": "Halifeliğin kaldırılması?", "back": "3 Mart 1924"},
    ],
    "Coğrafya": [
      {"front": "Türkiye'nin en uzun nehri?", "back": "Kızılırmak - 1.355 km"},
      {"front": "Türkiye'nin en büyük gölü?", "back": "Van Gölü - 3.713 km²"},
      {"front": "Türkiye'nin en yüksek dağı?", "back": "Ağrı Dağı - 5.137 m"},
      {"front": "Akdeniz ikliminin özellikleri?", "back": "Yazlar sıcak-kuru, kışlar ılık-yağışlı"},
      {"front": "Karadeniz ikliminin özellikleri?", "back": "Her mevsim yağışlı, ılıman"},
      {"front": "GAP nedir?", "back": "Güneydoğu Anadolu Projesi - Fırat/Dicle"},
      {"front": "Türkiye'nin yüzölçümü?", "back": "783.562 km²"},
      {"front": "Ergene Havzası nerede?", "back": "Trakya - Türkiye'nin en verimli ovası"},
      {"front": "Gediz Nehri nereye dökülür?", "back": "Ege Denizi"},
      {"front": "Tuz Gölü hangi bölgede?", "back": "İç Anadolu Bölgesi"},
    ],
    "Felsefe": [
      {"front": "Sokrates'in yöntemi?", "back": "Sorgulama (Maieutik) - 'Kendini bil'"},
      {"front": "Platon'un ünlü kuramı?", "back": "İdealar Kuramı"},
      {"front": "Aristoteles'in mantık ilkesi?", "back": "Altın Orta"},
      {"front": "Descartes'in ünlü sözü?", "back": "Cogito ergo sum - Düşünüyorum öyleyse varım"},
      {"front": "Kant'ın ana eseri?", "back": "Saf Aklın Eleştirisi"},
      {"front": "Nietzsche'nin kavramları?", "back": "Üstinsan, Tanrı öldü, Güç istenci"},
      {"front": "Hegel'in diyalektiği?", "back": "Tez - Antitez - Sentez"},
      {"front": "Sartre'ın varoluşçu sözü?", "back": "Varoluş özden önce gelir"},
      {"front": "Fârâbî'nin eseri?", "back": "El-Medinetü'l Fâzıla (Erdemli Şehir)"},
      {"front": "Karl Marx'ın görüşü?", "back": "Materyalist tarih anlayışı, sınıf mücadelesi"},
    ],
    "İngilizce": [
      {"front": "Nevertheless", "back": "Buna rağmen, yine de"},
      {"front": "Furthermore", "back": "Ayrıca, üstelik"},
      {"front": "Consequently", "back": "Sonuç olarak"},
      {"front": "Meanwhile", "back": "Bu arada, bu esnada"},
      {"front": "Therefore", "back": "Bu nedenle, bu yüzden"},
      {"front": "Although", "back": "Her ne kadar, -e rağmen"},
      {"front": "Despite / In spite of", "back": "-e rağmen (+ isim/fiil-ing)"},
      {"front": "Whereas", "back": "Oysa, halbuki"},
      {"front": "On the contrary", "back": "Aksine, tersine"},
      {"front": "Moreover", "back": "Bunun yanı sıra, dahası"},
    ],
  };

  // Leitner verileri (SharedPreferences'da saklanır)
  Map<String, LeitnerData> _leitnerData = {};

  @override
  void initState() {
    super.initState();
    _loadLeitnerData();
    _audioService.init(); // 🎵 TTS motorunu başlat
  }
  
  @override
  void dispose() {
    _audioService.stop(); // 🎵 Sayfa kapanınca sesi durdur
    super.dispose();
  }

  Future<void> _loadLeitnerData() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('leitnerData');
    if (saved != null) {
      final Map<String, dynamic> decoded = jsonDecode(saved);
      _leitnerData = decoded.map((key, value) => MapEntry(key, LeitnerData.fromJson(value)));
    }
    _loadDeck();
  }

  Future<void> _saveLeitnerData() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_leitnerData.map((key, value) => MapEntry(key, value.toJson())));
    await prefs.setString('leitnerData', encoded);
  }

  void _loadDeck() {
    final now = DateTime.now();
    final cards = <LeitnerCard>[];
    
    for (var cardData in _preloadedDecks[_selectedCategory] ?? []) {
      final cardId = "$_selectedCategory:${cardData['front']}";
      final leitner = _leitnerData[cardId] ?? LeitnerData(box: 1, nextReview: now);
      
      // Bugün gösterilmesi gereken kartları al
      if (leitner.nextReview.isBefore(now.add(const Duration(days: 1)))) {
        cards.add(LeitnerCard(
          id: cardId,
          front: cardData['front']!,
          back: cardData['back']!,
          box: leitner.box,
        ));
      }
    }
    
    // Kutu 1 (bilinmeyen) önce, sonra 2, sonra 3
    cards.sort((a, b) => a.box.compareTo(b.box));
    
    setState(() {
      _currentDeck = cards;
      _deckFinished = cards.isEmpty;
      _sessionCorrect = 0;
      _sessionWrong = 0;
    });
  }

  void _onSwipeRight(int index) {
    // Biliyorum - kutu yükselt
    final card = _currentDeck[index];
    final leitner = _leitnerData[card.id] ?? LeitnerData(box: 1, nextReview: DateTime.now());
    
    int newBox = (leitner.box + 1).clamp(1, 3);
    DateTime nextReview;
    
    switch (newBox) {
      case 1: nextReview = DateTime.now().add(const Duration(days: 1)); break;
      case 2: nextReview = DateTime.now().add(const Duration(days: 3)); break;
      case 3: nextReview = DateTime.now().add(const Duration(days: 7)); break;
      default: nextReview = DateTime.now().add(const Duration(days: 1));
    }
    
    _leitnerData[card.id] = LeitnerData(box: newBox, nextReview: nextReview);
    _saveLeitnerData();
    
    setState(() => _sessionCorrect++);
    _checkDeckFinished(index);
  }

  void _onSwipeLeft(int index) {
    // Bilmiyorum - kutu 1'e düşür
    final card = _currentDeck[index];
    
    _leitnerData[card.id] = LeitnerData(
      box: 1, 
      nextReview: DateTime.now().add(const Duration(days: 1)),
    );
    _saveLeitnerData();
    
    setState(() => _sessionWrong++);
    _checkDeckFinished(index);
  }

  void _checkDeckFinished(int index) {
    if (index >= _currentDeck.length - 1) {
      if (_isDuelMode) {
        _duelStopwatch.stop();
        _submitDuelResult();
      }
      setState(() => _deckFinished = true);
    }
  }

  Future<void> _generateAIDeck(String topic) async {
    if (topic.isEmpty) return;
    
    setState(() => _isGenerating = true);
    
    // 🎯 ÖSYM MASTER PROMPT
    const masterPrompt = '''
Sen, ÖSYM Soru Hazırlama Komitesi'nde 20 yıl görev yapmış, emekli bir profesör ve aynı zamanda öğrencilere ilham veren bir koçsun.

🎯 GÖREVİN:
Verilen konuda ÖSYM formatına uygun, öğrencinin aklında kalacak ve sınavda karşısına çıkma ihtimali yüksek olan bilgi kartları (flashcard) üret.

📚 TEMEL KURALLAR:
1. SADECE MEB Müfredatı ve ÖSYM çıkmış soru tarzına uygun ol.
2. Wikipedia veya gereksiz ansiklopedik bilgilerden KAÇIN. Net ve öz ol.
3. Tarihleri, formülleri, isimleri ve kavramları DOĞRU yaz. Hata YASAK.
4. Her kartta pedagojik bir yaklaşım olsun: İpucu ile düşündür, Motivasyonla ödüllendir.

📋 ZORUNLU JSON FORMATI (Başka format KABUL EDİLMEZ):
[
  {
    "question": "ÖSYM tarzı soru metni",
    "answer": "Net ve doğru cevap",
    "hint": "Cevabı bulamazsa yardımcı olacak ipucu (1 cümle)",
    "motivation": "Öğrenciyi motive eden kısa not (1 cümle)",
    "importance": "Her Yıl Çıkar | Sık Çıkar | Nadiren Çıkar"
  }
]

🔥 ÖNEM DERECELERİ:
- "Her Yıl Çıkar": Son 5 yılda en az 3 kez çıkmış konular
- "Sık Çıkar": Son 5 yılda 1-2 kez çıkmış konular  
- "Nadiren Çıkar": Müfredatta var ama seyrek sorulan konular

💡 İPUCU YAZMA REHBERİ:
- Doğrudan cevabı VERMEYECEKSİN.
- Hafızada çağrışım yapacak bir anahtar ver.

🚀 MOTİVASYON NOTU REHBERİ:
- Kısa, samimi ve cesaretlendirici ol.

⚠️ KRİTİK: JSON formatından ASLA çıkma. Soru sayısı tam 10 olsun.
''';

    try {
      final prompt = '''$masterPrompt

---

KONU: "$topic"
KART SAYISI: 10

Yukarıdaki konuda 10 adet ÖSYM tarzı bilgi kartı oluştur.
SADECE JSON dizisi döndür, başka hiçbir şey yazma.''';

      final response = await GravityAI.generateText(prompt);
      
      // JSON'u parse et
      final jsonStart = response.indexOf('[');
      final jsonEnd = response.lastIndexOf(']') + 1;
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        final List<dynamic> parsed = jsonDecode(jsonStr);
        
        final aiCards = parsed.map((item) => LeitnerCard(
          id: "AI:$topic:${item['question'] ?? item['front']}",
          front: item['question'] ?? item['front'] ?? '',
          back: item['answer'] ?? item['back'] ?? '',
          hint: item['hint'] ?? 'Bu konuyu tekrar gözden geçir.',
          motivation: item['motivation'] ?? 'Her soru seni hedefe yaklaştırıyor!',
          importance: item['importance'] ?? 'Sık Çıkar',
          box: 1,
        )).toList();
        
        setState(() {
          _currentDeck = aiCards;
          _deckFinished = false;
          _sessionCorrect = 0;
          _sessionWrong = 0;
        });
        
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✨ ${aiCards.length} ÖSYM tarzı kart oluşturuldu!"), 
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("🃏 Bilgi Kartları", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // 🎵 Uyku Modu Butonu (Pro Özelliği)
          IconButton(
            icon: Icon(
              _audioState == AudioState.stopped ? Icons.headphones : Icons.pause_circle,
              color: _audioState == AudioState.stopped ? Colors.deepPurple : Colors.green,
            ),
            onPressed: _showAudioPlayerSheet,
            tooltip: "Uyku Modu",
          ),
          // 🦖 Paragraf Canavarı Butonu
          IconButton(
            icon: const Icon(Icons.article, color: Colors.teal),
            onPressed: _showParagrafCanavarDialog,
            tooltip: "Paragraf Canavarı",
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.amber),
            onPressed: _showAIGeneratorDialog,
            tooltip: "AI ile Deste Oluştur",
          ),
          // ⚔️ Düelloya Katıl Butonu
          IconButton(
            icon: const Icon(Icons.bolt, color: Colors.orange),
            onPressed: _showJoinDuelDialog,
            tooltip: "Düelloya Katıl",
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeck,
            tooltip: "Yenile",
          ),
        ],
      ),
      body: Column(
        children: [
          // Kategori Seçimi
          _buildCategorySelector(),
          
          // Stats Bar
          _buildStatsBar(),
          
          // Ana Kart Alanı
          Expanded(
            child: _deckFinished ? _buildFinishedState() : _buildSwiper(),
          ),
          
          // Alt Butonlar
          if (!_deckFinished && _currentDeck.isNotEmpty) _buildActionButtons(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _preloadedDecks.keys.map((cat) {
            bool isSelected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedCategory = cat);
                  _loadDeck();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.purple : const Color(0xFF21262D),
                    borderRadius: BorderRadius.circular(25),
                    border: isSelected ? null : Border.all(color: Colors.grey.shade800),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade400,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("📚", "Kalan", _currentDeck.length.toString(), Colors.blue),
          _buildStatItem("✅", "Doğru", _sessionCorrect.toString(), Colors.green),
          _buildStatItem("❌", "Yanlış", _sessionWrong.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      ],
    );
  }

  Widget _buildSwiper() {
    if (_currentDeck.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppinioSwiper(
        controller: _swiperController,
        cardCount: _currentDeck.length,
        onSwipeEnd: (previousIndex, targetIndex, activity) {
          if (activity is Swipe) {
            if (activity.direction == AxisDirection.right) {
              _onSwipeRight(previousIndex);
            } else if (activity.direction == AxisDirection.left) {
              _onSwipeLeft(previousIndex);
            }
          }
        },
        cardBuilder: (context, index) => _buildFlipCard(_currentDeck[index]),
      ),
    );
  }

  // 🔔 İpucu gösterme durumu
  bool _showHint = false;
  
  Widget _buildFlipCard(LeitnerCard card) {
    return StatefulBuilder(
      builder: (context, setCardState) {
        return FlipCard(
          direction: FlipDirection.HORIZONTAL,
          onFlip: () => setCardState(() => _showHint = false), // Çevirince ipucu gizle
          front: _buildEnhancedFront(card, setCardState),
          back: _buildEnhancedBack(card),
        );
      },
    );
  }

  /// 🎯 ÖN YÜZ - Soru + Önem Derecesi + İpucu Butonu
  Widget _buildEnhancedFront(LeitnerCard card, StateSetter setCardState) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade800, Colors.deepPurple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 🔥 ÖNEM DERECESİ BADGE (Sağ Üst)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: card.importanceColor.withAlpha(200),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: card.importanceColor.withAlpha(100),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(card.importanceEmoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    card.importance,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          
          // 📦 Kutu göstergesi (Sol Üst)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                card.box == 1 ? "📅 Günlük" : (card.box == 2 ? "📆 3 Günlük" : "🗓️ Haftalık"),
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ),
          ),
          
          // 🎯 ANA İÇERİK - Soru
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.help_outline, color: Colors.white30, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    "SORU",
                    style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        card.front,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  
                  // 💡 İPUCU ALANI
                  if (_showHint) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withAlpha(80)),
                      ),
                      child: Row(
                        children: [
                          const Text("💡", style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              card.hint,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // 🔘 ALT BUTONLAR
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // İpucu Butonu
                GestureDetector(
                  onTap: () => setCardState(() => _showHint = !_showHint),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _showHint ? Colors.amber : Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_outline, 
                          color: _showHint ? Colors.black : Colors.white70, 
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _showHint ? "İpucu Gizle" : "İpucu Al",
                          style: TextStyle(
                            color: _showHint ? Colors.black : Colors.white70, 
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Çevir İpucu
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "👆 Çevirmek için dokun",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ ARKA YÜZ - Cevap + Motivasyon Notu
  Widget _buildEnhancedBack(LeitnerCard card) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ✅ Check Badge (Sağ Üst)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
          ),
          
          // 🎯 ANA İÇERİK - Cevap
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.white30, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    "CEVAP",
                    style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        card.back,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 🚀 MOTİVASYON NOTU (Alt Şerit)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade600, Colors.orange.shade500],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  const Text("🚀", style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      card.motivation,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Bilmiyorum (Sola)
          GestureDetector(
            onTap: () => _swiperController.swipeLeft(),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade700,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withAlpha(80),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 32),
            ),
          ),
          
          // Biliyorum (Sağa)
          GestureDetector(
            onTap: () => _swiperController.swipeRight(),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade700,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withAlpha(80),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.celebration, size: 60, color: Colors.green),
          ),
          const SizedBox(height: 24),
          const Text(
            "Bugün için kart kalmadı!",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Yarın tekrar gel",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishedState() {
    final total = _sessionCorrect + _sessionWrong;
    final percentage = total > 0 ? (_sessionCorrect / total * 100).toInt() : 0;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.purple.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
          ),
          const SizedBox(height: 24),
          const Text(
            "Seans Tamamlandı!",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            "%$percentage Başarı",
            style: TextStyle(
              color: percentage >= 70 ? Colors.green : Colors.orange,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$_sessionCorrect doğru, $_sessionWrong yanlış",
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadDeck,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text("Tekrar Çalış", style: TextStyle(fontSize: 16)),
          ),
          if (!_isDuelMode && total > 0) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _startDuelChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade800,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              icon: const Icon(Icons.bolt),
              label: const Text("🔥 Arkadaşına Meydan Oku", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  void _showAIGeneratorDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF161B22),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber),
                  const SizedBox(width: 12),
                  const Text(
                    "AI ile Deste Oluştur",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text("PRO", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Hangi konuda kart oluşturmamı istersin?",
                style: TextStyle(color: Colors.grey.shade400),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _aiTopicController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Örn: 2. Dünya Savaşı, Türev, Biyoloji Sistemler...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  filled: true,
                  fillColor: const Color(0xFF21262D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : () => _generateAIDeck(_aiTopicController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isGenerating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("✨ 10 Kart Oluştur", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 🦖 Paragraf Canavarı - Metinden Flashcard Oluştur
  final TextEditingController _paragrafController = TextEditingController();
  bool _isParagrafLoading = false;
  
  void _showParagrafCanavarDialog() {
    _paragrafController.clear();
    _isParagrafLoading = false;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Başlık
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("🦖", style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Paragraf Canavarı",
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Metni ver, kartları al",
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.teal.shade700, Colors.cyan.shade600]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text("AI", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Açıklama
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.withAlpha(50)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.teal, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Ders kitabından veya notlarından bir paragraf yapıştır. AI en önemli 5 bilgiyi kart haline getirecek.",
                            style: TextStyle(color: Colors.teal.shade200, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 📸 Kamera/Galeri OCR Butonları
                  if (!_isParagrafLoading) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF21262D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Metin yapıştır veya fotoğraf çek:",
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                            ),
                          ),
                          // Kamera butonu
                          IconButton(
                            onPressed: () async {
                              setSheetState(() => _isParagrafLoading = true);
                              try {
                                final ocrService = OcrService();
                                final metin = await ocrService.extractTextFromCamera();
                                if (metin != null && metin.isNotEmpty) {
                                  _paragrafController.text = metin;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("📸 Metin okundu! Düzeltip \"Ören\" diyebilirsin."),
                                      backgroundColor: Colors.teal,
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("❌ $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setSheetState(() => _isParagrafLoading = false);
                              }
                            },
                            icon: const Icon(Icons.camera_alt, color: Colors.teal),
                            tooltip: "Kameradan Tara",
                          ),
                          // Galeri butonu
                          IconButton(
                            onPressed: () async {
                              setSheetState(() => _isParagrafLoading = true);
                              try {
                                final ocrService = OcrService();
                                final metin = await ocrService.extractTextFromGallery();
                                if (metin != null && metin.isNotEmpty) {
                                  _paragrafController.text = metin;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("🖼️ Metin okundu! Düzeltip \"Ören\" diyebilirsin."),
                                      backgroundColor: Colors.teal,
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("❌ $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setSheetState(() => _isParagrafLoading = false);
                              }
                            },
                            icon: const Icon(Icons.photo_library, color: Colors.cyan),
                            tooltip: "Galeriden Seç",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Loading durumu
                  if (_isParagrafLoading) ...[
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(color: Colors.teal),
                          const SizedBox(height: 20),
                          Text(
                            "🦖 Metni yutuyorum...",
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "En önemli bilgileri çıkarıyorum (2-5 saniye)",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Metin alanı
                    TextField(
                      controller: _paragrafController,
                      maxLines: 8,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Ders kitabından veya notlarından kopyaladığın paragrafı buraya yapıştır...\n\nÖrnek:\n\"Tanzimat Fermanı 1839'da Gülhane Parkı'nda okundu. Bu fermanla padişahın yetkileri sınırlandırıldı...\"",
                        hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF21262D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Butonlar
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: BorderSide(color: Colors.grey.shade700),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text("İptal"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (_paragrafController.text.length < 50) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("⚠️ Lütfen daha uzun bir metin girin (en az 50 karakter)"),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              
                              setSheetState(() => _isParagrafLoading = true);
                              
                              try {
                                final kartlar = await GravityAI.paragrafToFlashcards(
                                  _paragrafController.text,
                                  kartSayisi: 5,
                                );
                                
                                // Kartları destenin başına ekle
                                final yeniKartlar = kartlar.map((k) => LeitnerCard(
                                  id: "AI:${DateTime.now().millisecondsSinceEpoch}:${k['soru']}",
                                  front: k['soru'] ?? '',
                                  back: k['cevap'] ?? '',
                                  box: 1,
                                )).toList();
                                
                                setState(() {
                                  _currentDeck = [...yeniKartlar, ..._currentDeck];
                                  _deckFinished = false;
                                });
                                
                                Navigator.pop(context);
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Text("🦖", style: TextStyle(fontSize: 20)),
                                        const SizedBox(width: 12),
                                        Text("${yeniKartlar.length} kart oluşturuldu!"),
                                      ],
                                    ),
                                    backgroundColor: Colors.teal,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                                
                              } catch (e) {
                                setSheetState(() => _isParagrafLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("❌ Hata: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: const Text("🦖", style: TextStyle(fontSize: 18)),
                            label: const Text("Kartları Oluştur", style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// 🎧 Uyku Modu - Audio Player Bottom Sheet
  void _showAudioPlayerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Başlık
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.headphones, color: Colors.deepPurple, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                "Uyku Modu",
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Text("🎧", style: TextStyle(fontSize: 20)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Ekranı kapat, dinle ve öğren",
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.orange.shade600]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text("PRO", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Açıklama kartı
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.deepPurple.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.deepPurple, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Soruyu okuyacağım, düşün, sonra cevabı söyleyeceğim. Otobüste, yatakta bile çalışabilirsin!",
                          style: TextStyle(color: Colors.deepPurple.shade200, fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Durum Göstergesi
                if (_audioState != AudioState.stopped) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF21262D),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${_currentAudioIndex + 1}",
                            style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${_audioState.emoji} ${_audioState.label}",
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Kart ${_currentAudioIndex + 1} / ${_currentDeck.length}",
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Kontrol Butonları
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Durdur
                    if (_audioState != AudioState.stopped)
                      GestureDetector(
                        onTap: () {
                          _audioService.stop();
                          setState(() => _audioState = AudioState.stopped);
                          setSheetState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.stop, color: Colors.red, size: 28),
                        ),
                      ),
                    const SizedBox(width: 20),
                    
                    // Oynat / Duraklat
                    GestureDetector(
                      onTap: () {
                        if (_audioState == AudioState.stopped) {
                          // Başlat
                          final cards = _currentDeck.map((c) => {
                            'soru': c.front,
                            'cevap': c.back,
                          }).toList();
                          
                          _audioService.startPlaylist(
                            cards,
                            onIndexChanged: (index) {
                              setState(() => _currentAudioIndex = index);
                              setSheetState(() {});
                              // Ekrandaki kartı da çevir
                              if (index < _currentDeck.length) {
                                _swiperController.swipeDefault();
                              }
                            },
                            onStateChanged: (state) {
                              setState(() => _audioState = state);
                              setSheetState(() {});
                            },
                          );
                          setState(() => _audioState = AudioState.playing);
                          setSheetState(() {});
                          
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.headphones, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text("🎧 Uyku Modu aktif! Ekranı kapatabilirsin."),
                                ],
                              ),
                              backgroundColor: Colors.deepPurple,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else if (_audioState == AudioState.paused) {
                          // Devam et
                          _audioService.resume();
                          setState(() => _audioState = AudioState.playing);
                          setSheetState(() {});
                        } else {
                          // Duraklat
                          _audioService.pause();
                          setState(() => _audioState = AudioState.paused);
                          setSheetState(() {});
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _audioState == AudioState.stopped
                                ? [Colors.deepPurple, Colors.purple]
                                : [Colors.green, Colors.teal],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_audioState == AudioState.stopped ? Colors.deepPurple : Colors.green).withAlpha(100),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _audioState == AudioState.stopped
                              ? Icons.play_arrow
                              : (_audioState == AudioState.paused ? Icons.play_arrow : Icons.pause),
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    
                    // Sonraki
                    if (_audioState != AudioState.stopped)
                      GestureDetector(
                        onTap: () {
                          _audioService.skipToNext();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.skip_next, color: Colors.blue, size: 28),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Kart sayısı bilgisi
                Text(
                  "${_currentDeck.length} kart dinlenmeye hazır",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // ⚔️ DÜELLO MANTIĞI
  
  /// Mevcut desteyi dondurup arkadaşına meydan oku
  void _startDuelChallenge() async {
    // Pro Kontrolü (Simüle)
    // if (!widget.ogrenci!.isPro) { ... }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.orange)),
    );

    try {
      // Mevcut desteyi Map listesine çevir
      final kartMapler = _currentDeck.map((k) => {
        'front': k.front,
        'back': k.back,
      }).toList();

      final code = await _duelService.createDuel(
        userId: widget.ogrenci?.id ?? "anonim",
        ad: widget.ogrenci?.ad ?? "Rakip",
        kartListesi: kartMapler,
        skor: _sessionCorrect,
        sureSaniye: 60, // Şimdilik sabit, normalde stopwatch farkı
      );

      Navigator.pop(context); // Loading'i kapat

      // Paylaşım Mesajı
      final message = "YKS Cepte'de sana meydan okuyorum! ⚔️\n"
          "Skorum: $_sessionCorrect / ${_sessionCorrect + _sessionWrong}\n"
          "Kodum: $code\n"
          "Hadi göreyim seni! 💪\n"
          "Uygulamayı indir: https://ykscepte.app";

      await Share.share(message, subject: "YKS Bilgi Kartları Düellosu");

    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  /// Düello kodunu girme ekranı
  void _showJoinDuelDialog() {
    final TextEditingController codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("⚔️ Düelloya Katıl", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Arkadaşından gelen 6 haneli kodu gir ve onunla kapış!",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "000000",
                hintStyle: TextStyle(color: Colors.grey.shade700),
                counterStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF0D1117),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () async {
              if (codeController.text.length < 6) return;
              
              Navigator.pop(context);
              _joinDuel(codeController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
            child: const Text("BAŞLA!", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Düelloya katıl ve desteyi yükle
  void _joinDuel(String code) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.orange)),
    );

    try {
      final duel = await _duelService.joinDuel(code, widget.ogrenci?.id ?? "anonim_rakip");
      
      final duelCards = duel.kartlar.map((k) => LeitnerCard(
        id: "DUEL:${duel.id}:${k['front']}",
        front: k['front'],
        back: k['back'],
        box: 1,
      )).toList();

      setState(() {
        _currentDeck = duelCards;
        _isDuelMode = true;
        _activeDuel = duel;
        _deckFinished = false;
        _sessionCorrect = 0;
        _sessionWrong = 0;
        _duelStopwatch.reset();
        _duelStopwatch.start();
      });

      Navigator.pop(context); // Loading kapat
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚔️ ${duel.kurucuAd} ile düello başladı! Başarılar!"),
          backgroundColor: Colors.orange.shade900,
        ),
      );

    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Olamadı: $e"), backgroundColor: Colors.red));
    }
  }

  /// Düello sonucunu rakip olarak gönder
  void _submitDuelResult() async {
    if (_activeDuel == null) return;

    try {
      await _duelService.submitRakipScore(
        duelId: _activeDuel!.id,
        rakipAd: widget.ogrenci?.ad ?? "Rakip",
        skor: _sessionCorrect,
        sureSaniye: _duelStopwatch.elapsed.inSeconds,
      );
      
      setState(() => _isDuelMode = false); // Düello bitti

      _showWinnerDialog(); // Kim kazandı göster

    } catch (e) {
      debugPrint("Sonuç gönderilemedi: $e");
    }
  }

  /// Kazananı kutlama ekranı
  void _showWinnerDialog() {
    // Basit bir kazanan kontrolü
    bool kazandim = false;
    if (_activeDuel != null) {
      if (_sessionCorrect > _activeDuel!.kurucuSkor) {
        kazandim = true;
      } else if (_sessionCorrect == _activeDuel!.kurucuSkor) {
        // Skorda eşitlik varsa süreye bakılabilir (implementasyon eksik)
        kazandim = false;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(kazandim ? "🎉 TEBRİKLER!" : "💪 GÜZEL ÇABAYDI!", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(
              kazandim 
                ? "Arkadaşını ${_sessionCorrect} - ${_activeDuel?.kurucuSkor} skorla yendin! Sınıfın yeni kralı sensin! 👑"
                : "Arkadaşın ${_activeDuel?.kurucuSkor} yaptı, sen ${_sessionCorrect} yaptın. Bir dahaki sefere! 😉",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: kazandim ? Colors.green : Colors.purple),
              child: const Text("Tamam"),
            ),
          ],
        ),
      ),
    );
  }
}


/// Leitner Kart Modeli (Zenginleştirilmiş)
class LeitnerCard {
  final String id;
  final String front;           // Soru
  final String back;            // Cevap
  final String hint;            // İpucu
  final String motivation;      // Motivasyon notu
  final String importance;      // Önem derecesi
  final int box;
  
  LeitnerCard({
    required this.id, 
    required this.front, 
    required this.back, 
    this.hint = 'Bu konuyu tekrar gözden geçir.',
    this.motivation = 'Her soru seni hedefe yaklaştırıyor!',
    this.importance = 'Sık Çıkar',
    this.box = 1,
  });
  
  /// Önem derecesine göre emoji
  String get importanceEmoji {
    switch (importance) {
      case 'Her Yıl Çıkar':
        return '🔥';
      case 'Sık Çıkar':
        return '⭐';
      case 'Nadiren Çıkar':
        return '💡';
      default:
        return '📝';
    }
  }
  
  /// Önem derecesine göre renk
  Color get importanceColor {
    switch (importance) {
      case 'Her Yıl Çıkar':
        return const Color(0xFFFF6B6B);
      case 'Sık Çıkar':
        return const Color(0xFFFFD93D);
      case 'Nadiren Çıkar':
        return const Color(0xFF6BCB77);
      default:
        return const Color(0xFF4D96FF);
    }
  }
}

/// Leitner Veri Modeli (Kutu + Sonraki Tekrar)
class LeitnerData {
  final int box;
  final DateTime nextReview;
  
  LeitnerData({required this.box, required this.nextReview});
  
  Map<String, dynamic> toJson() => {
    'box': box,
    'nextReview': nextReview.toIso8601String(),
  };
  
  factory LeitnerData.fromJson(Map<String, dynamic> json) => LeitnerData(
    box: json['box'],
    nextReview: DateTime.parse(json['nextReview']),
  );
}
