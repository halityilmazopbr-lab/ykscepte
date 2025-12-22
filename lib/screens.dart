import 'dart:convert';
import 'package:flutter/foundation.dart'; // kIsWeb için
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'models.dart';
import 'data.dart';
import 'gemini_service.dart';
import 'main.dart'; // Circular dependency possible if screens refer back to main components? Usually not needed if we design well.
// Actually TumProgramEkrani refers to nothing special.
// ProgramSihirbaziEkrani refers to TumProgramEkrani.

// --- PROGRAM SEÇİM EKRANI ---
class ProgramSecimEkrani extends StatelessWidget {
  const ProgramSecimEkrani({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Program Oluştur")),
        body: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const ManuelProgramSihirbazi())),
                  child: Container(
                      margin: const EdgeInsets.all(10),
                      height: 200,
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, size: 50, color: Colors.white),
                            Text("MANUEL",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20))
                          ])))),
          Expanded(
              child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const ProgramSihirbaziEkrani(mod: "AI"))),
                  child: Container(
                      margin: const EdgeInsets.all(10),
                      height: 200,
                      decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome,
                                size: 50, color: Colors.white),
                            Text("YAPAY ZEKA",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20))
                          ]))))
        ])));
  }
}

class SoruUretecEkrani extends StatefulWidget {
  const SoruUretecEkrani({super.key});
  @override
  State<SoruUretecEkrani> createState() => _SUEState();
}

class _SUEState extends State<SoruUretecEkrani> {
  String? ders, konu, zorluk;
  String soru = "";
  bool loading = false;
  Future<void> _uret() async {
    if (ders == null || konu == null) return;
    setState(() => loading = true);
    String s = await GravityAI.generateText(
        "$ders dersi $konu konusunda ${zorluk ?? 'orta'} seviye bir adet çoktan seçmeli YKS sorusu yaz.");
    setState(() {
      soru = s;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Soru Üreteci")),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              DropdownButtonFormField(
                  value: ders,
                  hint: const Text("Ders"),
                  items: VeriDeposu.dersKonuAgirliklari.keys
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() {
                        ders = v;
                        konu = null;
                      })),
              if (ders != null)
                DropdownButtonFormField(
                    value: konu,
                    hint: const Text("Konu"),
                    items: VeriDeposu.dersKonuAgirliklari[ders]!
                        .map((e) =>
                            DropdownMenuItem(value: e.ad, child: Text(e.ad)))
                        .toList(),
                    onChanged: (v) => setState(() => konu = v)),
              DropdownButtonFormField(
                  value: zorluk,
                  hint: const Text("Zorluk"),
                  items: ["Kolay", "Orta", "Zor"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => zorluk = v)),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: loading ? null : _uret,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text("SORU ÜRET")),
              const SizedBox(height: 20),
              Expanded(child: SingleChildScrollView(child: Text(soru)))
            ])));
  }
}

class OdevlerEkrani extends StatelessWidget {
  const OdevlerEkrani({super.key, this.ogrenciId});
  final String? ogrenciId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Ödevlerim")),
        body: ListView.builder(
            itemCount: VeriDeposu.odevler.length,
            itemBuilder: (c, i) {
              var o = VeriDeposu.odevler[i];
              return Card(
                  child: ListTile(
                      title: Text(o.ders),
                      subtitle: Text("${o.konu}\n${o.aciklama}"),
                      trailing: const Icon(Icons.assignment)));
            }));
  }
}

class YapayZekaSohbetEkrani extends StatefulWidget {
  const YapayZekaSohbetEkrani({super.key});
  @override
  State<YapayZekaSohbetEkrani> createState() => _YZSEState();
}

class _YZSEState extends State<YapayZekaSohbetEkrani> {
  final TextEditingController _c = TextEditingController();
  void _send() async {
    if (_c.text.isEmpty) return;
    String t = _c.text;
    setState(() {
      VeriDeposu.mesajlar.add(Mesaj(text: t, isUser: true));
      _c.clear();
    });
    String r =
        await GravityAI.generateText("Sen bir rehber öğretmenisin. Soru: $t");
    setState(() => VeriDeposu.mesajlar.add(Mesaj(text: r, isUser: false)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("AI Asistan")),
        body: Column(children: [
          Expanded(
              child: ListView.builder(
                  itemCount: VeriDeposu.mesajlar.length,
                  itemBuilder: (c, i) => Align(
                      alignment: VeriDeposu.mesajlar[i].isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: VeriDeposu.mesajlar[i].isUser
                                  ? Colors.blue[100]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(VeriDeposu.mesajlar[i].text))))),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                Expanded(child: TextField(controller: _c)),
                IconButton(icon: const Icon(Icons.send), onPressed: _send)
              ]))
        ]));
  }
}

class TumProgramEkrani extends StatefulWidget {
  const TumProgramEkrani({super.key});
  @override
  State<TumProgramEkrani> createState() => _TPEState();
}

