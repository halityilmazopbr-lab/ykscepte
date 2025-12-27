/// 🏆 NET-X Lig Modülü - Servis
/// Mock data + Firebase ready yapı

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'league_models.dart';

class LeagueService {
  static final LeagueService _instance = LeagueService._internal();
  factory LeagueService() => _instance;
  LeagueService._internal();

  // ═══════════════════════════════════════════════════════════════
  // 🏫 OKUL İSİMLERİ HAVUZU
  // ═══════════════════════════════════════════════════════════════

  final List<String> _schools = [
    'Galatasaray Lisesi', 'İstanbul Erkek Lisesi', 'Ankara Fen Lisesi',
    'Kabataş Erkek Lisesi', 'Robert Koleji', 'İzmir Fen Lisesi',
    'Çapa Fen Lisesi', 'Kadıköy Anadolu Lisesi', 'Cağaloğlu Anadolu',
    'Adana Fen Lisesi', 'Bursa Anadolu Lisesi', 'Gazi Anadolu Lisesi',
    'Trabzon Fen Lisesi', 'Konya Fen Lisesi', 'ODTÜ Geliştirme Vakfı',
    'TED Ankara Koleji', 'Özel Darüşşafaka', 'Eyüboğlu Koleji',
    'Uskudar Amerikan', 'Saint Joseph Lisesi', 'Notre Dame de Sion',
    'Alman Lisesi', 'Avusturya Lisesi', 'İtalyan Lisesi',
    'Beşiktaş Anadolu', 'Pertevniyal Lisesi', 'Vefa Lisesi',
    'Haydarpaşa Lisesi', 'Atatürk Fen Lisesi', 'Bornova Anadolu',
  ];

  // ═══════════════════════════════════════════════════════════════
  // 👤 OYUNCU TAKMA İSİMLERİ (Hibrit Mix)
  // ═══════════════════════════════════════════════════════════════

  final List<String> _agentNames = [
    // 🦁 Hayvan Temalı
    'Aslan Yürek', 'Kartal Göz', 'Kurt Tırnak', 'Tilki Zeka', 'Baykuş Bilge',
    'Kaplan Gücü', 'Şahin Hız', 'Ayı Kral', 'Panter Gölge', 'Vaşak Çevik',
    
    // ⚡ Mitolojik
    'Zeus Yıldırım', 'Apollo Işık', 'Artemis Ok', 'Hera Kraliçe', 'Ares Savaş',
    'Athena Bilge', 'Poseidon Dalga', 'Hermes Hızlı', 'Hades Gizem', 'Nike Zafer',
    
    // 👑 Ünvan Temalı
    'Şampiyon Ruh', 'Yıldız Avcı', 'Deha Beyni', 'Hedef Vuran', 'Zirve Koşan',
    'Altın Kalem', 'Elmas Zihin', 'Bronz Güç', 'Gümüş Ok', 'Platin Kalp',
    
    // 🎮 Eğlenceli
    'Kitap Kurdu', 'Formül Ustası', 'Çözüm Avcısı', 'Net Toplayıcı', 'Puan Canavarı',
    'Soru Delisi', 'Test Ustası', 'Sınav Savaşçısı', 'YKS Kahramanı', 'TYT Efsanesi',
    
    // 🌟 Kozmik
    'Nebula Zihin', 'Galaksi Yolcu', 'Kuasar Işık', 'Meteor Hız', 'Yıldız Tozu',
    'Güneş Savaşçı', 'Ay Prens', 'Mars Kızıl', 'Satürn Halka', 'Venüs Işıltı',
  ];

  final List<String> _avatars = [
    // Hayvan
    '🦁', '🦅', '🐺', '🦊', '🦉', '🐯', '🦅', '🐻', '🐆', '🐱',
    // Mitolojik
    '⚡', '☀️', '🏹', '👑', '⚔️', '🦉', '🌊', '👟', '💀', '🏆',
    // Ünvan
    '🏅', '⭐', '🧠', '🎯', '🏔️', '✏️', '💎', '🥉', '🥈', '💜',
    // Eğlenceli
    '📚', '🧮', '🔍', '📊', '👾', '❓', '📝', '⚔️', '🦸', '🌟',
    // Kozmik
    '🌌', '🚀', '💫', '☄️', '✨', '☀️', '🌙', '🔴', '🪐', '💖',
  ];

  // ═══════════════════════════════════════════════════════════════
  // 📊 LİG VERİSİ
  // ═══════════════════════════════════════════════════════════════

