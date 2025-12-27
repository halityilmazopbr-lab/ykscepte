import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 🔍 SORU MODERASYON SİSTEMİ
/// Hibrit yaklaşım: Otomatik tespit + Admin inceleme + Zamanaşımı silme
/// 
/// Akış:
/// 1. Kullanıcı soruyu puanlar (👍/👎)
/// 2. 3 olumsuz puan → "İnceleme Kuyruğu"na alınır
/// 3. Admin inceleyebilir: Onayla / Düzenle / Sil
/// 4. 10 gün içinde incelenmezse → Otomatik silinir

class QuestionModerationService {
  static final _db = FirebaseFirestore.instance;
  static const _reviewThreshold = 3; // Kaç olumsuz puandan sonra incelemeye alınacak
  static const _autoDeleteDays = 10; // Kaç gün sonra otomatik silinecek
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 📊 SORU PUANLAMA
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Soruyu puanla (thumbs up/down)
  static Future<void> rateQuestion({
    required String questionId,
    required String odenciId,
    required bool isPositive,
    String? reason, // Olumsuz ise sebep
  }) async {
    try {
      final ratingRef = _db.collection('question_ratings').doc(questionId);
      final doc = await ratingRef.get();
      
      Map<String, dynamic> data = doc.exists ? doc.data()! : {
        'questionId': questionId,
        'positiveCount': 0,
        'negativeCount': 0,
        'negativeReasons': [],
        'ratedBy': [],
        'status': 'active', // active, flagged, approved, deleted
        'flaggedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      // Daha önce puanladı mı kontrol et
      List<dynamic> ratedBy = data['ratedBy'] ?? [];
      if (ratedBy.contains(odenciId)) {
        debugPrint('⚠️ Bu soru zaten puanlandı');
        return;
      }
      
      // Puanı ekle
      ratedBy.add(odenciId);
      data['ratedBy'] = ratedBy;
      
      if (isPositive) {
        data['positiveCount'] = (data['positiveCount'] ?? 0) + 1;
      } else {
        data['negativeCount'] = (data['negativeCount'] ?? 0) + 1;
        if (reason != null && reason.isNotEmpty) {
          List<dynamic> reasons = data['negativeReasons'] ?? [];
          reasons.add({
            'userId': odenciId,
            'reason': reason,
            'timestamp': DateTime.now().toIso8601String(),
          });
          data['negativeReasons'] = reasons;
        }
        
        // Eşik aşıldı mı kontrol et
        if ((data['negativeCount'] ?? 0) >= _reviewThreshold && data['status'] == 'active') {
          data['status'] = 'flagged';
          data['flaggedAt'] = FieldValue.serverTimestamp();
          debugPrint('🚩 Soru inceleme kuyruğuna alındı: $questionId');
        }
      }
      
      await ratingRef.set(data);
      debugPrint('✅ Soru puanlandı: $questionId (${isPositive ? "👍" : "👎"})');
      
    } catch (e) {
      debugPrint('❌ Puanlama hatası: $e');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 📋 İNCELEME KUYRUĞU
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// İnceleme bekleyen soruları getir
  static Future<List<FlaggedQuestion>> getFlaggedQuestions() async {
    try {
      final snapshot = await _db
          .collection('question_ratings')
          .where('status', isEqualTo: 'flagged')
          .orderBy('flaggedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => FlaggedQuestion.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ Kuyruk getirme hatası: $e');
      return [];
    }
  }
  
  /// İnceleme bekleyen soru sayısı
  static Future<int> getFlaggedCount() async {
    try {
      final snapshot = await _db
          .collection('question_ratings')
          .where('status', isEqualTo: 'flagged')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('❌ Sayı getirme hatası: $e');
      return 0;
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 🔧 ADMİN İŞLEMLERİ
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Soruyu onayla (bayrağı kaldır)
  static Future<void> approveQuestion(String questionId) async {
    try {
      await _db.collection('question_ratings').doc(questionId).update({
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewAction': 'approved',
      });
      debugPrint('✅ Soru onaylandı: $questionId');
    } catch (e) {
      debugPrint('❌ Onaylama hatası: $e');
    }
  }
  
  /// Soruyu sil
  static Future<void> deleteQuestion(String questionId) async {
    try {
      // Puanlama kaydını güncelle
      await _db.collection('question_ratings').doc(questionId).update({
        'status': 'deleted',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewAction': 'deleted',
      });
      
      // Asıl soruyu sil (eğer ayrı koleksiyondaysa)
      // await _db.collection('questions').doc(questionId).delete();
      
      debugPrint('🗑️ Soru silindi: $questionId');
    } catch (e) {
      debugPrint('❌ Silme hatası: $e');
    }
  }
  
  /// Puanları sıfırla (ikinci şans ver)
  static Future<void> resetRatings(String questionId) async {
    try {
      await _db.collection('question_ratings').doc(questionId).update({
        'positiveCount': 0,
        'negativeCount': 0,
        'negativeReasons': [],
        'ratedBy': [],
        'status': 'active',
        'flaggedAt': null,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewAction': 'reset',
      });
      debugPrint('🔄 Puanlar sıfırlandı: $questionId');
    } catch (e) {
      debugPrint('❌ Sıfırlama hatası: $e');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // ⏰ OTOMATİK TEMİZLİK (10 gün sonra sil)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Süresi dolan soruları otomatik sil
  static Future<int> autoDeleteExpiredQuestions() async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: _autoDeleteDays));
      
      final snapshot = await _db
          .collection('question_ratings')
          .where('status', isEqualTo: 'flagged')
          .where('flaggedAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();
      
      int deletedCount = 0;
      for (var doc in snapshot.docs) {
        await deleteQuestion(doc.id);
        deletedCount++;
      }
      
      if (deletedCount > 0) {
        debugPrint('🤖 Otomatik silindi: $deletedCount soru');
      }
      
      return deletedCount;
    } catch (e) {
      debugPrint('❌ Otomatik silme hatası: $e');
      return 0;
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 📈 İSTATİSTİKLER
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Moderasyon istatistikleri
  static Future<ModerationStats> getStats() async {
    try {
      final activeCount = await _db
          .collection('question_ratings')
          .where('status', isEqualTo: 'active')
          .count()
          .get();
      
      final flaggedCount = await _db
          .collection('question_ratings')
          .where('status', isEqualTo: 'flagged')
          .count()
          .get();
      
      final approvedCount = await _db
          .collection('question_ratings')
          .where('status', isEqualTo: 'approved')
          .count()
          .get();
      
      final deletedCount = await _db
          .collection('question_ratings')
          .where('status', isEqualTo: 'deleted')
          .count()
          .get();
      
      return ModerationStats(
        activeQuestions: activeCount.count ?? 0,
        flaggedQuestions: flaggedCount.count ?? 0,
        approvedQuestions: approvedCount.count ?? 0,
        deletedQuestions: deletedCount.count ?? 0,
      );
    } catch (e) {
      debugPrint('❌ İstatistik hatası: $e');
      return ModerationStats.empty();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 VERİ MODELLERİ
// ═══════════════════════════════════════════════════════════════════════════

class FlaggedQuestion {
  final String questionId;
  final int positiveCount;
  final int negativeCount;
  final List<NegativeReason> negativeReasons;
  final DateTime? flaggedAt;
  final String status;
  
  FlaggedQuestion({
    required this.questionId,
    required this.positiveCount,
    required this.negativeCount,
    required this.negativeReasons,
    this.flaggedAt,
    required this.status,
  });
  
  factory FlaggedQuestion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    List<NegativeReason> reasons = [];
    if (data['negativeReasons'] != null) {
      for (var r in data['negativeReasons']) {
        reasons.add(NegativeReason(
          userId: r['userId'] ?? '',
          reason: r['reason'] ?? '',
          timestamp: DateTime.tryParse(r['timestamp'] ?? '') ?? DateTime.now(),
        ));
      }
    }
    
    return FlaggedQuestion(
      questionId: doc.id,
      positiveCount: data['positiveCount'] ?? 0,
      negativeCount: data['negativeCount'] ?? 0,
      negativeReasons: reasons,
      flaggedAt: (data['flaggedAt'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'flagged',
    );
  }
  
  /// Kalan gün (otomatik silmeye kadar)
  int get remainingDays {
    if (flaggedAt == null) return 10;
    final expiryDate = flaggedAt!.add(const Duration(days: 10));
    return expiryDate.difference(DateTime.now()).inDays;
  }
  
  /// Acil mi? (2 günden az kaldıysa)
  bool get isUrgent => remainingDays <= 2;
}

class NegativeReason {
  final String userId;
  final String reason;
  final DateTime timestamp;
  
  NegativeReason({
    required this.userId,
    required this.reason,
    required this.timestamp,
  });
}

class ModerationStats {
  final int activeQuestions;
  final int flaggedQuestions;
  final int approvedQuestions;
  final int deletedQuestions;
  
  ModerationStats({
    required this.activeQuestions,
    required this.flaggedQuestions,
    required this.approvedQuestions,
    required this.deletedQuestions,
  });
  
  factory ModerationStats.empty() => ModerationStats(
    activeQuestions: 0,
    flaggedQuestions: 0,
    approvedQuestions: 0,
    deletedQuestions: 0,
  );
  
  int get totalQuestions => activeQuestions + flaggedQuestions + approvedQuestions + deletedQuestions;
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 PUANLAMA WİDGET'I (Soru çözüm ekranında kullanılacak)
// ═══════════════════════════════════════════════════════════════════════════

class QuestionRatingWidget extends StatefulWidget {
  final String questionId;
  final String odenciId;
  
  const QuestionRatingWidget({
    super.key,
    required this.questionId,
    required this.odenciId,
  });
  
  @override
  State<QuestionRatingWidget> createState() => _QuestionRatingWidgetState();
}

class _QuestionRatingWidgetState extends State<QuestionRatingWidget> {
  bool? _rating; // null: puanlanmadı, true: olumlu, false: olumsuz
  bool _isSubmitting = false;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Bu soru nasıldı?", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 12),
          
          // Beğen
          IconButton(
            icon: Icon(
              _rating == true ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: _rating == true ? Colors.green : Colors.grey,
            ),
            onPressed: _isSubmitting ? null : () => _submitRating(true),
          ),
          
          // Beğenme
          IconButton(
            icon: Icon(
              _rating == false ? Icons.thumb_down : Icons.thumb_down_outlined,
              color: _rating == false ? Colors.red : Colors.grey,
            ),
            onPressed: _isSubmitting ? null : () => _showReportDialog(),
          ),
        ],
      ),
    );
  }
  
  void _submitRating(bool isPositive, [String? reason]) async {
    setState(() => _isSubmitting = true);
    
    await QuestionModerationService.rateQuestion(
      questionId: widget.questionId,
      odenciId: widget.odenciId,
      isPositive: isPositive,
      reason: reason,
    );
    
    setState(() {
      _rating = isPositive;
      _isSubmitting = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isPositive ? "Teşekkürler! 👍" : "Geri bildiriminiz için teşekkürler"),
          backgroundColor: isPositive ? Colors.green : Colors.orange,
        ),
      );
    }
  }
  
  void _showReportDialog() {
    String selectedReason = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sorun neydi?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReasonButton("Yanlış cevap", selectedReason, (r) => selectedReason = r),
            _buildReasonButton("Anlaşılmaz soru", selectedReason, (r) => selectedReason = r),
            _buildReasonButton("Yazım hatası", selectedReason, (r) => selectedReason = r),
            _buildReasonButton("Konu dışı", selectedReason, (r) => selectedReason = r),
            _buildReasonButton("Diğer", selectedReason, (r) => selectedReason = r),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitRating(false, selectedReason);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Bildir"),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReasonButton(String reason, String current, Function(String) onSelect) {
    return ListTile(
      title: Text(reason),
      leading: Radio<String>(
        value: reason,
        groupValue: current,
        onChanged: (v) => onSelect(v ?? ''),
      ),
      onTap: () => onSelect(reason),
    );
  }
}