class _TPEState extends State<TumProgramEkrani>
    with SingleTickerProviderStateMixin {
  late TabController _tc;
  int hSayisi = 1;
  @override
  void initState() {
    super.initState();
    if (VeriDeposu.kayitliProgram.isNotEmpty)
      hSayisi = VeriDeposu.kayitliProgram.map((e) => e.hafta).reduce(max);
    _tc = TabController(length: hSayisi, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    if (VeriDeposu.kayitliProgram.isEmpty)
      return Scaffold(
          appBar: AppBar(title: const Text("Program")),
          body: const Center(child: Text("Henüz program yok.")));
    return Scaffold(
        appBar: AppBar(
            title: const Text("Programım"),
            bottom: TabBar(
                controller: _tc,
                isScrollable: true,
                tabs: List.generate(hSayisi, (i) => Tab(text: "${i + 1}.H")))),
        body: TabBarView(
            controller: _tc,
            children: List.generate(hSayisi, (i) {
              int hafta = i + 1;
              var p = VeriDeposu.kayitliProgram
                  .where((x) => x.hafta == hafta)
                  .toList();
              List<String> gunler = [
                "Pazartesi",
                "Salı",
                "Çarşamba",
                "Perşembe",
                "Cuma",
                "Cumartesi",
                "Pazar"
              ];
              return ListView(
                  children: gunler.map((g) {
                var gunlukDersler = p.where((x) => x.gun == g).toList();
                return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ExpansionTile(
                        title: Text(g,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple)),
                        subtitle: Text("${gunlukDersler.length} Etüt"),
                        children: gunlukDersler
                            .map((d) => ListTile(
                                leading: const Icon(Icons.menu_book,
                                    color: Colors.blue),
                                title: Text(d.ders),
                                subtitle: Text("${d.saat} - ${d.konu}"),
                                onTap: () {
                                  // DÜZENLEME DİYALOĞU
                                  final dC = TextEditingController(text: d.ders);
                                  final kC = TextEditingController(text: d.konu);
                                  final sC = TextEditingController(text: d.saat);
                                  showDialog(context: context, builder: (c) => AlertDialog(
                                    title: const Text("Görevi Düzenle"),
                                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                                      TextField(controller: dC, decoration: const InputDecoration(labelText: "Ders")),
                                      TextField(controller: kC, decoration: const InputDecoration(labelText: "Konu")),
                                      TextField(controller: sC, decoration: const InputDecoration(labelText: "Saat")),
                                    ]),
                                    actions: [
                                      TextButton(onPressed: (){
                                        // SİL
                                        setState(() {
                                          VeriDeposu.kayitliProgram.remove(d);
                                          VeriDeposu.programiKaydet(VeriDeposu.kayitliProgram, "Düzenlendi");
                                        });
                                        Navigator.pop(c);
                                      }, child: const Text("SİL", style: TextStyle(color: Colors.red))),
                                      ElevatedButton(onPressed: (){
                                        // KAYDET
                                        setState(() {
                                          d.ders = dC.text;
                                          d.konu = kC.text;
                                          d.saat = sC.text;
                                          VeriDeposu.programiKaydet(VeriDeposu.kayitliProgram, "Düzenlendi");
                                        });
                                        Navigator.pop(c);
                                      }, child: const Text("KAYDET"))
                                    ],
                                  ));
                                },
                            ))
                            .toList()));
              }).toList());
            })));
  }
}

class ManuelProgramSihirbazi extends StatefulWidget {
  const ManuelProgramSihirbazi({super.key});
  @override
  State<ManuelProgramSihirbazi> createState() => _MPSState();
}

class _MPSState extends State<ManuelProgramSihirbazi> {
  int currentStep = 0;
  String stil = "Klasik";
  TimeOfDay basla = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay bitis = const TimeOfDay(hour: 17, minute: 0);
  List<String> tatiller = [];
  Map<String, bool> dersler = {};
  double haftaSayisi = 12; // Slider için double, aslında int

  @override
  void initState() {
    super.initState();
    for (var k in VeriDeposu.dersKonuAgirliklari.keys) {
      dersler[k] = false;
    }
  }

