import 'package:flutter/material.dart';
import 'envanter_models.dart';

/// Tüm envanterler için statik veri deposu
class EnvanterVerileri {
  
  /// Tüm envanterlerin listesi
  static List<Envanter> tumEnvanterler = [
    hollandTesti,
    sinavKaygisiTesti,
    basarisizlikNedenleriTesti,
    burdonTesti,
    varkOgrenmeStilleri,
    calismaDavranislari,
    akademikBenlikSaygisi,
    gritAzimOlcegi,
    cokluZekaEnvanteri,
  ];

  // ============================================
  // 1. MESLEKİ YÖNELİM ENVANTERİ (30 Soru)
  // ============================================
  static final Envanter hollandTesti = Envanter(
    id: 'holland',
    baslik: 'Meslek ve İlgi Haritası',
    aciklama: 'Kişilik tipine (RIASEC) göre sana en uygun meslekleri keşfet.',
    tip: 'radar',
    ikon: Icons.work_outline,
    renk: Colors.indigo,
    sureDakika: 10,
    kategoriler: ['Gerçekçi', 'Araştırmacı', 'Sanatsal', 'Sosyal', 'Girişimci', 'Geleneksel'],
    sorular: [
      // Gerçekçi (R) - 5 soru
      EnvanterSorusu(soruNo: 1, metin: 'Tamir işleri yapmaktan hoşlanırım.', kategori: 'Gerçekçi'),
      EnvanterSorusu(soruNo: 2, metin: 'Açık havada çalışmayı tercih ederim.', kategori: 'Gerçekçi'),
      EnvanterSorusu(soruNo: 3, metin: 'Ellerimi kullanarak bir şeyler yapmaktan keyif alırım.', kategori: 'Gerçekçi'),
      EnvanterSorusu(soruNo: 4, metin: 'Makinelerle çalışmak ilgimi çeker.', kategori: 'Gerçekçi'),
      EnvanterSorusu(soruNo: 5, metin: 'Spor yapmayı severim.', kategori: 'Gerçekçi'),
      
      // Araştırmacı (I) - 5 soru
      EnvanterSorusu(soruNo: 6, metin: 'Bilimsel dergileri okumaktan hoşlanırım.', kategori: 'Araştırmacı'),
      EnvanterSorusu(soruNo: 7, metin: 'Matematik problemleri çözmekten zevk alırım.', kategori: 'Araştırmacı'),
      EnvanterSorusu(soruNo: 8, metin: 'Olayların nedenlerini araştırmayı severim.', kategori: 'Araştırmacı'),
      EnvanterSorusu(soruNo: 9, metin: 'Laboratuvar çalışmaları ilgimi çeker.', kategori: 'Araştırmacı'),
      EnvanterSorusu(soruNo: 10, metin: 'Karmaşık problemleri analiz etmeyi severim.', kategori: 'Araştırmacı'),
      
      // Sanatsal (A) - 5 soru
      EnvanterSorusu(soruNo: 11, metin: 'Resim yapmak veya çizmek hoşuma gider.', kategori: 'Sanatsal'),
      EnvanterSorusu(soruNo: 12, metin: 'Müzik dinlemek veya çalmak beni mutlu eder.', kategori: 'Sanatsal'),
      EnvanterSorusu(soruNo: 13, metin: 'Yaratıcı yazarlık yapmayı severim.', kategori: 'Sanatsal'),
      EnvanterSorusu(soruNo: 14, metin: 'Tiyatro veya sinema ile ilgilenirim.', kategori: 'Sanatsal'),
      EnvanterSorusu(soruNo: 15, metin: 'Özgün fikirler üretmekten hoşlanırım.', kategori: 'Sanatsal'),
      
      // Sosyal (S) - 5 soru
      EnvanterSorusu(soruNo: 16, metin: 'İnsanlara yardım etmekten mutlu olurum.', kategori: 'Sosyal'),
      EnvanterSorusu(soruNo: 17, metin: 'Başkalarına bir şeyler öğretmeyi severim.', kategori: 'Sosyal'),
      EnvanterSorusu(soruNo: 18, metin: 'Grup çalışmalarını tercih ederim.', kategori: 'Sosyal'),
      EnvanterSorusu(soruNo: 19, metin: 'İnsanların problemlerini dinlemeyi severim.', kategori: 'Sosyal'),
      EnvanterSorusu(soruNo: 20, metin: 'Toplumsal konulara duyarlıyım.', kategori: 'Sosyal'),
      
      // Girişimci (E) - 5 soru
      EnvanterSorusu(soruNo: 21, metin: 'Liderlik yapmaktan hoşlanırım.', kategori: 'Girişimci'),
      EnvanterSorusu(soruNo: 22, metin: 'İnsanları ikna etme yeteneğim var.', kategori: 'Girişimci'),
      EnvanterSorusu(soruNo: 23, metin: 'Risk almaktan korkmam.', kategori: 'Girişimci'),
      EnvanterSorusu(soruNo: 24, metin: 'Kendi işimi kurmak isterim.', kategori: 'Girişimci'),
      EnvanterSorusu(soruNo: 25, metin: 'Rekabeti seviyorum.', kategori: 'Girişimci'),
      
      // Geleneksel (C) - 5 soru
      EnvanterSorusu(soruNo: 26, metin: 'Düzenli ve planlı çalışmayı severim.', kategori: 'Geleneksel'),
      EnvanterSorusu(soruNo: 27, metin: 'Detaylara dikkat ederim.', kategori: 'Geleneksel'),
      EnvanterSorusu(soruNo: 28, metin: 'Belirli kurallar içinde çalışmak bana uyar.', kategori: 'Geleneksel'),
      EnvanterSorusu(soruNo: 29, metin: 'Kayıt tutmak ve arşivlemek hoşuma gider.', kategori: 'Geleneksel'),
      EnvanterSorusu(soruNo: 30, metin: 'Hesap-kitap işleri ilgimi çeker.', kategori: 'Geleneksel'),
    ],
  );

