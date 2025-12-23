import 'package:flutter/material.dart';
import 'data.dart';
import 'models.dart';

/// Öğrenci Profil Ekranı
/// 4 Katmanlı Tasarım: Motivasyon, Akademik, İstatistik, Ayarlar
class ProfilEkrani extends StatefulWidget {
  final Ogrenci ogrenci;
  const ProfilEkrani({super.key, required this.ogrenci});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  late Ogrenci _ogrenci;
  
  // Avatar listesi (Emoji karakter)
  final List<String> _avatarlar = [
    "🧑‍🎓", "👨‍🎓", "👩‍🎓", "🧑‍💻", "👨‍💻", "👩‍💻",
    "🦸", "🦹", "🧙", "🧚", "🦊", "🐼",
    "🦁", "🐯", "🦄",
  ];
  
  // Alan seçenekleri
  final List<String> _alanlar = ["SAYISAL", "EA", "SÖZEL", "DİL"];
  
  // Akademik seviye seçenekleri  
  final List<Map<String, dynamic>> _seviyeler = [
    {"id": "BASLANGIC", "label": "Başlangıç", "desc": "Temelim zayıf", "icon": Icons.school},
    {"id": "ORTA", "label": "Orta", "desc": "Konuları biliyorum, pratik lazım", "icon": Icons.trending_up},
    {"id": "ILERI", "label": "İleri", "desc": "Derece istiyorum", "icon": Icons.emoji_events},
  ];

