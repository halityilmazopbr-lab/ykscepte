import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid.dart';
import 'data.dart';
import 'models.dart';
import 'gemini_service.dart';
import 'akademik_rontgen_screen.dart'; // YENİ

/// Program Sihirbazı - v4
/// AYT dersleri, 36 haftalık uzun dönemli program, akıllı dağılım
class YeniProgramSihirbaziEkrani extends StatefulWidget {
  const YeniProgramSihirbaziEkrani({super.key});

  @override
  State<YeniProgramSihirbaziEkrani> createState() => _YeniProgramSihirbaziEkraniState();
}

class _YeniProgramSihirbaziEkraniState extends State<YeniProgramSihirbaziEkrani> {
  int _currentStep = 0;
  bool _isAIMode = true;
  bool _isLoading = false;

  // YKS Tarihi
  static final DateTime yksTarihi = DateTime(2026, 6, 20);
  
  // Sınava kalan hafta
  int get _kalanGun => yksTarihi.difference(DateTime.now()).inDays;
  int get _kalanHafta => (_kalanGun / 7).ceil();
  
  // Sınav dönemi
  String get _sinavDonemi {
    if (_kalanGun <= 30) return "son_ay";
    if (_kalanGun <= 90) return "son_3ay";
    if (_kalanGun <= 180) return "son_6ay";
    return "normal";
  }

  // Form verileri
  String _sinif = "12";
  String _alan = "Sayısal";
  String _hedefUni = "";
  String _sinavTuru = "TYT+AYT";
  
  // Program süresi (hafta)
  int _programHaftasi = 12; // Varsayılan 12 hafta
  
  // Çalışma Modu
  String _calismaModu = "Standart (45+15)";
  final Map<String, Map<String, int>> _calismaModlari = {
    "Pomodoro (25+5)": {"calisma": 25, "mola": 5},
    "Standart (45+15)": {"calisma": 45, "mola": 15},
    "Yoğun (60+10)": {"calisma": 60, "mola": 10},
    "Maratoncuk (90+15)": {"calisma": 90, "mola": 15},
  };
  
  // Çalışma saatleri
  Set<int> _seciliSaatler = {8, 9, 10, 14, 15, 16, 19, 20};
  Set<String> _tatilGunleri = {};
  Map<String, int> _gunSureleri = {
    "Pazartesi": 6, "Salı": 6, "Çarşamba": 6, "Perşembe": 6, "Cuma": 6,
    "Cumartesi": 8, "Pazar": 8,
  };

  List<String> _zayifDersler = [];
  Set<String> _bitmisKonular = {};
  List<ProgramSatiri> _program = [];

  // DÜZELTME: Sınav türüne göre DOĞRU dersler
  List<String> get _tumDersler {
    List<String> dersler = [];
    
    if (_sinavTuru == "TYT" || _sinavTuru == "TYT+AYT") {
      // TYT dersleri
      dersler.addAll(["TYT Türkçe", "TYT Matematik", "TYT Geometri", 
                      "TYT Fizik", "TYT Kimya", "TYT Biyoloji",
                      "TYT Tarih", "TYT Coğrafya", "TYT Felsefe", "TYT Din Kültürü"]);
    }
    
    if (_sinavTuru == "AYT" || _sinavTuru == "TYT+AYT") {
      // AYT dersleri (alan bazlı)
      if (_alan == "Sayısal") {
        dersler.addAll(["AYT Matematik", "AYT Fizik", "AYT Kimya", "AYT Biyoloji"]);
      } else if (_alan == "Eşit Ağırlık") {
        dersler.addAll(["AYT Matematik", "AYT Edebiyat", "AYT Tarih-1", "AYT Coğrafya-1"]);
      } else if (_alan == "Sözel") {
        dersler.addAll(["AYT Edebiyat", "AYT Tarih-1", "AYT Coğrafya-1"]);
      } else {
        // Dil
        dersler.addAll(["AYT Edebiyat"]);
      }
    }
    
    return dersler;
  }
  
