/// 🧠 NETX AKADEMİK VERİ TABANI
/// Tüm YKS müfredatı, ön koşul zincirleri ve konu ağırlıkları
/// Bu dosya sistemin "Anayasası"dır - Değişiklik yapılırken dikkatli olunmalı!

library akademik_veri;

// =============================================================================
// 1. TEMEL VERİ YAPILARI
// =============================================================================

/// Tek bir konu
class Konu {
  final String ad;
  final String ders;
  final String kategori; // TYT, AYT
  final double agirlik;  // Sınavdaki önem (1.0 - 5.0)
  final int tahminiSure; // Dakika cinsinden çalışma süresi
  
  const Konu({
    required this.ad,
    required this.ders,
    this.kategori = "TYT",
    this.agirlik = 3.0,
    this.tahminiSure = 60,
  });
  
  /// Benzersiz ID (Ders-Konu formatında)
  String get id => "$ders-$ad";
}

/// Program satırı (Görev)
class PlanliGorev {
  final String id;
  final int hafta;
  final String gun;
  final String saat;
  final String ders;
  final String konu;
  final String calismaTuru; // "Konu Anlatımı", "Soru Çözümü", "Tekrar", "Deneme"
  final int sureDakika;
  bool yapildi;
  
  PlanliGorev({
    required this.id,
    required this.hafta,
    required this.gun,
    required this.saat,
    required this.ders,
    required this.konu,
    required this.calismaTuru,
    this.sureDakika = 45,
    this.yapildi = false,
  });
}

// =============================================================================
// 2. ÖN KOŞUL ZİNCİRİ (The Chain) - SİSTEMİN KALBİ
// =============================================================================

