import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/arena_service.dart';
import '../models/arena_katilim_model.dart';

/// Arena Leaderboard Page
/// 
/// Challenge lider tablosu:
/// - Top 10 sıralama (podium görsel)
/// - Kullanıcının kendi sırası (highlight)
/// - Realtime updates
class ArenaLeaderboardPage extends StatefulWidget {
  final String challengeId;

  const ArenaLeaderboardPage({super.key, required this.challengeId});

  @override
  State<ArenaLeaderboardPage> createState() => _ArenaLeaderboardPageState();
}

class _ArenaLeaderboardPageState extends State<ArenaLeaderboardPage> {
  final ArenaService _service = ArenaService();
  final String _currentUserId = 'demo_user'; // Gerçek uygulamada auth.currentUser.uid

  int? _kullaniciSirasi;

  @override
  void initState() {
    super.initState();
    _kullaniciSirasiniGetir();
  }

  Future<void> _kullaniciSirasiniGetir() async {
    var siralama = await _service.kullaniciSiralamasi(
      widget.challengeId,
      _currentUserId,
    );
    
    if (mounted) {
      setState(() {
        _kullaniciSirasi = siralama;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          'Lider Tablosu',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Kullanıcının sırası (eğer top 10'da değilse)
          if (_kullaniciSirasi != null && _kullaniciSirasi! > 10)
            _buildKullaniciSirasiKarti(),
          
          // Top 10 Liste
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _service.liderTablosuGetir(widget.challengeId, limit: 10),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.purple),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Henüz katılım yok',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                var katilimcilar = snapshot.data!.docs.map((doc) {
                  return ArenaKatilimModel.fromMap(doc.data() as Map<String, dynamic>);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: katilimcilar.length,
                  itemBuilder: (context, index) {
                    var katilimci = katilimcilar[index];
                    int sira = index + 1;
                    bool benimKayit = katilimci.userId == _currentUserId;

                    return _buildLeaderboardItem(
                      sira,
                      katilimci,
                      benimKayit,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKullaniciSirasiKarti() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.2),
        border: Border.all(color: Colors.purple, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, color: Colors.purple),
          const SizedBox(width: 8),
          Text(
            'Sıralaman: $_kullaniciSirasi',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(int sira, ArenaKatilimModel katilimci, bool benimKayit) {
    // Podium renkleri
    Color? siraRengi;
    IconData? medal;
    
    if (sira == 1) {
      siraRengi = Colors.amber;
      medal = Icons.emoji_events;
    } else if (sira == 2) {
      siraRengi = Colors.grey.shade400;
      medal = Icons.emoji_events;
    } else if (sira == 3) {
      siraRengi = Colors.orange.shade700;
      medal = Icons.emoji_events;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: benimKayit 
            ? Colors.purple.withOpacity(0.2) 
            : const Color(0xFF21262D),
        border: benimKayit 
            ? Border.all(color: Colors.purple, width: 2)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Sıra numarası veya medal
          SizedBox(
            width: 40,
            child: siraRengi != null && medal != null
                ? Icon(medal, color: siraRengi, size: 32)
                : Text(
                    '$sira',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          
          const SizedBox(width: 16),
          
          // Avatar (opsiyonel)
          if (katilimci.avatarUrl != null)
            CircleAvatar(
              backgroundImage: NetworkImage(katilimci.avatarUrl!),
              radius: 20,
            )
          else
            CircleAvatar(
              backgroundColor: Colors.grey.shade700,
              radius: 20,
              child: Text(
                katilimci.kullaniciAdi[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          
          const SizedBox(width: 12),
          
          // Kullanıcı bilgisi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  katilimci.kullaniciAdi,
                  style: TextStyle(
                    color: benimKayit ? Colors.purple.shade200 : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (katilimci.sehir != null)
                  Text(
                    katilimci.sehir!,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          
          // Puan ve süre
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${katilimci.puan}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Text(
                '${katilimci.sure}s',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