  // YKS Ders Ağırlıkları (katsayılar)
  Map<String, double> get _dersAgirliklari {
    Map<String, double> agirlik = {};
    
    if (_sinavTuru == "TYT") {
      return {
        "TYT Türkçe": 0.25, "TYT Matematik": 0.25, "TYT Geometri": 0.10,
        "TYT Fizik": 0.08, "TYT Kimya": 0.07, "TYT Biyoloji": 0.05,
        "TYT Tarih": 0.07, "TYT Coğrafya": 0.05, "TYT Felsefe": 0.04, "TYT Din Kültürü": 0.04,
      };
    } else if (_sinavTuru == "AYT") {
      if (_alan == "Sayısal") {
        return {"AYT Matematik": 0.35, "AYT Fizik": 0.25, "AYT Kimya": 0.22, "AYT Biyoloji": 0.18};
      } else if (_alan == "Eşit Ağırlık") {
        return {"AYT Matematik": 0.25, "AYT Edebiyat": 0.30, "AYT Tarih-1": 0.25, "AYT Coğrafya-1": 0.20};
      } else {
        return {"AYT Edebiyat": 0.35, "AYT Tarih-1": 0.30, "AYT Coğrafya-1": 0.20, "TYT Felsefe": 0.15};
      }
    } else {
      // TYT+AYT
      if (_alan == "Sayısal") {
        return {
          "TYT Türkçe": 0.10, "TYT Matematik": 0.10, "TYT Geometri": 0.05,
          "AYT Matematik": 0.20, "AYT Fizik": 0.18, "AYT Kimya": 0.15, "AYT Biyoloji": 0.12,
          "TYT Fizik": 0.03, "TYT Kimya": 0.02, "TYT Biyoloji": 0.02,
          "TYT Tarih": 0.01, "TYT Coğrafya": 0.01, "TYT Felsefe": 0.005, "TYT Din Kültürü": 0.005,
        };
      } else if (_alan == "Eşit Ağırlık") {
        return {
          "TYT Türkçe": 0.12, "TYT Matematik": 0.12, "TYT Geometri": 0.05,
          "AYT Matematik": 0.18, "AYT Edebiyat": 0.20, "AYT Tarih-1": 0.15, "AYT Coğrafya-1": 0.10,
          "TYT Tarih": 0.03, "TYT Coğrafya": 0.02, "TYT Felsefe": 0.02, "TYT Din Kültürü": 0.01,
        };
      } else {
        return {
          "TYT Türkçe": 0.15, "TYT Matematik": 0.10,
          "AYT Edebiyat": 0.25, "AYT Tarih-1": 0.20, "AYT Coğrafya-1": 0.15,
          "TYT Tarih": 0.05, "TYT Coğrafya": 0.05, "TYT Felsefe": 0.03, "TYT Din Kültürü": 0.02,
        };
      }
    }
  }

  // Çalışma şekilleri (haftaya göre)
  Map<String, double> _getCalismaAgirliklari(int hafta) {
    double ilerlemeOrani = hafta / _programHaftasi;
    
    if (ilerlemeOrani >= 0.9) {
      // Son %10: Yoğun deneme + soru
      return {"Soru Çözümü": 0.45, "Deneme Sınavı": 0.35, "Tekrar": 0.15, "Konu Anlatımı": 0.05};
    } else if (ilerlemeOrani >= 0.75) {
      // %75-90: Deneme + soru ağırlıklı
      return {"Soru Çözümü": 0.40, "Deneme Sınavı": 0.25, "Tekrar": 0.20, "Konu Anlatımı": 0.15};
    } else if (ilerlemeOrani >= 0.5) {
      // %50-75: Dengeli
      return {"Soru Çözümü": 0.35, "Konu Anlatımı": 0.25, "Tekrar": 0.20, "Deneme Sınavı": 0.15, "Video İzleme": 0.05};
    } else if (ilerlemeOrani >= 0.25) {
      // %25-50: Konu ağırlıklı
      return {"Konu Anlatımı": 0.35, "Soru Çözümü": 0.30, "Tekrar": 0.15, "Video İzleme": 0.10, "Not Alma": 0.10};
    } else {
      // İlk %25: Temel konu çalışma
      return {"Konu Anlatımı": 0.45, "Soru Çözümü": 0.25, "Video İzleme": 0.15, "Not Alma": 0.10, "Tekrar": 0.05};
    }
  }