  void _olustur() {
    // 1. Seçilen Dersleri ve Konuları Topla
    List<Map<String, dynamic>> tumKonular = [];
    dersler.forEach((dersAd, secili) {
      if (secili) {
        var konular = VeriDeposu.dersKonuAgirliklari[dersAd] ?? [];
        for (var konu in konular) {
          // Ağırlık 3 ise 3 kez ekle (daha fazla zaman ayır)
          int agirlik = konu.agirlik;
          // Strateji: Konu -> Test -> Tekrar
          tumKonular.add({"tur": "Konu", "ders": dersAd, "konu": konu.ad, "onem": agirlik});
          if(agirlik >= 2) tumKonular.add({"tur": "Test", "ders": dersAd, "konu": konu.ad, "onem": agirlik});
          if(agirlik == 3) tumKonular.add({"tur": "Derinleşme", "ders": dersAd, "konu": konu.ad, "onem": agirlik});
        }
      }
    });

    if (tumKonular.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen en az bir ders seçin.")));
      return;
    }

    // 2. Zaman Planlaması
    List<Gorev> program = [];
    int toplamHafta = haftaSayisi.toInt();
    List<String> gunler = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"];
    List<String> calismaGunleri = gunler.where((g) => !tatiller.contains(g)).toList();

    // Günde kaç slot var? (Basitçe saat farkı)
    int gunlukSlot = (bitis.hour - basla.hour).abs();
    if (gunlukSlot < 1) gunlukSlot = 1;

    int konuSayaci = 0;

    for (int h = 1; h <= toplamHafta; h++) {
      // 4. Hafta Genel Tekrar Haftası
      if (h % 4 == 0) {
        for (var gun in calismaGunleri) {
           program.add(Gorev(
             hafta: h,
             gun: gun,
             saat: "${basla.hour}:00 - ${bitis.hour}:00",
             ders: "GENEL TEKRAR",
             konu: "Geçmiş 3 haftanın taraması",
             aciklama: "Deneme çöz ve eksiklerini kapat."
           ));
        }
        continue; // Bu haftayı geç
      }

      for (var gun in calismaGunleri) {
        // Pazar günleri haftalık tekrar (Eğer tatil değilse)
        if (gun == "Pazar" && !tatiller.contains("Pazar")) {
             program.add(Gorev(hafta: h, gun: gun, saat: "Tüm Gün", ders: "HAFTALIK TEKRAR", konu: "Bu haftanın özeti", aciklama: "Notlarını oku."));
             continue;
        }

        for (int s = 0; s < gunlukSlot; s++) {
          if (konuSayaci >= tumKonular.length) break;

          var k = tumKonular[konuSayaci];
          program.add(Gorev(
            hafta: h,
            gun: gun,
            saat: "${basla.hour + s}:00",
            ders: k["ders"],
            konu: k["konu"],
            aciklama: "${k['tur']} çalışması yap. (Önem: ${k['onem']})"
          ));

          konuSayaci++;
        }
        if (konuSayaci >= tumKonular.length) break;
      }
      if (konuSayaci >= tumKonular.length) break;
    }

    VeriDeposu.programiKaydet(program, "Akıllı Program (${toplamHafta} Hafta)");
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (c) => const TumProgramEkrani()));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Akıllı Program Hazırlandı! (${program.length} Görev)"), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Akıllı Program Sihirbazı")),
        floatingActionButton: currentStep == 3
            ? FloatingActionButton.extended(
                onPressed: _olustur,
                label: const Text("OLUŞTUR"),
                icon: const Icon(Icons.check))
            : null,
        body: Stepper(
            currentStep: currentStep,
            onStepContinue: () {
              if (currentStep < 3) setState(() => currentStep++);
            },
            onStepCancel: () {
              if (currentStep > 0) setState(() => currentStep--);
            },
            steps: [
              Step(
                  title: const Text("Süre & Hedef"),
                  content: Column(children: [
                    const Text("Kaç hafta sürecek?"),
                    Slider(
                        min: 1,
                        max: 36,
                        divisions: 35,
                        label: "${haftaSayisi.toInt()} Hafta",
                        value: haftaSayisi,
                        onChanged: (v) => setState(() => haftaSayisi = v)),
                    Text("${haftaSayisi.toInt()} Hafta boyunca YKS müfredatını bitireceğiz.", style: const TextStyle(color: Colors.grey)),
                  ])),
              Step(
                  title: const Text("Günlük Rutin"),
                  content: Column(children: [
                    DropdownButtonFormField(
                        value: stil,
                        decoration: const InputDecoration(labelText: "Çalışma Stili"),
                        items: ["Klasik", "Pomodoro", "Blok"]
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) {
                          setState(() => stil = v!);
                        }),
                    Row(children: [
                      TextButton(
                          onPressed: () async {
                            var t = await showTimePicker(
                                context: context, initialTime: basla);
                            if (t != null) setState(() => basla = t);
                          },
                          child: Text("Başla: ${basla.format(context)}")),
                      TextButton(
                          onPressed: () async {
                            var t = await showTimePicker(
                                context: context, initialTime: bitis);
                            if (t != null) setState(() => bitis = t);
                          },
                          child: Text("Bitir: ${bitis.format(context)}"))
                    ])
                  ])),
              Step(
                  title: const Text("Tatil Günleri"),
                  content: Wrap(
                      spacing: 5,
                      children: [
                        "Pazartesi",
                        "Salı",
                        "Çarşamba",
                        "Perşembe",
                        "Cuma",
                        "Cumartesi",
                        "Pazar"
                      ]
                          .map((g) => FilterChip(
                              label: Text(g),
                              selected: tatiller.contains(g),
                              onSelected: (v) => setState(() {
                                    v ? tatiller.add(g) : tatiller.remove(g);
                                  })))
                          .toList())),
              Step(
                  title: const Text("Dersleri Seçin"),
                  content: SizedBox(
                      height: 300,
                      child: ListView(
                          children: dersler.keys
                              .map((k) => CheckboxListTile(
                                  title: Text(k),
                                  value: dersler[k],
                                  onChanged: (v) =>
                                      setState(() => dersler[k] = v!)))
                              .toList())))
            ]));
  }
}

