import 'package:uuid/uuid.dart';
import 'akademik_veri.dart';

/// 🧠 NETX PROGRAM MOTORU
/// Akıllı programlama algoritması
/// - Ön koşul zinciri kontrolü (Topolojik sıralama)
/// - Okul saati filtresi
/// - Ders ağırlıklarına göre dağılım
/// - Tekrar aralıklı öğrenme (Spaced Repetition)
class ProgramMotoru {
  // Girdiler
  final Set<String> bitenKonular;
  final bool okulVarMi;
  final int programHaftaSayisi;
  final Map<String, int> gunlukCalismaSureleri; // {"Pazartesi": 6, ...}
  final Set<String> tatilGunleri;
  final List<String> zayifDersler;
  final String sinavTuru; // "TYT", "AYT", "TYT+AYT"
  final String alan; // "Sayısal", "Eşit Ağırlık", "Sözel"
  final Set<int> seciliSaatler;
  
  ProgramMotoru({
    required this.bitenKonular,
    this.okulVarMi = true,
    this.programHaftaSayisi = 12,
    Map<String, int>? gunlukCalismaSureleri,
    Set<String>? tatilGunleri,
    this.zayifDersler = const [],
    this.sinavTuru = "TYT+AYT",
    this.alan = "Sayısal",
    Set<int>? seciliSaatler,
  }) : gunlukCalismaSureleri = gunlukCalismaSureleri ?? {
         "Pazartesi": 6, "Salı": 6, "Çarşamba": 6, "Perşembe": 6, "Cuma": 6,
         "Cumartesi": 8, "Pazar": 8,
       },
       tatilGunleri = tatilGunleri ?? {},
       seciliSaatler = seciliSaatler ?? {8, 9, 10, 14, 15, 16, 19, 20, 21};

  static const List<String> _gunler = [
    "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"
  ];

  /// 🚀 ANA FONKSİYON: Akıllı program oluştur
  List<PlanliGorev> programOlustur() {
    final List<PlanliGorev> program = [];
    
    // 1. ADIM: Çalışılabilir konuları belirle (ZİNCİR KURALI)
    final List<Konu> calismaListesi = _akilliKonuSecimi();
    
    if (calismaListesi.isEmpty) {
      print("⚠️ Motor: Çalışılabilir konu bulunamadı!");
      return [];
    }
    
    print("✅ Motor: ${calismaListesi.length} konu programa ekleniyor");
    
    // 2. ADIM: Haftalık program oluştur
    int konuIndex = 0;
    final uuid = const Uuid();
    
    for (int hafta = 1; hafta <= programHaftaSayisi; hafta++) {
      // Haftaya göre çalışma stratejisi belirle
      final strateji = _haftaStratejisiBelirle(hafta);
      
      for (var gun in _gunler) {
        // Tatil günü kontrolü
        if (tatilGunleri.contains(gun)) continue;
        
        bool isHaftaSonu = gun == "Cumartesi" || gun == "Pazar";
        int gunlukEtutSayisi = gunlukCalismaSureleri[gun] ?? 6;
        
        // Müsait saatleri hesapla
        final musaitSaatler = _musaitSaatleriHesapla(isHaftaSonu);
        
        // Her etüt için görev oluştur
        for (int etut = 0; etut < gunlukEtutSayisi && etut < musaitSaatler.length; etut++) {
          PlanliGorev? gorev;
          
          // Özel durumlar
          if (etut == 0 && !isHaftaSonu) {
            // İlk etüt: Paragraf/Problem (30 dk - her gün)
            gorev = _ozelEtutOlustur(
              uuid: uuid, hafta: hafta, gun: gun, saat: musaitSaatler[etut],
              tip: "paragraf_problem",
            );
          } else if (isHaftaSonu && etut == 0 && hafta % 2 == 0) {
            // Her 2 haftada bir hafta sonu deneme sınavı
            gorev = _ozelEtutOlustur(
              uuid: uuid, hafta: hafta, gun: gun, saat: musaitSaatler[etut],
              tip: "deneme",
            );
          } else if (gun == "Pazar" && etut == gunlukEtutSayisi - 1) {
            // Pazar son etüt: Haftalık tekrar
            gorev = _ozelEtutOlustur(
              uuid: uuid, hafta: hafta, gun: gun, saat: musaitSaatler[etut],
              tip: "haftalik_tekrar",
            );
          } else {
            // Normal konu etüdü
            if (calismaListesi.isNotEmpty) {
              final konu = calismaListesi[konuIndex % calismaListesi.length];
              konuIndex++;
              
              gorev = PlanliGorev(
                id: uuid.v4(),
                hafta: hafta,
                gun: gun,
                saat: "${musaitSaatler[etut].toString().padLeft(2, '0')}:00",
                ders: konu.ders,
                konu: konu.ad,
                calismaTuru: strateji.calismaTuru,
                sureDakika: 45,
              );
            }
          }
          
          if (gorev != null) {
            program.add(gorev);
          }
        }
      }
    }
    
    print("✅ Motor: Toplam ${program.length} görev oluşturuldu");
    return program;
  }