  final List<String> _gunler = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: Text(_isAIMode ? "🤖 AI Program Sihirbazı" : "📝 Manuel Program", style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
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
            if (_currentStep < 4)
              ElevatedButton(
                onPressed: _isLoading ? null : details.onStepContinue,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_currentStep == 3 ? "Program Oluştur" : "Devam"),
              ),
            const SizedBox(width: 12),
            if (_currentStep > 0)
              TextButton(onPressed: details.onStepCancel, child: const Text("Geri")),
          ],
        );
      },
      steps: [
        Step(
          title: const Text("Temel Bilgiler", style: TextStyle(color: Colors.white)),
          subtitle: Text("$_sinavTuru • $_alan • $_kalanGun gün kaldı", style: TextStyle(color: Colors.grey.shade500)),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          content: _buildStep1(),
        ),
        Step(
          title: const Text("Program Süresi", style: TextStyle(color: Colors.white)),
          subtitle: Text("$_programHaftasi haftalık plan", style: TextStyle(color: Colors.grey.shade500)),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          content: _buildStep2_ProgramSuresi(),
        ),
        Step(
          title: const Text("Gün Ayarları", style: TextStyle(color: Colors.white)),
          subtitle: Text("${_tatilGunleri.isEmpty ? 'Tatil yok' : '${_tatilGunleri.length} gün tatil'}", style: TextStyle(color: Colors.grey.shade500)),
          isActive: _currentStep >= 2,
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          content: _buildStep3_GunAyarlari(),
        ),
        Step(
          title: const Text("Zayıf Dersler", style: TextStyle(color: Colors.white)),
          subtitle: Text(_zayifDersler.isEmpty ? "Seçilmedi" : "${_zayifDersler.length} ders", style: TextStyle(color: Colors.grey.shade500)),
          isActive: _currentStep >= 3,
          state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          content: _buildStep4_ZayifDersler(),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sınava kalan süre
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.purple.withOpacity(0.3), Colors.blue.withOpacity(0.3)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("YKS 2026", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text("$_kalanGun gün • $_kalanHafta hafta kaldı", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Sınav Türü
        const Text("Hangi sınava çalışacaksın?", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ["TYT", "AYT", "TYT+AYT"].map((s) {
            bool isSelected = _sinavTuru == s;
            return ChoiceChip(
              label: Text(s),
              selected: isSelected,
              onSelected: (v) => setState(() {
                _sinavTuru = s;
                _zayifDersler.clear(); // Sınav türü değişince zayıf dersler sıfırla
              }),
              selectedColor: Colors.purple,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 20),
        
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
        
        // Alan (AYT veya TYT+AYT için)
        if (_sinavTuru != "TYT") ...[
          const Text("Puan Türü", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ["Sayısal", "Eşit Ağırlık", "Sözel", "Dil"].map((a) {
              bool isSelected = _alan == a;
              return ChoiceChip(
                label: Text(a),
                selected: isSelected,
                onSelected: (v) => setState(() {
                  _alan = a;
                  _zayifDersler.clear();
                }),
                selectedColor: Colors.purple,
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
              );
            }).toList(),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Seçilen dersler göster
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF21262D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Çalışılacak Dersler (${_tumDersler.length})", style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: _tumDersler.map((d) => Chip(
                  label: Text(d.replaceAll("TYT ", "").replaceAll("AYT ", ""), style: const TextStyle(fontSize: 10)),
                  backgroundColor: d.startsWith("AYT") ? Colors.blue.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2_ProgramSuresi() {
    int maxHafta = (_kalanHafta > 36) ? 36 : _kalanHafta;
    if (maxHafta < 1) maxHafta = 1;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Kaç haftalık program hazırlansın?", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Sınava $_kalanHafta hafta kaldı (max $maxHafta hafta)", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 16),
        
        // Hafta slider
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _programHaftasi.toDouble().clamp(1, maxHafta.toDouble()),
                min: 1,
                max: maxHafta.toDouble(),
                divisions: maxHafta - 1 > 0 ? maxHafta - 1 : 1,
                activeColor: Colors.purple,
                onChanged: (v) => setState(() => _programHaftasi = v.toInt()),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text("$_programHaftasi hafta", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Hızlı seçimler
        Wrap(
          spacing: 8,
          children: [
            if (maxHafta >= 4) ActionChip(label: const Text("4 Hafta"), onPressed: () => setState(() => _programHaftasi = 4)),
            if (maxHafta >= 8) ActionChip(label: const Text("8 Hafta"), onPressed: () => setState(() => _programHaftasi = 8)),
            if (maxHafta >= 12) ActionChip(label: const Text("12 Hafta"), onPressed: () => setState(() => _programHaftasi = 12)),
            if (maxHafta >= 24) ActionChip(label: const Text("24 Hafta"), onPressed: () => setState(() => _programHaftasi = 24)),
            ActionChip(label: Text("Sınava Kadar ($maxHafta)"), onPressed: () => setState(() => _programHaftasi = maxHafta), backgroundColor: Colors.purple.withOpacity(0.3)),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Çalışma modu
        const Text("Çalışma Modu", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        
        ..._calismaModlari.entries.map((entry) {
          bool isSelected = _calismaModu == entry.key;
          return GestureDetector(
            onTap: () => setState(() => _calismaModu = entry.key),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.purple.withOpacity(0.3) : const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? Border.all(color: Colors.purple, width: 2) : null,
              ),
              child: Row(
                children: [
                  Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? Colors.purple : Colors.grey),
                  const SizedBox(width: 12),
                  Text(entry.key, style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            ),
          );
        }),
        
        const SizedBox(height: 16),
        
        // Çalışma saatleri
        const Text("Çalışma Saatleri", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.5),
          itemCount: 18,
          itemBuilder: (context, index) {
            final saat = index + 6;
            bool isSelected = _seciliSaatler.contains(saat);
            Color bgColor = saat < 12 ? (isSelected ? Colors.orange : Colors.orange.withOpacity(0.2))
                          : saat < 18 ? (isSelected ? Colors.blue : Colors.blue.withOpacity(0.2))
                          : (isSelected ? Colors.purple : Colors.purple.withOpacity(0.2));
            
            return GestureDetector(
              onTap: () => setState(() => isSelected ? _seciliSaatler.remove(saat) : _seciliSaatler.add(saat)),
              child: Container(
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8), border: isSelected ? Border.all(color: Colors.white, width: 2) : null),
                child: Center(child: Text("${saat.toString().padLeft(2, '0')}:00", style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep3_GunAyarlari() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Her gün için çalışma süresi", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        ..._gunler.map((gun) {
          bool isTatil = _tatilGunleri.contains(gun);
          bool isHaftaSonu = gun == "Cumartesi" || gun == "Pazar";
          int sure = _gunSureleri[gun] ?? 6;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isTatil ? Colors.red.withOpacity(0.1) : (isHaftaSonu ? Colors.blue.withOpacity(0.1) : const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => isTatil ? _tatilGunleri.remove(gun) : _tatilGunleri.add(gun)),
                  child: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(color: isTatil ? Colors.red : Colors.transparent, borderRadius: BorderRadius.circular(6), border: Border.all(color: isTatil ? Colors.red : Colors.grey)),
                    child: isTatil ? const Icon(Icons.beach_access, size: 16, color: Colors.white) : null,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(width: 80, child: Text(gun, style: TextStyle(color: isTatil ? Colors.red : Colors.white, fontWeight: isHaftaSonu ? FontWeight.bold : FontWeight.normal))),
                Expanded(
                  child: isTatil 
                      ? Text("Tatil 🏖️", style: TextStyle(color: Colors.red.shade300))
                      : Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: sure.toDouble(), min: 1, max: 12, divisions: 11,
                                activeColor: isHaftaSonu ? Colors.blue : Colors.purple,
                                onChanged: (v) => setState(() => _gunSureleri[gun] = v.toInt()),
                              ),
                            ),
                            SizedBox(width: 50, child: Text("$sure saat", style: TextStyle(color: isHaftaSonu ? Colors.blue : Colors.purple, fontWeight: FontWeight.bold))),
                          ],
                        ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep4_ZayifDersler() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Hangi derslerde desteğe ihtiyacın var?", style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tumDersler.map((d) {
            bool isSelected = _zayifDersler.contains(d);
            bool isAYT = d.startsWith("AYT");
            return FilterChip(
              label: Text(d.replaceAll("TYT ", "").replaceAll("AYT ", "")),
              selected: isSelected,
              onSelected: (v) => setState(() => v ? _zayifDersler.add(d) : _zayifDersler.remove(d)),
              selectedColor: Colors.red.withAlpha(100),
              backgroundColor: isAYT ? Colors.blue.withOpacity(0.2) : Colors.green.withOpacity(0.2),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 12),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 20),
        
        // Hafta bazlı çalışma stratejisi
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF21262D), borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Program Stratejisi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Text(
                "• İlk %25: Konu ağırlıklı temel çalışma\n"
                "• %25-50: Konu + soru dengeli\n"
                "• %50-75: Soru çözümü artırılıyor\n"
                "• %75-90: Deneme sınavları yoğunlaşıyor\n"
                "• Son %10: Yoğun deneme + tekrar",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _nextStep() {
    if (_currentStep < 3) {
      // 1. FAZ: AKADEMİK RÖNTGEN (Gatekeeper)
      if (_currentStep == 0 && VeriDeposu.akilliKonuTakibi.isEmpty) {
        _showGatekeeperDialog();
        return;
      }
      setState(() => _currentStep++);
    } else {
      if (_isAIMode) {
        _generateAIProgram();
      } else {
        _createManualProgram();
      }
    }
  }

  void _showGatekeeperDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("🧠 Akademik Röntgen Gerekli", style: TextStyle(color: Colors.white)),
        content: const Text(
          "AI Koç'un sana özel, verimli bir program hazırlayabilmesi için bitirdiğin konuları ve unutma düzeyini bilmesi gerekiyor.\n\nÖnce kısa bir Check-Up yapalım mı?",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Daha Sonra")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const AkademikRontgenScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text("Check-Up Başlat"),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAIProgram() async {
    setState(() => _isLoading = true);
    
    try {
      // Ogrenci profilini güncelle (Kapasite ve Zayıf Dersler)
      if (VeriDeposu.aktifOgrenci != null) {
        VeriDeposu.aktifOgrenci!.dailyHours = 6; // Şimdilik default
        VeriDeposu.aktifOgrenci!.weakSubjects = _zayifDersler;
      }

      final result = await GravityAI.akilliProgramOlustur(
        ogrenci: VeriDeposu.aktifOgrenci!,
        bitenKonular: VeriDeposu.akilliKonuTakibi,
      );

      if (result['haftalik_plan'] != null) {
        List<ProgramSatiri> tempProgram = [];
        int h = 1;
        for (var gunData in result['haftalik_plan']) {
          String gun = gunData['gun'] ?? "";
          List<dynamic> bloklar = gunData['bloklar'] ?? [];
          for (var blok in bloklar) {
            tempProgram.add(ProgramSatiri(
              hafta: h,
              gun: gun,
              saat: "09:00", // AI aralığı vermezse default
              ders: blok['ders'] ?? "",
              konu: blok['konu'] ?? "",
              calisma: blok['tip'] ?? "Ders",
              sure: blok['sure_dk'] ?? 45,
            ));
          }
        }
        setState(() {
          _program = tempProgram;
          // Strateji notunu SNACKBAR ile göster
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("📢 AI Koç Notu: ${result['strateji_notu']}"),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.purple,
          ));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AI Program oluşturulamadı.")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _createManualProgram() {
    setState(() => _isLoading = true);
    
    try {
      _program = _generateSmartProgram();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<ProgramSatiri> _generateSmartProgram() {
    final program = <ProgramSatiri>[];
    final saatListesi = _seciliSaatler.toList()..sort();
    final modBilgi = _calismaModlari[_calismaModu]!;
    final etutSure = modBilgi["calisma"]!;
    final molaSure = modBilgi["mola"]!;
    
    // Tüm konuları topla
    List<KonuItem> tumKonular = [];
    for (var ders in _tumDersler) {
      final konular = VeriDeposu.dersKonuAgirliklari[ders] ?? [];
      for (var k in konular) {
        if (!_bitmisKonular.contains(k.ad)) {
          tumKonular.add(KonuItem(ders: ders, konu: k.ad, agirlik: k.agirlik.toDouble()));
        }
      }
    }
    
    // Zayıf dersleri önceliklendir
    tumKonular.sort((a, b) {
      bool aZayif = _zayifDersler.contains(a.ders);
      bool bZayif = _zayifDersler.contains(b.ders);
      if (aZayif && !bZayif) return -1;
      if (!aZayif && bZayif) return 1;
      return b.agirlik.compareTo(a.agirlik);
    });
    
    int konuIndex = 0;
    bool haftasonuDenemeEklendi = false;
    
    for (int hafta = 1; hafta <= _programHaftasi; hafta++) {
      final calismaAgirliklari = _getCalismaAgirliklari(hafta);
      final calismaTurleri = calismaAgirliklari.keys.toList();
      
      for (var gun in _gunler) {
        if (_tatilGunleri.contains(gun)) continue;
        
        int gunlukEtut = _gunSureleri[gun] ?? 6;
        bool isHaftaSonu = gun == "Cumartesi" || gun == "Pazar";
        
        // Hafta sonu başında deneme sınavı resetle
        if (isHaftaSonu && gun == "Cumartesi") haftasonuDenemeEklendi = false;
        
        int dakikaTotal = 0;
        int saatIndex = 0;
        
        for (int i = 0; i < gunlukEtut && saatIndex < saatListesi.length; i++) {
          String ders, konu, calisma;
          int sure = etutSure;
          
          if (i == 0 && !isHaftaSonu) {
            // İlk etüt: Paragraf/Problem (30 dk)
            ders = _sinavTuru == "AYT" ? (_alan == "Sayısal" ? "AYT Matematik" : "AYT Edebiyat") : "TYT Türkçe";
            konu = ders.contains("Matematik") ? "Problemler" : "Paragraf";
            calisma = "Soru Çözümü";
            sure = 30;
          } else if (i == 1 && !isHaftaSonu) {
            // İkinci etüt
            ders = _sinavTuru == "AYT" ? "AYT Matematik" : "TYT Matematik";
            konu = "Problemler";
            calisma = "Soru Çözümü";
            sure = 30;
          } else if (isHaftaSonu && i == 0 && !haftasonuDenemeEklendi) {
            // Hafta sonu: 1 deneme sınavı
            ders = "Deneme Sınavı";
            konu = _sinavTuru;
            calisma = "Deneme Sınavı";
            sure = _sinavTuru == "TYT" ? 135 : 180; // TYT 2.25 saat, AYT 3 saat
            haftasonuDenemeEklendi = true;
          } else {
            // Diğer etütler: Konulardan sırayla
            if (tumKonular.isNotEmpty && konuIndex < tumKonular.length) {
              var konuItem = tumKonular[konuIndex % tumKonular.length];
              ders = konuItem.ders;
              konu = konuItem.konu;
              konuIndex++;
            } else {
              ders = _tumDersler[i % _tumDersler.length];
              konu = "Genel Tekrar";
            }
            
            // Haftaya göre çalışma türü seç
            int calismaIdx = (hafta + i) % calismaTurleri.length;
            calisma = calismaTurleri[calismaIdx];
          }
          
          // Saat hesaplama
          int baslangicSaat = saatListesi[saatIndex];
          int baslangicDakika = dakikaTotal % 60;
          
          program.add(ProgramSatiri(
            hafta: hafta,
            gun: gun,
            saat: "${baslangicSaat.toString().padLeft(2, '0')}:${baslangicDakika.toString().padLeft(2, '0')}",
            ders: ders,
            konu: konu,
            calisma: calisma,
            sure: sure,
          ));
          
          dakikaTotal += sure + molaSure;
          if (dakikaTotal >= 60) {
            saatIndex++;
            dakikaTotal = dakikaTotal % 60;
          }
        }
      }
    }
    
    return program;
  }

  Widget _buildProgramTable() {
    // Haftalara göre grupla
    Map<int, List<ProgramSatiri>> haftalar = {};
    for (var s in _program) {
      haftalar.putIfAbsent(s.hafta, () => []);
      haftalar[s.hafta]!.add(s);
    }
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF161B22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$_programHaftasi Haftalık Program", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("${_program.length} etüt • $_calismaModu", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() => _program.clear()),
                    icon: const Icon(Icons.refresh, color: Colors.orange),
                    label: const Text("Yeniden", style: TextStyle(color: Colors.orange)),
                  ),
                  ElevatedButton.icon(
                    onPressed: _saveProgram,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text("Kaydet"),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: haftalar.length,
            itemBuilder: (context, index) {
              int hafta = index + 1;
              var haftaProgram = haftalar[hafta] ?? [];
              
              return ExpansionTile(
                title: Text("Hafta $hafta", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text("${haftaProgram.length} etüt", style: TextStyle(color: Colors.grey.shade500)),
                collapsedBackgroundColor: const Color(0xFF161B22),
                backgroundColor: const Color(0xFF0D1117),
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFF21262D)),
                      dataRowColor: WidgetStateProperty.all(const Color(0xFF161B22)),
                      columns: const [
                        DataColumn(label: Text("Gün", style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text("Saat", style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text("Ders", style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text("Konu", style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text("Çalışma", style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text("Süre", style: TextStyle(color: Colors.white))),
                      ],
                      rows: haftaProgram.map((s) => DataRow(cells: [
                        DataCell(Text(s.gun, style: const TextStyle(color: Colors.white70))),
                        DataCell(Text(s.saat, style: const TextStyle(color: Colors.cyan))),
                        DataCell(Text(s.ders.replaceAll("TYT ", "").replaceAll("AYT ", ""), style: TextStyle(color: s.ders.startsWith("AYT") ? Colors.blue : Colors.green))),
                        DataCell(Text(s.konu, style: const TextStyle(color: Colors.white))),
                        DataCell(Text(s.calisma, style: const TextStyle(color: Colors.purple))),
                        DataCell(Text("${s.sure} dk", style: const TextStyle(color: Colors.amber))),
                      ])).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _saveProgram() {
    final gorevler = _program.map((s) => Gorev(
      id: const Uuid().v4(),
      hafta: s.hafta, gun: s.gun, saat: s.saat, ders: s.ders, konu: s.konu,
      aciklama: "${s.calisma} (${s.sure} dk)", yapildi: false,
    )).toList();
    VeriDeposu.programiKaydet(gorevler, _isAIMode ? "AI Program" : "Manuel Program");
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Program kaydedildi!"), backgroundColor: Colors.green));
    Navigator.pop(context);
  }
}

class ProgramSatiri {
  int hafta;
  String gun, saat, ders, konu, calisma;
  int sure;
  ProgramSatiri({this.hafta = 1, required this.gun, required this.saat, required this.ders, required this.konu, required this.calisma, this.sure = 45});
}

class KonuItem {
  String ders;
  String konu;
  double agirlik;
  KonuItem({required this.ders, required this.konu, required this.agirlik});
}