  @override
  void initState() {
    super.initState();
    _ogrenci = widget.ogrenci;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF161B22),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_ogrenci.seviyeRenk.withOpacity(0.8), const Color(0xFF0D1117)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: _showAvatarPicker,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: _ogrenci.seviyeRenk, width: 3),
                          ),
                          child: Center(
                            child: Text(
                              _avatarlar[_ogrenci.avatarId.clamp(0, _avatarlar.length - 1)],
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // İsim ve Unvan
                      Text(
                        _ogrenci.ad,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _ogrenci.seviyeRenk.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _ogrenci.seviyeRenk),
                        ),
                        child: Text(
                          "⭐ ${_ogrenci.unvan}",
                          style: TextStyle(color: _ogrenci.seviyeRenk, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // İçerik
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // KATMAN 1: HEDEFİM
                  _buildHedefKarti(),
                  
                  const SizedBox(height: 16),
                  
                  // KATMAN 2: AKADEMİK BİLGİLER
                  _buildAkademikKimlik(),
                  
                  const SizedBox(height: 16),
                  
                  // KATMAN 3: İSTATİSTİKLER
                  _buildIstatistikler(),
                  
                  const SizedBox(height: 16),
                  
                  // KATMAN 4: KURUMSAL (varsa)
                  if (_ogrenci.kurumKodu != null) _buildKurumsalBilgi(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// KATMAN 1: Hedef Kartı
  Widget _buildHedefKarti() {
    return GestureDetector(
      onTap: _showHedefDuzenle,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade800, Colors.blue.shade800],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.rocket_launch, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text("HEDEFİM", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _ogrenci.hedefUniversite,
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (_ogrenci.hedefBolum.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _ogrenci.hedefBolum,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Hedef: ${_ogrenci.hedefPuan > 0 ? '${_ogrenci.hedefPuan} Puan' : 'Belirlenmedi'}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("Düzenlemek için dokun", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  /// KATMAN 2: Akademik Kimlik
  Widget _buildAkademikKimlik() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text("AKADEMİK KİMLİK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Alan Seçimi
          const Text("Puan Türü", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _alanlar.map((alan) {
              bool isSelected = _ogrenci.alan == alan;
              return ChoiceChip(
                label: Text(alan),
                selected: isSelected,
                selectedColor: Colors.blue,
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
                onSelected: (v) {
                  setState(() => _ogrenci.alan = alan);
                  VeriDeposu.kaydet();
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Sınıf Seviyesi
          const Text("Sınıf", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [9, 10, 11, 12, 0].map((sinif) {
              bool isSelected = _ogrenci.sinifSeviyesi == sinif;
              return ChoiceChip(
                label: Text(sinif == 0 ? "Mezun" : "$sinif. Sınıf"),
                selected: isSelected,
                selectedColor: Colors.purple,
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
                onSelected: (v) {
                  setState(() => _ogrenci.sinifSeviyesi = sinif);
                  VeriDeposu.kaydet();
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Akademik Seviye
          const Text("Kendini nasıl görüyorsun?", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          ..._seviyeler.map((s) {
            bool isSelected = _ogrenci.akademikSeviye == s["id"];
            return GestureDetector(
              onTap: () {
                setState(() => _ogrenci.akademikSeviye = s["id"]);
                VeriDeposu.kaydet();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green.withOpacity(0.2) : const Color(0xFF21262D),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(color: Colors.green) : null,
                ),
                child: Row(
                  children: [
                    Icon(s["icon"], color: isSelected ? Colors.green : Colors.grey, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s["label"], style: TextStyle(color: isSelected ? Colors.green : Colors.white, fontWeight: FontWeight.bold)),
                          Text(s["desc"], style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// KATMAN 3: İstatistikler
  Widget _buildIstatistikler() {
    // Toplam çözülen soru
    int toplamSoru = VeriDeposu.soruCozumListesi.fold(0, (sum, item) => sum + item.dogru + item.yanlis);
    
    // Son 3 deneme ortalaması
    var sonDenemeler = VeriDeposu.denemeListesi.take(3).toList();
    double ortNet = sonDenemeler.isEmpty ? 0 : sonDenemeler.fold(0.0, (sum, d) => sum + d.toplamNet) / sonDenemeler.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text("İSTATİSTİKLER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Streak
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade800, Colors.red.shade800],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text("🔥", style: TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_ogrenci.gunlukSeri} Gün",
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _ogrenci.gunlukSeri > 0 ? "Aralıksız çalışıyorsun! 💪" : "Bugün çalışmaya başla!",
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sayaçlar
          Row(
            children: [
              Expanded(
                child: _buildStatCard("XP", "${_ogrenci.puan}", _ogrenci.seviyeRenk, Icons.star),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard("Soru", "$toplamSoru", Colors.blue, Icons.edit),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard("Deneme Ort.", ortNet.toStringAsFixed(1), Colors.green, Icons.assessment),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Seviye Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Seviye: ${_ogrenci.seviye}", style: TextStyle(color: _ogrenci.seviyeRenk, fontWeight: FontWeight.bold)),
                  Text("${_ogrenci.puan} / ${_getNextLevelXP()} XP", style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _getLevelProgress(),
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade800,
                  color: _ogrenci.seviyeRenk,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }

  /// KATMAN 4: Kurumsal Bilgi
  Widget _buildKurumsalBilgi() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.business, color: Colors.teal, size: 20),
              SizedBox(width: 8),
              Text("KURUM BİLGİLERİ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow("Kurum", _ogrenci.kurumKodu ?? "-"),
          _buildInfoRow("Okul No", _ogrenci.okulNo ?? "-"),
          _buildInfoRow("Atanan Öğretmen", _ogrenci.atananOgretmenId ?? "Yok"),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade500)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  int _getNextLevelXP() {
    if (_ogrenci.puan >= 10000) return 10000;
    if (_ogrenci.puan >= 5000) return 10000;
    if (_ogrenci.puan >= 2500) return 5000;
    if (_ogrenci.puan >= 1000) return 2500;
    return 1000;
  }
  
  double _getLevelProgress() {
    int current = _ogrenci.puan;
    int next = _getNextLevelXP();
    int prev = 0;
    if (next == 10000) prev = 5000;
    else if (next == 5000) prev = 2500;
    else if (next == 2500) prev = 1000;
    if (current >= next) return 1.0;
    return (current - prev) / (next - prev);
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Avatar Seç", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: _avatarlar.length,
              itemBuilder: (context, index) {
                bool isSelected = _ogrenci.avatarId == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => _ogrenci.avatarId = index);
                    VeriDeposu.kaydet();
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.purple.withOpacity(0.3) : const Color(0xFF21262D),
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.purple, width: 3) : null,
                    ),
                    child: Center(child: Text(_avatarlar[index], style: const TextStyle(fontSize: 32))),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showHedefDuzenle() {
    final uniController = TextEditingController(text: _ogrenci.hedefUniversite);
    final bolumController = TextEditingController(text: _ogrenci.hedefBolum);
    final puanController = TextEditingController(text: _ogrenci.hedefPuan > 0 ? _ogrenci.hedefPuan.toString() : "");
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Hedefini Güncelle", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: uniController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Hedef Üniversite",
                labelStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF21262D),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bolumController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Hedef Bölüm",
                labelStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF21262D),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: puanController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Hedef Puan (opsiyonel)",
                labelStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF21262D),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _ogrenci.hedefUniversite = uniController.text.isNotEmpty ? uniController.text : "Hedef Yok";
                  _ogrenci.hedefBolum = bolumController.text;
                  _ogrenci.hedefPuan = int.tryParse(puanController.text) ?? 0;
                });
                VeriDeposu.kaydet();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, minimumSize: const Size(double.infinity, 50)),
              child: const Text("Kaydet"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