/// Hangi konu, hangi konuyu bitirmeden çalışılamaz?
/// Key: Çocuk Konu, Value: Anne Konu (Önce bitmesi gereken)
class OnKosulZinciri {
  static const Map<String, String> zincir = {
    // === MATEMATİK ===
    // Temel zincir
    "Birinci Dereceden Denklemler": "Cebirsel İfadeler",
    "İkinci Dereceden Denklemler": "Birinci Dereceden Denklemler",
    "Eşitsizlikler": "Denklemler",
    "Mutlak Değer": "Eşitsizlikler",
    
    // Fonksiyonlar zinciri (Kritik!)
    "Fonksiyonlar": "Küme İşlemleri",
    "Polinomlar": "Fonksiyonlar",
    "İkinci Dereceden Fonksiyonlar": "Polinomlar",
    
    // Limit-Türev-İntegral zinciri (EN KRİTİK)
    "Limit": "Fonksiyonlar",
    "Süreklilik": "Limit",
    "Türev": "Limit",
    "Türev Uygulamaları": "Türev",
    "İntegral": "Türev",
    "Belirli İntegral": "İntegral",
    
    // Logaritma zinciri
    "Logaritma": "Üslü Sayılar",
    "Üstel ve Logaritmik Fonksiyonlar": "Logaritma",
    
    // Trigonometri zinciri
    "Trigonometrik Fonksiyonlar": "Trigonometri",
    "Trigonometrik Denklemler": "Trigonometrik Fonksiyonlar",
    
    // Geometri zinciri
    "Analitik Geometri": "Doğruda Açılar",
    "Çember Analitiği": "Analitik Geometri",
    "Konikler": "Çember Analitiği",
    
    // === FİZİK ===
    "Kuvvet ve Hareket": "Vektörler",
    "Dinamik": "Kuvvet ve Hareket",
    "İş ve Enerji": "Dinamik",
    "Atışlar": "Kuvvet ve Hareket",
    "Dairesel Hareket": "Atışlar",
    "Basit Harmonik Hareket": "Dairesel Hareket",
    "Momentum": "Dinamik",
    "Tork ve Denge": "Momentum",
    
    // Elektrik zinciri
    "Elektriksel Alan": "Elektrik Yükleri",
    "Elektrik Potansiyeli": "Elektriksel Alan",
    "Kondansatörler": "Elektrik Potansiyeli",
    "Elektrik Akımı": "Kondansatörler",
    "Manyetizma": "Elektrik Akımı",
    "İndüksiyon": "Manyetizma",
    "Alternatif Akım": "İndüksiyon",
    
    // Optik zinciri
    "Dalga Mekaniği": "Basit Harmonik Hareket",
    "Geometrik Optik": "Işık ve Gölge",
    "Aynalar": "Geometrik Optik",
    "Mercekler": "Aynalar",
    
    // Modern Fizik
    "Özel Görelilik": "Dalga Mekaniği",
    "Atom Fiziği": "Işık Teorileri",
    "Çekirdek Fiziği": "Atom Fiziği",
    
    // === KİMYA ===
    "Periyodik Tablo Özellikleri": "Atom Modelleri",
    "Kimyasal Bağlar": "Periyodik Tablo Özellikleri",
    "Molekül Geometrisi": "Kimyasal Bağlar",
    "Mol Kavramı": "Bileşikler",
    "Kimyasal Tepkimeler": "Mol Kavramı",
    "Tepkimelerde Denge": "Kimyasal Tepkimeler",
    "Asit-Baz": "Tepkimelerde Denge",
    "Çözünürlük Dengesi": "Asit-Baz",
    "Elektrokimya": "Çözünürlük Dengesi",
    
    // Organik Kimya zinciri
    "Organik Bileşikler": "Karbon Kimyası",
    "Fonksiyonel Gruplar": "Organik Bileşikler",
    "Polimerler": "Fonksiyonel Gruplar",
    
    // === BİYOLOJİ ===
    "DNA ve RNA": "Hücre ve Organeller",
    "Protein Sentezi": "DNA ve RNA",
    "Mayoz Bölünme": "Mitoz Bölünme",
    "Mendel Genetiği": "Mayoz Bölünme",
    "Mutasyonlar": "Protein Sentezi",
    "Genetik Mühendisliği": "Mutasyonlar",
    "Evrim": "Genetik Mühendisliği",
    
    // Fizyoloji
    "Sindirim Sistemi": "Temel Biyokimya",
    "Dolaşım Sistemi": "Sindirim Sistemi",
    "Solunum Sistemi": "Dolaşım Sistemi",
    "Boşaltım Sistemi": "Solunum Sistemi",
    "Sinir Sistemi": "Boşaltım Sistemi",
    "Endokrin Sistem": "Sinir Sistemi",
    
    // Bitki Biyolojisi
    "Fotosentez": "Bitki Hücresi",
    "Bitki Hormonları": "Fotosentez",
    
    // === TÜRKÇE / EDEBİYAT ===
    "Cümlede Anlam": "Sözcükte Anlam",
    "Paragraf": "Cümlede Anlam",
    "Fiilimsi": "Fiiller",
    "Fiil Çatısı": "Fiilimsi",
    "Cümlenin Ögeleri": "Fiil Çatısı",
    "Cümle Türleri": "Cümlenin Ögeleri",
    
    // Edebiyat
    "Halk Edebiyatı": "Türk Edebiyatına Giriş",
    "Divan Edebiyatı": "Halk Edebiyatı",
    "Tanzimat Dönemi": "Divan Edebiyatı",
    "Servet-i Fünun": "Tanzimat Dönemi",
    "Milli Edebiyat": "Servet-i Fünun",
    "Cumhuriyet Dönemi": "Milli Edebiyat",
  };
  
  /// Bir konunun ön koşulu var mı?
  static bool onKosuluVarMi(String konuAdi) => zincir.containsKey(konuAdi);
  
  /// Bir konunun ön koşulunu getir (yoksa null)
  static String? onKosuluGetir(String konuAdi) => zincir[konuAdi];
  
  /// Bir konunun TÜM ön koşullarını sırayla getir (recursive)
  static List<String> tumOnKosullariGetir(String konuAdi) {
    List<String> kosullar = [];
    String? mevcut = konuAdi;
    
    while (mevcut != null && zincir.containsKey(mevcut)) {
      String onKosul = zincir[mevcut]!;
      kosullar.add(onKosul);
      mevcut = onKosul;
    }
    
    return kosullar.reversed.toList(); // En temelden başlayarak döndür
  }
  
