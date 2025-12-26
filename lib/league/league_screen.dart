/// 🏆 NET-X Lig Modülü - Ana Ekran
/// School Wars Edition - Bireysel + Okul Çift Katmanlı Rekabet

import 'package:flutter/material.dart';
import 'league_models.dart';
import 'league_service.dart';

class LeagueScreen extends StatefulWidget {
  final String ogrenciId;
  final String? ogrenciAdi;
  final String? okulAdi;

  const LeagueScreen({
    super.key,
    required this.ogrenciId,
    this.ogrenciAdi,
    this.okulAdi,
  });

  @override
  State<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen> with SingleTickerProviderStateMixin {
  final LeagueService _service = LeagueService();
  late TabController _tabController;
  
  late Future<List<LeaguePlayer>> _playersFuture;
  late Future<List<Clan>> _clansFuture;
  late Future<LeagueInfo> _infoFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    _infoFuture = _service.getLeagueInfo();
    _playersFuture = _service.getLeagueGroup(
      myUserId: widget.ogrenciId,
      myName: widget.ogrenciAdi,
      mySchool: widget.okulAdi,
    );
    _clansFuture = _service.getClanLeaderboard(mySchoolName: widget.okulAdi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: FutureBuilder<LeagueInfo>(
          future: _infoFuture,
          builder: (context, infoSnapshot) {
            return Column(
              children: [
                _buildAppBar(infoSnapshot.data),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildIndividualTab(),
                      _buildClanTab(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎨 APP BAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAppBar(LeagueInfo? info) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'SEZON ${info?.season ?? '-'} / HAFTA ${info?.week ?? '-'}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '🏆 SÜPER LİG',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Kalan süre
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.redAccent),
              borderRadius: BorderRadius.circular(12),
              color: Colors.redAccent.withValues(alpha: 0.1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, color: Colors.redAccent, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${info?.remainingDays ?? 0} GÜN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📱 TAB BAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
        ),
        labelColor: Colors.cyanAccent,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            icon: Icon(Icons.person, size: 18),
            text: 'BİREYSEL',
          ),
          Tab(
            icon: Icon(Icons.school, size: 18),
            text: 'OKULLAR',
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 👤 BİREYSEL LİG SEKMESİ
  // ═══════════════════════════════════════════════════════════════

  Widget _buildIndividualTab() {
    return FutureBuilder<List<LeaguePlayer>>(
      future: _playersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        }
        
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Veri yüklenemedi', style: TextStyle(color: Colors.white70)));
        }

        final players = snapshot.data!;
        final myPlayer = players.firstWhere((p) => p.isMe, orElse: () => players.first);

        return RefreshIndicator(
          onRefresh: () async => setState(() => _loadData()),
          color: Colors.cyanAccent,
          child: Column(
            children: [
              _buildStatusCard(
                rank: myPlayer.rank,
                title: 'AJAN DURUMU',
                isPromoting: myPlayer.isPromoting,
                isRelegating: myPlayer.isRelegating,
                themeColor: Colors.cyan,
              ),
              _buildTableHeader(isClan: false),
              Expanded(child: _buildPlayerList(players)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerList(List<LeaguePlayer> players) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        
        // Bölge renkleri
        Color? zoneColor;
        if (player.rank <= 5) zoneColor = Colors.greenAccent;
        else if (player.rank > 25) zoneColor = Colors.redAccent;

        return _buildListItem(
          rank: player.rank,
          name: player.name,
          subtitle: player.school,
          avatar: player.avatar ?? '🎯',
          xp: player.xp,
          xpLabel: 'XP',
          trend: player.trend,
          isMine: player.isMe,
          zoneColor: zoneColor,
          highlightColor: Colors.cyanAccent,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🏫 OKULLAR LİGİ SEKMESİ
  // ═══════════════════════════════════════════════════════════════

  Widget _buildClanTab() {
    return FutureBuilder<List<Clan>>(
      future: _clansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.orange));
        }
        
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Veri yüklenemedi', style: TextStyle(color: Colors.white70)));
        }

        final clans = snapshot.data!;
        final mySchool = clans.firstWhere((c) => c.isMySchool, orElse: () => clans.first);

        return RefreshIndicator(
          onRefresh: () async => setState(() => _loadData()),
          color: Colors.orange,
          child: Column(
            children: [
              _buildStatusCard(
                rank: mySchool.rank,
                title: 'OKULUNUN DURUMU',
                isPromoting: mySchool.isChampion,
                isRelegating: mySchool.isRelegating,
                themeColor: Colors.orange,
                schoolName: mySchool.name,
              ),
              _buildTableHeader(isClan: true),
              Expanded(child: _buildClanList(clans)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClanList(List<Clan> clans) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: clans.length,
      itemBuilder: (context, index) {
        final clan = clans[index];
        
        // Bölge renkleri (İlk 3 şampiyonluk, son 3 düşme)
        Color? zoneColor;
        if (clan.rank <= 3) zoneColor = Colors.amber;
        else if (clan.rank > 9) zoneColor = Colors.redAccent;

        return _buildListItem(
          rank: clan.rank,
          name: clan.name,
          subtitle: '${clan.memberCount} öğrenci savaşıyor',
          avatar: clan.logo ?? '🏫',
          xp: clan.totalXp,
          xpLabel: 'TOPLAM',
          trend: clan.trend,
          isMine: clan.isMySchool,
          zoneColor: zoneColor,
          highlightColor: Colors.orangeAccent,
          formatXp: true,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 ORTAK WIDGET'LAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStatusCard({
    required int rank,
    required String title,
    required bool isPromoting,
    required bool isRelegating,
    required Color themeColor,
    String? schoolName,
  }) {
    Color statusColor;
    IconData statusIcon;
    String message;

    if (isPromoting) {
      statusColor = Colors.greenAccent;
      statusIcon = Icons.emoji_events;
      message = schoolName != null 
          ? 'Okulun şampiyonluğa koşuyor! 🏆'
          : 'Zirvedesin ajan! 🔥';
    } else if (isRelegating) {
      statusColor = Colors.redAccent;
      statusIcon = Icons.warning_amber;
      message = schoolName != null 
          ? 'Düşme hattı! Kurtarman lazım. ⚠️'
          : 'Düşme hattı! Acil puan lazım. ⚠️';
    } else {
      statusColor = Colors.blueGrey;
      statusIcon = Icons.shield_outlined;
      message = schoolName != null 
          ? 'Orta sıralar. Gaza bas! 🚀'
          : 'Güvenli bölge. Üst sıraları zorla! 🚀';
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withValues(alpha: 0.2), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
            child: Icon(statusIcon, color: statusColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: themeColor, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '#$rank',
              style: TextStyle(color: statusColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader({required bool isClan}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 30, child: Text('#', style: TextStyle(color: Colors.grey, fontSize: 12))),
          Expanded(
            child: Text(
              isClan ? 'OKUL' : 'AJAN & OKUL',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Text(
            isClan ? 'TOPLAM' : 'XP',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required int rank,
    required String name,
    required String subtitle,
    required String avatar,
    required int xp,
    required String xpLabel,
    required String trend,
    required bool isMine,
    Color? zoneColor,
    required Color highlightColor,
    bool formatXp = false,
  }) {
    // XP formatla (450200 → "450.2K")
    String displayXp = formatXp
        ? (xp >= 1000000
            ? '${(xp / 1000000).toStringAsFixed(1)}M'
            : xp >= 1000
                ? '${(xp / 1000).toStringAsFixed(1)}K'
                : xp.toString())
        : xp.toString();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      decoration: BoxDecoration(
        color: isMine ? highlightColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isMine ? Border.all(color: highlightColor.withValues(alpha: 0.3)) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        // SIRA NO VE BÖLGE ÇİZGİSİ
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 35,
              decoration: BoxDecoration(
                color: zoneColor ?? Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: zoneColor != null
                    ? [BoxShadow(color: zoneColor, blurRadius: 6)]
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 24,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: isMine ? highlightColor : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),

        // AVATAR + İSİM + ALT BAŞLIK
        title: Row(
          children: [
            Text(avatar, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: isMine ? highlightColor : Colors.white,
                      fontWeight: isMine ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        // PUAN VE TREND
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trend == 'up') const Icon(Icons.arrow_drop_up, color: Colors.green, size: 24),
            if (trend == 'down') const Icon(Icons.arrow_drop_down, color: Colors.red, size: 24),
            if (trend == 'flat') const Icon(Icons.remove, color: Colors.grey, size: 16),
            const SizedBox(width: 6),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  displayXp,
                  style: TextStyle(
                    color: formatXp ? Colors.amber : Colors.yellowAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  xpLabel,
                  style: const TextStyle(color: Colors.grey, fontSize: 9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
