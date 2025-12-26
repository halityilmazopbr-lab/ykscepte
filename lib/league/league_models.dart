/// 🏆 NET-X Lig Modülü - Veri Modelleri
/// School Wars Edition

/// Lig Oyuncusu Modeli
class LeaguePlayer {
  final String id;
  final String name;
  final String school;   // Okul Adı (Clan)
  final String? avatar;  // Emoji avatar
  final int xp;          // Haftalık puan
  final int rank;        // Sıralama (1-30)
  final String trend;    // 'up', 'down', 'flat'
  final bool isMe;       // Bu kullanıcı ben miyim?
  final int weeklyQuestions; // Haftalık çözülen soru
  final int streak;      // Günlük seri

  LeaguePlayer({
    required this.id,
    required this.name,
    required this.school,
    this.avatar,
    required this.xp,
    required this.rank,
    this.trend = 'flat',
    this.isMe = false,
    this.weeklyQuestions = 0,
    this.streak = 0,
  });

  /// Yükseliyor mu?
  bool get isPromoting => rank <= 5;
  
  /// Düşme hattında mı?
  bool get isRelegating => rank > 25;
  
  /// Güvenli bölgede mi?
  bool get isSafe => !isPromoting && !isRelegating;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'school': school,
    'avatar': avatar,
    'xp': xp,
    'rank': rank,
    'trend': trend,
    'isMe': isMe,
    'weeklyQuestions': weeklyQuestions,
    'streak': streak,
  };

  factory LeaguePlayer.fromJson(Map<String, dynamic> json) => LeaguePlayer(
    id: json['id'] ?? '',
    name: json['name'] ?? 'Ajan',
    school: json['school'] ?? 'Bilinmeyen Okul',
    avatar: json['avatar'],
    xp: json['xp'] ?? 0,
    rank: json['rank'] ?? 0,
    trend: json['trend'] ?? 'flat',
    isMe: json['isMe'] ?? false,
    weeklyQuestions: json['weeklyQuestions'] ?? 0,
    streak: json['streak'] ?? 0,
  );
}

/// Lig Bilgisi
class LeagueInfo {
  final int tier;        // Lig seviyesi (1=Süper, 2=1.Lig, 3=2.Lig...)
  final String tierName; // Lig adı
  final int season;      // Sezon numarası
  final int week;        // Hafta numarası
  final DateTime weekEnd; // Hafta bitiş zamanı
  final int totalPlayers; // Toplam oyuncu sayısı

  LeagueInfo({
    required this.tier,
    required this.tierName,
    required this.season,
    required this.week,
    required this.weekEnd,
    this.totalPlayers = 30,
  });

  /// Kalan süre
  Duration get remainingTime => weekEnd.difference(DateTime.now());
  
  /// Kalan gün
  int get remainingDays => remainingTime.inDays;
  
  /// Kalan saat
  int get remainingHours => remainingTime.inHours % 24;
}

/// Lig Tier Renkleri
class LeagueTiers {
  static const Map<int, Map<String, dynamic>> tiers = {
    1: {'name': 'SÜPER LİG', 'color': 0xFFFFD700, 'emoji': '🏆'},     // Altın
    2: {'name': '1. LİG', 'color': 0xFFC0C0C0, 'emoji': '🥈'},        // Gümüş
    3: {'name': '2. LİG', 'color': 0xFFCD7F32, 'emoji': '🥉'},        // Bronz
    4: {'name': '3. LİG', 'color': 0xFF4A90D9, 'emoji': '🔵'},        // Mavi
    5: {'name': 'AMATÖR LİG', 'color': 0xFF808080, 'emoji': '⚪'},    // Gri
  };

  static String getTierName(int tier) => tiers[tier]?['name'] ?? 'LİG';
  static int getTierColor(int tier) => tiers[tier]?['color'] ?? 0xFF808080;
  static String getTierEmoji(int tier) => tiers[tier]?['emoji'] ?? '🔵';
}

// ═══════════════════════════════════════════════════════════════
// 🏫 OKUL (CLAN) MODELİ
// ═══════════════════════════════════════════════════════════════

/// Okul/Clan Modeli - Bireysel verilerin toplamı
class Clan {
  final String id;
  final String name;         // Okul adı
  final String? logo;        // Okul logosu (emoji)
  final int totalXp;         // Tüm öğrencilerin toplam XP'si
  final int memberCount;     // Öğrenci sayısı
  final int rank;            // Lig sıralaması
  final String trend;        // 'up', 'down', 'flat'
  final int tier;            // Lig kademesi (1=Süper, 2=1.Lig...)
  final double avgXp;        // Öğrenci başına ortalama XP
  final bool isMySchool;     // Benim okulum mu?

  Clan({
    required this.id,
    required this.name,
    this.logo,
    required this.totalXp,
    required this.memberCount,
    required this.rank,
    this.trend = 'flat',
    this.tier = 1,
    double? avgXp,
    this.isMySchool = false,
  }) : avgXp = avgXp ?? (memberCount > 0 ? totalXp / memberCount : 0);

  /// Şampiyonluk hattında mı? (İlk 3)
  bool get isChampion => rank <= 3;
  
  /// Düşme hattında mı? (Son 3)
  bool get isRelegating => rank > 9; // 12 takımlı ligde son 3
  
  /// Güvenli bölgede mi?
  bool get isSafe => !isChampion && !isRelegating;

  /// XP'yi binlik formatla (450200 → "450.2K")
  String get formattedXp {
    if (totalXp >= 1000000) {
      return '${(totalXp / 1000000).toStringAsFixed(1)}M';
    } else if (totalXp >= 1000) {
      return '${(totalXp / 1000).toStringAsFixed(1)}K';
    }
    return totalXp.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logo': logo,
    'totalXp': totalXp,
    'memberCount': memberCount,
    'rank': rank,
    'trend': trend,
    'tier': tier,
    'avgXp': avgXp,
    'isMySchool': isMySchool,
  };

  factory Clan.fromJson(Map<String, dynamic> json, {bool isMySchool = false}) => Clan(
    id: json['id'] ?? '',
    name: json['name'] ?? 'Bilinmeyen Okul',
    logo: json['logo'],
    totalXp: json['totalXp'] ?? 0,
    memberCount: json['memberCount'] ?? 0,
    rank: json['rank'] ?? 0,
    trend: json['trend'] ?? 'flat',
    tier: json['tier'] ?? 1,
    avgXp: (json['avgXp'] as num?)?.toDouble(),
    isMySchool: isMySchool,
  );
}
