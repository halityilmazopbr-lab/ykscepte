import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'randevu_models.dart';
import 'kurum_models.dart';

class VeriDeposu {
  static late SharedPreferences _prefs;
  static List<Gorev> kayitliProgram = [];
  static List<DenemeSonucu> denemeListesi = [];
  static List<PdfDeneme> kurumsalDenemeler = [];
  static List<KayitliProgramGecmisi> programArsivi = [];
  static List<SoruCozumKaydi> soruCozumListesi = [];
  static Map<String, bool> tamamlananKonular = {};
  static List<Rozet> tumRozetler = [];
  static List<HataDefteriSoru> hataDefteriListesi = [];
  static List<KonuTamamlama> akilliKonuTakibi = []; // Akademik Röntgen verileri
  
  // GÜNLÜK TAKİP SİSTEMİ
  static Map<String, Map<String, bool>> gunlukTakipDurumlari = {}; // "2024-12-25": {"09:00-Matematik": true}
  static Ogrenci? aktifOgrenci;
  
  // RANDEVU SİSTEMİ
  static Map<String, Map<int, Map<String, String>>> ogretmenMusaitlikleri = {};
  // Key: ogretmenId, Value: {gunIndex: {saat: durum}}
  static List<RandevuBildirimi> randevuBildirimleri = [];
  
  // KURUM & YOKLAMA SİSTEMİ
  static Kurum? aktifKurum;
  static List<YoklamaKaydi> yoklamaKayitlari = [];
  static List<Kurum> kurumlar = [
    Kurum(
      id: "kurum1",
      ad: "Bayburt Fen Dershanesi",
      adres: "Bayburt Merkez",
      latitude: 40.2565,
      longitude: 40.2256,
      yaricapMetre: 100,
    ),
  ];
  static List<KurumYoneticisi> kurumYoneticileri = [
    KurumYoneticisi(
      id: "kurum1",
      kurumId: "kurum1",
      ad: "Müdür Ahmet Yıldız",
      sifre: "123456",
    ),
  ];
  static List<KurumDuyuru> kurumDuyurulari = [];

  static const List<String> aktiviteler = [
    "Konu Çalışma",
    "Soru Çözümü",
    "Tekrar",
    "Deneme",
    "Video İzle",
    "Konu + Soru",
    "Özet Çıkarma",
    "Fasikül Bitirme",
    "MEB Kitabı Okuma"
  ];

  static const List<String> calismaStilleri = [
    "30+5 (30 Dk Ders, 5 Dk Mola)",
    "35+5 (35 Dk Ders, 5 Dk Mola)",
    "40+5 (40 Dk Ders, 5 Dk Mola)",
    "45+5 (45 Dk Ders, 5 Dk Mola)",
    "50+5 (50 Dk Ders, 5 Dk Mola)",
    "60+10 (60 Dk Ders, 10 Dk Mola)",
    "Pomodoro (25+5+25+5+25+30)"
  ];

  static List<Ogrenci> ogrenciler = [
    Ogrenci(
        id: "101",
        tcNo: "11111111111",
        sifre: "123456",
        ad: "Ahmet Yılmaz",
        sinif: "12-A",
        puan: 1250,
        atananOgretmenId: "t1",
        fotoUrl: "",
        girisSayisi: 45,
        hedefUniversite: "Boğaziçi",
        hedefBolum: "Bilgisayar",
        hedefPuan: 520,
        gunlukSeri: 5,
        kurumKodu: "kurum1", // KURUMSAL ÖĞRENCİ - Dersteyim ve diğer özellikleri görebilir
    ),
    Ogrenci(
        id: "102",
        tcNo: "22222222222",
        sifre: "123456",
        ad: "Ayşe Demir",
        sinif: "12-B",
        puan: 2400,
        atananOgretmenId: "t1",
        fotoUrl: "",
        girisSayisi: 82,
        hedefUniversite: "İstanbul",
        hedefBolum: "Hukuk",
        hedefPuan: 460,
        gunlukSeri: 12),
  ];
  static List<Ogretmen> ogretmenler = [
    Ogretmen(
        id: "t1",
        tcNo: "33333333333",
        sifre: "123456",
        ad: "Mustafa Hoca",
        brans: "Matematik"),
    Ogretmen(
        id: "t2",
        tcNo: "44444444444",
        sifre: "123456",
        ad: "Elif Hoca",
        brans: "Edebiyat"),
  ];
  static List<OkulDersi> okulNotlari = [
    OkulDersi(ad: "Matematik", yazili1: 60),
  ];
  static List<Gorev> odevler = [
    Gorev(
        id: "task_1",
        hafta: 1,
        gun: "Pazartesi",
        saat: "19:00",
        ders: "Matematik",
        konu: "Fonksiyonlar",
        aciklama: "Öğretmen Ödevi: 50 soru çöz",
        yapildi: false)
  ];

