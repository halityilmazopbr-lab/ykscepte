import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flip_card/flip_card.dart';
import 'gemini_service.dart';
import 'models.dart';

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
      setState(() => _deckFinished = true);
    }
  }

  Future<void> _generateAIDeck(String topic) async {
    if (topic.isEmpty) return;
    
    setState(() => _isGenerating = true);
    
    try {
      final prompt = '''Sen bir YKS öğretmenisin. Konu: "$topic".
Bana bilgi kartı (Flashcard) formatında 10 adet Soru-Cevap çifti oluştur.
Çıktıyı SADECE şu JSON formatında ver, başka hiçbir şey yazma:
[
  {"front": "Soru 1", "back": "Cevap 1"},
  {"front": "Soru 2", "back": "Cevap 2"}
]''';

      final response = await GravityAI.generateText(prompt);
      
      // JSON'u parse et
      final jsonStart = response.indexOf('[');
      final jsonEnd = response.lastIndexOf(']') + 1;
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        final List<dynamic> parsed = jsonDecode(jsonStr);
        
        final aiCards = parsed.map((item) => LeitnerCard(
          id: "AI:$topic:${item['front']}",
          front: item['front'],
          back: item['back'],
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
          SnackBar(content: Text("✨ ${aiCards.length} kart oluşturuldu!"), backgroundColor: Colors.green),
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
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.amber),
            onPressed: _showAIGeneratorDialog,
            tooltip: "AI ile Deste Oluştur",
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

  Widget _buildFlipCard(LeitnerCard card) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      front: _buildCardFace(card.front, true, card.box),
      back: _buildCardFace(card.back, false, card.box),
    );
  }

  Widget _buildCardFace(String text, bool isFront, int box) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFront 
              ? [Colors.purple.shade800, Colors.deepPurple.shade700]
              : [Colors.green.shade700, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isFront ? Colors.purple : Colors.green).withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Kutu göstergesi
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    box == 1 ? Icons.looks_one : (box == 2 ? Icons.looks_two : Icons.looks_3),
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    box == 1 ? "Günlük" : (box == 2 ? "3 Günlük" : "Haftalık"),
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          
          // Ana içerik
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isFront ? Icons.help_outline : Icons.lightbulb,
                    color: Colors.white.withAlpha(100),
                    size: 40,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isFront ? "SORU" : "CEVAP",
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Swipe ipucu
          if (isFront)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Text(
                "Çevirmek için dokun",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12),
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
}

/// Leitner Kart Modeli
class LeitnerCard {
  final String id;
  final String front;
  final String back;
  final int box;
  
  LeitnerCard({required this.id, required this.front, required this.back, this.box = 1});
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
