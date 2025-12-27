import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 5 Adımlı Onboarding Akışı
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  _OnboardingFlowState createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Adım 1: Kullanıcı Verileri
  String _studentName = '';
  String _selectedField = ''; // Sayısal, Eşit Ağırlık, Sözel

  // Adım 2: Akademik Durum (YKS Uyumlu)
  final Map<String, int> _tytNets = {
    'Türkçe': 0,
    'Matematik': 0,
    'Fen': 0, // 20 soru
    'Sosyal': 0,
  };
  
  final Map<String, int> _aytNets = {
    'Matematik': 0,
    'Fizik': 0,
    'Kimya': 0,
    'Biyoloji': 0,
    'Edebiyat': 0,
    'Tarih-1': 0,
    'Coğrafya-1': 0,
  };

  // Adım 3: Engeller
  final List<String> _selectedBarriers = [];
  final TextEditingController _otherBarrierController = TextEditingController();
  final List<String> _availableBarriers = [
    'Motivasyon eksikliği',
    'Zaman yönetimi',
    'Sınav kaygısı',
    'Sosyal medya bağımlılığı',
    'Plan yapamama',
    'Ders çalışma tekniği bilmiyorum',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildStep5(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentPage ? const Color(0xFF6366F1) : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// ADIM 1: Tanışma & Alan Seçimi
  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('👋 Merhaba!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Seni tanıyalım', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 40),
          TextField(
            onChanged: (value) => setState(() => _studentName = value),
            decoration: InputDecoration(
              labelText: 'Adın ne?',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 32),
          const Text('Hangi alana hazırlanıyorsun?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...[
            ('Sayısal', '🔢', 'TM, Mühendislik'),
            ('Eşit Ağırlık', '⚖️', 'MF, EA'),
            ('Sözel', '📚', 'Edebiyat, Sosyal'),
          ].map((field) => _buildFieldOption(field.$1, field.$2, field.$3)),
          const Spacer(),
          _buildNextButton(() {
            if (_studentName.isEmpty || _selectedField.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lütfen tüm alanları doldurun!')),
              );
              return;
            }
            _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          }),
        ],
      ),
    );
  }

  Widget _buildFieldOption(String field, String emoji, String subtitle) {
    return GestureDetector(
      onTap: () => setState(() => _selectedField = field),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedField == field ? const Color(0xFF6366F1).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedField == field ? const Color(0xFF6366F1) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(field, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            if (_selectedField == field) const Icon(Icons.check_circle, color: Color(0xFF6366F1)),
          ],
        ),
      ),
    );
  }

  /// ADIM 2: Akademik Röntgen (YKS Uyumlu)
  Widget _buildStep2() {
    // Soru sayıları (YKS gerçek değerleri)
    final Map<String, int> tytMax = {'Türkçe': 40, 'Matematik': 40, 'Fen': 20, 'Sosyal': 20};
    final Map<String, int> aytMax = {'Matematik': 40, 'Fizik': 14, 'Kimya': 13, 'Biyoloji': 13, 'Edebiyat': 24, 'Tarih-1': 10, 'Coğrafya-1': 6};

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📊 Akademik Röntgen', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Mevcut net durumunu görelim', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                const Text('TYT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                const SizedBox(height: 12),
                ..._tytNets.keys.map((subject) => _buildNetSlider(subject, _tytNets, tytMax[subject]!)),
                const SizedBox(height: 20),
                const Text('AYT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6))),
                const SizedBox(height: 12),
                ..._aytNets.keys.map((subject) => _buildNetSlider(subject, _aytNets, aytMax[subject]!)),
              ],
            ),
          ),
          _buildNextButton(() => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)),
        ],
      ),
    );
  }

  Widget _buildNetSlider(String subject, Map<String, int> netMap, int maxValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${netMap[subject]} / $maxValue', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          Slider(
            value: netMap[subject]!.toDouble(),
            min: 0,
            max: maxValue.toDouble(),
            divisions: maxValue,
            label: netMap[subject].toString(),
            onChanged: (value) => setState(() => netMap[subject] = value.toInt()),
          ),
        ],
      ),
    );
  }

  /// ADIM 3: İhtiyaç Analizi + Diğer Seçeneği
  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎯 Seni Engelleyen Ne?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Birden fazla seçebilirsin', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                ..._availableBarriers.map((barrier) {
                  final isSelected = _selectedBarriers.contains(barrier);
                  return CheckboxListTile(
                    title: Text(barrier),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value!) _selectedBarriers.add(barrier);
                        else _selectedBarriers.remove(barrier);
                      });
                    },
                    activeColor: const Color(0xFF6366F1),
                  );
                }),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Diğer (Kendin Yaz)', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _otherBarrierController,
                        decoration: InputDecoration(
                          hintText: 'Örn: Odaklanma problemi',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildNextButton(() {
            if (_selectedBarriers.isEmpty && _otherBarrierController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('En az bir engel seçmeli veya yazmalısın!')),
              );
              return;
            }
            if (_otherBarrierController.text.trim().isNotEmpty) {
              _selectedBarriers.add(_otherBarrierController.text.trim());
            }
            _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          }),
        ],
      ),
    );
  }

  /// ADIM 4: Beyaz Kağıt Sözleşme
  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Beyaz kağıt görünümü
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'SÖZLEŞME',
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Ben $_studentName,',
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Courier',
                    height: 1.8,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'bu sene bahanelerin arkasına sığınmayacağıma,\n\n'
                  'düştüğümde kalkacağıma ve\n\n'
                  'NETX ile potansiyelimi zorlayacağıma\n\n'
                  'söz veriyorum.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Courier',
                    height: 1.8,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: 200,
                  height: 1,
                  color: Colors.black87,
                ),
                const SizedBox(height: 8),
                Text(
                  '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Courier',
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('İMZALA VE BAŞLA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  /// ADIM 5: Genişletilmiş Tutorial
  Widget _buildStep5() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.rocket_launch, size: 80, color: Color(0xFF6366F1)),
          const SizedBox(height: 24),
          Text('Hazırsın, $_studentName! 🚀', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Seni bekleyen sistemler:', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('📚 AKADEMİK', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                ),
                _buildTutorialCard('📚', 'Programım', 'Haftalık çalışma programın', Colors.blueAccent),
                _buildTutorialCard('✅', 'Konu Takip', 'Hangi konuları bitirdin?', Colors.teal),
                _buildTutorialCard('📝', 'Soru Takip', 'Çözdüğün soruları takip et', Colors.indigo),
                _buildTutorialCard('📖', 'Notlarım', 'Okul sınav notların', Colors.brown),
                _buildTutorialCard('📋', 'Ödevlerim', 'Kurum ödevlerin', Colors.pink),
                _buildTutorialCard('➕', 'Deneme Ekle', 'Yeni deneme gir', Colors.green),
                _buildTutorialCard('📊', 'Denemelerim', 'Tüm denemeler', Colors.redAccent),
                _buildTutorialCard('📈', 'Grafik', 'Net artışı grafiği', Colors.purpleAccent),
                _buildTutorialCard('🏅', 'Rapor & Sıralama', 'Başarı raporu', Colors.indigo),
                _buildTutorialCard('📆', 'Günlük Takip', 'Günlük çalışma kaydı', Colors.teal),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('🛠️ ARAÇLAR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6))),
                ),
                _buildTutorialCard('📕', 'Hata Defteri', 'Çözemediğin soruları kaydet', Colors.red),
                _buildTutorialCard('🎧', 'Odak Modu', 'Konsantrasyon modları', Colors.purple),
                _buildTutorialCard('🎴', 'Flashcards', 'Dijital kart sistemi', Colors.pink),
                _buildTutorialCard('🧠', 'Soru Üreteci', 'AI ile soru oluştur', Colors.deepOrange),
                _buildTutorialCard('✨', 'Program Sihirbazı', 'Otomatik program oluştur', Colors.orange),
                _buildTutorialCard('💬', 'AI Asistan', 'Yapay zeka koçun', Colors.cyan),
                _buildTutorialCard('📸', 'Soru Çöz', 'Fotoğrafla soru çöz', Colors.amber),
                _buildTutorialCard('⏱️', 'Kronometre', 'Çalışma süren', Colors.lightBlue),
                _buildTutorialCard('🧪', 'Rehberlik', 'Psikolojik testler', Colors.teal),
                _buildTutorialCard('🏆', 'Rozetlerim', 'Kazanılan rozetler', Colors.yellow.shade700),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('🎮 ÖZEL SİSTEMLER', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                ),
                _buildTutorialCard('🤫', 'Sessiz Kütüphane', 'Gerçek zamanlı çalışma odası', Colors.indigo.shade800),
                _buildTutorialCard('🎯', 'Hedeflerim', 'Çalışma hedefleri', Colors.green.shade700),
                _buildTutorialCard('🎁', 'Ödül Mağazası', 'Dijital ödüller', Colors.orange.shade700),
                _buildTutorialCard('💆', 'Psikolojik Destek', 'Danışmanlık paketleri', const Color(0xFF6366F1)),
                _buildTutorialCard('👨‍⚕️', 'Paketim', 'Aktif danışmanlık paketim', const Color(0xFF8B5CF6)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('BAŞLAYALIM! 🎉', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialCard(String emoji, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.35), color.withOpacity(0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Devam Et →', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    await prefs.setString('student_name', _studentName);
    await prefs.setString('selected_field', _selectedField);
    
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }
}