  // --- TAM VE EKSİKSİZ MÜFREDAT LİSTESİ ---
  static final Map<String, List<KonuDetay>> dersKonuAgirliklari = {
    // TYT
    "TYT Türkçe": [
      KonuDetay("Sözcükte Anlam", 3),
      KonuDetay("Cümlede Anlam", 3),
      KonuDetay("Paragraf", 25),
      KonuDetay("Ses Bilgisi", 1),
      KonuDetay("Yazım Kuralları", 2),
      KonuDetay("Noktalama İşaretleri", 2),
      KonuDetay("Sözcükte Yapı", 1),
      KonuDetay("İsimler", 1),
      KonuDetay("Sıfatlar", 1),
      KonuDetay("Zamirler", 1),
      KonuDetay("Zarflar", 1),
      KonuDetay("Edat-Bağlaç-Ünlem", 1),
      KonuDetay("Fiiller", 1),
      KonuDetay("Ek Fiil", 1),
      KonuDetay("Fiilimsi", 1),
      KonuDetay("Fiil Çatısı", 1),
      KonuDetay("Cümlenin Ögeleri", 1),
      KonuDetay("Cümle Türleri", 1),
      KonuDetay("Anlatım Bozuklukları", 1)
    ],
    "TYT Matematik": [
      KonuDetay("Temel Kavramlar", 2),
      KonuDetay("Sayı Basamakları", 1),
      KonuDetay("Bölme ve Bölünebilme", 1),
      KonuDetay("EBOB - EKOK", 1),
      KonuDetay("Rasyonel Sayılar", 1),
      KonuDetay("Basit Eşitsizlikler", 1),
      KonuDetay("Mutlak Değer", 1),
      KonuDetay("Üslü Sayılar", 1),
      KonuDetay("Köklü Sayılar", 1),
      KonuDetay("Çarpanlara Ayırma", 1),
      KonuDetay("Oran Orantı", 1),
      KonuDetay("Denklem Çözme", 1),
      KonuDetay("Sayı Problemleri", 4),
      KonuDetay("Kesir Problemleri", 1),
      KonuDetay("Yaş Problemleri", 1),
      KonuDetay("İşçi Problemleri", 1),
      KonuDetay("Hareket Problemleri", 1),
      KonuDetay("Yüzde Kar Zarar Problemleri", 2),
      KonuDetay("Karışım Problemleri", 1),
      KonuDetay("Grafik Problemleri", 1),
      KonuDetay("Rutin Olmayan Problemler", 1),
      KonuDetay("Kümeler", 1),
      KonuDetay("Mantık", 1),
      KonuDetay("Fonksiyonlar", 2),
      KonuDetay("Polinomlar", 1),
      KonuDetay("2. Dereceden Denklemler", 1),
      KonuDetay("Karmaşık Sayılar", 1),
      KonuDetay("Permütasyon", 1),
      KonuDetay("Kombinasyon", 1),
      KonuDetay("Binom", 1),
      KonuDetay("Olasılık", 1),
      KonuDetay("Veri İstatistik", 1)
    ],
    "TYT Geometri": [
      KonuDetay("Doğruda Açılar", 1),
      KonuDetay("Üçgende Açılar", 1),
      KonuDetay("Dik ve Özel Üçgenler", 1),
      KonuDetay("İkizkenar ve Eşkenar Üçgen", 1),
      KonuDetay("Açıortay", 1),
      KonuDetay("Kenarortay", 1),
      KonuDetay("Eşlik ve Benzerlik", 1),
      KonuDetay("Üçgende Alan", 1),
      KonuDetay("Açı-Kenar Bağıntıları", 1),
      KonuDetay("Çokgenler", 1),
      KonuDetay("Dörtgenler", 1),
      KonuDetay("Yamuk", 1),
      KonuDetay("Paralelkenar", 1),
      KonuDetay("Eşkenar Dörtgen", 1),
      KonuDetay("Dikdörtgen", 1),
      KonuDetay("Kare", 1),
      KonuDetay("Yamuk", 1),
      KonuDetay("Çember ve Daire", 2),
      KonuDetay("Analitik Geometri", 1),
      KonuDetay("Katı Cisimler", 2)
    ],
    // --- TYT FEN ---
    "TYT Fizik": [
      KonuDetay("Fizik Bilimine Giriş", 1),
      KonuDetay("Madde ve Özellikleri", 1),
      KonuDetay("Hareket ve Kuvvet", 1),
      KonuDetay("Enerji", 1),
      KonuDetay("Isı ve Sıcaklık", 1),
      KonuDetay("Elektrostatik", 1),
      KonuDetay("Elektrik ve Manyetizma", 1),
      KonuDetay("Basınç ve Kaldırma Kuvveti", 1),
      KonuDetay("Dalgalar", 1),
      KonuDetay("Optik", 2),
    ],
    "TYT Kimya": [
      KonuDetay("Kimya Bilimi", 1),
      KonuDetay("Atom ve Periyodik Sistem", 1),
      KonuDetay("Kimyasal Türler Arası Etkileşimler", 1),
      KonuDetay("Maddenin Halleri", 1),
      KonuDetay("Doğa ve Kimya", 1),
      KonuDetay("Kimyanın Temel Kanunları", 1),
      KonuDetay("Karışımlar", 1),
      KonuDetay("Asitler, Bazlar ve Tuzlar", 1),
      KonuDetay("Kimya Her Yerde", 1),
    ],
    "TYT Biyoloji": [
      KonuDetay("Yaşam Bilimi Biyoloji", 1),
      KonuDetay("Hücre", 1),
      KonuDetay("Canlılar Dünyası", 1),
      KonuDetay("Hücre Bölünmeleri", 1),
      KonuDetay("Kalıtım", 1),
      KonuDetay("Ekosistem Ekolojisi", 1),
    ],
    // --- TYT SOSYAL ---
    "TYT Tarih": [
      KonuDetay("Tarih ve Zaman", 1),
      KonuDetay("İnsanlığın İlk Dönemleri", 1),
      KonuDetay("Orta Çağ'da Dünya", 1),
      KonuDetay("İlk ve Orta Çağlarda Türk Dünyası", 1),
      KonuDetay("İslam Medeniyetinin Doğuşu", 1),
      KonuDetay("Türklerin İslamiyet'i Kabulü", 1),
      KonuDetay("Yerleşme ve Devletleşme Sürecinde Selçuklu", 1),
      KonuDetay("Beylikten Devlete Osmanlı", 1),
      KonuDetay("Dünya Gücü Osmanlı", 1),
      KonuDetay("Değişim Çağında Avrupa ve Osmanlı", 1),
      KonuDetay("Uluslararası İlişkilerde Denge Stratejisi", 1),
      KonuDetay("Devrimler Çağında Değişen Devlet-Toplum", 1),
      KonuDetay("Sermaye ve Emek", 1),
      KonuDetay("XIX. ve XX. Yüzyılda Değişen Gündelik Hayat", 1),
      KonuDetay("Milli Mücadele", 2),
      KonuDetay("Atatürkçülük ve Türk İnkılabı", 1),
    ],
    "TYT Coğrafya": [
      KonuDetay("Doğa ve İnsan", 1),
      KonuDetay("Dünya'nın Şekli ve Hareketleri", 1),
      KonuDetay("Coğrafi Konum", 1),
      KonuDetay("Harita Bilgisi", 1),
      KonuDetay("Atmosfer ve İklim", 1),
      KonuDetay("Sıcaklık", 1),
      KonuDetay("Basınç ve Rüzgarlar", 1),
      KonuDetay("Nem ve Yağış", 1),
      KonuDetay("İklim Tipleri", 1),
      KonuDetay("İç ve Dış Kuvvetler", 1),
      KonuDetay("Nüfus", 1),
      KonuDetay("Göç", 1),
      KonuDetay("Yerleşme", 1),
      KonuDetay("Türkiye'nin Yer şekilleri", 1),
      KonuDetay("Ekonomik Faaliyetler", 1),
      KonuDetay("Bölgeler", 1),
      KonuDetay("Uluslararası Ulaşım Hatları", 1),
      KonuDetay("Çevre ve Toplum", 1),
      KonuDetay("Doğal Afetler", 1),
    ],
    "TYT Felsefe": [
      KonuDetay("Felsefeyi Tanıma", 1),
      KonuDetay("Felsefe ile Düşünme", 1),
      KonuDetay("Varlık Felsefesi", 1),
      KonuDetay("Bilgi Felsefesi", 1),
      KonuDetay("Bilim Felsefesi", 1),
      KonuDetay("Ahlak Felsefesi", 1),
      KonuDetay("Din Felsefesi", 1),
      KonuDetay("Siyaset Felsefesi", 1),
      KonuDetay("Sanat Felsefesi", 1),
    ],
    "TYT Din Kültürü": [
      KonuDetay("Bilgi ve İnanç", 1),
      KonuDetay("Din ve İslam", 1),
      KonuDetay("İslam ve İbadet", 1),
      KonuDetay("Gençlik ve Değerler", 1),
      KonuDetay("Gönül Coğrafyamız", 1),
      KonuDetay("Allah İnsan İlişkisi", 1),
      KonuDetay("Hz. Muhammed (S.A.V)", 1),
      KonuDetay("Vahiy ve Akıl", 1),
      KonuDetay("İslam Düşüncesinde Yorumlar", 1),
    ],
    // --- AYT MATEMATİK ---
    "AYT Matematik": [
      KonuDetay("Polinomlar", 1),
      KonuDetay("2. Dereceden Denklemler", 1),
      KonuDetay("Parabol", 1),
      KonuDetay("Eşitsizlikler", 1),
      KonuDetay("Trigonometri", 4),
      KonuDetay("Logaritma", 2),
      KonuDetay("Diziler", 1),
      KonuDetay("Limit", 2),
      KonuDetay("Türev", 4),
      KonuDetay("İntegral", 4),
      KonuDetay("Permütasyon-Kombinasyon-Olasılık", 2),
    ],
    // --- AYT FEN ---
    "AYT Fizik": [
      KonuDetay("Vektörler", 1),
      KonuDetay("Kuvvet, Tork ve Denge", 1),
      KonuDetay("Kütle Merkezi", 1),
      KonuDetay("Basit Makineler", 1),
      KonuDetay("Hareket", 1),
      KonuDetay("Newton'un Hareket Yasaları", 1),
      KonuDetay("İş, Güç ve Enerji", 1),
      KonuDetay("Atışlar", 1),
      KonuDetay("İtme ve Momentum", 1),
      KonuDetay("Elektrik Alan ve Potansiyel", 1),
      KonuDetay("Paralel Levhalar ve Sığa", 1),
      KonuDetay("Manyetizma", 1),
      KonuDetay("Alternatif Akım", 1),
      KonuDetay("Transformatörler", 1),
      KonuDetay("Çembersel Hareket", 1),
      KonuDetay("Basit Harmonik Hareket", 1),
      KonuDetay("Dalga Mekaniği", 1),
      KonuDetay("Atom Fiziği", 1),
      KonuDetay("Modern Fizik", 1),
    ],
    "AYT Kimya": [
      KonuDetay("Modern Atom Teorisi", 1),
      KonuDetay("Gazlar", 1),
      KonuDetay("Sıvı Çözeltiler", 1),
      KonuDetay("Kimyasal Tepkimelerde Enerji", 1),
      KonuDetay("Kimyasal Tepkimelerde Hız", 1),
      KonuDetay("Kimyasal Tepkimelerde Denge", 1),
      KonuDetay("Asit-Baz Dengesi", 1),
      KonuDetay("Çözünürlük Dengesi", 1),
      KonuDetay("Kimya ve Elektrik", 1),
      KonuDetay("Karbon Kimyasına Giriş", 1),
      KonuDetay("Organik Bileşikler", 2),
      KonuDetay("Enerji Kaynakları Bilimsel Gelişmeler", 1),
    ],
    "AYT Biyoloji": [
      KonuDetay("Sinir Sistemi", 1),
      KonuDetay("Endokrin Sistem", 1),
      KonuDetay("Duyu Organları", 1),
      KonuDetay("Destek ve Hareket Sistemi", 1),
      KonuDetay("Sindirim Sistemi", 1),
      KonuDetay("Dolaşım Sistemi", 1),
      KonuDetay("Bağışıklık Sistemi", 1),
      KonuDetay("Solunum Sistemi", 1),
      KonuDetay("Boşaltım Sistemi", 1),
      KonuDetay("Üreme Sistemi ve Embriyonik Gelişim", 1),
      KonuDetay("Komünite ve Popülasyon Ekolojisi", 1),
      KonuDetay("Nükleik Asitler", 1),
      KonuDetay("Genden Proteine", 1),
      KonuDetay("Canlılarda Enerji Dönüşümleri", 1),
      KonuDetay("Bitki Biyolojisi", 2),
      KonuDetay("Canlılar ve Çevre", 1),
    ],
    // --- AYT EDEBİYAT ---
    "AYT Edebiyat": [
      KonuDetay("Güzel Sanatlar ve Edebiyat", 1),
      KonuDetay("Edebi Metinler (Coşku ve Heyecan)", 1),
      KonuDetay("Edebi Sanatlar", 1),
      KonuDetay("İslamiyet Öncesi Türk Edebiyatı", 1),
      KonuDetay("İslami Devir Türk Edebiyatı", 1),
      KonuDetay("Halk Edebiyatı", 1),
      KonuDetay("Divan Edebiyatı", 3),
      KonuDetay("Tanzimat Edebiyatı", 1),
      KonuDetay("Servet-i Fünun Edebiyatı", 1),
      KonuDetay("Fecr-i Ati Edebiyatı", 1),
      KonuDetay("Milli Edebiyat", 1),
      KonuDetay("Cumhuriyet Dönemi Edebiyatı", 3),
      KonuDetay("Batı Edebiyatı", 1),
    ],
    // --- AYT TARİH/COĞRAFYA ---
    "AYT Tarih-1": [
      KonuDetay("Tarih Bilimi", 1),
      KonuDetay("Uygarlığın Doğuşu", 1),
      KonuDetay("İlk Türk Devletleri", 1),
      KonuDetay("İslam Tarihi", 1),
      KonuDetay("Türk-İslam Devletleri", 1),
      KonuDetay("Osmanlı Devleti Kuruluş-Yükselme", 1),
      KonuDetay("Osmanlı Kültür ve Medeniyeti", 1),
      KonuDetay("Yeniçağ Avrupası", 1),
      KonuDetay("Osmanlı Dağılma Dönemi", 1),
      KonuDetay("Milli Mücadele", 2),
      KonuDetay("Atatürk İlkeleri ve İnkılapları", 1),
      KonuDetay("Türk Dış Politikası", 1),
    ],
    "AYT Coğrafya-1": [
      KonuDetay("Ekosistem", 1),
      KonuDetay("Nüfus Politikaları", 1),
      KonuDetay("Türkiye'de Nüfus ve Yerleşme", 1),
      KonuDetay("Ekonomik Faaliyetler", 1),
      KonuDetay("Türkiye'de Ekonomi", 1),
      KonuDetay("Bölgeler ve Ülkeler", 1),
      KonuDetay("Çevre ve Toplum", 1),
    ],
    // --- AYT GEOMETRİ ---
    "AYT Geometri": [
      KonuDetay("Üçgenler (İleri)", 2),
      KonuDetay("Dik Üçgen ve Trigonometri", 2),
      KonuDetay("Çokgenler ve Dörtgenler (İleri)", 1),
      KonuDetay("Çemberin Analitik İncelenmesi", 2),
      KonuDetay("Elips", 1),
      KonuDetay("Hiperbol", 1),
      KonuDetay("Parabol (Geometrik)", 1),
      KonuDetay("Uzay Geometri", 2),
      KonuDetay("Katı Cisimler (İleri)", 2),
      KonuDetay("Dönüşümler", 1),
    ],
    // --- AYT TARİH-2 (İNKILAP TARİHİ) ---
    "AYT Tarih-2": [
      KonuDetay("20. Yüzyıl Başlarında Dünya", 1),
      KonuDetay("I. Dünya Savaşı", 1),
      KonuDetay("Mondros Mütarekesi", 1),
      KonuDetay("Kurtuluş Savaşı Hazırlık Dönemi", 1),
      KonuDetay("Kuvayımilliye ve Cemiyetler", 1),
      KonuDetay("TBMM'nin Açılması", 1),
      KonuDetay("Sevr Antlaşması", 1),
      KonuDetay("Sakarya ve Büyük Taarruz", 1),
      KonuDetay("Mudanya ve Lozan", 1),
      KonuDetay("Cumhuriyet'in İlanı", 1),
      KonuDetay("Çok Partili Hayat Denemeleri", 1),
      KonuDetay("Hukuk İnkılabı", 1),
      KonuDetay("Eğitim ve Kültür İnkılabı", 1),
      KonuDetay("Ekonomi İnkılabı", 1),
      KonuDetay("Toplumsal Hayatın Düzenlenmesi", 1),
      KonuDetay("Atatürk İlkeleri", 2),
      KonuDetay("Atatürk Dönemi Dış Politika", 1),
      KonuDetay("II. Dünya Savaşı ve Türkiye", 1),
      KonuDetay("Soğuk Savaş Dönemi", 1),
      KonuDetay("21. Yüzyılda Türkiye", 1),
    ],
    // --- AYT COĞRAFYA-2 ---
    "AYT Coğrafya-2": [
      KonuDetay("Beşeri Sistemler", 1),
      KonuDetay("Küresel Ortam: Bölgeler ve Ülkeler", 2),
      KonuDetay("Çevre ve Toplum (İleri)", 1),
      KonuDetay("Doğal Kaynaklar", 1),
      KonuDetay("Uluslararası Kuruluşlar", 1),
      KonuDetay("Kültür Bölgeleri", 1),
      KonuDetay("Ülkeler Coğrafyası", 2),
      KonuDetay("Türkiye'nin Jeopolitik Konumu", 1),
      KonuDetay("Küreselleşme", 1),
    ],
    // --- AYT FELSEFE GRUBU ---
    "AYT Felsefe": [
      KonuDetay("Felsefenin Konusu ve Yöntemi", 1),
      KonuDetay("İlk Çağ Felsefesi", 1),
      KonuDetay("Orta Çağ Felsefesi", 1),
      KonuDetay("15-17. Yüzyıl Felsefesi", 1),
      KonuDetay("18. Yüzyıl Felsefesi", 1),
      KonuDetay("19. Yüzyıl Felsefesi", 1),
      KonuDetay("20. Yüzyıl Felsefesi", 1),
      KonuDetay("Varlık Felsefesi (İleri)", 1),
      KonuDetay("Bilgi Felsefesi (İleri)", 1),
      KonuDetay("Ahlak Felsefesi (İleri)", 1),
      KonuDetay("Siyaset Felsefesi (İleri)", 1),
      KonuDetay("Estetik ve Sanat Felsefesi", 1),
    ],
    "AYT Psikoloji": [
      KonuDetay("Psikolojinin Tanımı ve Yöntemi", 1),
      KonuDetay("Psikolojinin Alt Dalları", 1),
      KonuDetay("Öğrenme", 2),
      KonuDetay("Bellek ve Unutma", 1),
      KonuDetay("Düşünme ve Problem Çözme", 1),
      KonuDetay("Zeka", 1),
      KonuDetay("Güdülenme ve Duygu", 1),
      KonuDetay("Kişilik", 1),
      KonuDetay("Davranış Bozuklukları", 1),
      KonuDetay("Sosyal Etki ve Tutum", 1),
    ],
    "AYT Sosyoloji": [
      KonuDetay("Sosyolojiye Giriş", 1),
      KonuDetay("Toplumsal Yapı", 1),
      KonuDetay("Birey ve Toplum", 1),
      KonuDetay("Toplumsal Gruplar", 1),
      KonuDetay("Kültür", 1),
      KonuDetay("Toplumsal Kurumlar", 2),
      KonuDetay("Toplumsal Tabakalaşma", 1),
      KonuDetay("Toplumsal Değişme", 1),
      KonuDetay("Toplumsal Sapma ve Kontrol", 1),
      KonuDetay("Toplum ve Teknoloji", 1),
    ],
    "AYT Mantık": [
      KonuDetay("Mantığın Konusu ve İlkeleri", 1),
      KonuDetay("Kavram ve Terim", 1),
      KonuDetay("Önerme", 1),
      KonuDetay("Çıkarım", 1),
      KonuDetay("Kıyas", 2),
      KonuDetay("Mantık Hataları", 1),
      KonuDetay("Sembolik Mantık", 2),
      KonuDetay("Modern Mantık", 1),
    ],
    "AYT Din Kültürü": [
      KonuDetay("Bilgi ve İnanç (İleri)", 1),
      KonuDetay("İslam ve Bilim", 1),
      KonuDetay("İslam Medeniyeti", 1),
      KonuDetay("İslam'ın Temel Kaynakları", 1),
      KonuDetay("Kelam ve İtikadi Mezhepler", 1),
      KonuDetay("İslam Fıkhı", 1),
      KonuDetay("Tasavvuf", 1),
      KonuDetay("İslam ve Sosyal Hayat", 1),
      KonuDetay("Günümüz İslam Dünyası", 1),
    ],
  };

