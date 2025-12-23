import 'dart:convert';
import 'package:flutter/material.dart';
import 'data.dart';
import 'models.dart';
import 'gemini_service.dart';

/// Program Sihirbazı - Yeni Tasarım
/// Manuel ve AI destekli program oluşturma
class YeniProgramSihirbaziEkrani extends StatefulWidget {
  const YeniProgramSihirbaziEkrani({super.key});

  @override
  State<YeniProgramSihirbaziEkrani> createState() => _YeniProgramSihirbaziEkraniState();
}

class _YeniProgramSihirbaziEkraniState extends State<YeniProgramSihirbaziEkrani> {
  int _currentStep = 0;
  bool _isAIMode = true;
  bool _isLoading = false;

  // Form verileri
  String _sinif = "12";
  String _alan = "Sayısal";
  int _gunlukSaat = 6;
  List<String> _zayifDersler = [];
  String _hedefUni = "";
  String _hedefBolum = "";

  // Oluşturulan program (düzenlenebilir tablo için)
  List<ProgramSatiri> _program = [];

  // YKS Ders Ağırlıkları (TYT + AYT Sayısal örneği)
  final Map<String, double> _dersAgirliklari = {
    "Matematik": 0.25,
    "Türkçe": 0.15,
    "Fizik": 0.15,
    "Kimya": 0.12,
    "Biyoloji": 0.10,
    "Geometri": 0.10,
    "Tarih": 0.05,
    "Coğrafya": 0.04,
    "Felsefe": 0.02,
    "Din Kültürü": 0.02,
  };

  // Öncelikli konular (ilk 2 etüt için)
  final Map<String, List<String>> _oncelikliKonular = {
    "Matematik": ["Problemler", "Fonksiyonlar", "Türev", "İntegral"],
    "Türkçe": ["Paragraf", "Anlam Bilgisi", "Dil Bilgisi"],
  };

  // Çalışma şekilleri
  final List<String> _calismaSecenekleri = [
    "Soru Çözümü",
    "Konu Anlatımı",
    "Video İzleme",
    "Tekrar",
    "Test Çözümü",
    "Not Alma",
  ];

  // Günler
  final List<String> _gunler = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"];

