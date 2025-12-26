import 'dart:math';

/// 🎭 Twin Personas - Anonim İkiz Kimlikleri
/// 50+ havalı kod adı ve emoji avatar kombinasyonu
class TwinPersonas {
  static final Random _random = Random();
  
  /// Kod Adları Listesi - Havalı ve motive edici isimler
  static const List<String> kodAdlari = [
    // Yırtıcılar
    'Neon Kaplan', 'Demir Kartal', 'Gölge Şahin', 'Kristal Tilki',
    'Elektrik Panter', 'Buz Aslanı', 'Ateş Baykuşu', 'Çelik Ejderha',
    'Fırtına Kobrası', 'Zümrüt Tavus', 'Altın Atmaca', 'Gece Kurdu',
    
    // Elementler
    'Yıldırım Okçu', 'Alev Savaşçı', 'Buz Prensi', 'Toprak Devı',
    'Rüzgar Kaşifi', 'Su Ustası', 'Işık Avcısı', 'Gölge Ninja',
    
    // Kozmik
    'Yıldız Gezgini', 'Ay Şövalyesi', 'Güneş Koruyucu', 'Galaksi Kaptanı',
    'Meteor Avcısı', 'Nebula Savaşçı', 'Kuasar Kaşifi', 'Pulsar Pilotu',
    
    // Efsanevi
    'Zaman Bükücü', 'Kadim Bilge', 'Mitik Kahraman', 'Efsane Avcı',
    'Destansı Savaşçı', 'Antik Koruyucu', 'Mistik Gezgin', 'Simya Ustası',
    
    // Teknolojik
    'Siber Savaşçı', 'Dijital Şampiyon', 'Kod Kırıcı', 'Data Avcısı',
    'Sistem Hakeri', 'Quantum Gezgin', 'Matrix Ustası', 'Pixel Şövalye',
    
    // Doğa
    'Orman Koruyucu', 'Okyanus Efendisi', 'Dağ Devı', 'Çöl Tilkisi',
    'Buzul Avcısı', 'Volkan Ustası', 'Fırtına Çağırıcı', 'Şimşek Tanrısı',
  ];

  /// Emoji Avatarları - Her biri bir persona'yı temsil eder
  static const List<String> avatarlar = [
    // Hayvanlar
    '🐯', '🦅', '🦊', '🐺', '🐆', '🦁', '🦉', '🐉',
    '🐍', '🦚', '🦇', '🐻‍❄️', '🦈', '🐙', '🦋', '🦄',
    
    // Elementler
    '⚡', '🔥', '❄️', '🌊', '🌪️', '☀️', '🌙', '⭐',
    
    // Objeler
    '💎', '🗡️', '🛡️', '🎯', '🏆', '👑', '🎭', '🔮',
  ];

  /// Deterministik persona ataması
  /// Aynı odgrenciId için her zaman aynı persona döner
  static (String kodAdi, String emoji) ataPersona(String odgrenciId) {
    // Hash bazlı seçim - aynı ID her zaman aynı sonucu verir
    int hash = odgrenciId.hashCode.abs();
    
    String kodAdi = kodAdlari[hash % kodAdlari.length];
    String emoji = avatarlar[(hash ~/ kodAdlari.length) % avatarlar.length];
    
    return (kodAdi, emoji);
  }

  /// Rastgele yeni persona ata (Lig atlayınca kullanılır)
  static (String kodAdi, String emoji) rastgelePersona() {
    String kodAdi = kodAdlari[_random.nextInt(kodAdlari.length)];
    String emoji = avatarlar[_random.nextInt(avatarlar.length)];
    return (kodAdi, emoji);
  }

  /// Seviye hesapla (puana göre 1-20 arası)
  static int hesaplaSeviye(int twinScore) {
    // 0-1000 puan -> 1-20 seviye
    return ((twinScore / 50) + 1).clamp(1, 20).toInt();
  }

  /// Seviye unvanı
  static String seviyeUnvani(int seviye) {
    if (seviye >= 18) return 'Efsane';
    if (seviye >= 15) return 'Usta';
    if (seviye >= 12) return 'Uzman';
    if (seviye >= 9) return 'Tecrübeli';
    if (seviye >= 6) return 'Gelişen';
    if (seviye >= 3) return 'Çaylak';
    return 'Acemi';
  }

  /// Seviye rengi (hex kodu)
  static String seviyeRengi(int seviye) {
    if (seviye >= 18) return '#FFD700'; // Altın
    if (seviye >= 15) return '#9B59B6'; // Mor
    if (seviye >= 12) return '#3498DB'; // Mavi
    if (seviye >= 9) return '#2ECC71';  // Yeşil
    if (seviye >= 6) return '#F39C12';  // Turuncu
    if (seviye >= 3) return '#95A5A6';  // Gri
    return '#BDC3C7'; // Açık gri
  }
}

/// Kullanılabilir reaksiyon emojileri
class TwinReactions {
  static const List<Map<String, String>> tumReaksiyonlar = [
    {'emoji': '🔥', 'ad': 'Alev At', 'aciklama': 'Harika iş çıkardığını göster!'},
    {'emoji': '👏', 'ad': 'Alkışla', 'aciklama': 'Başarıyı kutla!'},
    {'emoji': '💤', 'ad': 'Dürt', 'aciklama': 'Çalışmaya başlamasını hatırlat!'},
    {'emoji': '⚡', 'ad': 'Enerji', 'aciklama': 'Motivasyon gönder!'},
    {'emoji': '🎯', 'ad': 'Hedef', 'aciklama': 'Hedefe odaklanmasını hatırlat!'},
  ];

  static String emojiAciklama(String emoji) {
    final reaksiyon = tumReaksiyonlar.firstWhere(
      (r) => r['emoji'] == emoji,
      orElse: () => {'aciklama': 'Reaksiyon gönderdi'},
    );
    return reaksiyon['aciklama']!;
  }
}