  // VERİTABANI YÜKLEME (INIT)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.containsKey('ogrenciler')) {
      var list = jsonDecode(_prefs.getString('ogrenciler')!);
      ogrenciler = (list as List).map((e) => Ogrenci.fromJson(e)).toList();
    }
    if (_prefs.containsKey('gorevler')) {
      var list = jsonDecode(_prefs.getString('gorevler')!);
      kayitliProgram = (list as List).map((e) => Gorev.fromJson(e)).toList();
    }
    if (_prefs.containsKey('denemeler')) {
      var list = jsonDecode(_prefs.getString('denemeler')!);
      denemeListesi =
          (list as List).map((e) => DenemeSonucu.fromJson(e)).toList();
    }
    if (_prefs.containsKey('cozulenSorular')) {
      var list = jsonDecode(_prefs.getString('cozulenSorular')!);
      soruCozumListesi =
          (list as List).map((e) => SoruCozumKaydi.fromJson(e)).toList();
    }
    if (_prefs.containsKey('bitenKonular')) {
      tamamlananKonular =
          Map<String, bool>.from(jsonDecode(_prefs.getString('bitenKonular')!));
    }
    baslat();
    // Rozet Durumlarını Yükle
    if (_prefs.containsKey('rozetler')) {
      var savedBadges = jsonDecode(_prefs.getString('rozetler')!) as List;
      for (var s in savedBadges) {
        try {
          var r = tumRozetler.firstWhere((e) => e.id == s['id']);
          r.kazanildi = s['kazanildi'];
          r.mevcutSayi = s['mevcutSayi'];
        } catch (e) {}
      }
    }
    if (_prefs.containsKey('hataDefteriListesi')) {
      var list = jsonDecode(_prefs.getString('hataDefteriListesi')!);
      hataDefteriListesi =
          (list as List).map((e) => HataDefteriSoru.fromJson(e)).toList();
    }
    if (_prefs.containsKey('akilliKonuTakibi')) {
      var list = jsonDecode(_prefs.getString('akilliKonuTakibi')!);
      akilliKonuTakibi = (list as List).map((e) => KonuTamamlama.fromJson(e)).toList();
    }
  }

  // OTURUM YÖNETİMİ
  static String? get aktifKullaniciId => _prefs.getString('aktifKullaniciId');
  static String? get aktifKullaniciRol => _prefs.getString('aktifKullaniciRol');

  static Future<void> girisKaydet(String id, String rol) async {
    await _prefs.setString('aktifKullaniciId', id);
    await _prefs.setString('aktifKullaniciRol', rol);
  }

  static Future<void> cikisYap() async {
    await _prefs.remove('aktifKullaniciId');
    await _prefs.remove('aktifKullaniciRol');
    // Akıllı verileri de temizle (opsiyonel ama güvenli)
    akilliKonuTakibi = [];
    tamamlananKonular = {};
  }

  // Veri Kaydetme
  static Future<void> kaydet() async {
    await _prefs.setString(
        'ogrenciler', jsonEncode(ogrenciler.map((e) => e.toJson()).toList()));
    await _prefs.setString(
        'gorevler', jsonEncode(kayitliProgram.map((e) => e.toJson()).toList()));
    await _prefs.setString(
        'denemeler', jsonEncode(denemeListesi.map((e) => e.toJson()).toList()));
    await _prefs.setString('cozulenSorular',
        jsonEncode(soruCozumListesi.map((e) => e.toJson()).toList()));
    await _prefs.setString('bitenKonular', jsonEncode(tamamlananKonular));
    await _prefs.setString('rozetler',
        jsonEncode(tumRozetler.map((e) => e.toStateJson()).toList()));
    await _prefs.setString('hataDefteriListesi',
        jsonEncode(hataDefteriListesi.map((e) => e.toJson()).toList()));
    // Günlük Takip
    await _prefs.setString('gunlukTakipDurumlari', jsonEncode(gunlukTakipDurumlari));
    // Akıllı Koç verileri
    await _prefs.setString('akilliKonuTakibi', jsonEncode(akilliKonuTakibi.map((e) => e.toJson()).toList()));
  }

  static void baslat() {
    if (tumRozetler.isNotEmpty) return;
    kurumsalDenemeler.add(PdfDeneme("Türkiye Geneli TYT-1",
        DateTime.now().subtract(const Duration(days: 5)), "dosya.pdf"));

    tumRozetler.addAll([
      // SORU CANAVARI SERİSİ
      Rozet(id: "soru_100", ad: "Çırak", aciklama: "100 Soru Çöz", kategori: "Soru", seviye: "Bronz", puanDegeri: 50, ikon: Icons.edit, renk: Colors.brown, hedefSayi: 100, mevcutSayi: 0),
      Rozet(id: "soru_500", ad: "Kalfa", aciklama: "500 Soru Çöz", kategori: "Soru", seviye: "Gümüş", puanDegeri: 250, ikon: Icons.edit_note, renk: Colors.grey, hedefSayi: 500, mevcutSayi: 0),
      Rozet(id: "soru_1000", ad: "Usta", aciklama: "1000 Soru Çöz", kategori: "Soru", seviye: "Altın", puanDegeri: 500, ikon: Icons.history_edu, renk: Colors.amber, hedefSayi: 1000, mevcutSayi: 0),
      Rozet(id: "soru_5000", ad: "Üstat", aciklama: "5000 Soru Çöz", kategori: "Soru", seviye: "Elmas", puanDegeri: 2000, ikon: Icons.auto_awesome, renk: Colors.cyanAccent, hedefSayi: 5000, mevcutSayi: 0),
      Rozet(id: "soru_10000", ad: "YKS Efsanesi", aciklama: "10000 Soru Çöz", kategori: "Soru", seviye: "Efsane", puanDegeri: 5000, ikon: Icons.whatshot, renk: Colors.redAccent, hedefSayi: 10000, mevcutSayi: 0),
      
      // DENEME ŞAMPİYONU SERİSİ
      Rozet(id: "deneme_1", ad: "İlk Adım", aciklama: "İlk Denemeni Çöz", kategori: "Deneme", seviye: "Bronz", puanDegeri: 100, ikon: Icons.assignment, renk: Colors.brown, hedefSayi: 1, mevcutSayi: 0),
      Rozet(id: "deneme_5", ad: "Hızlanıyoruz", aciklama: "5 Deneme Çöz", kategori: "Deneme", seviye: "Gümüş", puanDegeri: 500, ikon: Icons.assignment_turned_in, renk: Colors.grey, hedefSayi: 5, mevcutSayi: 0),
      Rozet(id: "deneme_10", ad: "Maratoncu", aciklama: "10 Deneme Çöz", kategori: "Deneme", seviye: "Altın", puanDegeri: 1000, ikon: Icons.directions_run, renk: Colors.amber, hedefSayi: 10, mevcutSayi: 0),
      Rozet(id: "deneme_50", ad: "Demir Adam", aciklama: "50 Deneme Çöz", kategori: "Deneme", seviye: "Elmas", puanDegeri: 5000, ikon: Icons.security, renk: Colors.cyanAccent, hedefSayi: 50, mevcutSayi: 0),

      // İSTİKRAR ABİDESİ (SERİ)
      Rozet(id: "seri_3", ad: "Başlangıç", aciklama: "3 Gün Üst Üste Gir", kategori: "Seri", seviye: "Bronz", puanDegeri: 50, ikon: Icons.local_fire_department, renk: Colors.brown, hedefSayi: 3, mevcutSayi: 0),
      Rozet(id: "seri_7", ad: "Haftalık", aciklama: "1 Hafta Üst Üste Gir", kategori: "Seri", seviye: "Gümüş", puanDegeri: 150, ikon: Icons.local_fire_department, renk: Colors.grey, hedefSayi: 7, mevcutSayi: 0),
      Rozet(id: "seri_30", ad: "Aylık", aciklama: "30 Gün Üst Üste Gir", kategori: "Seri", seviye: "Altın", puanDegeri: 1000, ikon: Icons.local_fire_department, renk: Colors.amber, hedefSayi: 30, mevcutSayi: 0),
      Rozet(id: "seri_100", ad: "Yüzyıllık", aciklama: "100 Gün Serisi!", kategori: "Seri", seviye: "Elmas", puanDegeri: 5000, ikon: Icons.wb_sunny, renk: Colors.cyanAccent, hedefSayi: 100, mevcutSayi: 0),

      // KONU ÜSTADI
      Rozet(id: "konu_10", ad: "Meraklı", aciklama: "10 Konu Bitir", kategori: "Konu", seviye: "Bronz", puanDegeri: 200, ikon: Icons.menu_book, renk: Colors.brown, hedefSayi: 10, mevcutSayi: 0),
      Rozet(id: "konu_50", ad: "Bilgin", aciklama: "50 Konu Bitir", kategori: "Konu", seviye: "Altın", puanDegeri: 1000, ikon: Icons.import_contacts, renk: Colors.amber, hedefSayi: 50, mevcutSayi: 0),
      Rozet(id: "konu_100", ad: "Profesör", aciklama: "100 Konu Bitir!", kategori: "Konu", seviye: "Efsane", puanDegeri: 5000, ikon: Icons.school, renk: Colors.redAccent, hedefSayi: 100, mevcutSayi: 0),

      // SEVİYE LİGİ
      Rozet(id: "seviye_1000", ad: "Bronz Lig", aciklama: "1000 XP Kazan", kategori: "Seviye", seviye: "Bronz", puanDegeri: 0, ikon: Icons.star_border, renk: Colors.brown, hedefSayi: 1000, mevcutSayi: 0),
      Rozet(id: "seviye_5000", ad: "Gümüş Lig", aciklama: "5000 XP Kazan", kategori: "Seviye", seviye: "Gümüş", puanDegeri: 0, ikon: Icons.star_half, renk: Colors.grey, hedefSayi: 5000, mevcutSayi: 0),
      Rozet(id: "seviye_10000", ad: "Altın Lig", aciklama: "10000 XP Kazan", kategori: "Seviye", seviye: "Altın", puanDegeri: 0, ikon: Icons.star, renk: Colors.amber, hedefSayi: 10000, mevcutSayi: 0),
    ]);
  }

  static int get seviye => (ogrenciler[0].puan / 1000).floor() + 1;
  static double get seviyeYuzdesi => (ogrenciler[0].puan % 1000) / 1000;

  static void soruEkle(SoruCozumKaydi k) {
    soruCozumListesi.add(k);
    puanEkle(k.ogrenciId, (k.dogru + k.yanlis) ~/ 5);
    _rozetKontrol();
    kaydet();
  }

  static void puanEkle(String id, int p) {
    var o =
        ogrenciler.firstWhere((e) => e.id == id, orElse: () => ogrenciler[0]);
    o.puan += p;
    _rozetKontrol();
    kaydet();
  }

  static void _rozetKontrol() {
    int topSoru =
        soruCozumListesi.fold(0, (sum, item) => sum + item.dogru + item.yanlis);
    int bitenKonu = tamamlananKonular.length;
    int denemeSayisi = denemeListesi.length;
    int toplamPuan = ogrenciler[0].puan;

    for (var r in tumRozetler) {
      if (r.kategori == "Soru") r.mevcutSayi = topSoru;
      if (r.kategori == "Konu") r.mevcutSayi = bitenKonu;
      if (r.kategori == "Deneme") r.mevcutSayi = denemeSayisi;
      if (r.kategori == "Seviye") r.mevcutSayi = toplamPuan;

      if (!r.kazanildi && r.mevcutSayi >= r.hedefSayi) {
        r.kazanildi = true;
      }
    }
  }

  static void konuDurumDegistir(String k, bool v) {
    tamamlananKonular[k] = v;
    if (v) puanEkle("101", 10);
    kaydet();
  }



  static void denemeEkle(DenemeSonucu d) {
    denemeListesi.add(d);
    puanEkle(d.ogrenciId, 50);
    kaydet();
  }

  static void dersEkle(OkulDersi d) {
    okulNotlari.add(d);
    kaydet();
  }

  static void programiKaydet(List<Gorev> program, String tur) {
    kayitliProgram = List.from(program);
    programArsivi.add(KayitliProgramGecmisi(
        tarih: DateTime.now(), tur: tur, programVerisi: List.from(program)));
    puanEkle("101", 100);
    kaydet();
  }

  static dynamic girisKontrol(String k, String s) {
    if (k == "admin" && s == "123456") return "admin"; // Admin Check
    if (k == "ogrenci1" && s == "1234")
      return Ogrenci(id: "101", ad: "Ahmet Yılmaz", sinif: "12-A", puan: 1250, veliErisimKodu: "123456");
    // Dynamic Check
    try {
      var o = ogrenciler.firstWhere((e) => e.id == k || e.ad.toLowerCase().replaceAll(" ", "") == k.toLowerCase());
      if (s == "1234") return o;
    } catch (e) {}
    try {
      var t = ogretmenler.firstWhere((e) => e.id == k || e.ad.toLowerCase().replaceAll(" ", "") == k.toLowerCase());
      if (s == "1234") return t;
    } catch (e) {}
    
    return null;
  }

  /// Veli girişi için kontrol
  /// ogrenciId: Öğrenci TC/ID numarası
  /// erisimKodu: 6 haneli veli erişim kodu
  static Ogrenci? veliGirisKontrol(String ogrenciId, String erisimKodu) {
    // Test kullanıcı kontrolü
    if (ogrenciId == "101" && erisimKodu == "123456") {
      return Ogrenci(id: "101", ad: "Ahmet Yılmaz", sinif: "12-A", puan: 1250, veliErisimKodu: "123456");
    }
    
    // Gerçek kullanıcı kontrolü
    try {
      var ogrenci = ogrenciler.firstWhere(
        (e) => (e.id == ogrenciId || e.tcNo == ogrenciId) && e.veliErisimKodu == erisimKodu && e.veliErisimKodu.isNotEmpty
      );
      return ogrenci;
    } catch (e) {
      return null;
    }
  }

  /// Kurum yöneticisi girişi için kontrol
  static (KurumYoneticisi?, Kurum?) kurumYoneticisiGirisKontrol(String id, String sifre) {
    try {
      var yonetici = kurumYoneticileri.firstWhere(
        (y) => y.id == id && y.sifre == sifre
      );
      var kurum = kurumlar.firstWhere((k) => k.id == yonetici.kurumId);
      return (yonetici, kurum);
    } catch (e) {
      return (null, null);
    }
  }

  // --- YÖNETİCİ METOTLARI ---
  static void ogrenciEkle(String ad, String sinif) {
    String id = "ogr_${ogrenciler.length + 100}";
    ogrenciler.add(Ogrenci(id: id, ad: ad, sinif: sinif, puan: 0));
    kaydet();
  }

  static void ogretmenEkle(String ad, String brans) {
    String id = "ogrt_${ogretmenler.length + 100}";
    ogretmenler.add(Ogretmen(id: id, ad: ad, brans: brans));
    kaydet();
  }

  static void kullaniciSil(String id) {
    ogrenciler.removeWhere((e) => e.id == id);
    ogretmenler.removeWhere((e) => e.id == id);
    kaydet();
  }

  static void xpYagmuru() {
    for (var o in ogrenciler) {
      o.puan += 1000;
    }
    kaydet();
  }

  static Future<void> sifirla() async {
    await _prefs.clear();
    ogrenciler.clear();
    ogretmenler.clear();
    // Re-init default data if needed or just leave empty
    // But for safety, let's keep the session alive or force logout
  }


  static void atamaYap(String ogrenciId, String ogretmenId) {
    try {
      var o = ogrenciler.firstWhere((e) => e.id == ogrenciId);
      o.atananOgretmenId = ogretmenId;
      kaydet();
    } catch (e) {}
  }

  static void sifreSifirla(String id) {
    try {
      var o = ogrenciler.firstWhere((e) => e.id == id);
      o.sifre = "123456";
    } catch (e) {}
    try {
      var t = ogretmenler.firstWhere((e) => e.id == id);
      t.sifre = "123456";
    } catch (e) {}
    kaydet();
  }

  static void girisSayaciArtir(String id, bool isOgrenci) {
    if (isOgrenci)
      ogrenciler.firstWhere((e) => e.id == id).girisSayisi++;
    else
      ogretmenler.firstWhere((e) => e.id == id).girisSayisi++;
    kaydet();
  }
}
