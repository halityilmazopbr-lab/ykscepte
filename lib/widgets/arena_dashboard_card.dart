import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/arena_service.dart';
import '../models/arena_challenge_model.dart';
import '../screens/arena_challenge_page.dart';
import 'dart:async';

/// Arena Dashboard Card
/// 
/// Dashboard'da en üstte görünecek vitrin kartı.
/// Aktif challenge varsa gradient kart, yoksa "Yakında" kartı gösterir.
class ArenaDashboardCard extends StatefulWidget {
  const ArenaDashboardCard({super.key});

  @override
  State<ArenaDashboardCard> createState() => _ArenaDashboardCardState();
}

class _ArenaDashboardCardState extends State<ArenaDashboardCard> {
  final ArenaService _service = ArenaService();
  
  // Countdown timer için
  Timer? _countdownTimer;
  int _kalanSaniye = 0;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown(int kalanSaniye) {
    _kalanSaniye = kalanSaniye;
    _countdownTimer?.cancel();
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_kalanSaniye > 0) {
            _kalanSaniye--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  String _formatKalanSure(int saniye) {
    final saat = saniye ~/ 3600;
    final dakika = (saniye % 3600) ~/ 60;
    final sn = saniye % 60;
    return '${saat.toString().padLeft(2, '0')}:${dakika.toString().padLeft(2, '0')}:${sn.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _service.aktifChallengeGetir(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildWaitingCard();
        }

        var challengeData = snapshot.data!.docs.first;
        var challenge = ArenaChallengeModel.fromMap(
          challengeData.data() as Map<String, dynamic>,
          challengeData.id,
        );

        // Countdown başlat
        if (_kalanSaniye == 0) {
          _startCountdown(challenge.kalanSureSaniye);
        }

        return _buildActiveChallengeCard(context, challenge);
      },
    );
  }

  Widget _buildActiveChallengeCard(BuildContext context, ArenaChallengeModel challenge) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade900, Colors.orange.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArenaChallengePage(challenge: challenge),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: İkon + Başlık + Countdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.yellow.shade600,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ARENA AKTİF!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    // Countdown timer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatKalanSure(_kalanSaniye),
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Courier',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Başlık ve açıklama
                Text(
                  challenge.baslik,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  challenge.aciklama,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // İstatistikler
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem(
                      Icons.people,
                      '${challenge.katilimciSayisi}',
                      'Katıldı',
                    ),
                    _statItem(
                      Icons.emoji_events,
                      '${challenge.xpOdul} XP',
                      'Ödül',
                    ),
                    _statItem(
                      Icons.check_circle,
                      '${challenge.basariOrani.toStringAsFixed(0)}%',
                      'Başarı',
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // CTA Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArenaChallengePage(challenge: challenge),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'MEYDAN OKUMAYA KATIL',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        color: const Color(0xFF21262D),
        child: ListTile(
          leading: Icon(Icons.lock_clock, color: Colors.grey.shade400),
          title: const Text(
            'Arena Kapalı',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            'Bir sonraki meydan okuma: Bugün 20:00',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: const Card(
        color: Color(0xFF21262D),
        child: ListTile(
          leading: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
          title: Text(
            'Arena yükleniyor...',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
