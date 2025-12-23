import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models.dart';
import 'data.dart';

/// Dijital Hata Defteri Ekranı
/// Öğrencinin yapamadığı soruları kaydettiği premium ekran
class HataDefteriEkrani extends StatefulWidget {
  final String ogrenciId;
  const HataDefteriEkrani({super.key, required this.ogrenciId});
  
  @override
  State<HataDefteriEkrani> createState() => _HDEState();
}

class _HDEState extends State<HataDefteriEkrani> {
  String _selectedFilter = "Tümü";
  final List<String> _dersler = ["Tümü", "Matematik", "Fizik", "Kimya", "Biyoloji", "Türkçe", "Tarih", "Coğrafya", "Geometri"];

  List<HataDefteriSoru> get _filteredList {
    var list = VeriDeposu.hataDefteriListesi
        .where((s) => s.ogrenciId == widget.ogrenciId)
        .toList();
    
    if (_selectedFilter != "Tümü") {
      list = list.where((s) => s.ders == _selectedFilter).toList();
    }
    
    list.sort((a, b) => b.tarih.compareTo(a.tarih));
    return list;
  }

  int get _cozulmeyenSayisi => VeriDeposu.hataDefteriListesi
      .where((s) => s.ogrenciId == widget.ogrenciId && !s.cozuldu)
      .length;

  void _soruEkle() async {
    final result = await showModalBottomSheet<HataDefteriSoru>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SoruEkleBottomSheet(ogrenciId: widget.ogrenciId),
    );

    if (result != null) {
      setState(() {
        VeriDeposu.hataDefteriListesi.add(result);
        VeriDeposu.kaydet();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📚 Soru hata defterine eklendi!"), backgroundColor: Colors.green),
      );
    }
  }

  void _beniSina() {
    final cozulmeyenler = VeriDeposu.hataDefteriListesi
        .where((s) => s.ogrenciId == widget.ogrenciId && !s.cozuldu)
        .toList();
    
    if (cozulmeyenler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎉 Tebrikler! Tüm soruları çözmüşsün!"), backgroundColor: Colors.green),
      );
      return;
    }
    
