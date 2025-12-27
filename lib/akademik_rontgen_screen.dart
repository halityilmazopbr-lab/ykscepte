import 'package:flutter/material.dart';
import 'data.dart';
import 'models.dart';

class AkademikRontgenScreen extends StatefulWidget {
  const AkademikRontgenScreen({super.key});

  @override
  State<AkademikRontgenScreen> createState() => _AkademikRontgenScreenState();
}

class _AkademikRontgenScreenState extends State<AkademikRontgenScreen> {
  String _selectedDers = "TYT Matematik";
  final List<String> _dersler = VeriDeposu.dersKonuAgirliklari.keys.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text("🧠 Akademik Röntgen", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF161B22),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header & Info
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF161B22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kaldığın yerden başlayalım!",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "AI Koç'un sana özel program hazırlaması için bitirdiğin konuları 'ne zaman' bitirdiğinle birlikte işaretle.",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ],
            ),
          ),

          // Ders Seçimi
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _dersler.length,
              itemBuilder: (context, index) {
                final ders = _dersler[index];
                final isSelected = _selectedDers == ders;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(ders),
                    selected: isSelected,
                    onSelected: (v) => setState(() => _selectedDers = ders),
                    selectedColor: Colors.purple,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
                  ),
                );
              },
            ),
          ),

          // Konu Listesi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              itemCount: VeriDeposu.dersKonuAgirliklari[_selectedDers]?.length ?? 0,
              itemBuilder: (context, index) {
                final konu = VeriDeposu.dersKonuAgirliklari[_selectedDers]![index];
                return _KonuRontgenCard(
                  ders: _selectedDers,
                  konu: konu,
                  onChanged: () => setState(() {}),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          VeriDeposu.kaydet();
          Navigator.pop(context);
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.check),
        label: const Text("ANALİZİ TAMAMLA"),
      ),
    );
  }
}

class _KonuRontgenCard extends StatelessWidget {
  final String ders;
  final KonuDetay konu;
  final VoidCallback onChanged;

  const _KonuRontgenCard({
    required this.ders,
    required this.konu,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Mevcut durumu bul
    KonuTamamlama? durum;
    try {
      durum = VeriDeposu.akilliKonuTakibi.firstWhere(
        (e) => e.ders == ders && e.konu == konu.ad,
      );
    } catch (e) {
      durum = null;
    }

    final isSelected = durum != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: Colors.purple.withOpacity(0.5)) : null,
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: isSelected,
            onChanged: (v) {
              if (v == true) {
                // Varsayılan olarak "Yeni" ekle
                VeriDeposu.akilliKonuTakibi.add(KonuTamamlama(
                  ders: ders,
                  konu: konu.ad,
                  tarih: DateTime.now(),
                ));
                VeriDeposu.tamamlananKonular["$ders-${konu.ad}"] = true;
              } else {
                VeriDeposu.akilliKonuTakibi.removeWhere(
                  (e) => e.ders == ders && e.konu == konu.ad,
                );
                VeriDeposu.tamamlananKonular["$ders-${konu.ad}"] = false;
              }
              onChanged();
            },
            title: Text(konu.ad, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            activeColor: Colors.purple,
            subtitle: isSelected 
              ? Text("Tamamlandı: ${_formatDate(durum!.tarih)}", style: const TextStyle(color: Colors.green, fontSize: 12))
              : Text("Henüz bitirilmedi", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.grey, height: 20),
                  const Text("Bu konuyu ne zaman bitirdin?", 
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _DateOption(
                        label: "Yeni",
                        subtitle: "Bu hafta",
                        isSelected: _isRecently(durum.tarih),
                        onTap: () {
                          durum!.tarih = DateTime.now();
                          durum.hatirlatmaGerekli = false;
                          onChanged();
                        },
                      ),
                      const SizedBox(width: 8),
                      _DateOption(
                        label: "Orta",
                        subtitle: "1 ay oldu",
                        isSelected: _isMedium(durum.tarih),
                        onTap: () {
                          durum!.tarih = DateTime.now().subtract(const Duration(days: 30));
                          durum.hatirlatmaGerekli = true;
                          onChanged();
                        },
                      ),
                      const SizedBox(width: 8),
                      _DateOption(
                        label: "Eski",
                        subtitle: "Unuttum",
                        isSelected: _isOld(durum.tarih),
                        onTap: () {
                          durum!.tarih = DateTime.now().subtract(const Duration(days: 90));
                          durum.hatirlatmaGerekli = true;
                          onChanged();
                        },
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

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }

  bool _isRecently(DateTime d) => DateTime.now().difference(d).inDays < 7;
  bool _isMedium(DateTime d) => DateTime.now().difference(d).inDays >= 7 && DateTime.now().difference(d).inDays < 60;
  bool _isOld(DateTime d) => DateTime.now().difference(d).inDays >= 60;
}

class _DateOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateOption({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple.withOpacity(0.2) : Colors.black26,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? Colors.purple : Colors.transparent),
          ),
          child: Column(
            children: [
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(subtitle, style: TextStyle(color: isSelected ? Colors.purple.shade200 : Colors.grey.shade600, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}