  // Etüt saatleri
  final List<String> _saatler = ["08:00", "09:00", "10:00", "11:00", "14:00", "15:00", "16:00", "17:00", "19:00", "20:00"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: Text(_isAIMode ? "🤖 AI Program Sihirbazı" : "📝 Manuel Program", style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Mod değiştir
          TextButton.icon(
            onPressed: () => setState(() => _isAIMode = !_isAIMode),
            icon: Icon(_isAIMode ? Icons.auto_awesome : Icons.edit, color: Colors.amber),
            label: Text(_isAIMode ? "Manuel" : "AI", style: const TextStyle(color: Colors.amber)),
          ),
        ],
      ),
      body: _program.isEmpty ? _buildWizardSteps() : _buildProgramTable(),
    );
  }

  Widget _buildWizardSteps() {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: _nextStep,
      onStepCancel: _prevStep,
      type: StepperType.vertical,
      controlsBuilder: (context, details) {
        return Row(
          children: [
            if (_currentStep < 3)
              ElevatedButton(
                onPressed: _isLoading ? null : details.onStepContinue,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_currentStep == 2 ? "Program Oluştur" : "Devam"),
              ),
            const SizedBox(width: 12),
            if (_currentStep > 0)
              TextButton(onPressed: details.onStepCancel, child: const Text("Geri")),
          ],
        );
      },
      steps: [
        // Adım 1: Temel Bilgiler
        Step(
          title: const Text("Temel Bilgiler", style: TextStyle(color: Colors.white)),
          subtitle: Text("Sınıf: $_sinif, Alan: $_alan", style: TextStyle(color: Colors.grey.shade500)),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          content: _buildStep1(),
        ),
        // Adım 2: Çalışma Detayları
        Step(
          title: const Text("Çalışma Planı", style: TextStyle(color: Colors.white)),
          subtitle: Text("Günlük $_gunlukSaat saat", style: TextStyle(color: Colors.grey.shade500)),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          content: _buildStep2(),
        ),
        // Adım 3: Zayıf Dersler
        Step(
          title: const Text("Eksik Alanlar", style: TextStyle(color: Colors.white)),
          subtitle: Text(_zayifDersler.isEmpty ? "Seçilmedi" : _zayifDersler.join(", "), style: TextStyle(color: Colors.grey.shade500)),
          isActive: _currentStep >= 2,
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          content: _buildStep3(),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sınıf
        const Text("Sınıf", style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ["9", "10", "11", "12", "Mezun"].map((s) {
            bool isSelected = _sinif == s;
            return ChoiceChip(
              label: Text(s),
              selected: isSelected,
              onSelected: (v) => setState(() => _sinif = s),
              selectedColor: Colors.purple,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 20),
        
        // Alan
        const Text("Puan Türü", style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ["Sayısal", "Eşit Ağırlık", "Sözel", "Dil"].map((a) {
            bool isSelected = _alan == a;
            return ChoiceChip(
              label: Text(a),
              selected: isSelected,
              onSelected: (v) => setState(() => _alan = a),
              selectedColor: Colors.purple,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 20),
        
        // Hedef
        TextField(
          onChanged: (v) => _hedefUni = v,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Hedef Üniversite (opsiyonel)",
            labelStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: const Color(0xFF21262D),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Günlük çalışma saati
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Günlük Çalışma Süresi", style: TextStyle(color: Colors.white70)),
            Text("$_gunlukSaat saat", style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        Slider(
          value: _gunlukSaat.toDouble(),
          min: 2,
          max: 12,
          divisions: 10,
          activeColor: Colors.purple,
          onChanged: (v) => setState(() => _gunlukSaat = v.toInt()),
        ),
        
        const SizedBox(height: 20),
        
        // Öncelik bilgisi
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.withAlpha(50)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Text("Akıllı Dağılım", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "• İlk 2 etüt: Türkçe-Paragraf & Matematik-Problem\n• Sonraki etütler: YKS ağırlığına göre dağılım\n• Zayıf dersler: %30 daha fazla süre",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    final dersler = ["Matematik", "Türkçe", "Fizik", "Kimya", "Biyoloji", "Geometri", "Tarih", "Coğrafya", "Felsefe"];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Hangi derslerde desteğe ihtiyacın var?", style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: dersler.map((d) {
            bool isSelected = _zayifDersler.contains(d);
            return FilterChip(
              label: Text(d),
              selected: isSelected,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    _zayifDersler.add(d);
                  } else {
                    _zayifDersler.remove(d);
                  }
                });
              },
              selectedColor: Colors.red.withAlpha(100),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 20),
        
        if (_isAIMode)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "AI seçimlerine göre kişiselleştirilmiş haftalık program oluşturacak",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      // Program oluştur
      if (_isAIMode) {
        _createAIProgram();
      } else {
        _createManualProgram();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _createManualProgram() {
    // YKS ağırlıklarına göre akıllı dağılım
    _program = _generateSmartProgram();
    setState(() {});
  }

  Future<void> _createAIProgram() async {
    setState(() => _isLoading = true);

    try {
      final prompt = '''
Bir YKS uzmanı olarak haftalık ders programı oluştur.

Öğrenci Bilgileri:
- Sınıf: $_sinif
- Alan: $_alan
- Günlük Çalışma: $_gunlukSaat saat
- Zayıf Dersler: ${_zayifDersler.join(", ")}
- Hedef: $_hedefUni

Kurallar:
1. Her günün ilk 2 etüdü: Türkçe-Paragraf ve Matematik-Problem (soru çözümü)
2. Sonraki etütler YKS ağırlığına göre dağıt
3. Zayıf derslere %30 daha fazla süre ayır
4. Her etüt 45 dakika + 15 dk mola

Format (JSON array):
[{"gun":"Pazartesi","saat":"08:00","ders":"Türkçe","konu":"Paragraf","calisma":"Soru Çözümü"}]

Sadece JSON döndür, başka açıklama yazma.
''';

      final response = await GravityAI.generateText(prompt);
      
      // JSON parse
      final jsonStart = response.indexOf('[');
      final jsonEnd = response.lastIndexOf(']') + 1;
      
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        final List<dynamic> parsed = jsonDecode(jsonStr);
        
        _program = parsed.map((item) => ProgramSatiri(
          gun: item['gun'] ?? "Pazartesi",
          saat: item['saat'] ?? "09:00",
          ders: item['ders'] ?? "Matematik",
          konu: item['konu'] ?? "Genel",
          calisma: item['calisma'] ?? "Soru Çözümü",
        )).toList();
        
        setState(() {});
      } else {
        // AI başarısız, manuel oluştur
        _createManualProgram();
      }
    } catch (e) {
      // Hata durumunda manuel program oluştur
      _createManualProgram();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("AI hatası, manuel program oluşturuldu: $e"), backgroundColor: Colors.orange),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<ProgramSatiri> _generateSmartProgram() {
    final program = <ProgramSatiri>[];
    
    for (var gun in _gunler) {
      int etutIndex = 0;
      
      for (int i = 0; i < _gunlukSaat && etutIndex < _saatler.length; i++) {
        String ders, konu, calisma;
        
        if (i == 0) {
          // İlk etüt: Türkçe Paragraf
          ders = "Türkçe";
          konu = "Paragraf";
          calisma = "Soru Çözümü";
        } else if (i == 1) {
          // İkinci etüt: Matematik Problem
          ders = "Matematik";
          konu = "Problemler";
          calisma = "Soru Çözümü";
        } else {
          // Diğer etütler: YKS ağırlığına göre
          final dersListesi = _dersAgirliklari.keys.toList();
          // Zayıf dersler öncelikli
          dersListesi.sort((a, b) {
            bool aZayif = _zayifDersler.contains(a);
            bool bZayif = _zayifDersler.contains(b);
            if (aZayif && !bZayif) return -1;
            if (!aZayif && bZayif) return 1;
            return (_dersAgirliklari[b] ?? 0).compareTo(_dersAgirliklari[a] ?? 0);
          });
          
          ders = dersListesi[(i - 2) % dersListesi.length];
          konu = _getRandomKonu(ders);
          calisma = _calismaSecenekleri[(i + _gunler.indexOf(gun)) % _calismaSecenekleri.length];
        }
        
        program.add(ProgramSatiri(
          gun: gun,
          saat: _saatler[etutIndex],
          ders: ders,
          konu: konu,
          calisma: calisma,
        ));
        
        etutIndex++;
      }
    }
    
    return program;
  }

  String _getRandomKonu(String ders) {
    final konular = VeriDeposu.dersKonuAgirliklari[ders] ?? 
                    VeriDeposu.dersKonuAgirliklari["TYT $ders"] ?? [];
    if (konular.isEmpty) return "Genel";
    return konular[(DateTime.now().millisecond) % konular.length].ad;
  }

  Widget _buildProgramTable() {
    // Günlere göre grupla
    final gunlereGore = <String, List<ProgramSatiri>>{};
    for (var satir in _program) {
      gunlereGore.putIfAbsent(satir.gun, () => []).add(satir);
    }

    return Column(
      children: [
        // Başlık ve kaydet butonu
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF161B22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Haftalık Programın", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Düzenlemek için hücreye dokun", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() => _program.clear()),
                    icon: const Icon(Icons.refresh, color: Colors.orange),
                    label: const Text("Yeniden Oluştur", style: TextStyle(color: Colors.orange)),
                  ),
                  ElevatedButton.icon(
                    onPressed: _saveProgram,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    icon: const Icon(Icons.save),
                    label: const Text("Kaydet"),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Tablo
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFF21262D)),
                dataRowColor: WidgetStateProperty.all(const Color(0xFF161B22)),
                columns: const [
                  DataColumn(label: Text("Gün", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Saat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Ders", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Konu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Çalışma", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("", style: TextStyle(color: Colors.white))),
                ],
                rows: _program.asMap().entries.map((entry) {
                  final index = entry.key;
                  final satir = entry.value;
                  
                  return DataRow(cells: [
                    DataCell(Text(satir.gun, style: const TextStyle(color: Colors.white70))),
                    DataCell(Text(satir.saat, style: const TextStyle(color: Colors.cyan))),
                    DataCell(_buildEditableCell(index, "ders", satir.ders, _dersAgirliklari.keys.toList())),
                    DataCell(_buildEditableKonuCell(index, satir.ders, satir.konu)),
                    DataCell(_buildEditableCell(index, "calisma", satir.calisma, _calismaSecenekleri)),
                    DataCell(IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => setState(() => _program.removeAt(index)),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableCell(int index, String field, String currentValue, List<String> options) {
    return GestureDetector(
      onTap: () => _showEditDialog(index, field, currentValue, options),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.purple.withAlpha(30),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentValue, style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 4),
            const Icon(Icons.edit, size: 14, color: Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableKonuCell(int index, String ders, String currentKonu) {
    final konular = VeriDeposu.dersKonuAgirliklari[ders] ?? 
                    VeriDeposu.dersKonuAgirliklari["TYT $ders"] ?? [];
    final konuIsimleri = konular.map((k) => k.ad).toList();
    if (konuIsimleri.isEmpty) konuIsimleri.add("Genel");
    
    return GestureDetector(
      onTap: () => _showEditDialog(index, "konu", currentKonu, konuIsimleri),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(30),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentKonu, style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 4),
            const Icon(Icons.edit, size: 14, color: Colors.green),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(int index, String field, String currentValue, List<String> options) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field == "ders" ? "Ders Seç" : (field == "konu" ? "Konu Seç" : "Çalışma Şekli Seç"),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((opt) {
                bool isSelected = opt == currentValue;
                return ChoiceChip(
                  label: Text(opt),
                  selected: isSelected,
                  onSelected: (v) {
                    setState(() {
                      if (field == "ders") {
                        _program[index].ders = opt;
                        // Ders değişince konu da güncelle
                        _program[index].konu = _getRandomKonu(opt);
                      } else if (field == "konu") {
                        _program[index].konu = opt;
                      } else if (field == "calisma") {
                        _program[index].calisma = opt;
                      }
                    });
                    Navigator.pop(context);
                  },
                  selectedColor: Colors.purple,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _saveProgram() {
    // Program'ı Gorev listesine çevir
    final gorevler = _program.asMap().entries.map((e) {
      return Gorev(
        hafta: 1,
        gun: e.value.gun,
        saat: e.value.saat,
        ders: e.value.ders,
        konu: e.value.konu,
        aciklama: e.value.calisma,
        yapildi: false,
      );
    }).toList();

    VeriDeposu.programiKaydet(gorevler, _isAIMode ? "AI Program" : "Manuel Program");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Program kaydedildi!"), backgroundColor: Colors.green),
    );

    Navigator.pop(context);
  }
}

/// Program satırı modeli
class ProgramSatiri {
  String gun;
  String saat;
  String ders;
  String konu;
  String calisma;

  ProgramSatiri({
    required this.gun,
    required this.saat,
    required this.ders,
    required this.konu,
    required this.calisma,
  });
}