class ProgramSihirbaziEkrani extends StatefulWidget {
  const ProgramSihirbaziEkrani({super.key, this.mod = "Genel"});
  final String mod;
  @override
  State<ProgramSihirbaziEkrani> createState() => _PSEState();
}

class _PSEState extends State<ProgramSihirbaziEkrani> {
  final _formKey = GlobalKey<FormState>();
  String sinif = "12",
      alan = "Sayısal",
      hedef = "Tıp",
      zayif = "Matematik",
      saat = "5";
  bool loading = false;
  void _olusturAI() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => loading = true);
    List<Gorev> program = await GravityAI.programOlustur(
        sinif, alan, "30+5", int.parse(saat), zayif);
    setState(() => loading = false);
    if (program.isNotEmpty) {
      VeriDeposu.programiKaydet(program, "AI Program");
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (c) => TumProgramEkrani()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("AI Program")),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
                key: _formKey,
                child: Column(children: [
                  const Icon(Icons.psychology,
                      size: 80, color: Colors.deepPurple),
                  DropdownButtonFormField(
                      value: sinif,
                      items: ["9", "10", "11", "12"]
                          .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => sinif = v!)),
                  ElevatedButton(
                      onPressed: loading ? null : _olusturAI,
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text("OLUŞTUR"))
                ]))));
  }
}

class DenemeEkleEkrani extends StatefulWidget {
  final String ogrenciId;
  const DenemeEkleEkrani({super.key, required this.ogrenciId});
  @override
  State<DenemeEkleEkrani> createState() => _DEEState();
}

class _DEEState extends State<DenemeEkleEkrani> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Deneme Ekle")),
        body: const Center(child: Text("Deneme Ekleme Formu")));
  }
}

// --- UI POLISH: SCHOOL NOTES SCREEN ---
class OkulSinavlariEkrani extends StatefulWidget {
  const OkulSinavlariEkrani({super.key});
  @override
  State<OkulSinavlariEkrani> createState() => _OSEState();
}

class _OSEState extends State<OkulSinavlariEkrani> {
  final _dersAd = TextEditingController();
  final _y1 = TextEditingController(), _y2 = TextEditingController(), _p = TextEditingController();

  void _ekle() {
    if (_dersAd.text.isEmpty) return;
    VeriDeposu.dersEkle(OkulDersi(
      ad: _dersAd.text,
      yazili1: double.tryParse(_y1.text) ?? 0,
      yazili2: double.tryParse(_y2.text) ?? 0,
      performans: double.tryParse(_p.text) ?? 0,
    ));
    setState(() {
      _dersAd.clear(); _y1.clear(); _y2.clear(); _p.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ders Kaydedildi!"), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Notlar")),
        body: ListView(children: [
          ExpansionTile(
            title: const Text("Yeni Ders Ekle", style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(children: [
                  TextField(controller: _dersAd, decoration: const InputDecoration(labelText: "Ders Adı", border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: TextField(controller: _y1, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "1.Yazılı"))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: _y2, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "2.Yazılı"))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: _p, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Sözlü"))),
                  ]),
                  const SizedBox(height: 10),
                  ElevatedButton(onPressed: _ekle, child: const Text("KAYDET"))
                ]),
              )
            ],
          ),
          ...VeriDeposu.okulNotlari.map((d) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(d.ad),
              subtitle: Text("Y1: ${d.yazili1}  Y2: ${d.yazili2}  S: ${d.performans}"),
              trailing: CircleAvatar(
                backgroundColor: d.ortalama >= 50 ? Colors.green : Colors.red,
                child: Text(d.ortalama.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          )).toList()
        ]));
  }
}

// UI POLISH: SIMPLE PLACEHOLDER REPLACEMENTS
class KronometreEkrani extends StatefulWidget {
  const KronometreEkrani({super.key});
  @override
  State<KronometreEkrani> createState() => _KREState();
}
class _KREState extends State<KronometreEkrani> {
  int _seconds = 0;
  bool _running = false;
  
  @override
  void initState() {
    super.initState();
    _tick();
  }
  void _tick() async {
    while(true) {
      await Future.delayed(const Duration(seconds: 1));
      if(_running && mounted) setState(() => _seconds++);
    }
  }