  // ============================================
  // 2. SINAV KAYGISI ÖLÇEĞİ (20 Soru)
  // ============================================
  static final Envanter sinavKaygisiTesti = Envanter(
    id: 'sinav_kaygisi',
    baslik: 'Sınav Kaygısı Ölçeği',
    aciklama: 'Sınav öncesi ve sırasında yaşadığın kaygı seviyesini ölç.',
    tip: 'progress',
    ikon: Icons.psychology,
    renk: Colors.deepOrange,
    sureDakika: 8,
    kategoriler: ['Kaygı'],
    sorular: [
      EnvanterSorusu(soruNo: 1, metin: 'Sınav yaklaştıkça huzursuzlanırım.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 2, metin: 'Sınavdan önce uyku problemleri yaşarım.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 3, metin: 'Sınav sırasında ellerim titrer.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 4, metin: 'Sınavda bildiklerimi unuturum.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 5, metin: 'Sınav günü mide bulantısı yaşarım.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 6, metin: 'Sınavda kalp çarpıntısı hissederim.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 7, metin: 'Sınav sırasında konsantrasyonumu kaybederim.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 8, metin: 'Başarısız olacağımı düşünürüm.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 9, metin: 'Sınavdan kaçmak isterim.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 10, metin: 'Sınav sonuçlarını beklerken gergin olurum.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 11, metin: 'Sınav stresi iştahımı etkiler.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 12, metin: 'Sınav öncesi çok fazla endişelenirim.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 13, metin: 'Sınavda zamanın yetmeyeceğinden korkarım.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 14, metin: 'Sınav sırasında ter basması yaşarım.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 15, metin: 'Sınava hazırlanırken panik atak geçiririm.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 16, metin: 'Sınavda diğerlerinden kötü yapacağımı düşünürüm.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 17, metin: 'Sınav günü kendimi hasta hissederim.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 18, metin: 'Sınav stresi günlük hayatımı etkiler.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 19, metin: 'Sınavda başarısız olursam ne olacağını düşünürüm.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 20, metin: 'Sınav düşüncesi bile beni strese sokar.', kategori: 'Kaygı', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
    ],
  );

  // ============================================
  // 3. BAŞARISIZLIK NEDENLERİ TESTİ (25 Soru)
  // ============================================
  static final Envanter basarisizlikNedenleriTesti = Envanter(
    id: 'basarisizlik',
    baslik: 'Başarısızlık Nedenleri Analizi',
    aciklama: 'Başarını engelleyen faktörleri keşfet ve çözüm önerileri al.',
    tip: 'bar',
    ikon: Icons.trending_down,
    renk: Colors.red,
    sureDakika: 10,
    kategoriler: ['Motivasyon', 'Çalışma Yöntemi', 'Dikkat', 'Stres', 'Çevre'],
    sorular: [
      // Motivasyon Eksikliği - 5 soru
      EnvanterSorusu(soruNo: 1, metin: 'Ders çalışmaya başlamakta zorlanıyorum.', kategori: 'Motivasyon'),
      EnvanterSorusu(soruNo: 2, metin: 'Hedeflerim net değil.', kategori: 'Motivasyon'),
      EnvanterSorusu(soruNo: 3, metin: 'Başarının benim için önemli olmadığını hissediyorum.', kategori: 'Motivasyon'),
      EnvanterSorusu(soruNo: 4, metin: 'Çabalarımın sonuç vermeyeceğini düşünüyorum.', kategori: 'Motivasyon'),
      EnvanterSorusu(soruNo: 5, metin: 'Ders çalışmak yerine başka şeyler yapmayı tercih ediyorum.', kategori: 'Motivasyon'),
      
      // Çalışma Yöntemi - 5 soru
      EnvanterSorusu(soruNo: 6, metin: 'Verimli ders çalışma tekniklerini bilmiyorum.', kategori: 'Çalışma Yöntemi'),
      EnvanterSorusu(soruNo: 7, metin: 'Not alma konusunda zorlanıyorum.', kategori: 'Çalışma Yöntemi'),
      EnvanterSorusu(soruNo: 8, metin: 'Çalışma planı yapmıyorum.', kategori: 'Çalışma Yöntemi'),
      EnvanterSorusu(soruNo: 9, metin: 'Konuları anlamadan ezberlemeye çalışıyorum.', kategori: 'Çalışma Yöntemi'),
      EnvanterSorusu(soruNo: 10, metin: 'Tekrar yapmayı ihmal ediyorum.', kategori: 'Çalışma Yöntemi'),
      
      // Dikkat Dağınıklığı - 5 soru
      EnvanterSorusu(soruNo: 11, metin: 'Ders çalışırken telefon/sosyal medya dikkatimi dağıtıyor.', kategori: 'Dikkat'),
      EnvanterSorusu(soruNo: 12, metin: 'Uzun süre odaklanamıyorum.', kategori: 'Dikkat'),
      EnvanterSorusu(soruNo: 13, metin: 'Okuduğumu anlamakta güçlük çekiyorum.', kategori: 'Dikkat'),
      EnvanterSorusu(soruNo: 14, metin: 'Hayal kurarak zaman kaybediyorum.', kategori: 'Dikkat'),
      EnvanterSorusu(soruNo: 15, metin: 'Birden fazla şeyle aynı anda ilgilenmeye çalışıyorum.', kategori: 'Dikkat'),
      
      // Sınav Stresi - 5 soru
      EnvanterSorusu(soruNo: 16, metin: 'Sınav stresi performansımı düşürüyor.', kategori: 'Stres'),
      EnvanterSorusu(soruNo: 17, metin: 'Sınavda panik yapıyorum.', kategori: 'Stres'),
      EnvanterSorusu(soruNo: 18, metin: 'Başarısızlık korkusu beni etkiliyor.', kategori: 'Stres'),
      EnvanterSorusu(soruNo: 19, metin: 'Baskı altında düşünemiyorum.', kategori: 'Stres'),
      EnvanterSorusu(soruNo: 20, metin: 'Stres yüzünden sağlık problemleri yaşıyorum.', kategori: 'Stres'),
      
      // Çevresel Faktörler - 5 soru
      EnvanterSorusu(soruNo: 21, metin: 'Evde uygun çalışma ortamım yok.', kategori: 'Çevre'),
      EnvanterSorusu(soruNo: 22, metin: 'Ailem beni desteklemiyor.', kategori: 'Çevre'),
      EnvanterSorusu(soruNo: 23, metin: 'Arkadaş çevrem olumsuz etkiliyor.', kategori: 'Çevre'),
      EnvanterSorusu(soruNo: 24, metin: 'Ekonomik sorunlar dikkatimi dağıtıyor.', kategori: 'Çevre'),
      EnvanterSorusu(soruNo: 25, metin: 'Sağlık problemleri yaşıyorum.', kategori: 'Çevre'),
    ],
  );

  // ============================================
  // 4. BURDON DİKKAT TESTİ
  // ============================================
  static final Envanter burdonTesti = Envanter(
    id: 'burdon',
    baslik: 'Burdon Dikkat Testi',
    aciklama: '3 dakika içinde hedef harfleri bul. Dikkat ve konsantrasyon seviyeni ölç.',
    tip: 'timed',
    ikon: Icons.visibility,
    renk: Colors.teal,
    sureDakika: 3,
    kategoriler: ['Dikkat'],
    sorular: [], // Burdon testi soru formatında değil
  );

  // ============================================
  // 5. ÖĞRENME TARZI ANALİZİ (16 Soru)
  // ============================================
  static final Envanter varkOgrenmeStilleri = Envanter(
    id: 'vark',
    baslik: 'Öğrenme Tarzı Analizi',
    aciklama: 'Görsel, İşitsel veya Kinestetik... Hangi yöntemle daha iyi öğreniyorsun?',
    tip: 'radar',
    ikon: Icons.school,
    renk: Colors.purple,
    sureDakika: 8,
    kategoriler: ['Görsel', 'İşitsel', 'Okuma-Yazma', 'Kinestetik'],
    sorular: [
      // Görsel - 4 soru
      EnvanterSorusu(soruNo: 1, metin: 'Bir konuyu öğrenirken şema ve grafikler bana çok yardımcı olur.', kategori: 'Görsel'),
      EnvanterSorusu(soruNo: 2, metin: 'Harita ve diyagramları kolayca anlayabilirim.', kategori: 'Görsel'),
      EnvanterSorusu(soruNo: 3, metin: 'Renkli kalemlerle not tutmak dikkatimi artırır.', kategori: 'Görsel'),
      EnvanterSorusu(soruNo: 4, metin: 'Video izleyerek öğrenmek bana uygun.', kategori: 'Görsel'),
      
      // İşitsel - 4 soru
      EnvanterSorusu(soruNo: 5, metin: 'Bir konuyu dinleyerek daha iyi öğrenirim.', kategori: 'İşitsel'),
      EnvanterSorusu(soruNo: 6, metin: 'Birisiyle tartışarak konuyu daha iyi anlarım.', kategori: 'İşitsel'),
      EnvanterSorusu(soruNo: 7, metin: 'Sesli okumak veya mırıldanmak bana yardımcı olur.', kategori: 'İşitsel'),
      EnvanterSorusu(soruNo: 8, metin: 'Podcast veya sesli kitap dinlemeyi severim.', kategori: 'İşitsel'),
      
      // Okuma-Yazma - 4 soru
      EnvanterSorusu(soruNo: 9, metin: 'Yazılı materyalleri okuyarak en iyi öğrenirim.', kategori: 'Okuma-Yazma'),
      EnvanterSorusu(soruNo: 10, metin: 'Detaylı not tutmak öğrenmemi kolaylaştırır.', kategori: 'Okuma-Yazma'),
      EnvanterSorusu(soruNo: 11, metin: 'Liste yapmak ve yazı yazmak bana yardımcı olur.', kategori: 'Okuma-Yazma'),
      EnvanterSorusu(soruNo: 12, metin: 'Kitap okumayı diğer öğrenme yöntemlerine tercih ederim.', kategori: 'Okuma-Yazma'),
      
      // Kinestetik - 4 soru
      EnvanterSorusu(soruNo: 13, metin: 'Yaparak ve deneyerek öğrenmeyi tercih ederim.', kategori: 'Kinestetik'),
      EnvanterSorusu(soruNo: 14, metin: 'Uzun süre oturup ders çalışmak bana zor gelir.', kategori: 'Kinestetik'),
      EnvanterSorusu(soruNo: 15, metin: 'Fiziksel aktiviteler sırasında daha iyi düşünebilirim.', kategori: 'Kinestetik'),
      EnvanterSorusu(soruNo: 16, metin: 'Somut örnekler ve pratik uygulamalar bana yardımcı olur.', kategori: 'Kinestetik'),
    ],
  );

  // ============================================
  // 6. ÇALIŞMA DAVRANIŞLARI ÖLÇEĞİ (20 Soru)
  // ============================================
  static final Envanter calismaDavranislari = Envanter(
    id: 'calisma_davranislari',
    baslik: 'Çalışma Davranışları Değerlendirmesi',
    aciklama: 'Çalışma alışkanlıklarını analiz et ve geliştirmen gereken alanları bul.',
    tip: 'bar',
    ikon: Icons.assignment_turned_in,
    renk: Colors.blue,
    sureDakika: 10,
    kategoriler: ['Zaman Yönetimi', 'Not Tutma', 'Tekrar', 'Ortam', 'Motivasyon'],
    sorular: [
      // Zaman Yönetimi - 4 soru
      EnvanterSorusu(soruNo: 1, metin: 'Günlük/haftalık çalışma planı yapıyorum.', kategori: 'Zaman Yönetimi'),
      EnvanterSorusu(soruNo: 2, metin: 'Planıma uygun şekilde çalışıyorum.', kategori: 'Zaman Yönetimi'),
      EnvanterSorusu(soruNo: 3, metin: 'Her derse yeterli zaman ayırıyorum.', kategori: 'Zaman Yönetimi'),
      EnvanterSorusu(soruNo: 4, metin: 'Erteleme yapmadan çalışmaya başlıyorum.', kategori: 'Zaman Yönetimi'),
      
      // Not Tutma - 4 soru
      EnvanterSorusu(soruNo: 5, metin: 'Derste düzenli not tutuyorum.', kategori: 'Not Tutma'),
      EnvanterSorusu(soruNo: 6, metin: 'Notlarımı özet ve şema haline getiriyorum.', kategori: 'Not Tutma'),
      EnvanterSorusu(soruNo: 7, metin: 'Önemli yerleri renkli işaretliyorum.', kategori: 'Not Tutma'),
      EnvanterSorusu(soruNo: 8, metin: 'Notlarım düzenli ve okunabilir.', kategori: 'Not Tutma'),
      
      // Tekrar - 4 soru
      EnvanterSorusu(soruNo: 9, metin: 'Öğrendiklerimi düzenli olarak tekrar ediyorum.', kategori: 'Tekrar'),
      EnvanterSorusu(soruNo: 10, metin: 'Soru çözerek konuları pekiştiriyorum.', kategori: 'Tekrar'),
      EnvanterSorusu(soruNo: 11, metin: 'Eski konuları unutmamak için geri dönüyorum.', kategori: 'Tekrar'),
      EnvanterSorusu(soruNo: 12, metin: 'Öğrendiklerimi başkasına anlatarak tekrar ediyorum.', kategori: 'Tekrar'),
      
      // Ortam - 4 soru
      EnvanterSorusu(soruNo: 13, metin: 'Sessiz ve düzenli bir çalışma ortamım var.', kategori: 'Ortam'),
      EnvanterSorusu(soruNo: 14, metin: 'Çalışırken telefonumu uzaklaştırıyorum.', kategori: 'Ortam'),
      EnvanterSorusu(soruNo: 15, metin: 'Masam temiz ve düzenli.', kategori: 'Ortam'),
      EnvanterSorusu(soruNo: 16, metin: 'Çalışırken dikkatimi dağıtan şeyler yok.', kategori: 'Ortam'),
      
      // Motivasyon - 4 soru
      EnvanterSorusu(soruNo: 17, metin: 'Hedeflerim net ve belirli.', kategori: 'Motivasyon'),
      EnvanterSorusu(soruNo: 18, metin: 'Başarılı olacağıma inanıyorum.', kategori: 'Motivasyon'),
      EnvanterSorusu(soruNo: 19, metin: 'Zorluklarla karşılaşınca pes etmiyorum.', kategori: 'Motivasyon'),
      EnvanterSorusu(soruNo: 20, metin: 'Küçük başarılarımı kutluyorum.', kategori: 'Motivasyon'),
    ],
  );

  // ============================================
  // 7. AKADEMİK BENLİK SAYGISI ÖLÇEĞİ (15 Soru)
  // ============================================
  static final Envanter akademikBenlikSaygisi = Envanter(
    id: 'akademik_benlik',
    baslik: 'Akademik Benlik Saygısı Ölçeği',
    aciklama: 'Akademik potansiyeline ne kadar inandığını ölç.',
    tip: 'progress',
    ikon: Icons.sentiment_very_satisfied,
    renk: Colors.amber,
    sureDakika: 6,
    kategoriler: ['Benlik'],
    sorular: [
      EnvanterSorusu(soruNo: 1, metin: 'Zor konuları bile anlayabileceğime inanıyorum.', kategori: 'Benlik', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 2, metin: 'Sınavlarda başarılı olacağımı düşünüyorum.', kategori: 'Benlik', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 3, metin: 'Diğer öğrenciler kadar yetenekliyim.', kategori: 'Benlik', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 4, metin: 'Akademik hedeflerime ulaşabilirim.', kategori: 'Benlik', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 5, metin: 'Çok çalışırsam başarılı olurum.', kategori: 'Benlik', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 6, metin: 'Derslerde söz almaktan çekinmem.', kategori: 'Benlik', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 7, metin: 'Hata yapsam bile öğrenebilirim.', kategori: 'Benlik', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 8, metin: 'Başarısızlıklar beni yıldırmaz.', kategori: 'Benlik', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 9, metin: 'Yeni şeyler öğrenmekten keyif alırım.', kategori: 'Benlik', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 10, metin: 'Zorlu görevlerin üstesinden gelebilirim.', kategori: 'Benlik', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 11, metin: 'Kendi fikirlerimi ifade edebilirim.', kategori: 'Benlik', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 12, metin: 'Öğrenmek için yeterli kapasitem var.', kategori: 'Benlik', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 13, metin: 'Gelecekte başarılı bir kariyer yapabilirim.', kategori: 'Benlik', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 14, metin: 'Kendime güveniyorum.', kategori: 'Benlik', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 15, metin: 'Yeteneklerimi keşfetmeye devam ediyorum.', kategori: 'Benlik', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
    ],
  );

  // ============================================
  // 8. AKADEMİK AZİM TESTİ (12 Soru)
  // ============================================
  static final Envanter gritAzimOlcegi = Envanter(
    id: 'grit',
    baslik: 'Akademik Azim Testi',
    aciklama: 'Hedeflerine ulaşmak için ne kadar kararlısın? Pes etme gücünü ölç.',
    tip: 'progress',
    ikon: Icons.fitness_center,
    renk: Colors.green,
    sureDakika: 5,
    kategoriler: ['Azim'],
    sorular: [
      EnvanterSorusu(soruNo: 1, metin: 'Başladığım işi mutlaka bitiririm.', kategori: 'Azim', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 2, metin: 'Engellerle karşılaştığımda pes etmem.', kategori: 'Azim', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 3, metin: 'Uzun vadeli hedeflerim var.', kategori: 'Azim', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 4, metin: 'Zor görevler beni motive eder.', kategori: 'Azim', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 5, metin: 'Başarısızlıktan ders çıkarırım.', kategori: 'Azim', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 6, metin: 'Hedeflerime ulaşmak için fedakarlık yaparım.', kategori: 'Azim', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 7, metin: 'Çalışkanlık yeteneğin önünde gelir.', kategori: 'Azim', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 8, metin: 'Sabırlı bir insanım.', kategori: 'Azim', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 9, metin: 'Tutkulu olduğum konularda durmaksızın çalışırım.', kategori: 'Azim', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 10, metin: 'Başkalarının vazgeçtiği yerde devam ederim.', kategori: 'Azim', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 11, metin: 'Kararlı bir yapım var.', kategori: 'Azim', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
      EnvanterSorusu(soruNo: 12, metin: 'Hayatta büyük bir amaç için çalışıyorum.', kategori: 'Azim', secenekler: ['Hiç', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman']),
    ],
  );

  // ============================================
  // 9. YETENEK ALANLARI KEŞFİ (24 Soru)
  // ============================================
  static final Envanter cokluZekaEnvanteri = Envanter(
    id: 'coklu_zeka',
    baslik: 'Yetenek Alanları Keşfi',
    aciklama: 'Sözel, Sayısal veya Görsel... Hangi yetenek alanında daha baskınsın?',
    tip: 'radar',
    ikon: Icons.psychology,
    renk: Colors.deepPurple,
    sureDakika: 12,
    kategoriler: ['Sözel', 'Mantıksal', 'Görsel', 'Müziksel', 'Bedensel', 'Sosyal', 'İçsel', 'Doğacı'],
    sorular: [
      // Sözel-Dilsel - 3 soru
      EnvanterSorusu(soruNo: 1, metin: 'Yazı yazmak ve okumak hoşuma gider.', kategori: 'Sözel'),
      EnvanterSorusu(soruNo: 2, metin: 'Kelime oyunları ve bulmacalar çözerim.', kategori: 'Sözel'),
      EnvanterSorusu(soruNo: 3, metin: 'Düşüncelerimi kolayca ifade edebilirim.', kategori: 'Sözel'),
      
      // Mantıksal-Matematiksel - 3 soru
      EnvanterSorusu(soruNo: 4, metin: 'Sayılar ve hesaplamalar ilgimi çeker.', kategori: 'Mantıksal'),
      EnvanterSorusu(soruNo: 5, metin: 'Problemleri mantıksal olarak çözerim.', kategori: 'Mantıksal'),
      EnvanterSorusu(soruNo: 6, metin: 'Bilimsel deneyler yapmayı severim.', kategori: 'Mantıksal'),
      
      // Görsel-Mekansal - 3 soru
      EnvanterSorusu(soruNo: 7, metin: 'Resim, grafik ve haritalar ilgimi çeker.', kategori: 'Görsel'),
      EnvanterSorusu(soruNo: 8, metin: 'Yön bulmada iyiyim.', kategori: 'Görsel'),
      EnvanterSorusu(soruNo: 9, metin: 'Zihnimde görüntüler ve şekiller canlandırabilirim.', kategori: 'Görsel'),
      
      // Müziksel-Ritmik - 3 soru
      EnvanterSorusu(soruNo: 10, metin: 'Müzik dinlemek veya çalmak hoşuma gider.', kategori: 'Müziksel'),
      EnvanterSorusu(soruNo: 11, metin: 'Ritimleri ve melodileri kolayca hatırlarım.', kategori: 'Müziksel'),
      EnvanterSorusu(soruNo: 12, metin: 'Çalışırken müzik dinlemeyi severim.', kategori: 'Müziksel'),
      
      // Bedensel-Kinestetik - 3 soru
      EnvanterSorusu(soruNo: 13, metin: 'Spor ve fiziksel aktivitelerden keyif alırım.', kategori: 'Bedensel'),
      EnvanterSorusu(soruNo: 14, metin: 'Ellerimi kullanarak bir şeyler yapmayı severim.', kategori: 'Bedensel'),
      EnvanterSorusu(soruNo: 15, metin: 'Dans etmek veya hareket etmek bana iyi gelir.', kategori: 'Bedensel'),
      
      // Sosyal-Kişilerarası - 3 soru
      EnvanterSorusu(soruNo: 16, metin: 'İnsanlarla iletişim kurmak kolayıma gelir.', kategori: 'Sosyal'),
      EnvanterSorusu(soruNo: 17, metin: 'Grup çalışmalarını severim.', kategori: 'Sosyal'),
      EnvanterSorusu(soruNo: 18, metin: 'Başkalarının duygularını anlayabiliyorum.', kategori: 'Sosyal'),
      
      // İçsel-Bireysel - 3 soru
      EnvanterSorusu(soruNo: 19, metin: 'Kendi başıma düşünmeyi severim.', kategori: 'İçsel'),
      EnvanterSorusu(soruNo: 20, metin: 'Güçlü ve zayıf yönlerimi bilirim.', kategori: 'İçsel'),
      EnvanterSorusu(soruNo: 21, metin: 'Kendimi iyi tanırım.', kategori: 'İçsel'),
      
      // Doğacı - 3 soru
      EnvanterSorusu(soruNo: 22, metin: 'Doğada vakit geçirmeyi severim.', kategori: 'Doğacı'),
      EnvanterSorusu(soruNo: 23, metin: 'Hayvanlar ve bitkiler ilgimi çeker.', kategori: 'Doğacı'),
      EnvanterSorusu(soruNo: 24, metin: 'Çevre sorunlarına duyarlıyım.', kategori: 'Doğacı'),
    ],
  );

  // ============================================
  // AI YORUM OLUŞTURMA
  // ============================================
  
  /// Holland testi için AI yorumu
  static String hollandYorumu(Map<String, int> skorlar) {
    // En yüksek 3 kategoriyi bul
    var sirali = skorlar.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    var en1 = sirali[0].key;
    var en2 = sirali[1].key;
    var en3 = sirali[2].key;
    
    String meslek = _meslekOnerisi(en1, en2);
    
    return "🎯 Profil: $en1-$en2-$en3\n\n"
           "En güçlü yönün '$en1' alanında. "
           "$meslek\n\n"
           "💡 Bu alanlarda kendini geliştirmeye devam edersen başarılı olabilirsin!";
  }
  
  static String _meslekOnerisi(String en1, String en2) {
    Map<String, String> meslekler = {
      'Gerçekçi': 'Mühendislik, Mimarlık, Teknisyenlik',
      'Araştırmacı': 'Bilim İnsanı, Doktor, Eczacı',
      'Sanatsal': 'Grafik Tasarım, Müzisyen, Yazar',
      'Sosyal': 'Öğretmen, Psikolog, Sosyal Hizmet',
      'Girişimci': 'İşletmeci, Pazarlama, Hukuk',
      'Geleneksel': 'Muhasebe, Bankacılık, Sekreterlik',
    };
    return "Sana uygun meslekler: ${meslekler[en1]}, ${meslekler[en2]}";
  }
  
  /// Sınav kaygısı için AI yorumu
  static String kaygiYorumu(int toplamSkor) {
    String seviye;
    String oneri;
    
    if (toplamSkor <= 40) {
      seviye = "Düşük";
      oneri = "Sınav kaygın normal seviyede. Mevcut stratejilerine devam et!";
    } else if (toplamSkor <= 60) {
      seviye = "Orta-Düşük";
      oneri = "Hafif kaygı belirtileri var. Düzenli nefes egzersizleri faydalı olabilir.";
    } else if (toplamSkor <= 75) {
      seviye = "Orta";
      oneri = "Kaygı seviyesi orta düzeyde. Pomodoro tekniği ve düzenli molalar öneriyorum.";
    } else if (toplamSkor <= 90) {
      seviye = "Yüksek";
      oneri = "Kaygı seviyesi yüksek. Meditasyon, spor ve profesyonel destek düşünebilirsin.";
    } else {
      seviye = "Çok Yüksek";
      oneri = "Ciddi sınav kaygısı belirtileri var. Bir uzmanla görüşmeni öneriyorum.";
    }
    
    return "📊 Kaygı Seviyesi: $seviye\n\n$oneri";
  }
  
  /// Başarısızlık nedenleri için AI yorumu
  static String basarisizlikYorumu(Map<String, int> skorlar) {
    var sirali = skorlar.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    var enBuyukEngel = sirali[0].key;
    
    Map<String, String> oneriler = {
      'Motivasyon': 'Küçük, ulaşılabilir hedefler koy ve kendini ödüllendir.',
      'Çalışma Yöntemi': 'Aktif öğrenme teknikleri dene: özetleme, soru çözme, akran öğretimi.',
      'Dikkat': 'Pomodoro tekniği (25dk çalış, 5dk mola) ve telefonu uzaklaştır.',
      'Stres': 'Nefes egzersizleri, meditasyon ve düzenli uyku alışkanlığı edin.',
      'Çevre': 'Kütüphane gibi sessiz ortamlar bul, aile ile iletişim kur.',
    };
    
    return "🔍 En Büyük Engelin: $enBuyukEngel\n\n"
           "💡 Öneri: ${oneriler[enBuyukEngel]}\n\n"
           "Diğer alanları da göz ardı etme!";
  }
  
  /// Burdon testi için AI yorumu
  static String burdonYorumu(double basariYuzdesi, int dogru, int yanlis) {
    String seviye;
    String oneri;
    
    if (basariYuzdesi >= 90) {
      seviye = "Mükemmel";
      oneri = "Dikkat ve konsantrasyonun harika! Bu seviyeyi koru.";
    } else if (basariYuzdesi >= 75) {
      seviye = "İyi";
      oneri = "Dikkat seviyen iyi. Düzenli pratikle daha da geliştirebilirsin.";
    } else if (basariYuzdesi >= 50) {
      seviye = "Orta";
      oneri = "Dikkat seviyeni geliştirmek için puzzle, sudoku gibi oyunlar oynayabilirsin.";
    } else {
      seviye = "Geliştirilmeli";
      oneri = "Dikkat egzersizleri yapmalısın. Meditasyon ve odaklanma teknikleri dene.";
    }
    
    return "🎯 Dikkat Seviyesi: $seviye\n"
           "✅ Doğru: $dogru | ❌ Yanlış: $yanlis\n\n"
           "$oneri";
  }

  /// VARK Öğrenme Stilleri için AI yorumu
  static String varkYorumu(Map<String, int> skorlar) {
    var sirali = skorlar.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    var baskinStil = sirali[0].key;
    
    Map<String, String> oneriler = {
      'Görsel': '👁️ Sen GÖRSEL bir öğrenencisin!\n\n'
               '• Konu anlatım videolarını izle\n'
               '• Renkli kalemlerle not tut\n'
               '• Şema, grafik ve zihin haritaları kullan\n'
               '• Konuları görselleştirerek ezberle',
      'İşitsel': '👂 Sen İŞİTSEL bir öğrenencisin!\n\n'
                 '• Podcast ve sesli kitap dinle\n'
                 '• Konuları sesli oku veya birilerine anlat\n'
                 '• Tartışma gruplarına katıl\n'
                 '• Kayıt yapıp kendini dinle',
      'Okuma-Yazma': '✍️ Sen OKUMA-YAZMA stilinde öğreniyorsun!\n\n'
                     '• Detaylı notlar tut\n'
                     '• Kitap ve yazılı kaynaklardan çalış\n'
                     '• Listeler ve özetler hazırla\n'
                     '• Anlamadıklarını yazarak tekrar et',
      'Kinestetik': '🏃 Sen KİNESTETİK (Dokunsal) bir öğrenencisin!\n\n'
                    '• Yaparak ve deneyerek öğren\n'
                    '• Yürürken veya hareket ederken çalış\n'
                    '• Pratik uygulamalar yap\n'
                    '• Sık sık mola ver, hareketsiz kalma',
    };
    
    return oneriler[baskinStil] ?? 'Öğrenme stilin belirlendi.';
  }

  /// Çalışma Davranışları için AI yorumu (Yıldızlı karne)
  static String calismaDavranislariYorumu(Map<String, int> skorlar) {
    String karne = "📊 ÇALIŞMA KARNEN\n\n";
    
    for (var entry in skorlar.entries) {
      int yildiz = (entry.value / 2).round().clamp(1, 5);
      String yildizStr = '⭐' * yildiz + '☆' * (5 - yildiz);
      String durum = yildiz <= 2 ? '(Geliştir!)' : yildiz <= 3 ? '(Orta)' : '(İyi)';
      karne += "${entry.key}: $yildizStr $durum\n";
    }
    
    // En zayıf alanı bul
    var sirali = skorlar.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    var enZayif = sirali[0].key;
    
    Map<String, String> ipuclari = {
      'Zaman Yönetimi': 'Günlük ve haftalık plan yap, Pomodoro tekniği dene.',
      'Not Tutma': 'Cornell not sistemi veya zihin haritası kullan.',
      'Tekrar': 'Aralıklı tekrar (spaced repetition) yöntemini uygula.',
      'Ortam': 'Sessiz bir çalışma alanı oluştur, telefonu uzaklaştır.',
      'Motivasyon': 'Küçük hedefler koy, kendini ödüllendir.',
    };
    
    karne += "\n💡 Öncelikli Gelişim Alanın: $enZayif\n";
    karne += "📝 ${ipuclari[enZayif]}";
    
    return karne;
  }

  /// Akademik Benlik Saygısı için AI yorumu
  static String akademikBenlikYorumu(int toplamSkor) {
    String seviye;
    String mesaj;
    String bildirimTipi;
    
    if (toplamSkor >= 60) {
      seviye = "Yüksek";
      mesaj = "Kendine güvenin harika! Bu özgüveni koru ama kibirden kaçın.";
      bildirimTipi = "Rakiplerin çalışıyor, hadi masaya! 💪";
    } else if (toplamSkor >= 45) {
      seviye = "Orta";
      mesaj = "Potansiyeline inanıyorsun ama biraz daha cesaret gerekiyor.";
      bildirimTipi = "Yapabilirsin, her küçük adım seni hedefe yaklaştırır! 🚀";
    } else if (toplamSkor >= 30) {
      seviye = "Orta-Düşük";
      mesaj = "Kendine daha çok güvenmelisin. Hatalar öğrenme fırsatıdır!";
      bildirimTipi = "Harikasın! Her deneme seni güçlendirir! ⭐";
    } else {
      seviye = "Düşük";
      mesaj = "Akademik özgüvenin düşük görünüyor. Küçük başarılarla başla!";
      bildirimTipi = "Sana inanan insanlar var! Yapabilirsin! 💖";
    }
    
    return "💪 Akademik Benlik Saygısı: $seviye\n\n"
           "$mesaj\n\n"
           "📱 Sana özel bildirim stili:\n\"$bildirimTipi\"";
  }

  /// GRIT Azim Ölçeği için AI yorumu
  static String gritYorumu(int toplamSkor) {
    String seviye;
    String unvan;
    String mesaj;
    
    if (toplamSkor >= 50) {
      seviye = "Çok Yüksek";
      unvan = "🏆 YILMAZ SAVAŞÇI";
      mesaj = "Azim ve kararlılığın mükemmel! Angela Duckworth senden gurur duyardı.";
    } else if (toplamSkor >= 40) {
      seviye = "Yüksek";
      unvan = "💪 PES ETMEYEN";
      mesaj = "Azimlisin ve hedeflerine bağlısın. Bu yolda devam et!";
    } else if (toplamSkor >= 30) {
      seviye = "Orta";
      unvan = "🌱 GELİŞEN RUHLU";
      mesaj = "Potansiyelin var ama bazen pes edebiliyorsun. Küçük hedeflerle başla.";
    } else if (toplamSkor >= 20) {
      seviye = "Düşük";
      unvan = "🔄 ARAYIŞ İÇİNDE";
      mesaj = "Tutkunu bulmaya çalış. Sevdiğin şeyde azim göstermek kolaydır.";
    } else {
      seviye = "Çok Düşük";
      unvan = "🌟 KEŞFEDEN";
      mesaj = "Azim geliştirilebilir bir kas gibidir. Küçük adımlarla başla!";
    }
    
    return "$unvan\n\n"
           "📊 Azim Seviyesi: $seviye ($toplamSkor/60)\n\n"
           "$mesaj\n\n"
           "💡 İpucu: 'Yetenek seni başlatır, azim seni bitiş çizgisine taşır.'";
  }

  /// Çoklu Zeka Envanteri için AI yorumu
  static String cokluZekaYorumu(Map<String, int> skorlar) {
    var sirali = skorlar.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    var en1 = sirali[0].key;
    var en2 = sirali[1].key;
    
    Map<String, String> alanOnerisi = {
      'Sözel': 'Edebiyat, Hukuk, Gazetecilik, Öğretmenlik',
      'Mantıksal': 'Mühendislik, Tıp, Ekonomi, Bilgisayar',
      'Görsel': 'Mimarlık, Grafik Tasarım, Pilot, Cerrahlık',
      'Müziksel': 'Müzisyen, Ses Mühendisi, Müzik Öğretmeni',
      'Bedensel': 'Sporcu, Cerrah, Dansçı, Fizyoterapist',
      'Sosyal': 'Psikolog, Öğretmen, İnsan Kaynakları, Politikacı',
      'İçsel': 'Yazar, Filozof, Danışman, Girişimci',
      'Doğacı': 'Biyolog, Çevre Mühendisi, Veteriner, Tarım Uzmanı',
    };
    
    String alanSecimi = "";
    if (['Mantıksal', 'Görsel'].contains(en1) || ['Mantıksal', 'Görsel'].contains(en2)) {
      alanSecimi = "🔢 SAYISAL ALAN sana uygun görünüyor!";
    } else if (['Sözel', 'Sosyal'].contains(en1) || ['Sözel', 'Sosyal'].contains(en2)) {
      alanSecimi = "📚 SÖZEL ALAN veya EŞİT AĞIRLIK sana uygun görünüyor!";
    } else {
      alanSecimi = "⚖️ EŞİT AĞIRLIK veya özel yetenekler sana uygun görünüyor!";
    }
    
    return "🧠 EN GÜÇLÜ ZEKA ALANIN: $en1 ve $en2\n\n"
           "$alanSecimi\n\n"
           "💼 Kariyer Önerileri:\n"
           "• $en1: ${alanOnerisi[en1]}\n"
           "• $en2: ${alanOnerisi[en2]}";
  }
}