  /// Konu çalışılabilir mi? (Tüm ön koşullar bitti mi?)
  static bool calisilabilirMi(String konuAdi, Set<String> bitenKonular) {
    String? onKosul = zincir[konuAdi];
    
    if (onKosul == null) {
      // Ön koşulu yok, doğrudan çalışılabilir
      return true;
    }
    
    // Ön koşul bitti mi kontrol et
    return bitenKonular.any((k) => 
      k == onKosul || 
      k.endsWith("-$onKosul") || 
      k.contains(onKosul)
    );
  }
}

// =============================================================================
// 3. OKUL SAATİ FİLTRESİ
// =============================================================================

class OkulSaatFiltresi {
  /// Varsayılan okul saatleri: 08:00 - 16:00
  static const int varsayilanBaslangic = 8;
  static const int varsayilanBitis = 16;
  
  /// Bu saat okul saati mi?
  static bool okulSaatiMi(int saat, {bool okulVarMi = true, bool haftaSonuMu = false}) {
    if (!okulVarMi) return false; // Okula gitmiyorsa filtre yok
    if (haftaSonuMu) return false; // Hafta sonu okul yok
    
    return saat >= varsayilanBaslangic && saat < varsayilanBitis;
  }
  
  /// Müsait saatleri getir
  static List<int> musaitSaatleriGetir({
    required bool okulVarMi,
    required bool haftaSonuMu,
    int sabahBaslangic = 6,
    int geceKaydi = 23,
  }) {
    List<int> musaitSaatler = [];
    
    for (int saat = sabahBaslangic; saat <= geceKaydi; saat++) {
      if (!okulSaatiMi(saat, okulVarMi: okulVarMi, haftaSonuMu: haftaSonuMu)) {
        musaitSaatler.add(saat);
      }
    }
    
    return musaitSaatler;
  }
}

// =============================================================================
// 4. TYT/AYT KONU LİSTESİ VE AĞIRLIKLARI
// =============================================================================

class YKSMufredat {
  /// TYT Konuları (Ortak)
  static const List<Konu> tytTurkce = [
    Konu(ad: "Sözcükte Anlam", ders: "TYT Türkçe", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Cümlede Anlam", ders: "TYT Türkçe", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Paragraf", ders: "TYT Türkçe", agirlik: 5.0, tahminiSure: 60),
    Konu(ad: "Ses Bilgisi", ders: "TYT Türkçe", agirlik: 2.0, tahminiSure: 30),
    Konu(ad: "Yazım Kuralları", ders: "TYT Türkçe", agirlik: 3.0, tahminiSure: 30),
    Konu(ad: "Noktalama İşaretleri", ders: "TYT Türkçe", agirlik: 3.0, tahminiSure: 30),
    Konu(ad: "Sözcükte Yapı", ders: "TYT Türkçe", agirlik: 2.0, tahminiSure: 30),
    Konu(ad: "İsimler", ders: "TYT Türkçe", agirlik: 2.0, tahminiSure: 30),
    Konu(ad: "Sıfatlar", ders: "TYT Türkçe", agirlik: 2.0, tahminiSure: 30),
    Konu(ad: "Zamirler", ders: "TYT Türkçe", agirlik: 2.0, tahminiSure: 30),
    Konu(ad: "Zarflar", ders: "TYT Türkçe", agirlik: 2.0, tahminiSure: 30),
    Konu(ad: "Edat-Bağlaç-Ünlem", ders: "TYT Türkçe", agirlik: 2.0, tahminiSure: 30),
    Konu(ad: "Fiiller", ders: "TYT Türkçe", agirlik: 3.0, tahminiSure: 45),
    Konu(ad: "Ek Fiil", ders: "TYT Türkçe", agirlik: 2.0, tahminiSure: 30),
    Konu(ad: "Fiilimsi", ders: "TYT Türkçe", agirlik: 3.0, tahminiSure: 45),
    Konu(ad: "Fiil Çatısı", ders: "TYT Türkçe", agirlik: 2.0, tahminiSure: 30),
    Konu(ad: "Cümlenin Ögeleri", ders: "TYT Türkçe", agirlik: 3.0, tahminiSure: 45),
    Konu(ad: "Cümle Türleri", ders: "TYT Türkçe", agirlik: 3.0, tahminiSure: 45),
    Konu(ad: "Anlatım Bozuklukları", ders: "TYT Türkçe", agirlik: 4.0, tahminiSure: 45),
  ];
  