  @override
  Widget build(BuildContext context) {
    int m = _seconds ~/ 60;
    int s = _seconds % 60;
    return Scaffold(
        appBar: AppBar(title: const Text("Sayaç")),
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(onPressed: () => setState(() => _running = !_running), child: Text(_running ? "DURAKLAT" : "BAŞLAT")),
            const SizedBox(width: 20),
            ElevatedButton(onPressed: () => setState(() { _running = false; _seconds = 0; }), child: const Text("SIFIRLA"))
          ])
        ])));
  }
}

class BasariGrafigiEkrani extends StatelessWidget {
  final String ogrenciId;
  const BasariGrafigiEkrani({super.key, required this.ogrenciId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Grafik")),
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
           Icon(Icons.show_chart, size: 100, color: Colors.grey[300]),
           const Text("Grafikler Veri Toplandıkça Açılacak", style: TextStyle(color: Colors.grey))
        ])));
  }
}

class DenemeListesiEkrani extends StatelessWidget {
  final String? ogrenciId;
  const DenemeListesiEkrani({super.key, this.ogrenciId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Denemeler")),
        body: VeriDeposu.denemeListesi.isEmpty 
        ? const Center(child: Text("Henüz Deneme Yok"))
        : ListView.builder(
            itemCount: VeriDeposu.denemeListesi.length,
            itemBuilder: (c, i) {
               var d = VeriDeposu.denemeListesi[i];
               return ListTile(
                 title: Text(d.tur),
                 subtitle: Text(d.tarih.toString().substring(0, 10)),
                 trailing: Text("${d.toplamNet} Net", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
               );
            }));
  }
}

class RozetlerEkrani extends StatelessWidget {
  final Ogrenci ogrenci;
  const RozetlerEkrani({super.key, required this.ogrenci});

  Color _getTierColor(String tier) {
    switch (tier) {
      case "Bronz": return const Color(0xFFCD7F32);
      case "Gümüş": return const Color(0xFFC0C0C0);
      case "Altın": return const Color(0xFFFFD700);
      case "Elmas": return const Color(0xFFB9F2FF);
      case "Efsane": return const Color(0xFFFF4500);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    var gruplar = <String, List<Rozet>>{};
    for (var r in VeriDeposu.tumRozetler) {
      gruplar.putIfAbsent(r.kategori, () => []).add(r);
    }
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Başarımlar & Rozetler"), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(16), children: gruplar.keys.map((kategori) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
           Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(kategori.toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700], letterSpacing: 1.2))),
           GridView.builder(
             shrinkWrap: true,
             physics: const NeverScrollableScrollPhysics(),
             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.75, crossAxisSpacing: 10, mainAxisSpacing: 10),
             itemCount: gruplar[kategori]!.length,
             itemBuilder: (c, i) {
                var r = gruplar[kategori]![i];
                var progress = (r.mevcutSayi / r.hedefSayi).clamp(0.0, 1.0);
                var color = _getTierColor(r.seviye);
                return Container(
                   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: r.kazanildi ? Border.all(color: color, width: 2) : Border.all(color: Colors.grey.withOpacity(0.3)), boxShadow: [if (r.kazanildi) BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]),
                   child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(shape: BoxShape.circle, color: r.kazanildi ? color.withOpacity(0.2) : Colors.grey[200]), child: Icon(r.ikon, size: 30, color: r.kazanildi ? color : Colors.grey)),
                      const SizedBox(height: 8),
                      Text(r.ad, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: r.kazanildi ? Colors.black : Colors.grey)),
                      Text(r.seviye, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: Colors.grey[200], color: color))),
                      const SizedBox(height: 2),
                      Text("${r.mevcutSayi}/${r.hedefSayi}", style: const TextStyle(fontSize: 9, color: Colors.grey))
                   ])
                );
             })
        ]);
      }).toList(),
    ));
  }
}

class KonuTakipEkrani extends StatefulWidget {
  final bool readOnly;
  const KonuTakipEkrani({super.key, this.readOnly = false});
  @override
  State<KonuTakipEkrani> createState() => _KTE();
}
class _KTE extends State<KonuTakipEkrani> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Konu Takip (YKS)")),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              VeriDeposu.kaydet();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konular Kaydedildi!"), backgroundColor: Colors.green));
              setState(() {}); // Refresh percentages
            },
            icon: const Icon(Icons.save),
            label: const Text("KAYDET")),
        body: ListView(
            children: VeriDeposu.dersKonuAgirliklari.keys.map((d) {
               // Calculate Percentage
               var topics = VeriDeposu.dersKonuAgirliklari[d]!;
               int completed = topics.where((t) => VeriDeposu.tamamlananKonular["$d - ${t.ad}"] == true).length;
               double percent = topics.isEmpty ? 0 : completed / topics.length;

               return ExpansionTile(
                    title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                       Text(d, style: const TextStyle(fontWeight: FontWeight.bold)),
                       Text("%${(percent * 100).toInt()}", style: TextStyle(color: percent == 1.0 ? Colors.green : Colors.grey))
                    ]),
                    subtitle: LinearProgressIndicator(value: percent, backgroundColor: Colors.grey[200], color: Colors.green),
                    children: topics.map((k) => CheckboxListTile(
                            title: Text(k.ad),
                            value: VeriDeposu.tamamlananKonular["$d - ${k.ad}"] ?? false,
                            onChanged: (v) => setState(() => VeriDeposu.konuDurumDegistir("$d - ${k.ad}", v!))))
                        .toList());
            }).toList()));
  }
}

