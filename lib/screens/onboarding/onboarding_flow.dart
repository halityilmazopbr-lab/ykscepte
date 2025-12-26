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

  // Adım 2: Akademik Durum
  final Map<String, int> _nets = {
    'TYT Türkçe': 0,
    'TYT Matematik': 0,
    'TYT Fen': 0,
    'TYT Sosyal': 0,
  };

  // Adım 3: Engeller
  final List<String> _selectedBarriers = [];
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

  /// ADIM 2: Akademik Röntgen
  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📊 Akademik Röntgen', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Mevcut net durumunu görelim', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: _nets.keys.map((subject) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _nets[subject]!.toDouble(),
                              min: 0,
                              max: 40,
                              divisions: 40,
                              label: _nets[subject].toString(),
                              onChanged: (value) => setState(() => _nets[subject] = value.toInt()),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text('${_nets[subject]}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          _buildNextButton(() => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)),
        ],
      ),
    );
  }

  /// ADIM 3: İhtiyaç Analizi
  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎯 Seni Engelleyen Ne?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Birden fazla seçebilirsin', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: _availableBarriers.map((barrier) {
                final isSelected = _selectedBarriers.contains(barrier);
                return CheckboxListTile(
                  title: Text(barrier),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        _selectedBarriers.add(barrier);
                      } else {
                        _selectedBarriers.remove(barrier);
                      }
                    });
                  },
                  activeColor: const Color(0xFF6366F1),
                );
              }).toList(),
            ),
          ),
          _buildNextButton(() {
            if (_selectedBarriers.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('En az bir engel seçmelisin!')),
              );
              return;
            }
            _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          }),
        ],
      ),
    );
  }

  /// ADIM 4: Psikolojik Sözleşme
  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.handshake, size: 80, color: Color(0xFF6366F1)),
          const SizedBox(height: 24),
          const Text('📜 Psikolojik Taahhüt', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildCommitmentItem('💪', 'Her gün en az 1 saat çalışacağım'),
                _buildCommitmentItem('📱', 'Çalışırken telefonu uzak tutacağım'),
                _buildCommitmentItem('🎯', 'Hedeflerimi takip edeceğim'),
                _buildCommitmentItem('🔄', 'Düştüğümde tekrar kalkacağım'),
              ],
            ),
          ),
          const Spacer(),
          const Text(
            'Bu bir söz değil, kendine verdiğin bir taahhüt.',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildNextButton(() => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)),
        ],
      ),
    );
  }

  Widget _buildCommitmentItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  /// ADIM 5: Mini Tutorial
  Widget _buildStep5() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.rocket_launch, size: 80, color: Color(0xFF6366F1)),
          const SizedBox(height: 24),
          Text('Hazırsın, $_studentName! 🚀', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          ...[
            ('📚', 'Ana Sayfa', 'Tüm araçlarına buradan ulaş'),
            ('📊', 'İstatistikler', 'İlerlemenİ grafiklerle gör'),
            ('🎯', 'Hedefler', 'Ödül kazan, motivasyonunu koru'),
            ('🤫', 'Gölge Odası', '100 kişi ile birlikte çalış'),
          ].map((item) => _buildTutorialCard(item.$1, item.$2, item.$3)),
          const Spacer(),
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

  Widget _buildTutorialCard(String emoji, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
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