  /// 🧠 AKILLI KONU SEÇİMİ (Topolojik Sıralama)
  List<Konu> _akilliKonuSecimi() {
    // Tüm müfredat konularını al
    final tumKonular = YKSMufredat.konulariGetir(sinavTuru: sinavTuru, alan: alan);
    
    List<Konu> calisabilirKonular = [];
    List<Konu> kilitlenenKonular = [];
    
    for (var konu in tumKonular) {
      // Zaten biten konuları çıkar
      if (_konuBittiMi(konu)) {
        continue;
      }
      
      // ÖN KOŞUL KONTROLÜ (ZİNCİR KURALI)
      if (OnKosulZinciri.calisilabilirMi(konu.ad, bitenKonular)) {
        calisabilirKonular.add(konu);
      } else {
        kilitlenenKonular.add(konu);
        print("🔒 Kilitli: ${konu.ad} → Önce '${OnKosulZinciri.onKosuluGetir(konu.ad)}' bitmeli");
      }
    }
    
    // Zayıf dersleri önceliklendir
    calisabilirKonular.sort((a, b) {
      bool aZayif = zayifDersler.contains(a.ders);
      bool bZayif = zayifDersler.contains(b.ders);
      
      if (aZayif && !bZayif) return -1;
      if (!aZayif && bZayif) return 1;
      
      // Sonra ağırlığa göre sırala (yüksekten düşüğe)
      return b.agirlik.compareTo(a.agirlik);
    });
    
    print("📊 Motor: ${calisabilirKonular.length} çalışılabilir, ${kilitlenenKonular.length} kilitli konu");
    return calisabilirKonular;
  }

  /// Konu bitti mi?
  bool _konuBittiMi(Konu konu) {
    return bitenKonular.any((b) => 
      b == konu.ad || 
      b == konu.id || 
      b.endsWith("-${konu.ad}") ||
      b.contains(konu.ad)
    );
  }

  /// 📅 Müsait saatleri hesapla (okul filtresi ile)
  List<int> _musaitSaatleriHesapla(bool haftaSonuMu) {
    List<int> musait = [];
    
    for (var saat in seciliSaatler.toList()..sort()) {
      bool okuldaMi = OkulSaatFiltresi.okulSaatiMi(
        saat, 
        okulVarMi: okulVarMi, 
        haftaSonuMu: haftaSonuMu,
      );
      
      if (!okuldaMi) {
        musait.add(saat);
      }
    }
    
    return musait;
  }

  /// 📊 Hafta stratejisi belirle
  _HaftaStrateji _haftaStratejisiBelirle(int hafta) {
    double ilerleme = hafta / programHaftaSayisi;
    
    if (ilerleme >= 0.9) {
      // Son %10: Yoğun deneme + tekrar
      return _HaftaStrateji(
        calismaTuru: "Soru Çözümü",
        denemeOrani: 0.35,
        konuOrani: 0.15,
        soruOrani: 0.50,
      );
    } else if (ilerleme >= 0.75) {
      // %75-90: Deneme ağırlıklı
      return _HaftaStrateji(
        calismaTuru: "Soru Çözümü",
        denemeOrani: 0.25,
        konuOrani: 0.25,
        soruOrani: 0.50,
      );
    } else if (ilerleme >= 0.5) {
      // %50-75: Dengeli
      return _HaftaStrateji(
        calismaTuru: "Konu + Soru",
        denemeOrani: 0.15,
        konuOrani: 0.35,
        soruOrani: 0.50,
      );
    } else if (ilerleme >= 0.25) {
      // %25-50: Konu ağırlıklı
      return _HaftaStrateji(
        calismaTuru: "Konu Anlatımı",
        denemeOrani: 0.10,
        konuOrani: 0.50,
        soruOrani: 0.40,
      );
    } else {
      // İlk %25: Temel konu çalışması
      return _HaftaStrateji(
        calismaTuru: "Konu Anlatımı",
        denemeOrani: 0.05,
        konuOrani: 0.60,
        soruOrani: 0.35,
      );
    }
  }

  /// 🎯 Özel etüt oluştur (Paragraf/Problem, Deneme, Haftalık Tekrar)
  PlanliGorev _ozelEtutOlustur({
    required Uuid uuid,
    required int hafta,
    required String gun,
    required int saat,
    required String tip,
  }) {
    switch (tip) {
      case "paragraf_problem":
        bool sayisal = alan == "Sayısal" || sinavTuru == "TYT";
        return PlanliGorev(
          id: uuid.v4(),
          hafta: hafta,
          gun: gun,
          saat: "${saat.toString().padLeft(2, '0')}:00",
          ders: sayisal ? "Matematik" : "Türkçe",
          konu: sayisal ? "Problemler" : "Paragraf",
          calismaTuru: "Soru Çözümü",
          sureDakika: 30,
        );
        
      case "deneme":
        int sure = sinavTuru == "TYT" ? 135 : 180;
        return PlanliGorev(
          id: uuid.v4(),
          hafta: hafta,
          gun: gun,
          saat: "${saat.toString().padLeft(2, '0')}:00",
          ders: "Deneme Sınavı",
          konu: sinavTuru,
          calismaTuru: "Deneme Sınavı",
          sureDakika: sure,
        );
        
      case "haftalik_tekrar":
        return PlanliGorev(
          id: uuid.v4(),
          hafta: hafta,
          gun: gun,
          saat: "${saat.toString().padLeft(2, '0')}:00",
          ders: "Genel",
          konu: "Hafta $hafta Tekrarı",
          calismaTuru: "Tekrar",
          sureDakika: 60,
        );
        
      default:
        return PlanliGorev(
          id: uuid.v4(),
          hafta: hafta,
          gun: gun,
          saat: "${saat.toString().padLeft(2, '0')}:00",
          ders: "Genel",
          konu: "Çalışma",
          calismaTuru: "Konu Anlatımı",
          sureDakika: 45,
        );
    }
  }
}

/// Hafta stratejisi veri yapısı
class _HaftaStrateji {
  final String calismaTuru;
  final double denemeOrani;
  final double konuOrani;
  final double soruOrani;
  
  _HaftaStrateji({
    required this.calismaTuru,
    required this.denemeOrani,
    required this.konuOrani,
    required this.soruOrani,
  });
}