class SoruTakipEkrani extends StatefulWidget {
  final String ogrenciId;
  const SoruTakipEkrani({super.key, required this.ogrenciId});
  @override
  State<SoruTakipEkrani> createState() => _STE();
}
class _STE extends State<SoruTakipEkrani> {
  String? d, k;
  final c1 = TextEditingController(), c2 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Soru Takip")),
        body: Padding(padding: const EdgeInsets.all(10), child: Column(children: [
              DropdownButton<String>(isExpanded: true, value: d, hint: const Text("Ders"), items: VeriDeposu.dersKonuAgirliklari.keys.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() { d = v; k = null; })),
              if (d != null) DropdownButton<String>(isExpanded: true, value: k, hint: const Text("Konu"), items: VeriDeposu.dersKonuAgirliklari[d]!.map((e) => DropdownMenuItem(value: e.ad, child: Text(e.ad))).toList(), onChanged: (v) => setState(() => k = v)),
              Row(children: [Expanded(child: TextField(controller: c1, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Doğru"))), const SizedBox(width: 10), Expanded(child: TextField(controller: c2, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Yanlış")))]),
              ElevatedButton(onPressed: () {
                    VeriDeposu.soruEkle(SoruCozumKaydi(ogrenciId: widget.ogrenciId, ders: d ?? "?", konu: k ?? "?", dogru: int.tryParse(c1.text)??0, yanlis: int.tryParse(c2.text)??0, tarih: DateTime.now()));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Soru Kaydedildi!"), backgroundColor: Colors.green));
                    setState(() {});
                  }, child: const Text("KAYDET & EKLE")),
              Expanded(child: ListView.builder(itemCount: VeriDeposu.soruCozumListesi.where((x) => x.ogrenciId == widget.ogrenciId).length, itemBuilder: (c, i) => ListTile(title: Text(VeriDeposu.soruCozumListesi[i].konu), trailing: Text("D:${VeriDeposu.soruCozumListesi[i].dogru} Y:${VeriDeposu.soruCozumListesi[i].yanlis}"))))
            ])));
  }
}

class SoruCozumEkrani extends StatefulWidget {
  const SoruCozumEkrani({super.key});
  @override
  State<SoruCozumEkrani> createState() => _SCEState();
}
class _SCEState extends State<SoruCozumEkrani> {
  XFile? _image; // File yerine XFile (Web uyumlu)
  String _cozum = "";
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _foto(ImageSource s) async {
    final f = await _picker.pickImage(source: s);
    if (f != null) setState(() => _image = f);
  }

  Future<void> _coz() async {
    if (_image == null) return;
    setState(() => _loading = true);
    // GravityAI artık XFile kabul ediyor
    String c = await GravityAI.soruCoz(_image!);
    setState(() { _cozum = c; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("AI Soru Çöz")),
        body: SingleChildScrollView(child: Column(children: [
          if(_image != null) 
             kIsWeb 
                ? Image.network(_image!.path, height: 200) // Web için
                : Image.file(File(_image!.path), height: 200), // Mobil için (import dart:io gerekir ama screens.dart'ta var mı?)

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
             ElevatedButton(onPressed: () => _foto(ImageSource.camera), child: const Text("Kamera")),
             const SizedBox(width: 10),
             ElevatedButton(onPressed: () => _foto(ImageSource.gallery), child: const Text("Galeri")),
          ]),
          if(_image != null) ElevatedButton(onPressed: _coz, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text("ÇÖZ (AI)")),
          if (_loading) const CircularProgressIndicator(),
          Padding(padding: const EdgeInsets.all(12), child: Text(_cozum))
        ])));
  }
}

class GunlukTakipEkrani extends StatefulWidget {
  const GunlukTakipEkrani({super.key});
  @override
  State<GunlukTakipEkrani> createState() => _GTEState();
}
class _GTEState extends State<GunlukTakipEkrani> {
  final Map<String, bool> _check = {"Paragraf Çözdüm": false, "Problem Çözdüm": false, "Deneme Çözdüm": false, "8 Saat Uyudum": false, "Su İçtim": false};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Günlük Rutin")),
        floatingActionButton: FloatingActionButton(child: const Icon(Icons.save), onPressed: () {
           // Save logic placeholder
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rutin Kaydedildi! +20 Puan"), backgroundColor: Colors.green));
        }),
        body: ListView(children: _check.keys.map((k) => CheckboxListTile(title: Text(k), value: _check[k], onChanged: (v) => setState(() => _check[k] = v!))).toList()));
  }
}