  /// Mevcut lig bilgisini getir
  Future<LeagueInfo> getLeagueInfo() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Hafta sonu pazar 23:59
    final now = DateTime.now();
    final daysUntilSunday = DateTime.sunday - now.weekday;
    final sunday = now.add(Duration(days: daysUntilSunday >= 0 ? daysUntilSunday : 7 + daysUntilSunday));
    final weekEnd = DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59);

    return LeagueInfo(
      tier: 2, // 1. Lig
      tierName: '1. LİG',
      season: 4,
      week: 34,
      weekEnd: weekEnd,
      totalPlayers: 30,
    );
  }

  /// Haftalık 30 kişilik lig grubunu getir
  Future<List<LeaguePlayer>> getLeagueGroup({
    required String myUserId,
    String? myName,
    String? mySchool,
    int? myXp,
  }) async {
    // Simüle edilmiş ağ gecikmesi
    await Future.delayed(const Duration(milliseconds: 800));

    List<LeaguePlayer> players = [];
    Random random = Random();

    // Kullanıcının gerçek XP'si (yoksa rastgele)
    final userXp = myXp ?? (1200 + random.nextInt(600));
    final userName = myName ?? 'Sen';
    final userSchool = mySchool ?? 'Bilinmeyen Okul';

    // 29 Rakip Oluştur
    for (int i = 0; i < 29; i++) {
      final randomXp = 800 + random.nextInt(1500); // 800-2300 arası
      final nameIndex = i % _agentNames.length;
      final schoolIndex = random.nextInt(_schools.length);
      
      players.add(LeaguePlayer(
        id: 'rival_$i',
        name: _agentNames[nameIndex],
        school: _schools[schoolIndex],
        avatar: _avatars[nameIndex],
        xp: randomXp,
        rank: 0, // Sonra hesaplanacak
        trend: random.nextDouble() > 0.5 
            ? 'up' 
            : (random.nextDouble() > 0.5 ? 'down' : 'flat'),
        weeklyQuestions: 50 + random.nextInt(200),
        streak: random.nextInt(14),
      ));
    }

    // Beni listeye ekle
    players.add(LeaguePlayer(
      id: myUserId,
      name: userName,
      school: userSchool,
      avatar: '🎯',
      xp: userXp,
      rank: 0,
      isMe: true,
      trend: 'up',
      weeklyQuestions: 120,
      streak: 7,
    ));

    // Puan sıralaması (büyükten küçüğe)
    players.sort((a, b) => b.xp.compareTo(a.xp));

    // Sıra numaralarını güncelle
    final rankedPlayers = <LeaguePlayer>[];
    for (int i = 0; i < players.length; i++) {
      final p = players[i];
      rankedPlayers.add(LeaguePlayer(
        id: p.id,
        name: p.name,
        school: p.school,
        avatar: p.avatar,
        xp: p.xp,
        rank: i + 1,
        trend: p.trend,
        isMe: p.isMe,
        weeklyQuestions: p.weeklyQuestions,
        streak: p.streak,
      ));
    }

    debugPrint('🏆 Lig grubu oluşturuldu: ${rankedPlayers.length} oyuncu');
    return rankedPlayers;
  }

  /// Kullanıcının lig geçmişini getir
  Future<List<Map<String, dynamic>>> getLeagueHistory(String userId, {int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock geçmiş verisi
    return [
      {'week': 33, 'rank': 8, 'xp': 1380, 'result': 'safe'},
      {'week': 32, 'rank': 12, 'xp': 1250, 'result': 'safe'},
      {'week': 31, 'rank': 5, 'xp': 1520, 'result': 'promoted'},
      {'week': 30, 'rank': 3, 'xp': 1680, 'result': 'promoted'},
      {'week': 29, 'rank': 18, 'xp': 980, 'result': 'safe'},
    ];
  }

  /// Okul sıralamasını getir
  Future<List<Map<String, dynamic>>> getSchoolRankings({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final random = Random();
    final schoolRankings = <Map<String, dynamic>>[];
    
    for (int i = 0; i < limit && i < _schools.length; i++) {
      schoolRankings.add({
        'rank': i + 1,
        'school': _schools[i],
        'totalXp': 50000 + random.nextInt(30000),
        'playerCount': 15 + random.nextInt(50),
        'avgXp': 1200 + random.nextInt(500),
      });
    }
    
    // Toplam XP'ye göre sırala
    schoolRankings.sort((a, b) => (b['totalXp'] as int).compareTo(a['totalXp'] as int));
    
    // Sıra numaralarını güncelle
    for (int i = 0; i < schoolRankings.length; i++) {
      schoolRankings[i]['rank'] = i + 1;
    }
    
    return schoolRankings;
  }

  // ═══════════════════════════════════════════════════════════════
  // 🏫 OKULLAR LİGİ (CLAN WARS)
  // ═══════════════════════════════════════════════════════════════

  /// Okul logolarını getir
  final Map<String, String> _schoolLogos = {
    'Galatasaray Lisesi': '🦁',
    'İstanbul Erkek Lisesi': '🏛️',
    'Ankara Fen Lisesi': '🔬',
    'Kabataş Erkek Lisesi': '⚓',
    'Robert Koleji': '🎓',
    'İzmir Fen Lisesi': '🧪',
    'Çapa Fen Lisesi': '⚕️',
    'Kadıköy Anadolu Lisesi': '🎭',
    'Cağaloğlu Anadolu': '📚',
    'Adana Fen Lisesi': '🌟',
    'Bursa Anadolu Lisesi': '🏔️',
    'Gazi Anadolu Lisesi': '🦅',
  };

  /// OKULLAR SÜPER LİGİ - Bireysel verilerin toplamı
  Future<List<Clan>> getClanLeaderboard({String? mySchoolName}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final random = Random();
    
    // 12 takımlı Süper Lig simülasyonu
    // Gerçekte bu veriler Firebase'den gelecek (öğrenci XP'lerinin toplamı)
    final List<Map<String, dynamic>> rawData = [
      {'id': 's1', 'name': 'Galatasaray Lisesi', 'totalXp': 450200, 'memberCount': 120, 'trend': 'up'},
      {'id': 's2', 'name': 'Ankara Fen Lisesi', 'totalXp': 448100, 'memberCount': 115, 'trend': 'up'},
      {'id': 's3', 'name': 'İstanbul Erkek Lisesi', 'totalXp': 430000, 'memberCount': 90, 'trend': 'flat'},
      {'id': 's4', 'name': 'Kabataş Erkek Lisesi', 'totalXp': 410500, 'memberCount': 105, 'trend': 'down'},
      {'id': 's5', 'name': 'İzmir Fen Lisesi', 'totalXp': 390000, 'memberCount': 88, 'trend': 'flat'},
      {'id': 's6', 'name': 'Robert Koleji', 'totalXp': 380000, 'memberCount': 70, 'trend': 'up'},
      {'id': 's7', 'name': 'Çapa Fen Lisesi', 'totalXp': 375000, 'memberCount': 95, 'trend': 'up'},
      {'id': 's8', 'name': 'Kadıköy Anadolu Lisesi', 'totalXp': 360000, 'memberCount': 130, 'trend': 'down'},
      {'id': 's9', 'name': 'Cağaloğlu Anadolu', 'totalXp': 340000, 'memberCount': 85, 'trend': 'flat'},
      // Düşme Hattı (Son 3)
      {'id': 's10', 'name': 'Bursa Anadolu Lisesi', 'totalXp': 310000, 'memberCount': 60, 'trend': 'down'},
      {'id': 's11', 'name': 'Adana Fen Lisesi', 'totalXp': 290000, 'memberCount': 55, 'trend': 'down'},
      {'id': 's12', 'name': 'Gazi Anadolu Lisesi', 'totalXp': 280000, 'memberCount': 50, 'trend': 'down'},
    ];

    // Rastgele varyasyon ekle (dinamik görünsün)
    for (var data in rawData) {
      data['totalXp'] = (data['totalXp'] as int) + random.nextInt(10000) - 5000;
      data['memberCount'] = (data['memberCount'] as int) + random.nextInt(10) - 5;
    }

    // Toplam XP'ye göre sırala
    rawData.sort((a, b) => (b['totalXp'] as int).compareTo(a['totalXp'] as int));

    // Clan listesi oluştur
    final clans = <Clan>[];
    for (int i = 0; i < rawData.length; i++) {
      final data = rawData[i];
      final schoolName = data['name'] as String;
      
      clans.add(Clan(
        id: data['id'] as String,
        name: schoolName,
        logo: _schoolLogos[schoolName],
        totalXp: data['totalXp'] as int,
        memberCount: data['memberCount'] as int,
        rank: i + 1,
        trend: data['trend'] as String,
        tier: 1, // Süper Lig
        isMySchool: schoolName == mySchoolName,
      ));
    }

    debugPrint('🏫 Okul ligi oluşturuldu: ${clans.length} okul');
    return clans;
  }
}