  static const List<Konu> tytMatematik = [
    Konu(ad: "Temel Kavramlar", ders: "TYT Matematik", agirlik: 3.0, tahminiSure: 30),
    Konu(ad: "Sayı Basamakları", ders: "TYT Matematik", agirlik: 3.0, tahminiSure: 30),
    Konu(ad: "Bölme ve Bölünebilme", ders: "TYT Matematik", agirlik: 3.0, tahminiSure: 45),
    Konu(ad: "EBOB - EKOK", ders: "TYT Matematik", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Rasyonel Sayılar", ders: "TYT Matematik", agirlik: 3.0, tahminiSure: 45),
    Konu(ad: "Basit Eşitsizlikler", ders: "TYT Matematik", agirlik: 3.0, tahminiSure: 30),
    Konu(ad: "Mutlak Değer", ders: "TYT Matematik", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Üslü Sayılar", ders: "TYT Matematik", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Köklü Sayılar", ders: "TYT Matematik", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Çarpanlara Ayırma", ders: "TYT Matematik", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Oran Orantı", ders: "TYT Matematik", agirlik: 5.0, tahminiSure: 60),
    Konu(ad: "Problemler", ders: "TYT Matematik", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "Küme İşlemleri", ders: "TYT Matematik", agirlik: 3.0, tahminiSure: 45),
    Konu(ad: "Fonksiyonlar", ders: "TYT Matematik", agirlik: 5.0, tahminiSure: 60),
    Konu(ad: "Polinomlar", ders: "TYT Matematik", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "İkinci Dereceden Denklemler", ders: "TYT Matematik", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Permütasyon", ders: "TYT Matematik", agirlik: 3.0, tahminiSure: 45),
    Konu(ad: "Kombinasyon", ders: "TYT Matematik", agirlik: 3.0, tahminiSure: 45),
    Konu(ad: "Olasılık", ders: "TYT Matematik", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "İstatistik", ders: "TYT Matematik", agirlik: 3.0, tahminiSure: 45),
  ];
  
  static const List<Konu> tytGeometri = [
    Konu(ad: "Temel Kavramlar", ders: "TYT Geometri", agirlik: 3.0, tahminiSure: 30),
    Konu(ad: "Doğruda Açılar", ders: "TYT Geometri", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Üçgende Açılar", ders: "TYT Geometri", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Üçgende Alan", ders: "TYT Geometri", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Üçgende Benzerlik", ders: "TYT Geometri", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Özel Üçgenler", ders: "TYT Geometri", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Çokgenler", ders: "TYT Geometri", agirlik: 3.0, tahminiSure: 45),
    Konu(ad: "Dörtgenler", ders: "TYT Geometri", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Çember", ders: "TYT Geometri", agirlik: 5.0, tahminiSure: 60),
    Konu(ad: "Daire", ders: "TYT Geometri", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Katı Cisimler", ders: "TYT Geometri", agirlik: 3.0, tahminiSure: 45),
  ];
  
  static const List<Konu> aytMatematik = [
    Konu(ad: "Fonksiyonlar İleri", ders: "AYT Matematik", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "Logaritma", ders: "AYT Matematik", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Diziler", ders: "AYT Matematik", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "Limit", ders: "AYT Matematik", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "Türev", ders: "AYT Matematik", kategori: "AYT", agirlik: 5.0, tahminiSure: 120),
    Konu(ad: "Türev Uygulamaları", ders: "AYT Matematik", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "İntegral", ders: "AYT Matematik", kategori: "AYT", agirlik: 5.0, tahminiSure: 120),
    Konu(ad: "Trigonometri", ders: "AYT Matematik", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "Analitik Geometri", ders: "AYT Matematik", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Konikler", ders: "AYT Matematik", kategori: "AYT", agirlik: 3.0, tahminiSure: 45),
  ];
  
  static const List<Konu> aytFizik = [
    Konu(ad: "Vektörler", ders: "AYT Fizik", kategori: "AYT", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Kuvvet ve Hareket", ders: "AYT Fizik", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "Dinamik", ders: "AYT Fizik", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "İş ve Enerji", ders: "AYT Fizik", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "Atışlar", ders: "AYT Fizik", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Momentum", ders: "AYT Fizik", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Elektrik Yükleri", ders: "AYT Fizik", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Elektriksel Alan", ders: "AYT Fizik", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Elektrik Potansiyeli", ders: "AYT Fizik", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Kondansatörler", ders: "AYT Fizik", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Manyetizma", ders: "AYT Fizik", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "İndüksiyon", ders: "AYT Fizik", kategori: "AYT", agirlik: 3.0, tahminiSure: 45),
    Konu(ad: "Dalga Mekaniği", ders: "AYT Fizik", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Atom Fiziği", ders: "AYT Fizik", kategori: "AYT", agirlik: 3.0, tahminiSure: 45),
  ];
  
  static const List<Konu> aytKimya = [
    Konu(ad: "Atom Modelleri", ders: "AYT Kimya", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Periyodik Tablo Özellikleri", ders: "AYT Kimya", kategori: "AYT", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Kimyasal Bağlar", ders: "AYT Kimya", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "Mol Kavramı", ders: "AYT Kimya", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "Kimyasal Tepkimeler", ders: "AYT Kimya", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "Tepkimelerde Denge", ders: "AYT Kimya", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "Asit-Baz", ders: "AYT Kimya", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "Elektrokimya", ders: "AYT Kimya", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Karbon Kimyası", ders: "AYT Kimya", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Organik Bileşikler", ders: "AYT Kimya", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
  ];
  
  static const List<Konu> aytBiyoloji = [
    Konu(ad: "Hücre ve Organeller", ders: "AYT Biyoloji", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "DNA ve RNA", ders: "AYT Biyoloji", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "Protein Sentezi", ders: "AYT Biyoloji", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Mitoz Bölünme", ders: "AYT Biyoloji", kategori: "AYT", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Mayoz Bölünme", ders: "AYT Biyoloji", kategori: "AYT", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Mendel Genetiği", ders: "AYT Biyoloji", kategori: "AYT", agirlik: 5.0, tahminiSure: 90),
    Konu(ad: "Sindirim Sistemi", ders: "AYT Biyoloji", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Dolaşım Sistemi", ders: "AYT Biyoloji", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Solunum Sistemi", ders: "AYT Biyoloji", kategori: "AYT", agirlik: 4.0, tahminiSure: 45),
    Konu(ad: "Sinir Sistemi", ders: "AYT Biyoloji", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Fotosentez", ders: "AYT Biyoloji", kategori: "AYT", agirlik: 4.0, tahminiSure: 60),
    Konu(ad: "Evrim", ders: "AYT Biyoloji", kategori: "AYT", agirlik: 3.0, tahminiSure: 45),
  ];
  
  /// Tüm konuları getir (sınav türü ve alana göre)
  static List<Konu> konulariGetir({
    required String sinavTuru, // "TYT", "AYT", "TYT+AYT"
    String alan = "Sayısal",  // "Sayısal", "Eşit Ağırlık", "Sözel"
  }) {
    List<Konu> konular = [];
    
    if (sinavTuru == "TYT" || sinavTuru == "TYT+AYT") {
      konular.addAll(tytTurkce);
      konular.addAll(tytMatematik);
      konular.addAll(tytGeometri);
    }
    
    if ((sinavTuru == "AYT" || sinavTuru == "TYT+AYT") && alan == "Sayısal") {
      konular.addAll(aytMatematik);
      konular.addAll(aytFizik);
      konular.addAll(aytKimya);
      konular.addAll(aytBiyoloji);
    }
    
    // Eşit Ağırlık ve Sözel için de eklenebilir...
    
    return konular;
  }
}