// --- ÖĞRETMEN & KOÇ PANELİ ---
class OgretmenPaneli extends StatefulWidget {
  final Ogretmen aktifOgretmen;
  const OgretmenPaneli({super.key, required this.aktifOgretmen});
  @override
  State<OgretmenPaneli> createState() => _OPState();
}

class _OPState extends State<OgretmenPaneli> {
  // AI Analiz Fonksiyonu
  void _analizEt(Ogrenci o) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()));

    String prompt =
        "Bu öğrenci için bir koç olarak 2-3 cümlelik motive edici ve yönlendirici bir analiz yap: "
        "Ad: ${o.ad}, Puan: ${o.puan}, Seri: ${o.gunlukSeri} Gün, Sınıf: ${o.sinif}. "
        "Cevabı Türkçe ver ve samimi ol.";

    String tavsiye = await GravityAI.generateText(prompt);

    if (!mounted) return;
    Navigator.pop(context); // Loading kapat

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (c) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.psychology, size: 50, color: Colors.deepPurple),
              const SizedBox(height: 10),
              Text("Koç Tavsiyesi (${o.ad})",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              Text(tavsiye,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text("Teşekkürler"))
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Koç Paneli: ${widget.aktifOgretmen.ad}"),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await VeriDeposu.cikisYap();
                if (!mounted) return;
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (c) => const LoginPage()));
              })
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: VeriDeposu.ogrenciler.length,
        itemBuilder: (c, i) {
          var o = VeriDeposu.ogrenciler[i];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text(o.ad.substring(0, 1),
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.ad,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("${o.sinif} • ${o.puan} XP",
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const Icon(Icons.local_fire_department,
                              color: Colors.orange),
                          Text("${o.gunlukSeri} Gün")
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton.icon(
                              onPressed: () => _analizEt(o),
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text("AI Analiz Et"),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white))),
                      const SizedBox(width: 10),
                      OutlinedButton(
                          onPressed: () {
                             // Detay sayfasına git (Opsiyonel, şimdilik boş)
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Detaylar yakında...")));
                          },
                          child: const Text("Detay"))
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- YÖNETİCİ & GOD MODE PANELİ ---
class YoneticiPaneli extends StatefulWidget {
  const YoneticiPaneli({super.key});
  @override
  State<YoneticiPaneli> createState() => _YPState();
}

class _YPState extends State<YoneticiPaneli> {
  // Diyaloglar
  void _uyeEkleDialog() {
    final adC = TextEditingController(), sinifC = TextEditingController();
    bool isOgrenci = true;
    showDialog(
        context: context,
        builder: (c) => StatefulBuilder(
              builder: (context, setD) => AlertDialog(
                title: const Text("Yeni Kullanıcı Ekle"),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(controller: adC, decoration: const InputDecoration(labelText: "Ad Soyad")),
                  const SizedBox(height: 10),
                  Row(children: [
                    const Text("Rol: "),
                    DropdownButton<bool>(
                        value: isOgrenci,
                        items: const [
                          DropdownMenuItem(value: true, child: Text("Öğrenci")),
                          DropdownMenuItem(value: false, child: Text("Öğretmen"))
                        ],
                        onChanged: (v) => setD(() => isOgrenci = v!))
                  ]),
                  if (isOgrenci)
                    TextField(controller: sinifC, decoration: const InputDecoration(labelText: "Sınıf (Örn: 12-A)")),
                  if (!isOgrenci)
                    TextField(controller: sinifC, decoration: const InputDecoration(labelText: "Branş (Örn: Matematik)")),
                ]),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(c), child: const Text("İptal")),
                  ElevatedButton(
                      onPressed: () {
                        if (isOgrenci) {
                          VeriDeposu.ogrenciEkle(adC.text, sinifC.text);
                        } else {
                          VeriDeposu.ogretmenEkle(adC.text, sinifC.text);
                        }
                        Navigator.pop(c);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kullanıcı Eklendi"), backgroundColor: Colors.green));
                      },
                      child: const Text("EKLE"))
                ],
              ),
            ));
  }

  void _atamaDialog() {
    String? secilenOgrt;
    final secilenOgrler = <String>[];

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setD) => AlertDialog(
          title: const Text("Öğrenci Ata"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButton<String>(
                  isExpanded: true,
                  value: secilenOgrt,
                  hint: const Text("Öğretmen Seç"),
                  items: VeriDeposu.ogretmenler.map((e) => DropdownMenuItem(value: e.id, child: Text(e.ad))).toList(),
                  onChanged: (v) => setD(() => secilenOgrt = v)),
              const SizedBox(height: 10),
              const Text("Öğrenciler (Çoklu Seçim):", style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: VeriDeposu.ogrenciler.map((o) {
                    final checked = secilenOgrler.contains(o.id);
                    return CheckboxListTile(
                      title: Text(o.ad),
                      subtitle: Text(o.sinif),
                      value: checked,
                      onChanged: (v) {
                        setD(() {
                          if (v == true)
                            secilenOgrler.add(o.id);
                          else
                            secilenOgrler.remove(o.id);
                        });
                      },
                    );
                  }).toList(),
                ),
              )
            ]),
          ),
          actions: [
             ElevatedButton(onPressed: (){
               if(secilenOgrt == null) return;
               for(var oId in secilenOgrler) {
                 VeriDeposu.atamaYap(oId, secilenOgrt!);
               }
               Navigator.pop(c);
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${secilenOgrler.length} Öğrenci Atandı!")));
             }, child: const Text("KAYDET"))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Süper Yönetici Paneli"),
          backgroundColor: Colors.black87,
          bottom: const TabBar(tabs: [
            Tab(text: "Kullanıcılar", icon: Icon(Icons.people)),
            Tab(text: "Atamalar", icon: Icon(Icons.link)),
            Tab(text: "GOD MODE", icon: Icon(Icons.flash_on)),
          ]),
          actions: [
            IconButton(icon: const Icon(Icons.logout), onPressed: () async {
               await VeriDeposu.cikisYap();
               Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginPage()));
            })
          ],
        ),
        body: TabBarView(children: [
          // 1. KULLANICILAR
          Scaffold(
            floatingActionButton: FloatingActionButton(onPressed: _uyeEkleDialog, child: const Icon(Icons.add)),
            body: ListView(
              children: [
                ...VeriDeposu.ogretmenler.map((t) => ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.school, color: Colors.white)),
                  title: Text(t.ad),
                  subtitle: Text(t.brans),
                  trailing: PopupMenuButton(itemBuilder: (c) => [
                    const PopupMenuItem(value: "del", child: Text("Sil"))
                  ], onSelected: (v) {
                     if(v=="del") { VeriDeposu.kullaniciSil(t.id); setState((){}); }
                  }),
                )),
                const Divider(),
                ...VeriDeposu.ogrenciler.map((o) => ListTile(
                  leading: CircleAvatar(child: Text(o.sinif.substring(0,2))),
                  title: Text(o.ad),
                  subtitle: Text("Puan: ${o.puan} | ${o.sinif}"),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.key), onPressed: () {
                      VeriDeposu.sifreSifirla(o.id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şifre 123456 oldu")));
                    }),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: (){
                      VeriDeposu.kullaniciSil(o.id); setState((){});
                    })
                  ]),
                  onTap: () {
                    // Edit XP Dialog
                    final xpC = TextEditingController(text: o.puan.toString());
                    showDialog(context: context, builder: (c) => AlertDialog(
                      title: Text("${o.ad} Düzenle"),
                      content: TextField(controller: xpC, decoration: const InputDecoration(labelText: "XP Puanı"), keyboardType: TextInputType.number),
                      actions: [
                        ElevatedButton(onPressed: (){
                          o.puan = int.tryParse(xpC.text) ?? o.puan;
                          VeriDeposu.kaydet();
                          Navigator.pop(c);
                          setState((){});
                        }, child: const Text("KAYDET"))
                      ],
                    ));
                  },
                ))
              ],
            ),
          ),
          
          // 2. ATAMALAR
          Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.assignment_ind, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _atamaDialog, child: const Text("Öğrenci - Öğretmen Eşleştir"))
          ])),

          // 3. GOD MODE
          Container(
            color: Colors.black12,
            child: ListView(padding: const EdgeInsets.all(20), children: [
              Card(child: ListTile(
                leading: const Icon(Icons.cloud, color: Colors.blue),
                title: const Text("XP Yağmuru"),
                subtitle: const Text("Herkese +1000 XP verir."),
                onTap: () {
                   VeriDeposu.xpYagmuru();
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("XP YAĞDI! 🌧️")));
                },
              )),
               Card(child: ListTile(
                leading: const Icon(Icons.lock_open, color: Colors.amber),
                title: const Text("Rozetleri Aç"),
                subtitle: const Text("Herkesin tüm rozetlerini açar."),
                onTap: () {
                   // Implement if needed
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu özellik şu an kapalı.")));
                },
              )), 
              const SizedBox(height: 50),
              Card(color: Colors.redAccent, child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.white),
                title: const Text("FABRİKA AYARLARINA DÖN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("TÜM VERİ SİLİNİR!", style: TextStyle(color: Colors.white70)),
                onTap: () async {
                  await VeriDeposu.sifirla();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginPage()));
                },
              )),
            ]),
          )
        ]),
      ),
    );
  }
}

