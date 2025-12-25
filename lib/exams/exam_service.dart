import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'exam_model.dart';

/// 🔐 Deneme Sınavı Servis Katmanı
/// Güvenlik + Veri Erişim Yönetimi
class ExamService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // ═══════════════════════════════════════════════════════════════
  // 📋 SINAV LİSTELEME (GÜVENLİK FİLTRELİ)
  // ═══════════════════════════════════════════════════════════════
  
  /// Kullanıcıya göre sınavları getir (Güvenlik Duvarı)
  Stream<List<ExamModel>> getExamsForUser(String userRole, String? institutionId) {
    // Sadece aktif sınavları getir
    Query query = _db.collection('exams').where('is_active', isEqualTo: true);
    
    return query.snapshots().map((snapshot) {
      final allExams = snapshot.docs.map((doc) => ExamModel.fromFirestore(doc)).toList();
      
      // Güvenlik filtresi: Kullanıcının görebileceği sınavları filtrele
      return allExams.where((exam) => exam.isVisibleTo(userRole, institutionId)).toList();
    });
  }
  
  /// Public sınav var mı? (Bireysel kullanıcılar için kontrol)
  Future<bool> hasPublicExams() async {
    try {
      final snapshot = await _db
          .collection('exams')
          .where('visibility', isEqualTo: 'public')
          .where('is_active', isEqualTo: true)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Public sınav kontrolü hatası: $e');
      return false;
    }
  }
  
  /// Kuruma özel sınav var mı?
  Future<bool> hasInstitutionExams(String institutionId) async {
    try {
      final snapshot = await _db
          .collection('exams')
          .where('target_institution_id', isEqualTo: institutionId)
          .where('is_active', isEqualTo: true)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Kurum sınav kontrolü hatası: $e');
      return false;
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // 📤 SINAV YÜKLEME (ADMİN)
  // ═══════════════════════════════════════════════════════════════
  
  /// Yeni sınav yükle
  Future<String?> uploadExam({
    required String title,
    required String visibility,
    String? targetInstitutionId,
    String? pdfUrl,
    required DateTime date,
  }) async {
    try {
      final docRef = await _db.collection('exams').add({
        'title': title,
        'visibility': visibility,
        'target_institution_id': visibility == 'private' ? targetInstitutionId : null,
        'pdf_url': pdfUrl,
        'date': Timestamp.fromDate(date),
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ Sınav yüklendi: $title (ID: ${docRef.id})');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Sınav yükleme hatası: $e');
      return null;
    }
  }
  
  /// Sınavı güncelle
  Future<bool> updateExam(String examId, Map<String, dynamic> updates) async {
    try {
      await _db.collection('exams').doc(examId).update(updates);
      debugPrint('✅ Sınav güncellendi: $examId');
      return true;
    } catch (e) {
      debugPrint('❌ Sınav güncelleme hatası: $e');
      return false;
    }
  }
  
  /// Sınavı pasife al (silme yerine)
  Future<bool> deactivateExam(String examId) async {
    return updateExam(examId, {'is_active': false});
  }
  
  // ═══════════════════════════════════════════════════════════════
  // 🏢 KURUM YÖNETİMİ
  // ═══════════════════════════════════════════════════════════════
  
  /// Tüm kurumları getir (Admin için dropdown)
  Future<List<Map<String, String>>> getInstitutions() async {
    try {
      final snapshot = await _db.collection('kurumlar').get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': (data['ad'] ?? data['name'] ?? 'İsimsiz Kurum') as String,
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ Kurum listesi hatası: $e');
      // Demo veriler dön
      return [
        {'id': 'kurum1', 'name': 'Demo Dershane'},
        {'id': 'kurum2', 'name': 'Örnek Lise'},
      ];
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // 📊 İSTATİSTİK
  // ═══════════════════════════════════════════════════════════════
  
  /// Toplam aktif sınav sayısı
  Future<int> getActiveExamCount() async {
    try {
      final snapshot = await _db
          .collection('exams')
          .where('is_active', isEqualTo: true)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