    cozulmeyenler.shuffle();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => BeniSinaEkrani(sorular: cozulmeyenler)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("📚 Hata Defteri", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_cozulmeyenSayisi > 0)
            TextButton.icon(
              onPressed: _beniSina,
              icon: const Icon(Icons.quiz, color: Colors.amber),
              label: Text("Beni Sına (${_cozulmeyenSayisi})", style: const TextStyle(color: Colors.amber)),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _soruEkle,
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add_a_photo),
        label: const Text("Soru Ekle"),
      ),
      body: Column(
        children: [
          // Filtre chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _dersler.map((ders) {
                  bool isSelected = _selectedFilter == ders;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(ders),
                      selected: isSelected,
                      onSelected: (selected) => setState(() => _selectedFilter = ders),
                      backgroundColor: const Color(0xFF21262D),
                      selectedColor: Colors.purple,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade400,
                      ),
                      checkmarkColor: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Liste
          Expanded(
            child: _filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) => _buildSoruCard(_filteredList[index]),
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
              color: Colors.purple.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book, size: 80, color: Colors.purple),
          ),
          const SizedBox(height: 24),
          const Text(
            "Hata Defteri Boş",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Yapamadığın soruları buraya ekle,\nsonra \"Beni Sına\" ile tekrar et!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildSoruCard(HataDefteriSoru soru) {
    Uint8List imageBytes = base64Decode(soru.imageBase64);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(16),
        border: soru.cozuldu 
            ? Border.all(color: Colors.green.withAlpha(100), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resim
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.memory(
              imageBytes,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Etiketler
                Row(
                  children: [
                    _buildBadge(soru.ders, Colors.purple),
                    const SizedBox(width: 8),
                    _buildBadge(soru.konu, Colors.blue),
                    const Spacer(),
                    if (soru.cozuldu)
                      const Icon(Icons.check_circle, color: Colors.green, size: 24),
                  ],
                ),

                if (soru.aciklama != null && soru.aciklama!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    soru.aciklama!,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                ],

                const SizedBox(height: 12),

                // Butonlar
                Row(
                  children: [
                    Text(
                      "${soru.tarih.day}/${soru.tarih.month}/${soru.tarih.year}",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _toggleCozuldu(soru),
                      child: Text(
                        soru.cozuldu ? "Tekrar Aç" : "Çözüldü ✓",
                        style: TextStyle(
                          color: soru.cozuldu ? Colors.orange : Colors.green,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _soruSil(soru),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _toggleCozuldu(HataDefteriSoru soru) {
    setState(() {
      soru.cozuldu = !soru.cozuldu;
      VeriDeposu.kaydet();
    });
  }

  void _soruSil(HataDefteriSoru soru) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Soruyu Sil?"),
        content: const Text("Bu işlem geri alınamaz."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                VeriDeposu.hataDefteriListesi.remove(soru);
                VeriDeposu.kaydet();
              });
              Navigator.pop(context);
            },
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }
}

/// Soru Ekleme Bottom Sheet
class _SoruEkleBottomSheet extends StatefulWidget {
  final String ogrenciId;
  const _SoruEkleBottomSheet({required this.ogrenciId});

  @override
  State<_SoruEkleBottomSheet> createState() => _SoruEkleBottomSheetState();
}

class _SoruEkleBottomSheetState extends State<_SoruEkleBottomSheet> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _selectedDers;
  String? _selectedKonu;
  final TextEditingController _aciklamaController = TextEditingController();

  final Map<String, List<String>> _dersKonulari = {
    "Matematik": ["Türev", "İntegral", "Limit", "Olasılık", "Fonksiyonlar", "Logaritma", "Üslü Sayılar", "Denklemler"],
    "Fizik": ["Kuvvet", "Hareket", "Elektrik", "Manyetizma", "Optik", "Dalgalar", "Isı"],
    "Kimya": ["Mol", "Kimyasal Tepkimeler", "Asit-Baz", "Organik Kimya", "Elektrokimya"],
    "Biyoloji": ["Hücre", "Genetik", "Ekosistem", "Sindirim", "Dolaşım", "Solunum"],
    "Türkçe": ["Paragraf", "Dil Bilgisi", "Anlam Bilgisi", "Sözcük Türleri"],
    "Geometri": ["Üçgenler", "Dörtgenler", "Çember", "Alan-Hacim", "Trigonometri"],
    "Tarih": ["Osmanlı", "Cumhuriyet", "İnkılap Tarihi", "Dünya Tarihi"],
    "Coğrafya": ["İklim", "Nüfus", "Ekonomi", "Türkiye Coğrafyası"],
  };

  void _resimSec(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _image = picked);
    }
  }

  void _kaydet() async {
    if (_image == null || _selectedDers == null || _selectedKonu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen resim, ders ve konu seçin!"), backgroundColor: Colors.orange),
      );
      return;
    }

    final bytes = await _image!.readAsBytes();
    final base64Image = base64Encode(bytes);

    final yeniSoru = HataDefteriSoru(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ogrenciId: widget.ogrenciId,
      imageBase64: base64Image,
      ders: _selectedDers!,
      konu: _selectedKonu!,
      aciklama: _aciklamaController.text.isEmpty ? null : _aciklamaController.text,
      tarih: DateTime.now(),
    );

    Navigator.pop(context, yeniSoru);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  "Soru Ekle",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("İptal", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Resim Seçim
                  GestureDetector(
                    onTap: () => _resimSecDialog(),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF21262D),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.purple.withAlpha(50)),
                      ),
                      child: _image != null
                          ? FutureBuilder<Uint8List>(
                              future: _image!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                                  );
                                }
                                return const Center(child: CircularProgressIndicator());
                              },
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 50, color: Colors.purple.withAlpha(150)),
                                const SizedBox(height: 12),
                                Text("Fotoğraf Ekle", style: TextStyle(color: Colors.grey.shade500)),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Ders Seçimi
                  DropdownButtonFormField<String>(
                    value: _selectedDers,
                    hint: const Text("Ders Seç", style: TextStyle(color: Colors.grey)),
                    dropdownColor: const Color(0xFF21262D),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF21262D),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: _dersKonulari.keys.map((ders) => DropdownMenuItem(value: ders, child: Text(ders))).toList(),
                    onChanged: (v) => setState(() {
                      _selectedDers = v;
                      _selectedKonu = null;
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Konu Seçimi
                  if (_selectedDers != null)
                    DropdownButtonFormField<String>(
                      value: _selectedKonu,
                      hint: const Text("Konu Seç", style: TextStyle(color: Colors.grey)),
                      dropdownColor: const Color(0xFF21262D),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF21262D),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: (_dersKonulari[_selectedDers] ?? []).map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                      onChanged: (v) => setState(() => _selectedKonu = v),
                    ),

                  const SizedBox(height: 16),

                  // Açıklama
                  TextField(
                    controller: _aciklamaController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Açıklama (opsiyonel)",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: const Color(0xFF21262D),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Kaydet Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _kaydet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("KAYDET", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resimSecDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF21262D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _resimSecButon(Icons.camera_alt, "Kamera", () {
              Navigator.pop(context);
              _resimSec(ImageSource.camera);
            }),
            _resimSecButon(Icons.photo_library, "Galeri", () {
              Navigator.pop(context);
              _resimSec(ImageSource.gallery);
            }),
          ],
        ),
      ),
    );
  }

  Widget _resimSecButon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: Colors.purple),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

/// Beni Sına Ekranı (Quiz Mode)
class BeniSinaEkrani extends StatefulWidget {
  final List<HataDefteriSoru> sorular;
  const BeniSinaEkrani({super.key, required this.sorular});

  @override
  State<BeniSinaEkrani> createState() => _BeniSinaEkraniState();
}

class _BeniSinaEkraniState extends State<BeniSinaEkrani> {
  int _currentIndex = 0;
  int _cozulenSayisi = 0;

  HataDefteriSoru get _currentSoru => widget.sorular[_currentIndex];
  bool get _isLast => _currentIndex == widget.sorular.length - 1;

  void _cozdum() {
    setState(() {
      _currentSoru.cozuldu = true;
      _cozulenSayisi++;
      VeriDeposu.kaydet();
    });
    _next();
  }

  void _cozemedim() {
    _next();
  }

  void _next() {
    if (_isLast) {
      _showResult();
    } else {
      setState(() => _currentIndex++);
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF21262D),
        title: const Text("🎯 Sınav Bitti!", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$_cozulenSayisi / ${widget.sorular.length}",
              style: const TextStyle(color: Colors.purple, fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "soruyu çözdün!",
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Uint8List imageBytes = base64Decode(_currentSoru.imageBase64);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: Text("Soru ${_currentIndex + 1} / ${widget.sorular.length}", style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.sorular.length,
            backgroundColor: Colors.grey.shade800,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
          ),

          // Etiketler
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_currentSoru.ders, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_currentSoru.konu, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Resim
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withAlpha(30),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  child: Image.memory(imageBytes, fit: BoxFit.contain),
                ),
              ),
            ),
          ),

          // Butonlar
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _cozemedim,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Çözemedim 😔", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _cozdum,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Çözdüm! ✓", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
